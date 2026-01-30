# 🚀 Orchestrate Full Migration with Azure Functions Init

**Triggered when user says:** "migra todo", "migración completa", "automaticamente", "orchestrate", "con func init"

---

## 🎯 Mission

Execute a complete, automated migration of Azure Functions from C# to Java using Azure Functions CLI (`func init`, `func new`), with real-time progress tracking, multi-checkpoint validation, and automatic error recovery.

---

## 📋 Pre-Flight Checklist

Before starting migration, verify:

- [ ] Workspace contains C# Azure Functions project
- [ ] `.csproj` or `.sln` files are present
- [ ] C# code is syntactically valid
- [ ] Java 17+ is available on system
- [ ] Maven 3.9+ is installed
- [ ] Azure Functions Core Tools installed (required)
- [ ] `func` command is accessible from terminal

**If any check fails:** Stop and notify user with specific remediation steps.

---

## 🔄 EXECUTION PHASES (Automated)

### Phase 0: Preparation & Discovery (5 min)

```
🎯 GOALS:
- Analyze C# project structure
- Extract function names from .csproj
- Create project structure with func init
- Initialize tracking system

ACTIONS:
1. Analyze C# Project Structure
   ├─ Scan for .csproj, .sln, .cs files
   ├─ Parse .csproj to extract:
   │  ├─ Project name
   │  ├─ Package references (NuGet dependencies)
   │  └─ Output type and target framework
   ├─ List all .cs files
   └─ Identify function files (with [FunctionName] attribute)

2. Extract Function Names
   ├─ For each .cs file with [FunctionName("Name")]
   │  ├─ Extract function name
   │  ├─ Detect trigger type (HttpTrigger, TimerTrigger, etc)
   │  ├─ Extract function signature
   │  └─ Store in functions inventory
   └─ Create ordered list of functions to create

3. Initialize Java Azure Functions Project
   └─ Run: func init [project-name] --worker-runtime java
      ├─ Creates: pom.xml, local.settings.json, .gitignore
      ├─ Directory structure:
      │  ├─ src/main/java/com/example/functions/
      │  ├─ src/main/resources/
      │  └─ src/test/java/com/example/functions/
      └─ Validates Java project structure

4. Backup original C# project
   └─ Create backup timestamp folder

5. Initialize progress tracking
   └─ Create migration.log and progress.json
   └─ Track: Total functions, completed, pending

CHECKPOINT VALIDATION:
✅ All .cs files identified
✅ Function names extracted
✅ func init completed successfully
✅ pom.xml exists with Java Azure Functions dependency
✅ Progress tracking initialized
```

**Output:**

- `migration-progress.json` tracking all functions
- `functions-inventory.json` with function details
- Azure Functions project initialized in working directory

### Phase 1: Deep Analysis (10-15 min)

```
🎯 GOALS:
- Understand complete project structure
- Detect all triggers and bindings
- Map all dependencies (NuGet → Maven)
- Identify patterns and complexity

ACTIONS:
1. C# File Discovery
   ├─ List all .cs files
   ├─ Identify test files (Test.cs, *Tests.cs)
   ├─ Locate configuration files (appsettings.json, .csproj)
   └─ Count LOC and file complexity

2. Trigger Detection
   ├─ Find [HttpTrigger] functions → @HttpTrigger
   ├─ Find [TimerTrigger] functions → @TimerTrigger
   ├─ Find [QueueTrigger] functions → @QueueTrigger
   ├─ Find [CosmosDBTrigger] functions → @CosmosDBTrigger
   ├─ Find [BlobTrigger] functions → @BlobTrigger
   └─ Find [ServiceBusTrigger] functions → @ServiceBusTrigger

3. Dependency Analysis
   ├─ Parse .csproj for NuGet packages
   ├─ Map NuGet packages to Maven equivalents
   ├─ Identify version constraints
   ├─ Detect custom libraries
   ├─ Check for deprecated packages
   └─ Flag potential compatibility issues

4. Code Pattern Detection
   ├─ Count async/await usage → CompletableFuture/Mono/Flux
   ├─ Detect LINQ queries → Stream API
   ├─ Identify Entity Framework usage → JPA/Hibernate
   ├─ Find exception handling patterns
   ├─ Detect custom attributes/annotations
   └─ Identify logging statements

5. Configuration Analysis
   ├─ Parse appsettings.json
   ├─ Extract connection strings
   ├─ Identify environment-specific configs
   └─ Detect secrets/sensitive data

CHECKPOINT VALIDATION:
✅ All .cs files identified with function names
✅ All triggers detected and mapped
✅ All NuGet dependencies mapped to Maven
✅ Generate detailed analysis report
```

**Output:** `analysis-report.json` with findings

### Phase 2: Generate pom.xml & Dependencies (5 min)

```
🎯 GOALS:
- Generate pom.xml with all mapped dependencies
- Configure Maven plugins for Azure Functions
- Prepare build configuration

ACTIONS:
1. Generate pom.xml
   ├─ Start from func init template
   ├─ Add mapped NuGet → Maven dependencies
   ├─ Configure:
   │  ├─ <groupId>com.example.functions</groupId>
   │  ├─ <artifactId>[function-app-name]</artifactId>
   │  ├─ <version>1.0.0</version>
   │  ├─ Java version: 17
   │  └─ UTF-8 encoding
   ├─ Add Azure Functions Maven plugin:
   │  ├─ com.microsoft.azure:azure-functions-maven-plugin
   │  └─ Configured for local runtime
   └─ Add test dependencies (JUnit 5, Mockito, AssertJ)

2. Update project properties
   ├─ maven.compiler.source=17
   ├─ maven.compiler.target=17
   ├─ project.build.sourceEncoding=UTF-8
   └─ functionAppName and functionAppRegion

3. Validate pom.xml
   ├─ Run: mvn validate
   └─ Check for dependency conflicts

CHECKPOINT VALIDATION:
✅ pom.xml generated with all dependencies
✅ All NuGet packages properly mapped
✅ Maven structure is valid
✅ No dependency conflicts
```

**Output:** Updated `pom.xml` with complete Maven configuration

### Phase 3: Create Functions with func new (15-20 min)

```
🎯 GOALS:
- Create each Java function using func new command
- Set up function triggers and templates
- Prepare for code migration

ACTIONS (SEQUENTIAL per function):

For each function in functions-inventory:

1. Execute func new command
   └─ Run: func new --name [FunctionName] --template [template]

      TEMPLATE MAPPING (C# → Java):
      ├─ [HttpTrigger] → "HTTP trigger"
      ├─ [TimerTrigger] → "Timer trigger"
      ├─ [QueueTrigger] → "Queue trigger"
      ├─ [CosmosDBTrigger] → "Cosmos DB trigger"
      ├─ [BlobTrigger] → "Blob trigger"
      └─ [ServiceBusTrigger] → "Service Bus trigger"

   Creates directory structure:
   ├─ src/main/java/com/example/functions/[FunctionName].java
   ├─ src/main/resources/[FunctionName]/function.json
   └─ Updates pom.xml if needed

2. Update function.json binding
   ├─ Set correct trigger type
   ├─ Configure input/output bindings
   ├─ Set correct parameter names from C# source
   └─ Validate function.json syntax

3. Track progress
   ├─ Update migration-progress.json
   ├─ Mark function as "created" with timestamp
   ├─ Show progress: "3/15 functions created"
   └─ Display estimated time remaining

REPETITION:
├─ Repeat for EACH function in inventory
├─ Parallel execution possible but sequential recommended for safety
└─ Each iteration shows: [FunctionName] ✅ Created

CHECKPOINT VALIDATION (after all func new):
✅ All function .java files created
✅ All function.json files present
✅ No duplicate functions
✅ All triggers properly typed
```

**Output:** Complete Java project structure with all function templates

### Phase 4: Migrate Code (C# → Java) (30-45 min)

```
🎯 GOALS:
- Convert C# function code to Java
- Apply Java idioms and best practices
- Generate functionally equivalent Java code

ACTIONS (PARALLEL for multiple functions):

For each .cs file with [FunctionName]:

1. Pre-Translation Analysis
   ├─ Detect class structure
   ├─ Identify method signatures
   ├─ Find triggers/bindings
   ├─ Detect dependencies used
   └─ Calculate complexity score

2. Extract C# Function Code
   ├─ Get method body with all logic
   ├─ Identify local variables and their types
   ├─ Find external dependencies/calls
   ├─ Extract configuration/constants used
   └─ Identify logging calls

3. Code Translation
   ├─ Convert async Task<T> → CompletableFuture<T>/Mono<T>/Flux<T>
   ├─ Convert IEnumerable<T> → Stream<T>/List<T>
   ├─ Convert Dictionary<K,V> → Map<K,V>/HashMap<K,V>
   ├─ Convert LINQ → Java Stream API
   ├─ Convert using statements → try-with-resources
   ├─ Convert null-coalescing (??) → Optional/ternary
   ├─ Convert string interpolation → String.format()
   ├─ Convert attributes → annotations
   ├─ Convert exception handling → Java try-catch-finally
   └─ Convert logging → SLF4J/Java Logging

4. Azure Functions Mapping
   ├─ Map [FunctionName] → @FunctionName annotation
   ├─ Map parameter annotations:
   │  ├─ [HttpTrigger] → @HttpTrigger
   │  ├─ [TimerTrigger] → @TimerTrigger
   │  ├─ [QueueTrigger] → @QueueTrigger
   │  ├─ [CosmosDBTrigger] → @CosmosDBTrigger
   │  ├─ [BlobTrigger] → @BlobTrigger
   │  └─ [ServiceBusTrigger] → @ServiceBusTrigger
   ├─ Convert HttpRequest → HttpRequestMessage
   ├─ Convert ILogger → Logger (java.util.logging or SLF4J)
   ├─ Convert return types:
   │  ├─ IActionResult → HttpResponseMessage
   │  ├─ OkResult() → response.build(HttpStatus.OK)
   │  └─ BadRequestObjectResult() → response.build(HttpStatus.BAD_REQUEST)
   └─ Validate function.json matches code

5. Generate Java Method
   ├─ Create properly formatted Java method
   ├─ Add necessary imports
   ├─ Add JavaDoc comments
   ├─ Maintain code structure and logic
   └─ Apply Java naming conventions (camelCase)

6. Inject into function .java file
   ├─ Replace template method body with migrated code
   ├─ Ensure imports are complete
   ├─ Validate Java syntax
   └─ Run: mvn compile on this function's class

CHECKPOINT VALIDATION (per function):
✅ Java code compiles without errors
✅ Function signature matches trigger type
✅ All necessary imports present
✅ Logic preserved from C# original
```

**Output:** Complete migrated function implementations

### Phase 5: Migrate Tests (15-20 min)

```
🎯 GOALS:
- Convert C# xUnit/NUnit tests to JUnit 5
- Maintain test coverage
- Generate executable Java tests

ACTIONS (PARALLEL for multiple test files):

For each .cs test file:

1. Analyze Test Structure
   ├─ Identify test class [Theory] or [Fact] patterns
   ├─ Find test methods
   ├─ Detect Moq/NSubstitute mock setup
   ├─ Identify assertions (Assert.*)
   └─ Find test data/fixtures

2. Code Translation (xUnit → JUnit 5)
   ├─ [Fact] → @Test
   ├─ [Theory] → @ParameterizedTest
   ├─ [InlineData] → @ValueSource
   ├─ Moq.Mock<T>() → Mockito.mock(T.class)
   ├─ mock.Setup() → Mockito.when()
   ├─ Assert.Equal() → assertEquals()
   ├─ Assert.Throws() → assertThrows()
   ├─ [Trait("Category", "Unit")] → @Tag("Unit")
   └─ BeforeEach/AfterEach → @BeforeEach/@AfterEach

3. Create test .java file
   ├─ src/test/java/com/example/functions/[FunctionName]Test.java
   ├─ Add @DisplayName annotations with test descriptions
   ├─ Add @Test and mock setup
   ├─ Add assertions from original tests
   └─ Create parameterized tests from [Theory]

4. Validate test syntax
   ├─ Run: mvn test -Dtest=[TestClass]
   └─ Verify all tests run without syntax errors

CHECKPOINT VALIDATION (after all tests migrated):
✅ All test .java files created
✅ JUnit 5 syntax correct
✅ Mock setup working
✅ Tests compile and execute
```

**Output:** Complete test suite in JUnit 5

### Phase 6: Compile & Validate (5-10 min)

```
🎯 GOALS:
- Verify complete project compiles
- Run all tests
- Validate Azure Functions structure

ACTIONS:
1. Full Maven Compilation
   └─ Run: mvn clean compile
      ├─ Verify all .java files compile
      ├─ Check for type errors
      ├─ Validate imports
      └─ Report any compilation errors

2. Run All Tests
   └─ Run: mvn test
      ├─ Execute all JUnit 5 tests
      ├─ Report test results (passed/failed/skipped)
      ├─ Calculate test coverage
      └─ Flag any failing tests

3. Azure Functions Validation
   ├─ Verify all function.json files are valid
   ├─ Check all functions have @FunctionName annotations
   ├─ Validate trigger types match function.json
   ├─ Check no duplicate function names
   └─ Verify entry points are correct

4. Package Project
   └─ Run: mvn package -DskipTests
      ├─ Create JAR artifact
      ├─ Verify packaging successful
      └─ Show artifact location

CHECKPOINT VALIDATION:
✅ Project compiles without errors
✅ All tests pass (or report failures)
✅ Azure Functions structure valid
✅ Artifact created successfully
✅ Ready for local testing or deployment
```

**Output:** Compiled project with passing tests

### Phase 7: Generate Reports & Summary (5 min)

```
🎯 GOALS:
- Create migration summary
- Document findings and changes
- Provide deployment guidance

ACTIONS:
1. Generate Migration Report
   ├─ Total files migrated
   ├─ Functions created: [count]
   ├─ Tests migrated: [count]
   ├─ Dependencies mapped: [count]
   ├─ Build status: SUCCESS/FAILED
   ├─ Tests status: PASSED/FAILED
   ├─ Code coverage percentage
   ├─ Lines of code (before/after)
   └─ Estimated effort savings

2. Create Dependency Mapping Document
   ├─ List all NuGet → Maven mappings
   ├─ Show version mappings
   ├─ Highlight any version conflicts resolved
   └─ Note any custom dependencies

3. Create Deployment Guide
   ├─ How to run locally: func start
   ├─ How to publish to Azure: func azure functionapp publish [name]
   ├─ Configuration requirements
   ├─ Connection strings to update
   └─ Environment-specific settings

4. Create Troubleshooting Guide
   ├─ Common issues encountered
   ├─ How to solve them
   ├─ Known limitations vs C# original
   └─ Performance considerations

FINAL CHECKPOINT VALIDATION:
✅ All phases completed
✅ Build successful
✅ Tests passing
✅ Reports generated
✅ Migration complete and ready for deployment
```

**Output:**

- `migration-report.md` - Complete summary
- `dependency-mapping.json` - Dependency details
- `deployment-guide.md` - How to deploy
- `troubleshooting.md` - Known issues and solutions

---

## ⏱️ Expected Timeline

| Phase                   | Duration       | Status           |
| ----------------------- | -------------- | ---------------- |
| Phase 0: Preparation    | 5 min          | Preparation      |
| Phase 1: Analysis       | 10-15 min      | Analysis         |
| Phase 2: Dependencies   | 5 min          | Dependencies     |
| Phase 3: func new       | 15-20 min      | Function Setup   |
| Phase 4: Code Migration | 30-45 min      | Code Translation |
| Phase 5: Test Migration | 15-20 min      | Testing          |
| Phase 6: Compilation    | 5-10 min       | Validation       |
| Phase 7: Reports        | 5 min          | Documentation    |
| **TOTAL**               | **90-120 min** | **COMPLETE**     |

---

## 🎯 Success Criteria

✅ **Phase 0:** Java Functions project initialized  
✅ **Phase 1:** All C# functions identified and analyzed  
✅ **Phase 2:** pom.xml generated with all dependencies  
✅ **Phase 3:** All functions created with `func new`  
✅ **Phase 4:** All code migrated and compiles  
✅ **Phase 5:** All tests migrated and passing  
✅ **Phase 6:** Full project compiles and tests pass  
✅ **Phase 7:** Reports and documentation complete

🎉 **Migration Complete and Ready for Production!**

---

## 📊 Progress Tracking

Throughout execution, display:

```
🚀 Migración Completa: C# → Java Functions
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Phase 0: Preparation ✅ 5 min
  ├─ Project analyzed: 5 functions found
  ├─ func init completed
  └─ Backup created

Phase 1: Analysis ✅ 12 min
  ├─ Functions: HTTP, Timer, Queue, Cosmos, Blob
  ├─ Dependencies: 15 packages mapped
  └─ Patterns: async/await, LINQ, Entity Framework

Phase 2: Dependencies ✅ 5 min
  ├─ pom.xml generated
  └─ 15 dependencies configured

Phase 3: func new 📊 10/15 functions
  ├─ CardPaymentProcessor ✅
  ├─ UserNotificationHandler ✅
  ├─ StorageProcessor ✅
  ├─ ... (7 more)

Phase 4: Code Migration 📊 8/15 files
  ├─ Converting async/await → CompletableFuture
  ├─ Translating LINQ → Stream API
  └─ Mapping triggers and annotations

Phase 5: Tests 🔄 Running...
Phase 6: Compilation 🔄 Pending...
Phase 7: Reports 🔄 Pending...

⏱️ Elapsed: 45 min | Estimated: 75 min remaining
```

---

## 🔄 Error Recovery & Rollback

**If error occurs:**

1. **Severity Level 1 (Warning):** Continue with next step
   - Minor style issues
   - Optional dependency updates

2. **Severity Level 2 (Error):** Retry up to 3 times
   - File parsing errors
   - Template generation issues

3. **Severity Level 3 (Critical):** Halt and ask user
   - Compilation failures
   - Invalid Azure Functions structure
   - Test failures

**Rollback strategy:**

- Keep backup of original C# project
- Preserve all generated files even on failure
- Allow user to review before restarting failed phase

---

**Prompt Version:** 2.0  
**Target:** Azure Functions Java Runtime  
**Orchestration Type:** Hybrid Parallel with func CLI integration  
**Success Rate Target:** 95%+
