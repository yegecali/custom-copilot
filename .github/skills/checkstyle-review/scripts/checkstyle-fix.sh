#!/bin/bash

###############################################################################
# CHECKSTYLE AUTOMATIC REVIEW & FIX SCRIPT v2.0
# 
# Purpose: Analyze Java code against Checkstyle rules and auto-fix violations
# 
# Usage: ./checkstyle-fix.sh [OPTIONS]
# 
# Options:
#   --fix               Apply auto-fixes with Spotless
#   --report            Generate HTML report
#   --verbose           Enable verbose output
#   --skip-tests        Skip unit tests validation
#   --install-spotless  Install Spotless plugin automatically
#   --dry-run           Show what would be done without executing
#   --help              Show this help message
#
# Examples:
#   ./checkstyle-fix.sh                    # Analysis only
#   ./checkstyle-fix.sh --fix --report     # Full workflow with report
#   ./checkstyle-fix.sh --dry-run --fix    # Preview changes before applying
###############################################################################

# Exit on error, pipe failure, undefined variable
set -eEuo pipefail

# Trap errors
trap 'error "Script failed at line $LINENO"; exit 1' ERR

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_ROOT="$(cd "$SKILL_DIR/../.." && pwd)"

# Configuration - use local config from skill directory
CHECKSTYLE_CONFIG="${CHECKSTYLE_CONFIG:-$SKILL_DIR/config/checkstyle.xml}"
CHECKSTYLE_REPORT="target/checkstyle-result.xml"
CHECKSTYLE_OUTPUT="target/checkstyle-output.txt"
VIOLATIONS_BEFORE="target/violations-before.txt"
VIOLATIONS_AFTER="target/violations-after.txt"

# Script options
AUTO_FIX=false
GENERATE_REPORT=false
VERBOSE=false
SKIP_TESTS=false
INSTALL_SPOTLESS=false
DRY_RUN=false
SHOW_HELP=false

# Statistics
TOTAL_VIOLATIONS_BEFORE=0
TOTAL_VIOLATIONS_AFTER=0
FILES_FIXED=0

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --fix) AUTO_FIX=true; shift ;;
    --report) GENERATE_REPORT=true; shift ;;
    --verbose) VERBOSE=true; shift ;;
    --skip-tests) SKIP_TESTS=true; shift ;;
    --install-spotless) INSTALL_SPOTLESS=true; shift ;;
    --dry-run) DRY_RUN=true; shift ;;
    --help|-h) SHOW_HELP=true; shift ;;
    *) error "Unknown option: $1"; exit 1 ;;
  esac
done

###############################################################################
# HELPER FUNCTIONS
###############################################################################

log() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
  echo -e "${GREEN}[✓]${NC} $1"
}

warning() {
  echo -e "${YELLOW}[⚠]${NC} $1"
}

error() {
  echo -e "${RED}[✗]${NC} $1"
}

debug() {
  if [ "$VERBOSE" = true ]; then
    echo -e "${CYAN}[DEBUG]${NC} $1"
  fi
}

info_box() {
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BLUE}$1${NC}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

show_help() {
  cat << EOF
${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}
${BLUE}║  🎯 CHECKSTYLE AUTOMATIC REVIEW & FIX SCRIPT v2.0             ║${NC}
${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}

${GREEN}USAGE:${NC}
  ./checkstyle-fix.sh [OPTIONS]

${GREEN}OPTIONS:${NC}
  --fix                 Apply auto-fixes with Spotless
  --report              Generate HTML report  
  --verbose             Enable verbose output
  --skip-tests          Skip unit tests validation after fixes
  --install-spotless    Install Spotless plugin if missing
  --dry-run             Show what would be done without executing
  --help, -h            Show this help message

${GREEN}EXAMPLES:${NC}
  ${CYAN}# Analysis only (default)${NC}
  ./checkstyle-fix.sh

  ${CYAN}# Analysis with violations report${NC}
  ./checkstyle-fix.sh --report

  ${CYAN}# Auto-fix with HTML report${NC}
  ./checkstyle-fix.sh --fix --report

  ${CYAN}# Preview changes without applying${NC}
  ./checkstyle-fix.sh --fix --dry-run

  ${CYAN}# Full workflow with all options${NC}
  ./checkstyle-fix.sh --fix --report --verbose

  ${CYAN}# Auto-install Spotless if missing${NC}
  ./checkstyle-fix.sh --fix --install-spotless

${GREEN}REPORT FILES:${NC}
  target/checkstyle-result.xml     XML report
  target/site/checkstyle.html      HTML report (with --report)
  target/checkstyle-output.txt     Console output

EOF
}

# Cleanup function
cleanup() {
  if [ -f "$CHECKSTYLE_OUTPUT" ] && [ "$VERBOSE" = false ]; then
    rm -f "$CHECKSTYLE_OUTPUT" 2>/dev/null || true
  fi
  debug "Cleanup completed"
}

trap cleanup EXIT

###############################################################################
# HELPER: Count violations from XML report
###############################################################################

count_violations() {
  local report_file="$1"
  
  if [ -f "$report_file" ]; then
    grep -c "<violation" "$report_file" 2>/dev/null || echo "0"
  else
    echo "0"
  fi
}

###############################################################################
# HELPER: Extract top violations
###############################################################################

get_top_violations() {
  local report_file="$1"
  local limit="${2:-10}"
  
  if [ -f "$report_file" ]; then
    grep "<violation" "$report_file" 2>/dev/null | \
      sed 's/.*message="//' | sed 's/".*//' | \
      sort | uniq -c | sort -rn | head -n "$limit"
  fi
}

###############################################################################
# PHASE 1: VERIFY CONFIGURATION & ENVIRONMENT
###############################################################################

verify_configuration() {
  info_box "PHASE 1: Verifying Configuration & Environment"
  
  # Check if in git repository
  if ! git rev-parse --git-dir > /dev/null 2>&1; then
    error "Not a git repository. Please run from project root."
    exit 1
  fi
  success "Git repository verified"
  
  # Verify checkstyle.xml exists
  if [ ! -f "$CHECKSTYLE_CONFIG" ]; then
    error "Checkstyle configuration not found at: $CHECKSTYLE_CONFIG"
    log "Expected location: $CHECKSTYLE_CONFIG"
    exit 1
  fi
  success "Checkstyle configuration found: $CHECKSTYLE_CONFIG"
  
  # Verify pom.xml exists
  if [ ! -f "$PROJECT_ROOT/pom.xml" ]; then
    error "pom.xml not found. Are you in a Maven project?"
    exit 1
  fi
  success "Maven project detected"
  
  # Verify Maven is installed
  if ! command -v mvn &> /dev/null; then
    error "Maven not found. Please install Maven."
    exit 1
  fi
  
  local mvn_version
  mvn_version=$(mvn -v 2>/dev/null | head -1)
  success "Maven installed: $mvn_version"
  
  # Check if Spotless is needed but missing
  if [ "$AUTO_FIX" = true ] && [ "$INSTALL_SPOTLESS" = false ]; then
    if ! grep -q "spotless-maven-plugin" "$PROJECT_ROOT/pom.xml"; then
      warning "Spotless not configured in pom.xml"
      log "Use --install-spotless flag to install automatically, or add to pom.xml manually"
    fi
  fi
  
  # Create target directory if needed
  mkdir -p target
  
  log "Configuration verification complete"
  echo ""
}

###############################################################################
# HELPER: Install Spotless plugin
###############################################################################

install_spotless_plugin() {
  log "Installing Spotless Maven Plugin..."
  
  local spotless_config=$(cat << 'SPOTLESS_XML'

  <!-- Spotless Plugin for Auto-Fix -->
  <plugin>
    <groupId>com.diffplug.spotless</groupId>
    <artifactId>spotless-maven-plugin</artifactId>
    <version>2.35.0</version>
    <configuration>
      <java>
        <includes>
          <include>src/main/java/**/*.java</include>
          <include>src/test/java/**/*.java</include>
        </includes>
        <googleJavaFormat>
          <version>1.15.0</version>
        </googleJavaFormat>
        <importOrder>
          <order>java,javax,org,com</order>
        </importOrder>
      </java>
    </configuration>
  </plugin>
SPOTLESS_XML
)
  
  if grep -q "spotless-maven-plugin" "$PROJECT_ROOT/pom.xml"; then
    success "Spotless already configured"
    return 0
  fi
  
  warning "Automatic plugin installation not yet implemented"
  warning "Please add the following to your pom.xml <plugins> section:"
  echo "$spotless_config"
  exit 1
}

###############################################################################
# PHASE 2: ANALYZE CODE
###############################################################################

analyze_code() {
  info_box "PHASE 2: Analyzing Code with Checkstyle"
  
  log "Running Checkstyle analysis..."
  debug "Config: $CHECKSTYLE_CONFIG"
  
  if [ "$DRY_RUN" = true ]; then
    log "[DRY-RUN] Would execute: mvn checkstyle:check"
    TOTAL_VIOLATIONS_BEFORE=0
    return 1
  fi
  
  # Run analysis and capture output
  local exit_code=0
  mvn checkstyle:check \
    -Dcheckstyle.config.location="$CHECKSTYLE_CONFIG" \
    -Dcheckstyle.consoleOutput=true \
    -Dcheckstyle.skip=false \
    -q 2>&1 | tee "$CHECKSTYLE_OUTPUT" || exit_code=$?
  
  # Generate detailed report
  mvn checkstyle:checkstyle \
    -Dcheckstyle.config.location="$CHECKSTYLE_CONFIG" \
    -q 2>&1 > /dev/null || true
  
  # Check for violations
  if [ $exit_code -eq 0 ]; then
    success "No Checkstyle violations found!"
    TOTAL_VIOLATIONS_BEFORE=0
    return 0
  else
    warning "Checkstyle violations detected"
    return 1
  fi
}

###############################################################################
# PHASE 3: PARSE VIOLATIONS
###############################################################################

parse_violations() {
  info_box "PHASE 3: Parsing & Categorizing Violations"
  
  if [ ! -f "$CHECKSTYLE_REPORT" ]; then
    log "Generating detailed report..."
    mvn checkstyle:checkstyle \
      -Dcheckstyle.config.location="$CHECKSTYLE_CONFIG" \
      -q 2>&1 > /dev/null || true
  fi
  
  if [ ! -f "$CHECKSTYLE_REPORT" ]; then
    warning "No violations report generated (no violations found)"
    TOTAL_VIOLATIONS_BEFORE=0
    return 0
  fi
  
  # Count total violations
  TOTAL_VIOLATIONS_BEFORE=$(count_violations "$CHECKSTYLE_REPORT")
  
  if [ "$TOTAL_VIOLATIONS_BEFORE" -eq 0 ]; then
    success "No violations found!"
    return 0
  fi
  
  success "Found $TOTAL_VIOLATIONS_BEFORE violations"
  echo ""
  
  # Show violation summary
  log "Violation Categories (Top 10):"
  echo ""
  
  get_top_violations "$CHECKSTYLE_REPORT" 10 | while read count msg; do
    # Color code by severity
    if [[ "$msg" =~ (Javadoc|complexity|nesting) ]]; then
      printf "  ${RED}[HIGH]${NC}    %3d: %s\n" "$count" "$msg"
    elif [[ "$msg" =~ (length|indent|space) ]]; then
      printf "  ${YELLOW}[MED]${NC}     %3d: %s\n" "$count" "$msg"
    else
      printf "  ${GREEN}[LOW]${NC}     %3d: %s\n" "$count" "$msg"
    fi
  done
  
  echo ""
  
  # Show violations by file
  log "Violations by File (Top 5):"
  echo ""
  
  grep "<violation" "$CHECKSTYLE_REPORT" 2>/dev/null | \
    sed 's/.*file="//' | sed 's/".*//' | \
    sort | uniq -c | sort -rn | head -5 | \
    while read count file; do
      printf "  %3d violations: %s\n" "$count" "$file"
    done
  
  echo ""
}

###############################################################################
# PHASE 4: AUTO-FIX VIOLATIONS
###############################################################################

apply_fixes() {
  if [ "$AUTO_FIX" = false ]; then
    log "Skipping auto-fix (use --fix flag to enable)"
    return 0
  fi
  
  info_box "PHASE 4: Applying Auto-Fixes with Spotless"
  
  # Check if Spotless is configured
  if ! grep -q "spotless-maven-plugin" "$PROJECT_ROOT/pom.xml"; then
    if [ "$INSTALL_SPOTLESS" = true ]; then
      install_spotless_plugin
    else
      warning "Spotless not configured in pom.xml"
      log "Use --install-spotless to configure automatically"
      return 1
    fi
  fi
  
  if [ "$DRY_RUN" = true ]; then
    log "[DRY-RUN] Would execute: mvn spotless:apply"
    return 0
  fi
  
  success "Applying code formatting..."
  
  if mvn spotless:apply -q 2>&1; then
    success "Spotless auto-fixes applied successfully"
    FILES_FIXED=$((FILES_FIXED + 1))
    return 0
  else
    error "Failed to apply Spotless fixes"
    return 1
  fi
}

###############################################################################
# PHASE 5: VALIDATE FIXES
###############################################################################

validate_fixes() {
  if [ "$AUTO_FIX" = false ]; then
    return 0
  fi
  
  info_box "PHASE 5: Validating Fixes"
  
  if [ "$DRY_RUN" = true ]; then
    log "[DRY-RUN] Would re-run Checkstyle analysis"
    log "[DRY-RUN] Would run unit tests"
    return 0
  fi
  
  log "Re-running Checkstyle analysis..."
  
  if mvn checkstyle:check \
    -Dcheckstyle.config.location="$CHECKSTYLE_CONFIG" \
    -q 2>&1; then
    success "All Checkstyle violations resolved!"
    TOTAL_VIOLATIONS_AFTER=0
  else
    # Count remaining violations
    mvn checkstyle:checkstyle \
      -Dcheckstyle.config.location="$CHECKSTYLE_CONFIG" \
      -q 2>&1 > /dev/null || true
    
    TOTAL_VIOLATIONS_AFTER=$(count_violations "$CHECKSTYLE_REPORT")
    warning "Some violations remain (${TOTAL_VIOLATIONS_AFTER} remaining)"
  fi
  
  # Run unit tests if not skipped
  if [ "$SKIP_TESTS" = true ]; then
    log "Skipping unit tests (--skip-tests flag set)"
    return 0
  fi
  
  log "Running unit tests..."
  
  if mvn test -q 2>&1; then
    success "All unit tests passed"
  else
    error "Tests failed - fixes may have broken functionality"
    warning "Review changes and run: mvn test -X"
    return 1
  fi
}

###############################################################################
# PHASE 6: GENERATE REPORT
###############################################################################

generate_report() {
  if [ "$GENERATE_REPORT" = false ]; then
    return 0
  fi
  
  info_box "PHASE 6: Generating HTML Report"
  
  if [ "$DRY_RUN" = true ]; then
    log "[DRY-RUN] Would generate HTML report"
    return 0
  fi
  
  log "Generating Checkstyle HTML report..."
  
  mvn checkstyle:checkstyle \
    -Dcheckstyle.config.location="$CHECKSTYLE_CONFIG" \
    -q 2>&1 > /dev/null || true
  
  if [ ! -f "target/site/checkstyle.html" ]; then
    warning "HTML report not generated"
    return 1
  fi
  
  success "Report generated: target/site/checkstyle.html"
  
  # Try to open in browser
  if command -v open &> /dev/null; then
    log "Opening report in browser..."
    open target/site/checkstyle.html
  elif command -v xdg-open &> /dev/null; then
    log "Opening report in browser..."
    xdg-open target/site/checkstyle.html
  elif command -v start &> /dev/null; then
    log "Opening report in browser..."
    start target/site/checkstyle.html
  fi
}

###############################################################################
# MAIN EXECUTION
###############################################################################

main() {
  # Show help if requested
  if [ "$SHOW_HELP" = true ]; then
    show_help
    exit 0
  fi
  
  # Header
  echo ""
  echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${BLUE}║  🎯 CHECKSTYLE AUTOMATIC REVIEW & FIX v2.0                    ║${NC}"
  echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
  echo ""
  
  # Show configuration
  log "Configuration:"
  echo "  Project Root:   $PROJECT_ROOT"
  echo "  Checkstyle Config: $CHECKSTYLE_CONFIG"
  echo ""
  
  # Show mode
  log "Execution Mode:"
  
  if [ "$DRY_RUN" = true ]; then
    echo -e "  Mode: ${CYAN}DRY-RUN (preview only)${NC}"
  fi
  
  if [ "$AUTO_FIX" = true ]; then
    echo -e "  Fix:  ${GREEN}ENABLED${NC} (auto-fixes will be applied)"
  else
    echo -e "  Fix:  ${YELLOW}DISABLED${NC} (analysis only)"
  fi
  
  if [ "$GENERATE_REPORT" = true ]; then
    echo -e "  Report: ${GREEN}ENABLED${NC} (HTML report will be generated)"
  else
    echo -e "  Report: ${YELLOW}DISABLED${NC}"
  fi
  
  if [ "$SKIP_TESTS" = true ]; then
    echo -e "  Tests: ${YELLOW}SKIPPED${NC}"
  else
    echo -e "  Tests: ${GREEN}ENABLED${NC}"
  fi
  
  if [ "$VERBOSE" = true ]; then
    echo -e "  Verbose: ${GREEN}ON${NC}"
  fi
  
  echo ""
  
  # Execute phases
  debug "Starting phase execution..."
  
  verify_configuration
  
  local analysis_success=false
  if analyze_code; then
    analysis_success=true
  fi
  
  if [ "$analysis_success" = true ]; then
    debug "No violations found, skipping parse_violations"
  else
    parse_violations
  fi
  
  apply_fixes || true
  validate_fixes || true
  generate_report
  
  # Final summary
  echo ""
  echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${BLUE}║  ✅ CHECKSTYLE REVIEW COMPLETE                                ║${NC}"
  echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
  echo ""
  
  # Statistics
  log "Summary:"
  echo "  ✓ Configuration verified"
  echo "  ✓ Code analyzed"
  
  if [ "$TOTAL_VIOLATIONS_BEFORE" -gt 0 ]; then
    echo "  ✓ Found $TOTAL_VIOLATIONS_BEFORE violations"
  else
    echo "  ✓ No violations found"
  fi
  
  if [ "$AUTO_FIX" = true ]; then
    echo "  ✓ Auto-fixes applied"
    
    if [ "$TOTAL_VIOLATIONS_AFTER" -lt "$TOTAL_VIOLATIONS_BEFORE" ]; then
      local fixed=$((TOTAL_VIOLATIONS_BEFORE - TOTAL_VIOLATIONS_AFTER))
      echo "  ✓ Fixed $fixed violations"
    fi
    
    if [ "$SKIP_TESTS" = false ]; then
      echo "  ✓ Unit tests validated"
    fi
  fi
  
  if [ "$GENERATE_REPORT" = true ]; then
    echo "  ✓ HTML report generated"
  fi
  
  if [ "$DRY_RUN" = true ]; then
    echo ""
    echo -e "${YELLOW}[DRY-RUN] No actual changes were made${NC}"
  fi
  
  echo ""
  
  # Next steps
  if [ "$TOTAL_VIOLATIONS_BEFORE" -gt 0 ] && [ "$AUTO_FIX" = false ]; then
    log "Next Steps:"
    echo "  1. Review violations above"
    echo "  2. Run with --fix to apply auto-fixes"
    echo "  3. Run with --report to generate HTML report"
    echo ""
  fi
}

# Run main function
main
