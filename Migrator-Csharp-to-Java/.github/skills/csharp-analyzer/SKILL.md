# 🔍 C# Code Analyzer Skill

## Purpose

Provide deep analysis of C# code to understand structure, patterns, and complexity before migration.

## Capabilities

This skill specializes in:

- Deep C# code analysis
- Pattern identification
- Complexity assessment
- Dependency mapping
- Architecture understanding
- Best practices evaluation

## Usage

```
@csharp-to-java-migrator #skill csharp-analyzer [file-or-description]
```

## What It Does

### 1. Code Structure Analysis

- Identifies all classes, interfaces, methods
- Maps public/private/protected members
- Detects inheritance hierarchies
- Finds composition patterns

### 2. Async Pattern Detection

- Locates all async/await usage
- Identifies Task<T> returns
- Maps await points
- Finds blocking operations

### 3. Dependency Analysis

- Lists all NuGet packages used
- Identifies version requirements
- Maps inter-class dependencies
- Finds external service calls

### 4. Complexity Metrics

- Cyclomatic complexity per method
- Lines of code analysis
- Cognitive complexity
- Code health score

### 5. Pattern Recognition

- Detects design patterns (Singleton, Factory, etc.)
- Identifies anti-patterns
- Finds code smells
- Suggests improvements

### 6. Test Coverage Analysis

- Identifies test classes
- Calculates coverage percentage
- Maps tested/untested code
- Suggests missing test cases

### 7. Security Assessment

- Finds hardcoded credentials
- Identifies input validation gaps
- Detects unsafe operations
- Checks authentication/authorization

## Output Format

### Analysis Report Structure

```markdown
# C# Code Analysis Report

## Executive Summary

- Total Files Analyzed: [N]
- Total Classes: [N]
- Total Methods: [N]
- Avg Complexity: [Score]
- Health Score: [%]

## Class Diagram
```

[UML-style diagram of classes]

```

## Async Usage Map
- [Method] uses async/await: [line numbers]
- [Method] returns Task<T>: [type]

## Dependencies
### External (NuGet)
- [Package]: [Version] (used in [N] files)

### Internal
- [Class] → [Class]: [Relationship]

## Complexity Analysis
- [Method]: Cyclomatic = [N]
- Highest Complexity: [Method] = [N]

## Patterns Detected
✅ [Pattern]: [Location]
⚠️ [Anti-pattern]: [Location]

## Security Findings
🔒 [Issue]: [Location]

## Migration Difficulty Score
- Easy (Direct translation): [%]
- Medium (Some refactoring): [%]
- Hard (Major changes): [%]
```

## Example

When you run this skill:

```
@csharp-to-java-migrator #skill csharp-analyzer PaymentProcessor.cs
```

You get:

```markdown
# C# Code Analysis: PaymentProcessor.cs

## Structure

- Class: PaymentProcessor
- Parent: IPaymentProcessor
- Methods: 5
  - ProcessPayment (async)
  - ValidateAmount (sync)
  - LogTransaction (sync)
  - HandleError (private)
  - Dispose (public)

## Async Pattern

- ProcessPayment: async Task<PaymentResult>
  - Await points: 3
    - \_repository.GetAsync (line 25)
    - \_validator.ValidateAsync (line 30)
    - \_logger.LogAsync (line 35)

## Dependencies

### NuGet

- Microsoft.Azure.Functions
- Newtonsoft.Json
- Application.Insights

### Internal

- IRepository interface
- IValidator interface
- ILogger interface

## Complexity

- ProcessPayment: CC = 8 (High)
- ValidateAmount: CC = 4 (Medium)
- LogTransaction: CC = 2 (Low)
- Overall Health: 78/100

## Patterns

✅ Dependency Injection Pattern
✅ Async/Await Pattern
⚠️ Large class warning (450 LOC)

## Security

🔓 Missing input validation on AmountField
🔓 No rate limiting detected

## Migration Assessment

- Difficulty: MEDIUM
- Estimated Effort: 4-6 hours
- Key Challenges: Async conversion, DI setup
```

## Integration with Migration Process

This skill helps:

1. **Planning**: Understand code before starting
2. **Resource Allocation**: Estimate migration effort
3. **Risk Assessment**: Identify complex areas
4. **Validation**: Compare before/after metrics

## Key Metrics Provided

- **Cyclomatic Complexity** (CC): How many paths through code
- **Lines of Code** (LOC): Size measurement
- **Cognitive Complexity**: Mental effort to understand
- **Test Coverage**: % of code tested
- **Async Ratio**: % of code that's async
- **Dependency Count**: External dependencies

## When to Use

Use `#skill csharp-analyzer` when you need to:

- ✅ Understand a C# component before migration
- ✅ Estimate migration effort
- ✅ Plan the migration strategy
- ✅ Identify risky areas
- ✅ Compare complexity metrics
- ✅ Validate translation completeness

---

**Skill Version**: 1.0  
**Languages**: C#  
**Analysis Depth**: Complete
