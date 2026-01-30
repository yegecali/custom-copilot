# 🚀 Orchestrate Full Migration Prompt

**Triggered when user says:** "migra todo", "migración completa", "automaticamente", "orchestrate"

---

## 🎯 Mission

Execute a complete, automated migration of Azure Functions from C# to Java with real-time progress tracking, multi-checkpoint validation, and automatic error recovery.

---

## 📋 Pre-Flight Checklist

Before starting migration, verify:

- [ ] Workspace contains C# Azure Functions project
- [ ] `.csproj` or `.sln` files are present
- [ ] C# code is syntactically valid
- [ ] Java 17+ is available on system
- [ ] Maven 3.9+ is installed
- [ ] Azure Functions Core Tools installed (optional but recommended)

**If any check fails:** Stop and notify user with specific remediation steps.

---

## 🔄 EXECUTION PHASES (Automated)

### Phase 0: Preparation (5 min)

```
🎯 GOALS:
- Create project structure
- Initialize tracking system
- Generate backup

ACTIONS:
1. Analyze workspace structure
   └─ Scan for .csproj, .sln, .cs files

2. Create [ProjectName]-migrated/ directory
   └─ Create src/main/java, src/test/java, src/main/resources

3. Initialize progress tracking
   └─ Create migration.log and progress.json

4. Backup original C# project
   └─ Create backup timestamp folder

5. Detect project metadata
   ├─ Project name
   ├─ Project description
   ├─ Current .NET version
   └─ Target Java version (default: 17)

CHECKPOINT VALIDATION:
✅ Directory structure created
✅ Backup exists
✅ Metadata extracted
```

### Phase 1: Deep Analysis (10-15 min)

```
🎯 GOALS:
- Understand complete project
- Detect all triggers and bindings
- Map all dependencies
- Identify patterns and complexity

ACTIONS:
1. File Discovery
   ├─ List all .cs files
   ├─ Identify test files (Test.cs, *Tests.cs)
   ├─ Locate configuration files (appsettings.json, .csproj)
   └─ Count LOC and file complexity

2. Trigger Detection
   ├─ Find @HttpTrigger functions
   ├─ Find @TimerTrigger functions
   ├─ Find @QueueTrigger functions
   ├─ Find @CosmosDBTrigger functions
   ├─ Find @BlobTrigger functions
   └─ Find @ServiceBusTrigger functions

3. Dependency Analysis
   ├─ Parse .csproj for NuGet packages
   ├─ Identify version constraints
   ├─ Detect custom libraries
   ├─ Check for deprecated packages
   └─ Flag potential compatibility issues

4. Code Pattern Detection
   ├─ Count async/await usage
   ├─ Detect LINQ queries
   ├─ Identify Entity Framework usage
   ├─ Find exception handling patterns
   ├─ Detect custom attributes/annotations
   └─ Identify logging statements

5. Configuration Analysis
   ├─ Parse appsettings.json
   ├─ Extract connection strings
   ├─ Identify environment-specific configs
   └─ Detect secrets/sensitive data

CHECKPOINT VALIDATION:
✅ All .cs files identified
✅ All triggers detected
✅ All dependencies mapped
✅ Generate analysis report
```

**Output:** `analysis-report.json` with detailed findings

### Phase 2: Parallel Translation (20-30 min)

```
🎯 GOALS:
- Convert all .cs files to .java
- Apply Java idioms and best practices
- Generate structurally sound Java code

ACTIONS (PARALLEL for multiple files):
For each .cs file:

1. Pre-Translation Analysis
   ├─ Detect class structure
   ├─ Identify methods and signatures
   ├─ Find triggers/bindings
   ├─ Detect dependencies
   └─ Calculate complexity score

2. Code Translation
   ├─ Convert async Task<T> → CompletableFuture<T>/Mono<T>
   ├─ Convert IEnumerable → Stream/List
   ├─ Convert Dictionary → Map/HashMap
   ├─ Convert LINQ → Stream API
   ├─ Convert using statements → try-with-resources
   ├─ Convert null-coalescing (??) → Optional
   ├─ Convert string interpolation → proper format
   ├─ Convert attributes → annotations
   └─ Convert exception handling

3. Azure Functions Mapping
   ├─ Map [FunctionName] → @FunctionName
   ├─ Map [HttpTrigger] → @HttpTrigger
   ├─ Map [TimerTrigger] → @TimerTrigger
   ├─ Map [QueueTrigger] → @QueueTrigger
   ├─ Map [CosmosDBTrigger] → @CosmosDBTrigger
   ├─ Map ILogger → SLF4J Logger
   ├─ Map ExecutionContext → same interface
   └─ Map binding parameters → annotations

4. Formatting & Style
   ├─ Apply Java conventions
   ├─ Fix indentation (4 spaces)
   ├─ Add missing imports
   ├─ Organize method order
   ├─ Add javadoc comments
   └─ Ensure 120-char line limit

5. Validation
   ├─ Compile check with javac
   ├─ Verify imports exist
   ├─ Check annotation syntax
   └─ Flag TODO items

BATCHING STRATEGY:
- Files < 100 LOC: Batch 5 files per worker
- Files 100-500 LOC: Batch 2 files per worker
- Files > 500 LOC: 1 file per worker

CHECKPOINT VALIDATION:
✅ No syntax errors in generated .java
✅ All imports resolved (or TODO marked)
✅ All triggers mapped
✅ Coverage: 100% of .cs files translated
```

**Output:** All .java files in `src/main/java/` and `src/test/java/`

### Phase 3: Configuration Generation (5-10 min)

```
🎯 GOALS:
- Generate Maven configuration
- Create Azure Functions config
- Convert application settings

ACTIONS:

1. Generate pom.xml
   ├─ Set Java version to 17 (configurable)
   ├─ Set Spring Boot version (3.x)
   ├─ Map all NuGet → Maven dependencies
   ├─ Add Azure Functions maven plugin
   ├─ Add test dependencies (JUnit 5, Mockito)
   ├─ Add code quality plugins (SpotBugs, Checkstyle)
   ├─ Add compiler settings
   └─ Validate pom.xml schema

2. Generate function.json for each trigger
   ├─ HTTP: method, route, auth level
   ├─ Timer: schedule expression
   ├─ Queue: queue name, connection
   ├─ Cosmos: database, collection, connection
   └─ Generate in src/main/resources/

3. Convert appsettings.json
   ├─ Parse JSON structure
   ├─ Convert to application.properties format
   ├─ Create profiles (application-dev.properties, etc)
   ├─ Flag secrets for Azure Key Vault
   └─ Generate in src/main/resources/

4. Create .gitignore
   ├─ Add Maven patterns (target/, *.class)
   ├─ Add IDE patterns (.idea/, .vscode/)
   ├─ Add OS patterns (.DS_Store, Thumbs.db)
   └─ Add secrets patterns (*.env, credentials)

5. Create README migration guide
   ├─ Project overview
   ├─ Build instructions
   ├─ Deployment instructions
   ├─ Environment setup
   └─ Troubleshooting guide

CHECKPOINT VALIDATION:
✅ pom.xml is valid XML and Maven-compatible
✅ function.json files are valid JSON
✅ application.properties are parseable
✅ No missing required properties
```

**Output:** `pom.xml`, `function.json`, `application.properties`, `README-MIGRATION.md`

### Phase 4: Testing Migration (10-15 min)

```
🎯 GOALS:
- Migrate all unit tests from xUnit to JUnit 5
- Generate missing tests
- Ensure test coverage

ACTIONS (PARALLEL for test files):

1. Test File Discovery
   ├─ Find *Test.cs or Tests.cs files
   ├─ Parse test structure
   ├─ Identify test classes and methods
   └─ Map assertions and attributes

2. xUnit → JUnit 5 Conversion
   ├─ [Fact] → @Test
   ├─ [Theory] → @ParameterizedTest
   ├─ Assert.Equal → assertEquals
   ├─ Assert.True → assertTrue
   ├─ Assert.Throws<T> → assertThrows
   ├─ [InlineData] → @ValueSource
   ├─ IAsyncLifetime → @BeforeEach/@AfterEach
   └─ TestFixture → @ExtendWith

3. Test Method Enhancement
   ├─ Add @DisplayName with descriptive names
   ├─ Convert AAA (Arrange-Act-Assert) comments
   ├─ Add parameterized test names
   ├─ Convert mocking libraries (Moq → Mockito)
   └─ Add timeout annotations

4. Missing Test Generation
   ├─ Identify untested public methods
   ├─ Generate skeleton tests
   ├─ Add TODO comments for implementation
   └─ Generate 80% code coverage

5. Test Configuration
   ├─ Create test dependencies in pom.xml
   ├─ Add JUnit 5, Mockito, AssertJ
   ├─ Configure test runner
   └─ Create application-test.properties

CHECKPOINT VALIDATION:
✅ All tests have @Test or @ParameterizedTest
✅ No xUnit artifacts remaining
✅ Test compilation successful
✅ All test imports resolved
```

**Output:** All test files in `src/test/java/`

### Phase 5: Validation & Build (10-15 min)

```
🎯 GOALS:
- Validate all generated code
- Execute Maven build
- Run test suite
- Perform static analysis

ACTIONS:

1. Pre-Build Validation
   ├─ Check pom.xml validity
   ├─ Verify all Java files compile
   ├─ Validate Azure Functions structure
   ├─ Check @FunctionName uniqueness
   └─ Verify trigger configurations

2. Maven Build
   ├─ Clean: mvn clean
   ├─ Compile: mvn compile
   ├─ Test: mvn test
   ├─ Package: mvn package
   ├─ Generate site: mvn site (optional)
   └─ Report on: Build time, LOC, coverage

3. Test Execution
   ├─ Run full test suite
   ├─ Collect coverage metrics
   ├─ Report pass/fail counts
   ├─ Generate test report
   └─ Flag failing tests with suggestions

4. Static Analysis (Optional)
   ├─ Run SpotBugs: mvn spotbugs:check
   ├─ Run Checkstyle: mvn checkstyle:check
   ├─ Report findings
   └─ Suggest fixes

5. Functional Validation
   ├─ Verify HTTP endpoints are mapped
   ├─ Verify trigger decorators are present
   ├─ Verify connection strings configured
   ├─ Verify logging is configured
   └─ Generate validation report

CHECKPOINT VALIDATION:
✅ Zero build errors (critical failures → rollback)
✅ All tests pass OR documented known failures
✅ Coverage above threshold (default: 70%)
✅ Azure Functions structure valid
```

**Output:** `build-report.json`, `test-report.html`, validation logs

### Phase 6: Documentation (5-10 min)

```
🎯 GOALS:
- Create comprehensive migration documentation
- Generate runbooks for deployment
- Document breaking changes

ACTIONS:

1. Migration Summary Document
   ├─ Project overview
   ├─ Migration scope and timeline
   ├─ Files migrated: [count] .cs → .java
   ├─ Major patterns converted
   ├─ Triggers identified: [list]
   └─ Dependencies mapped: [count]

2. Dependency Mapping Guide
   ├─ NuGet packages → Maven artifacts
   ├─ Version mappings
   ├─ Notable replacements (Entity Framework → JPA)
   ├─ Breaking changes
   └─ Migration notes per dependency

3. Deployment Guide
   ├─ Local development setup
   ├─ Azure Functions deployment steps
   ├─ Environment variable configuration
   ├─ Connection string setup
   ├─ Azure Key Vault integration
   └─ Troubleshooting section

4. Breaking Changes Document
   ├─ Behavioral differences
   ├─ Configuration changes
   ├─ API endpoint changes (if any)
   ├─ Error handling differences
   └─ Performance considerations

5. Troubleshooting Guide
   ├─ Common issues and solutions
   ├─ Debugging tips
   ├─ Performance tuning
   ├─ Logging and monitoring
   └─ Support contacts

CHECKPOINT VALIDATION:
✅ All documents generated
✅ Links are valid
✅ Code examples compile
```

**Output:** Markdown files in `docs/`

### Phase 7: Final Report & Summary (2-5 min)

```
🎯 GOALS:
- Summarize migration results
- Provide post-migration checklist
- Show statistics and insights

ACTIONS:

1. Migration Statistics
   ├─ Total execution time
   ├─ Files processed: [count]
   ├─ Lines of code: [original] → [migrated]
   ├─ Test coverage: [%]
   ├─ Build time: [seconds]
   └─ Issues found and resolved: [count]

2. Quality Metrics
   ├─ Code compilation: ✅ 0 errors
   ├─ Test results: ✅ 95/100 passed
   ├─ Code coverage: ✅ 82%
   ├─ Static analysis: ✅ 3 warnings
   └─ Azure Functions compatibility: ✅ Valid

3. Detailed Results
   ├─ Phase completion: [all phases ✅]
   ├─ Files by category:
   │   ├─ Triggers migrated: 5
   │   ├─ Utility classes: 12
   │   ├─ Models/Entities: 8
   │   └─ Tests generated: 10
   ├─ Dependencies:
   │   ├─ Mapped: 24/24
   │   ├─ Conflicts resolved: 2
   │   └─ Version updates: 0
   └─ Configuration:
       ├─ pom.xml: ✅ Generated
       ├─ function.json: ✅ Generated
       └─ application.properties: ✅ Generated

4. Post-Migration Checklist
   [ ] Review generated Java code
   [ ] Execute tests locally
   [ ] Configure Azure resources
   [ ] Deploy to dev environment
   [ ] Test triggers in Azure
   [ ] Update CI/CD pipelines
   [ ] Train team on Java code
   [ ] Schedule production deployment

5. Next Steps
   ├─ Recommended: Review trigger handlers
   ├─ Optional: Optimize async patterns
   ├─ Optional: Add integration tests
   ├─ Optional: Configure monitoring/alerting
   └─ Optional: Performance tuning

CHECKPOINT VALIDATION:
✅ All statistics calculated
✅ Report generated
✅ Checklist created
```

**Output:** `migration-report.md`, `migration-report.json`

---

## ⚠️ Error Handling Strategy

### Level 1: Warning (Non-blocking)

```
Examples:
- Minor code style issues
- Optional dependency updates
- Info-level logging statements

Action:
→ Log warning
→ Continue execution
→ Add to report section "Warnings"
```

### Level 2: Error (Retriable)

```
Examples:
- File parsing errors
- Incomplete translations
- Transient network issues

Action:
→ Log error
→ Retry up to 3 times with backoff
→ If still failing, skip file and continue
→ Add TODO comment in generated code
→ Add to report section "Errors - Skipped"
```

### Level 3: Critical (Non-retriable)

```
Examples:
- Syntax errors in generated .java files
- Failed Maven compilation
- Invalid Azure Functions structure
- Corrupted pom.xml

Action:
→ Log critical error with full stack
→ HALT orchestration
→ Initiate ROLLBACK:
   ├─ Delete partially migrated files
   ├─ Restore from backup
   ├─ Display error to user
   └─ Suggest manual fixes
→ Offer user options:
   ├─ Fix and retry specific phase
   ├─ Skip this file and continue
   ├─ Abort and keep backup
   └─ Contact support
```

---

## 🔄 Retry Strategy

```
For retriable errors:
Attempt 1: Immediate (0 second delay)
Attempt 2: After 2 seconds
Attempt 3: After 5 seconds

If all 3 attempts fail:
→ Log final failure
→ Skip file/operation
→ Continue with next item
→ Mark in report as "Partial Migration"
```

---

## ✅ Success Criteria

Migration is considered **SUCCESSFUL** when:

- ✅ Phase 0-7 all completed or safely skipped
- ✅ Zero critical errors
- ✅ Maven build with 0 errors
- ✅ All tests compile
- ✅ 70%+ test pass rate
- ✅ Azure Functions structure valid
- ✅ Documentation generated
- ✅ Report shows actionable summary

Migration is **PARTIAL** when:

- ⚠️ Some files skipped due to Level 2 errors
- ⚠️ Build succeeds but with warnings
- ⚠️ Some tests failing but documented
- ⚠️ Manual intervention needed for [specific files]

Migration **FAILED** when:

- ❌ Critical error encountered and rollback activated
- ❌ Maven build failed with errors
- ❌ Azure Functions validation failed
- ❌ User aborted mid-migration

---

## 📊 Real-Time Progress Display

```
🚀 MIGRACIÓN COMPLETA EN PROGRESO
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📍 Fase: 2/7 - Translation (Parallel)
⏱️  Tiempo: 15m 23s / ~45m estimado

📊 Progreso Global: ████████░░░░░░░░░░░░░░ 42%

Fase 0 (Preparation):     ✅ Completado (3m 12s)
Fase 1 (Analysis):        ✅ Completado (8m 45s)
Fase 2 (Translation):     🔄 En progreso
  ├─ Processed: 12/28 files
  ├─ Current: CardPaymentProcessor.cs → CardPaymentProcessor.java
  ├─ Batches: 3/5 completados
  └─ ETA: 8m 30s
Fase 3 (Configuration):   ⏳ Pendiente
Fase 4 (Testing):         ⏳ Pendiente
Fase 5 (Validation):      ⏳ Pendiente
Fase 6 (Documentation):   ⏳ Pendiente
Fase 7 (Summary):         ⏳ Pendiente

⚠️  Warnings: 2
  - [Info] Optional dependency update available
  - [Info] One async method using Task.Result

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## 🎯 When to Use This Prompt

**USE this prompt when:**

- User says "migra todo"
- User says "migración automática completa"
- User says "orchestrate full migration"
- User wants to migrate entire project in one go
- Time is critical and full automation needed

**DO NOT use when:**

- User wants to migrate single function only
- User wants step-by-step control
- User wants to analyze without migrating
- User wants specific trigger-type migration

---

**Last Updated:** January 2025
**Version:** 2.0
**Owner:** Migration Specialist Agent
