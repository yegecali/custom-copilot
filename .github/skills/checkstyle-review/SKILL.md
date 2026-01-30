# 🎯 CHECKSTYLE REVIEW SKILL

**Domain:** Code Quality & Style Enforcement  
**Purpose:** Automatically analyze Java code against Checkstyle rules, detect violations, and apply auto-fixes  
**Scope:** Java source files in the project  

---

## � SKILL STRUCTURE

This skill is self-contained and includes all necessary files:

```
.github/skills/checkstyle-review/
├── SKILL.md                    # This documentation
├── README.md                   # Quick start guide
├── config/
│   └── checkstyle.xml         # Checkstyle configuration rules
└── scripts/
    └── checkstyle-fix.sh      # Automation script (6-phase workflow)
```

**Key Features:**
- ✅ Local configuration (no external dependencies)
- ✅ Automated 6-phase workflow
- ✅ Auto-fix with Spotless integration
- ✅ HTML report generation
- ✅ Unit test validation

---

## �📋 SKILL OVERVIEW

This skill provides **automated code style validation and correction** using Checkstyle with custom rules from XML configuration files.

### Capabilities

✅ **Configuration Management**
- Read custom checkstyle.xml rules
- Parse and understand configuration
- Support multiple rule sets

✅ **Code Analysis**
- Scan Java source files
- Detect style violations
- Classify by severity

✅ **Auto-Correction**
- Fix formatting issues automatically
- Apply style corrections
- Preserve code logic

✅ **Reporting**
- Detailed violation reports
- Grouped by category
- Before/after comparison

✅ **Validation**
- Verify fixes don't break code
- Run unit tests
- Ensure code integrity

---

## 🚀 EXECUTION WORKFLOW

### Phase 1-6: Automated Execution Script

This skill includes a complete automation script located at:
- 📝 Configuration: [`.github/skills/checkstyle-review/config/checkstyle.xml`](.github/skills/checkstyle-review/config/checkstyle.xml)
- 🔧 Script: [`.github/skills/checkstyle-review/scripts/checkstyle-fix.sh`](.github/skills/checkstyle-review/scripts/checkstyle-fix.sh)

**Quick Start:**

```bash
# Make script executable
chmod +x .github/skills/checkstyle-review/scripts/checkstyle-fix.sh

# Run analysis only
./.github/skills/checkstyle-review/scripts/checkstyle-fix.sh

# Run with auto-fix
./.github/skills/checkstyle-review/scripts/checkstyle-fix.sh --fix

# Run with report generation
./.github/skills/checkstyle-review/scripts/checkstyle-fix.sh --fix --report

# Run verbose mode
./.github/skills/checkstyle-review/scripts/checkstyle-fix.sh --fix --report --verbose
```

**What the script does:**

1. **Phase 1: Verify Configuration** - Loads checkstyle.xml from skill directory
2. **Phase 2: Analyze Code** - Runs `mvn checkstyle:check` 
3. **Phase 3: Parse Violations** - Categorizes and counts issues
4. **Phase 4: Apply Fixes** - Runs `mvn spotless:apply` (if --fix enabled)
5. **Phase 5: Validate Fixes** - Re-runs analysis and tests
6. **Phase 6: Generate Report** - Creates HTML report (if --report enabled)

---

## 📂 CHECKSTYLE CONFIGURATION STRUCTURE

### Skill's checkstyle.xml File

The configuration is located at: `.github/skills/checkstyle-review/config/checkstyle.xml`

**Standard checkstyle.xml Layout**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE module PUBLIC "-//Puppy Crawl//DTD Check Configuration 1.3//EN"
  "https://checkstyle.org/dtds/configuration_1_3.dtd">

<module name="Checker">
  <!-- File length checks -->
  <module name="FileLength">
    <property name="max" value="2000"/>
  </module>

  <!-- Line length -->
  <module name="LineLength">
    <property name="max" value="120"/>
    <property name="ignorePattern" value="^package.*|^import.*|a href|href|http://|https://"/>
  </module>

  <!-- Tree walker: checks on individual files -->
  <module name="TreeWalker">
    
    <!-- Naming conventions -->
    <module name="TypeName">
      <property name="format" value="^[A-Z][a-zA-Z0-9]*$"/>
    </module>
    
    <module name="MethodName">
      <property name="format" value="^[a-z][a-zA-Z0-9]*$"/>
    </module>
    
    <module name="ConstantName">
      <property name="format" value="^[A-Z][A-Z0-9]*(_[A-Z0-9]+)*$"/>
    </module>

    <!-- Whitespace -->
    <module name="WhitespaceAround"/>
    <module name="WhitespaceAfterComma"/>
    <module name="NoWhitespaceAfter"/>
    <module name="NoWhitespaceBefore"/>

    <!-- Indentation -->
    <module name="Indentation">
      <property name="basicOffset" value="4"/>
      <property name="braceAdjustment" value="0"/>
    </module>

    <!-- Imports -->
    <module name="AvoidStarImport"/>
    <module name="UnusedImports"/>
    <module name="ImportOrder">
      <property name="groups" value="/^java\./,/^javax\./,/^org\./,/^com\./"/>
    </module>

    <!-- Braces -->
    <module name="LeftCurly"/>
    <module name="RightCurly"/>
    <module name="NeedBraces"/>

    <!-- Javadoc -->
    <module name="JavadocMethod">
      <property name="scope" value="public"/>
    </module>

    <!-- Complexity -->
    <module name="CyclomaticComplexity">
      <property name="max" value="10"/>
    </module>

  </module>
</module>
```

---

## 🔍 VIOLATION DETECTION & CLASSIFICATION

### Violation Categories

| Category | Examples | Severity | Fixable |
|----------|----------|----------|---------|
| **Naming** | Variable names, method names | 🟡 MEDIUM | ✅ Yes |
| **Whitespace** | Extra spaces, line endings | 🟢 LOW | ✅ Yes |
| **Indentation** | Incorrect indentation | 🟡 MEDIUM | ✅ Yes |
| **Import Order** | Unorganized imports | 🟡 MEDIUM | ✅ Yes |
| **Line Length** | Lines too long | 🟡 MEDIUM | ✅ Partial |
| **Braces** | Missing/misplaced braces | 🟠 HIGH | ✅ Yes |
| **Javadoc** | Missing documentation | 🟠 HIGH | 🟔 Partial |
| **Complexity** | Too complex methods | 🔴 CRITICAL | ❌ No |

### Severity Levels

```
CRITICAL  (🔴) - Code logic issue, requires manual review
HIGH      (🟠) - Must fix before merge
MEDIUM    (🟡) - Should fix before merge
LOW       (🟢) - Nice to fix, not blocking
```

---

## 🛠️ AUTO-FIX STRATEGIES

### Strategy 1: Spotless (Recommended)

```xml
<!-- pom.xml -->
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
```

**Commands:**
```bash
# Apply formatting automatically
mvn spotless:apply

# Check without applying
mvn spotless:check

# Fix specific file
mvn spotless:apply -Dspotless.apply.skip=false -DskipTests
```

### Strategy 2: Google Java Format

```bash
# Install
brew install google-java-format

# Apply to file
google-java-format -i src/main/java/com/example/MyClass.java

# Apply to directory
find src -name "*.java" -exec google-java-format -i {} \;
```

### Strategy 3: Maven Checkstyle Plugin

```bash
# Check violations
mvn checkstyle:check

# Generate report
mvn checkstyle:checkstyle

# Check with specific configuration
mvn checkstyle:check -Dcheckstyle.config.location=config/checkstyle/checkstyle.xml
```

---

## 📊 DETAILED VIOLATION ANALYSIS

### Common Violations & Fixes

#### 1. **Line too long**
```java
// ❌ VIOLATION: Line exceeds 120 characters
public static final String VERY_LONG_CONSTANT_NAME = "This is a very long string that exceeds the maximum line length";

// ✅ FIXED
public static final String VERY_LONG_CONSTANT_NAME = 
    "This is a very long string that exceeds the maximum line length";
```

#### 2. **Incorrect Indentation**
```java
// ❌ VIOLATION: Inconsistent indentation
public class MyClass {
    public void myMethod() {
      int x = 5;  // 2 spaces instead of 4
        System.out.println(x);  // 8 spaces
    }
}

// ✅ FIXED
public class MyClass {
    public void myMethod() {
        int x = 5;
        System.out.println(x);
    }
}
```

#### 3. **Missing Whitespace**
```java
// ❌ VIOLATION: Missing whitespace around operators
int result=x+y*2;

// ✅ FIXED
int result = x + y * 2;
```

#### 4. **Unorganized Imports**
```java
// ❌ VIOLATION: Wrong import order
import com.example.MyClass;
import java.util.List;
import org.springframework.stereotype.Service;
import javax.persistence.Entity;

// ✅ FIXED
import java.util.List;
import javax.persistence.Entity;
import org.springframework.stereotype.Service;
import com.example.MyClass;
```

#### 5. **Missing Braces**
```java
// ❌ VIOLATION: Missing braces on if statement
if (condition)
    doSomething();

// ✅ FIXED
if (condition) {
    doSomething();
}
```

#### 6. **Wrong Naming Convention**
```java
// ❌ VIOLATION: Variable name doesn't follow camelCase
int MyVariable = 5;
public static final int myConstant = 10;

// ✅ FIXED
int myVariable = 5;
public static final int MY_CONSTANT = 10;
```

#### 7. **Missing Javadoc**
```java
// ❌ VIOLATION: Public method missing Javadoc
public void processOrder(Order order) {
    // implementation
}

// ✅ FIXED
/**
 * Processes an order and updates its status.
 *
 * @param order the order to process
 * @throws IllegalArgumentException if order is null
 */
public void processOrder(Order order) {
    // implementation
}
```

---

## 🤖 AUTO-CORRECTION WORKFLOW

### Step 1: Load Configuration

```bash
# The script automatically loads checkstyle.xml from skill directory
CONFIG_FILE=".github/skills/checkstyle-review/config/checkstyle.xml"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Checkstyle configuration not found at $CONFIG_FILE"
    exit 1
fi
echo "Loaded configuration: $CONFIG_FILE"
```

### Step 2: Scan Project

```bash
# Run checkstyle with local configuration
mvn checkstyle:check \
    -Dcheckstyle.config.location=".github/skills/checkstyle-review/config/checkstyle.xml" \
    -Dcheckstyle.consoleOutput=true
```

### Step 3: Parse Violations

```bash
# Extract violations by category
echo "=== LINE LENGTH VIOLATIONS ==="
grep -i "line is longer" checkstyle-output.txt

echo "=== INDENTATION VIOLATIONS ==="
grep -i "indentation" checkstyle-output.txt

echo "=== NAMING VIOLATIONS ==="
grep -i "name" checkstyle-output.txt
```

### Step 4: Apply Auto-Fixes

```bash
# Apply all automatically fixable violations
mvn spotless:apply

# For non-fixable issues, generate recommendations
grep -i "complexity\|javadoc" checkstyle-output.txt > recommendations.txt
```

### Step 5: Validate

```bash
# Run checkstyle again to verify
mvn checkstyle:check

# Run all tests
mvn test

# Run integration tests
mvn integration-test
```

### Step 6: Report Results

---

## 📋 CHECKSTYLE REPORT TEMPLATE

```markdown
# 🎯 CHECKSTYLE ANALYSIS REPORT

## 📊 Summary

| Metric | Count | Status |
|--------|-------|--------|
| Total Files Analyzed | X | - |
| Total Violations | X | 🔴 |
| **CRITICAL** | X | Action Required |
| **HIGH** | X | Must Fix |
| **MEDIUM** | X | Should Fix |
| **LOW** | X | Nice to Fix |
| Auto-Fixed | X | ✅ |
| Manual Review | X | 🔍 |
| Passing Rate | X% | - |

## 🔴 CRITICAL ISSUES (Manual Review Required)

### 1. Cyclomatic Complexity Exceeded

**File:** `src/main/java/com/example/OrderProcessor.java:45`  
**Issue:** Method `processOrder()` has complexity 15 (max: 10)  
**Severity:** CRITICAL  
**Action:** Refactor method to reduce complexity

```java
// Recommendation: Split into smaller methods
private void validateOrder(Order order) { ... }
private void calculateTotals(Order order) { ... }
private void saveOrder(Order order) { ... }
```

## 🟠 HIGH PRIORITY (Must Fix)

### Violations Summary

| Violation | Count | Files |
|-----------|-------|-------|
| Missing Javadoc | 12 | OrderService.java, UserService.java |
| Missing Braces | 8 | PaymentProcessor.java |
| Line Too Long | 15 | Various files |

## 🟡 MEDIUM PRIORITY (Should Fix)

...

## 🟢 LOW PRIORITY (Nice to Fix)

...

## ✅ AUTO-FIXED VIOLATIONS

- ✅ Whitespace around operators: 45 violations
- ✅ Incorrect indentation: 23 violations
- ✅ Import order: 8 violations
- ✅ Blank lines: 12 violations

**Total Auto-Fixed:** 88 violations

## 🔍 BEFORE vs AFTER

### File: `UserService.java`

**BEFORE:**
```java
public class UserService{
    public void createUser(User user){
      String name=user.getName();
      System.out.println( name );
    }
}
```

**AFTER:**
```java
/**
 * Service for managing user operations.
 */
public class UserService {
    
    /**
     * Creates a new user in the system.
     *
     * @param user the user to create
     */
    public void createUser(User user) {
        String name = user.getName();
        System.out.println(name);
    }
}
```

## 📋 CHECKLIST

- ✅ Configuration loaded successfully
- ✅ Code scanned for violations
- ✅ Auto-fixes applied
- ✅ Tests passing
- ✅ Ready for merge

## 🚀 Next Steps

1. Review CRITICAL issues manually
2. Add missing Javadoc to public methods
3. Refactor complex methods
4. Run full test suite
5. Create commit with checkstyle fixes
```

---

## 💻 IMPLEMENTATION COMMANDS

### Maven Integration

**Step 1: Add Plugin to pom.xml**

```xml
<plugin>
  <groupId>org.apache.maven.plugins</groupId>
  <artifactId>maven-checkstyle-plugin</artifactId>
  <version>3.1.2</version>
  <configuration>
    <configLocation>config/checkstyle/checkstyle.xml</configLocation>
    <consoleOutput>true</consoleOutput>
    <failsOnError>true</failsOnError>
    <linkXRef>false</linkXRef>
  </configuration>
  <executions>
    <execution>
      <id>validate</id>
      <phase>validate</phase>
      <goals>
        <goal>check</goal>
      </goals>
    </execution>
  </executions>
</plugin>

<!-- Spotless for auto-fixing -->
<plugin>
  <groupId>com.diffplug.spotless</groupId>
  <artifactId>spotless-maven-plugin</artifactId>
  <version>2.35.0</version>
  <executions>
    <execution>
      <goals>
        <goal>check</goal>
      </goals>
      <phase>validate</phase>
    </execution>
  </executions>
</plugin>
```

**Step 2: Run Analysis**

```bash
# Check for violations
mvn checkstyle:check

# Apply auto-fixes
mvn spotless:apply

# Generate report
mvn checkstyle:checkstyle site:generate-reports
```

---

## 🎯 USAGE EXAMPLES

### Example 1: Complete Check & Fix

```bash
#!/bin/bash

echo "🔍 Running Checkstyle Analysis..."
mvn checkstyle:check || true

echo "🔧 Applying Auto-Fixes..."
mvn spotless:apply

echo "✅ Verifying Fixes..."
mvn checkstyle:check

echo "🧪 Running Tests..."
mvn test

echo "✨ Complete!"
```

### Example 2: Check Specific Files

```bash
mvn checkstyle:check \
    -Dcheckstyle.includes="src/main/java/com/example/UserService.java"
```

### Example 3: Generate HTML Report

```bash
mvn checkstyle:checkstyle
open target/site/checkstyle.html
```

---

## ✅ CONSTRAINTS & BEST PRACTICES

**Always:**
- Load configuration before analysis
- Validate configuration file exists
- Run tests after applying fixes
- Generate before/after reports
- Document manual changes needed
- Review CRITICAL issues manually

**Never:**
- Apply fixes without validation
- Ignore CRITICAL violations
- Skip test suite after fixes
- Commit code with style violations
- Override checkstyle rules without justification
- Apply fixes without backing up original files

---

## 🔗 RELATED SKILLS

- [Java Code Review](/skills/java-code-review/SKILL.md)
- [PMD Analysis](/skills/pmd-analysis/SKILL.md)
- [SpotBugs Security](/skills/spotbugs-security/SKILL.md)

---

## 🎯 INTEGRATING SKILL INTO PROJECT

### Step 1: Make Script Executable

```bash
chmod +x .github/skills/checkstyle-review/scripts/checkstyle-fix.sh
```

### Step 2: Add Maven Plugins to pom.xml

```xml
<!-- Checkstyle Plugin -->
<plugin>
  <groupId>org.apache.maven.plugins</groupId>
  <artifactId>maven-checkstyle-plugin</artifactId>
  <version>3.1.2</version>
  <configuration>
    <configLocation>.github/skills/checkstyle-review/config/checkstyle.xml</configLocation>
    <consoleOutput>true</consoleOutput>
    <failsOnError>false</failsOnError>
    <linkXRef>false</linkXRef>
  </configuration>
</plugin>

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
```

### Step 3: Create Git Pre-Commit Hook (Optional)

```bash
# Create hook
mkdir -p .git/hooks
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
echo "Running Checkstyle Review..."
./.github/skills/checkstyle-review/scripts/checkstyle-fix.sh --fix

if [ $? -ne 0 ]; then
    echo "Checkstyle violations found. Commit aborted."
    exit 1
fi

echo "✅ All checks passed!"
exit 0
EOF

# Make executable
chmod +x .git/hooks/pre-commit
```

### Step 4: Create CI/CD Pipeline Integration (GitHub Actions)

```yaml
# .github/workflows/code-quality.yml
name: Code Quality

on: [push, pull_request]

jobs:
  checkstyle:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Java
        uses: actions/setup-java@v3
        with:
          java-version: '11'
          distribution: 'temurin'
      
      - name: Make script executable
        run: chmod +x .github/skills/checkstyle-review/scripts/checkstyle-fix.sh
      
      - name: Run Checkstyle Review
        run: ./.github/skills/checkstyle-review/scripts/checkstyle-fix.sh --report
      
      - name: Upload Report
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: checkstyle-report
          path: target/site/checkstyle.html
```

### Step 5: Run Skill

```bash
# Analysis only
./.github/skills/checkstyle-review/scripts/checkstyle-fix.sh

# With auto-fix
./.github/skills/checkstyle-review/scripts/checkstyle-fix.sh --fix

# Full workflow with report
./.github/skills/checkstyle-review/scripts/checkstyle-fix.sh --fix --report --verbose
```

---

## 📚 DOCUMENTATION FILES

- [**SKILL.md**](SKILL.md) - Comprehensive skill documentation (this file)
- [**README.md**](README.md) - Quick start guide with examples
- [**config/checkstyle.xml**](config/checkstyle.xml) - XML rule configuration
- [**scripts/checkstyle-fix.sh**](scripts/checkstyle-fix.sh) - Automation script

---

## 🚀 QUICK REFERENCE

| Task | Command |
|------|---------|
| **Analysis** | `./.github/skills/checkstyle-review/scripts/checkstyle-fix.sh` |
| **Auto-Fix** | `./.github/skills/checkstyle-review/scripts/checkstyle-fix.sh --fix` |
| **With Report** | `./.github/skills/checkstyle-review/scripts/checkstyle-fix.sh --fix --report` |
| **Verbose** | `./.github/skills/checkstyle-review/scripts/checkstyle-fix.sh --verbose` |
| **Integration** | Add plugins to `pom.xml` (see section above) |
