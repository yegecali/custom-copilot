# 🎯 Checkstyle Review - Complete Guide

## 📋 Overview

This setup provides **automated code style validation and correction** for your Java project using Checkstyle with custom rules.

### Components

1. **SKILL.md** - Detailed documentation of the checkstyle review skill
2. **checkstyle.xml** - Custom Checkstyle rules configuration
3. **checkstyle-fix.sh** - Automated script to analyze and fix violations
4. **pom.xml** - Maven plugins configuration (needs to be added)

---

## 🚀 Quick Start

### 1. Add Maven Plugins to pom.xml

```xml
<plugin>
  <groupId>org.apache.maven.plugins</groupId>
  <artifactId>maven-checkstyle-plugin</artifactId>
  <version>3.1.2</version>
  <configuration>
    <configLocation>config/checkstyle/checkstyle.xml</configLocation>
    <consoleOutput>true</consoleOutput>
    <failsOnError>false</failsOnError>
    <linkXRef>false</linkXRef>
  </configuration>
</plugin>

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
    </java>
  </configuration>
</plugin>
```

### 2. Make Script Executable

```bash
chmod +x scripts/checkstyle-fix.sh
```

### 3. Run Analysis

```bash
# Just analyze (no changes)
./scripts/checkstyle-fix.sh

# Analyze + auto-fix
./scripts/checkstyle-fix.sh --fix

# With HTML report
./scripts/checkstyle-fix.sh --fix --report
```

---

## 🔧 Commands Reference

### Analysis Commands

```bash
# Check for violations
mvn checkstyle:check -Dcheckstyle.config.location=config/checkstyle/checkstyle.xml

# Generate detailed XML report
mvn checkstyle:checkstyle

# Generate HTML report
mvn checkstyle:checkstyle site:generate-reports
```

### Auto-Fix Commands

```bash
# Apply Google Java Format
mvn spotless:apply

# Check formatting without applying
mvn spotless:check

# Format specific file
google-java-format -i src/main/java/com/example/MyClass.java
```

### Full Workflow

```bash
# 1. Analyze
./scripts/checkstyle-fix.sh

# 2. Auto-fix
./scripts/checkstyle-fix.sh --fix

# 3. Verify
./scripts/checkstyle-fix.sh

# 4. Generate report
mvn checkstyle:checkstyle site:generate-reports

# 5. Review HTML report
open target/site/checkstyle.html
```

---

## 📊 Configuration Rules

The `checkstyle.xml` includes the following rule categories:

### Naming Conventions
- Classes: PascalCase
- Methods: camelCase  
- Constants: UPPER_CASE
- Variables: camelCase

### Code Style
- Line length: Maximum 120 characters
- Indentation: 4 spaces
- Braces: Always required (except lambdas)
- Imports: Organized by package (java, javax, org, com)

### Complexity
- Cyclomatic complexity: Max 10
- Nesting level: Max 5
- Parameter count: Max 7
- Return statements: Max 3

### Javadoc
- Public classes: Require Javadoc
- Public methods: Require Javadoc
- Parameters: Must be documented
- Return values: Must be documented

### Best Practices
- No wildcard imports
- No unused imports
- No generic exceptions
- No System.out.println in production code

---

## 🔍 Common Violations & Fixes

### Line Too Long
```java
// ❌ VIOLATION
public static final String VERY_LONG_NAME = "This is a very long string that exceeds 120 characters";

// ✅ FIXED
public static final String VERY_LONG_NAME =
    "This is a very long string that exceeds 120 characters";
```

### Incorrect Indentation
```java
// ❌ VIOLATION
public class MyClass {
  public void method() {
    int x = 5;
  }
}

// ✅ FIXED
public class MyClass {
    public void method() {
        int x = 5;
    }
}
```

### Missing Whitespace
```java
// ❌ VIOLATION
int result=x+y;

// ✅ FIXED
int result = x + y;
```

### Wrong Import Order
```java
// ❌ VIOLATION
import com.example.MyClass;
import java.util.List;
import org.springframework.Component;
import javax.persistence.Entity;

// ✅ FIXED
import java.util.List;
import javax.persistence.Entity;
import org.springframework.Component;
import com.example.MyClass;
```

### Missing Javadoc
```java
// ❌ VIOLATION
public void processOrder(Order order) {
    // implementation
}

// ✅ FIXED
/**
 * Processes an order and updates its status.
 *
 * @param order the order to process
 */
public void processOrder(Order order) {
    // implementation
}
```

---

## 📋 Violation Severity Levels

| Severity | CVSS | Examples | Action |
|----------|------|----------|--------|
| CRITICAL | 9-10 | Complexity > 10, Missing Javadoc | Fix immediately |
| HIGH | 7-8 | Missing braces, Wrong naming | Fix before merge |
| MEDIUM | 4-6 | Line too long, Bad indentation | Fix in this sprint |
| LOW | 1-3 | Whitespace issues | Fix when convenient |

---

## 🤖 Customizing Rules

Edit `config/checkstyle/checkstyle.xml` to:

### Increase Line Length Limit
```xml
<module name="LineLength">
  <property name="max" value="140"/>  <!-- was 120 -->
</module>
```

### Relax Complexity Check
```xml
<module name="CyclomaticComplexity">
  <property name="max" value="15"/>  <!-- was 10 -->
</module>
```

### Make Javadoc Optional
```xml
<module name="JavadocMethod">
  <property name="scope" value="private"/>  <!-- was public -->
</module>
```

---

## 🔗 Integration with Git

### Pre-commit Hook

Create `.git/hooks/pre-commit`:

```bash
#!/bin/bash
mvn checkstyle:check -q || exit 1
```

Make executable:
```bash
chmod +x .git/hooks/pre-commit
```

### CI/CD Integration (GitHub Actions)

Create `.github/workflows/checkstyle.yml`:

```yaml
name: Checkstyle

on: [push, pull_request]

jobs:
  checkstyle:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Set up JDK
        uses: actions/setup-java@v2
        with:
          java-version: '11'
      - name: Run Checkstyle
        run: mvn checkstyle:check -q
      - name: Report
        if: failure()
        run: mvn checkstyle:checkstyle && exit 1
```

---

## 📊 Reports

### HTML Report

```bash
mvn checkstyle:checkstyle site:generate-reports
open target/site/checkstyle.html
```

### XML Report

```bash
cat target/checkstyle-result.xml
```

### Summary

```bash
grep "<violation" target/checkstyle-result.xml | wc -l
```

---

## ✅ Checklist Before Commit

- ✅ Run `./scripts/checkstyle-fix.sh --fix`
- ✅ Review violations report
- ✅ Verify auto-fixes are correct
- ✅ Run `mvn test` to ensure nothing broke
- ✅ No CRITICAL violations remain
- ✅ Commit with message: `chore(style): TEST-XXXX Fix code style violations`

---

## 🆘 Troubleshooting

### Spotless not found
```bash
# Add to pom.xml and try again
mvn spotless:apply
```

### Checkstyle configuration not found
```bash
# Verify file exists
ls -la config/checkstyle/checkstyle.xml

# Set environment variable
export CHECKSTYLE_CONFIG=/path/to/checkstyle.xml
```

### Tests failing after fixes
```bash
# Revert changes
git checkout src/

# Run original tests
mvn test

# Debug the issue
```

---

## 📚 References

- [Checkstyle Documentation](https://checkstyle.sourceforge.io/)
- [Google Java Style Guide](https://google.github.io/styleguide/javaguide.html)
- [Spotless Maven Plugin](https://github.com/diffplug/spotless)
- [Maven Checkstyle Plugin](https://maven.apache.org/plugins/maven-checkstyle-plugin/)

---

## 📞 Support

For issues or questions:
1. Check [SKILL.md](SKILL.md) for detailed documentation
2. Review violations in HTML report
3. Consult Checkstyle documentation
4. Customize rules in `checkstyle.xml` as needed
