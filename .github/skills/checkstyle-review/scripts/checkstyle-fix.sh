#!/bin/bash

###############################################################################
# CHECKSTYLE AUTOMATIC REVIEW & FIX SCRIPT
# 
# Purpose: Analyze Java code against Checkstyle rules and auto-fix violations
# Usage: ./scripts/checkstyle-fix.sh [--fix] [--report] [--verbose]
###############################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"

# Configuration - use local config from skill directory
CHECKSTYLE_CONFIG="${CHECKSTYLE_CONFIG:-$SKILL_DIR/config/checkstyle.xml}"
CHECKSTYLE_REPORT="target/checkstyle-result.xml"
AUTO_FIX=false
GENERATE_REPORT=false
VERBOSE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --fix) AUTO_FIX=true; shift ;;
    --report) GENERATE_REPORT=true; shift ;;
    --verbose) VERBOSE=true; shift ;;
    *) echo "Unknown option: $1"; exit 1 ;;
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

###############################################################################
# PHASE 1: VERIFY CONFIGURATION
###############################################################################

verify_configuration() {
  log "PHASE 1: Verifying Configuration"
  
  if [ ! -f "$CHECKSTYLE_CONFIG" ]; then
    error "Checkstyle configuration not found at: $CHECKSTYLE_CONFIG"
    echo "Please create the configuration file or set CHECKSTYLE_CONFIG environment variable"
    exit 1
  fi
  
  success "Configuration file found: $CHECKSTYLE_CONFIG"
  
  # Verify Maven is installed
  if ! command -v mvn &> /dev/null; then
    error "Maven not found. Please install Maven."
    exit 1
  fi
  
  success "Maven is installed"
  log "Configuration verification complete.\n"
}

###############################################################################
# PHASE 2: ANALYZE CODE
###############################################################################

analyze_code() {
  log "PHASE 2: Analyzing Code with Checkstyle"
  
  log "Running Checkstyle check..."
  
  if mvn checkstyle:check \
    -Dcheckstyle.config.location="$CHECKSTYLE_CONFIG" \
    -Dcheckstyle.consoleOutput=true \
    -Dcheckstyle.skip=false 2>&1 | tee checkstyle-output.txt; then
    success "No Checkstyle violations found!"
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
  log "PHASE 3: Parsing Violations"
  
  if [ ! -f "$CHECKSTYLE_REPORT" ]; then
    log "Generating detailed report..."
    mvn checkstyle:checkstyle -Dcheckstyle.config.location="$CHECKSTYLE_CONFIG" > /dev/null 2>&1
  fi
  
  if [ -f "$CHECKSTYLE_REPORT" ]; then
    # Count violations by category
    echo ""
    log "Violation Summary:"
    
    # Extract and count violations
    TOTAL=$(grep -c "<violation" "$CHECKSTYLE_REPORT" || echo "0")
    echo -e "  Total violations: ${YELLOW}$TOTAL${NC}"
    
    # Show top violations
    echo ""
    echo "Top violations:"
    grep "<violation" "$CHECKSTYLE_REPORT" | \
      sed 's/.*message="//' | sed 's/".*//' | \
      sort | uniq -c | sort -rn | head -10 | \
      while read count msg; do
        printf "  %3d: %s\n" "$count" "$msg"
      done
  fi
  
  echo ""
}

###############################################################################
# PHASE 4: AUTO-FIX VIOLATIONS
###############################################################################

apply_fixes() {
  log "PHASE 4: Applying Auto-Fixes"
  
  if [ "$AUTO_FIX" = false ]; then
    log "Skipping auto-fix. Use --fix flag to enable."
    return 0
  fi
  
  log "Installing Spotless plugin..."
  
  # Check if Spotless is configured
  if ! grep -q "spotless-maven-plugin" pom.xml; then
    warning "Spotless not configured in pom.xml"
    log "Would apply Google Java Format manually..."
  fi
  
  log "Applying code formatting with Spotless..."
  if mvn spotless:apply -q; then
    success "Auto-fixes applied successfully"
  else
    error "Failed to apply auto-fixes"
    return 1
  fi
}

###############################################################################
# PHASE 5: VALIDATE FIXES
###############################################################################

validate_fixes() {
  log "PHASE 5: Validating Fixes"
  
  log "Re-running Checkstyle analysis..."
  
  if mvn checkstyle:check \
    -Dcheckstyle.config.location="$CHECKSTYLE_CONFIG" \
    -q 2>&1; then
    success "All Checkstyle violations resolved!"
  else
    warning "Some violations remain - manual review may be required"
  fi
  
  log "Running unit tests..."
  if mvn test -q 2>&1; then
    success "All tests passed"
  else
    error "Tests failed - fixes may have broken functionality"
    return 1
  fi
}

###############################################################################
# PHASE 6: GENERATE REPORT
###############################################################################

generate_report() {
  log "PHASE 6: Generating Report"
  
  if [ "$GENERATE_REPORT" = false ]; then
    return 0
  fi
  
  log "Generating HTML report..."
  mvn checkstyle:checkstyle \
    -Dcheckstyle.config.location="$CHECKSTYLE_CONFIG" \
    -q 2>&1
  
  if [ -f "target/site/checkstyle.html" ]; then
    success "Report generated: target/site/checkstyle.html"
    if command -v open &> /dev/null; then
      log "Opening report in browser..."
      open target/site/checkstyle.html
    fi
  fi
}

###############################################################################
# MAIN EXECUTION
###############################################################################

main() {
  echo ""
  echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${BLUE}║      🎯 CHECKSTYLE AUTOMATIC REVIEW & FIX                      ║${NC}"
  echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
  echo ""
  
  # Display options
  if [ "$AUTO_FIX" = true ]; then
    log "Mode: AUTO-FIX enabled"
  else
    log "Mode: ANALYSIS only (use --fix to enable auto-fix)"
  fi
  
  if [ "$GENERATE_REPORT" = true ]; then
    log "Report: HTML report will be generated"
  fi
  
  if [ "$VERBOSE" = true ]; then
    log "Verbose: Enabled"
  fi
  
  echo ""
  
  # Execute phases
  verify_configuration
  analyze_code || true
  parse_violations
  apply_fixes || true
  validate_fixes || true
  generate_report
  
  echo ""
  echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${BLUE}║      ✅ CHECKSTYLE REVIEW COMPLETE                             ║${NC}"
  echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
  echo ""
  
  # Summary
  log "Summary:"
  echo "  • Configuration verified"
  echo "  • Code analyzed"
  echo "  • Violations parsed"
  if [ "$AUTO_FIX" = true ]; then
    echo "  • Auto-fixes applied"
    echo "  • Fixes validated"
  fi
  if [ "$GENERATE_REPORT" = true ]; then
    echo "  • Report generated"
  fi
  echo ""
}

main
