# 🚀 Orchestrate Full Migration: Automated End-to-End Migration

## Objective

Orchestrate a complete, automated migration from C# to Java with progress tracking, directory creation, and organized output.

## Context

- User wants full automation
- Start with directory exploration
- Create organized migrated project structure
- Show progress at each step
- Generate all necessary files

## Instructions

You are the migration orchestrator. Execute this complete workflow:

### Phase 1: Discovery & Setup

**Step 1.1: Explore Project Structure**

```
📂 DISCOVERY PHASE
├─ 1. List the current directory structure
├─ 2. Identify all .cs files
├─ 3. Identify all .csproj files
├─ 4. Find all test files (*.Tests.cs)
└─ 5. Show summary of files found
```

**Command to execute:**

```bash
find . -type f \( -name "*.cs" -o -name "*.csproj" -o -name "*.json" \) | head -20
```

**Output format:**

```
📁 PROJECT STRUCTURE ANALYSIS
=====================================
Project Root: [path]
Total .cs files: [count]
Total .csproj files: [count]
Total Test files: [count]
Configuration files: [list]

Sample Files Found:
├── [File1.cs]
├── [File2.cs]
├── [Project.csproj]
└── appsettings.json
```

---

### Phase 2: Directory Creation

**Step 2.1: Create Migrated Project Directory**

```
📂 DIRECTORY CREATION PHASE
├─ 1. Get project name from current directory
├─ 2. Create directory: [ProjectName]-migrated
├─ 3. Create subdirectories:
│  ├─ src/main/java/com/example/[projectname]/
│  ├─ src/test/java/com/example/[projectname]/
│  ├─ src/main/resources/
│  ├─ config/
│  └─ docs/
└─ 4. Show directory tree created
```

**Commands to create structure:**

```bash
# Create main directory
mkdir -p [ProjectName]-migrated/src/main/java/com/example/[projectname]
mkdir -p [ProjectName]-migrated/src/test/java/com/example/[projectname]
mkdir -p [ProjectName]-migrated/src/main/resources
mkdir -p [ProjectName]-migrated/config
mkdir -p [ProjectName]-migrated/docs

# Show structure
tree [ProjectName]-migrated
```

**Output format:**

```
✅ DIRECTORY STRUCTURE CREATED
=====================================
📂 PaymentFunction-migrated/
├── 📂 src/
│   ├── 📂 main/java/com/example/payment/
│   │   ├── 📄 PaymentProcessor.java
│   │   └── 📂 models/
│   └── 📂 test/java/com/example/payment/
│       └── 📄 PaymentProcessorTests.java
├── 📂 src/main/resources/
│   └── 📄 application.properties
├── 📂 config/
│   ├── 📄 pom.xml
│   ├── 📄 function.json
│   ├── 📄 host.json
│   └── 📄 local.settings.json
├── 📂 docs/
│   ├── 📄 MIGRATION_REPORT.md
│   └── 📄 IMPLEMENTATION_GUIDE.md
└── 📄 README.md
```

---

### Phase 3: Analysis & Planning

**Step 3.1: Deep Analysis**

```
📊 ANALYSIS PHASE
├─ 1. Analyze all C# files
├─ 2. Identify triggers and bindings
├─ 3. Map all dependencies
├─ 4. Calculate complexity metrics
└─ 5. Create migration plan
```

**Output format:**

```
📊 MIGRATION ANALYSIS REPORT
=====================================

FUNCTIONS FOUND: [Count]
┌─ Function: [Name]
│  ├─ Trigger: [Type] (HTTP/Timer/Queue/etc)
│  ├─ Route: [Route pattern]
│  ├─ Methods: [GET, POST, etc]
│  ├─ Complexity: [Score]
│  ├─ Dependencies: [List]
│  └─ Estimated Effort: [Hours]
└─ ...

DEPENDENCIES FOUND: [Count]
├─ Microsoft.Azure.Functions v4.0
├─ Newtonsoft.Json v13.0
└─ ...

CONFIGURATION FILES:
├─ appsettings.json
├─ .csproj
└─ ...

TOTAL MIGRATION EFFORT: [X hours]
ESTIMATED COMPLEXITY: [Easy/Medium/Hard]
```

---

### Phase 4: Code Migration

**Step 4.1: Migrate Each Function**

```
🔄 CODE MIGRATION PHASE
├─ For each .cs file:
│  ├─ 1. Analyze function
│  ├─ 2. Translate to Java
│  ├─ 3. Generate .java file in migrated dir
│  ├─ 4. Add to progress tracker
│  └─ 5. Show progress bar
└─ Generate summary
```

**Progress display:**

```
🔄 MIGRATING SOURCE CODE
=====================================
[████████░░░░░░░░░░░] 50% (5/10 files)

✅ PaymentProcessor.cs → PaymentProcessor.java
✅ Models/PaymentRequest.cs → models/PaymentRequest.java
✅ Models/PaymentResult.cs → models/PaymentResult.java
⏳ Services/PaymentService.cs (in progress...)
⬜ Tests/PaymentProcessorTests.cs (pending)

Estimated Time Remaining: 15 minutes
```

**Output per file:**

```
✅ MIGRATED: PaymentProcessor.cs
=====================================
📍 Location: src/main/java/com/example/payment/PaymentProcessor.java
📊 Stats:
  - Lines of Code: 145
  - Complexity: 8
  - Methods: 5
  - Async Operations: 3
📝 Changes Applied:
  ✓ async Task → CompletableFuture
  ✓ HttpRequest → HttpRequestMessage
  ✓ ILogger → SLF4J Logger
  ✓ Dependency Injection setup
```

---

### Phase 5: Configuration Migration

**Step 5.1: Migrate Configuration**

```
⚙️ CONFIGURATION MIGRATION PHASE
├─ 1. Convert appsettings.json → application.properties
├─ 2. Generate pom.xml from .csproj
├─ 3. Create function.json
├─ 4. Create host.json
└─ 5. Create local.settings.json
```

**Output format:**

```
⚙️ CONFIGURATION FILES GENERATED
=====================================
✅ config/pom.xml (157 lines)
   └─ Maven dependencies resolved: 12
   └─ Conflict resolution: 2
✅ config/function.json (28 lines)
✅ config/host.json (15 lines)
✅ config/local.settings.json (12 lines)
✅ src/main/resources/application.properties (24 lines)
```

---

### Phase 6: Testing Migration

**Step 6.1: Migrate Test Suite**

```
🧪 TESTING MIGRATION PHASE
├─ For each test file:
│  ├─ 1. Convert xUnit → JUnit 5
│  ├─ 2. Convert Moq → Mockito
│  ├─ 3. Update assertions
│  └─ 4. Generate .java test file
└─ Show test coverage
```

**Progress display:**

```
🧪 MIGRATING TESTS
=====================================
[███████░░░░░░░░░░░░] 35% (3/8 test files)

✅ PaymentProcessorTests.cs → PaymentProcessorTests.java
✅ ModelsTests.cs → ModelsTests.java
⏳ IntegrationTests.cs (in progress...)
⬜ E2ETests.cs (pending)

Test Coverage: 95%
Estimated Time: 20 minutes
```

**Output format:**

```
✅ TESTS MIGRATED
=====================================
✅ src/test/java/com/example/payment/PaymentProcessorTests.java
   └─ Test Methods: 8
   └─ Assertions: 24
   └─ Mocks: 3
   └─ Coverage: 95%
```

---

### Phase 7: Validation & Quality Checks

**Step 7.1: Validate Migration**

```
✅ VALIDATION PHASE
├─ 1. Syntax validation
├─ 2. Compile Java code
├─ 3. Run unit tests
├─ 4. Check coverage
└─ 5. Security scan
```

**Output format:**

```
✅ VALIDATION RESULTS
=====================================
[✓] Syntax Check: PASSED
[✓] Java Compilation: SUCCESS (0 errors, 0 warnings)
[✓] Unit Tests: PASSED (35/35 tests)
[✓] Test Coverage: 95% (Target: 85%) ✅
[✓] Security Scan: PASSED (0 critical issues)

Overall Status: ✅ READY FOR PRODUCTION
```

---

### Phase 8: Documentation & Reporting

**Step 8.1: Generate Documentation**

```
📚 DOCUMENTATION PHASE
├─ 1. Generate MIGRATION_REPORT.md
├─ 2. Generate IMPLEMENTATION_GUIDE.md
├─ 3. Generate API_DOCUMENTATION.md
├─ 4. Create architecture diagrams
└─ 5. Create deployment guide
```

**Output format:**

```
📚 DOCUMENTATION GENERATED
=====================================
✅ docs/MIGRATION_REPORT.md (250 lines)
   └─ Executive Summary
   └─ File-by-file changes
   └─ Dependency mapping
   └─ Performance analysis
   └─ Lessons learned

✅ docs/IMPLEMENTATION_GUIDE.md (180 lines)
   └─ Setup instructions
   └─ Build process
   └─ Deployment steps
   └─ Troubleshooting

✅ docs/API_DOCUMENTATION.md (120 lines)
   └─ Endpoint documentation
   └─ Request/Response examples
   └─ Error codes

✅ README.md (Root directory)
   └─ Quick start guide
   └─ Project structure
   └─ How to run
```

---

### Phase 9: Final Summary & Next Steps

**Step 9.1: Complete Migration**

```
🎉 MIGRATION COMPLETE
═══════════════════════════════════════

📊 MIGRATION STATISTICS
├─ Files Migrated: 12/12 ✅
├─ Lines of Code: 2,847
├─ Test Coverage: 95%
├─ Build Status: ✅ SUCCESS
├─ Time Taken: 45 minutes
└─ Status: ✅ READY FOR DEPLOYMENT

📂 MIGRATED PROJECT STRUCTURE
PaymentFunction-migrated/
├── src/main/java/com/example/payment/
│   ├── PaymentProcessor.java ✅
│   ├── PaymentService.java ✅
│   └── models/ ✅
├── src/test/java/com/example/payment/ ✅
├── src/main/resources/
│   └── application.properties ✅
├── config/
│   ├── pom.xml ✅
│   ├── function.json ✅
│   ├── host.json ✅
│   └── local.settings.json ✅
├── docs/ ✅
├── README.md ✅
└── .gitignore ✅

📋 NEXT STEPS:
1️⃣  Review the migration report: docs/MIGRATION_REPORT.md
2️⃣  Read implementation guide: docs/IMPLEMENTATION_GUIDE.md
3️⃣  Build the project: cd PaymentFunction-migrated && mvn clean package
4️⃣  Run tests: mvn test
5️⃣  Deploy to Azure: func azure functionapp publish <FunctionAppName>

🎯 DEPLOYMENT CHECKLIST:
□ Code review completed
□ All tests passing
□ Performance validated
□ Security scan passed
□ Staging deployment successful
□ UAT testing completed
□ Ready for production deployment
```

---

## Complete Workflow Timeline

```
START: 10:00 AM
│
├─ 10:00 - 10:05: Phase 1 - Discovery (5 min)
│  └─ List project, identify files
│
├─ 10:05 - 10:10: Phase 2 - Directory Setup (5 min)
│  └─ Create migrated directory structure
│
├─ 10:10 - 10:20: Phase 3 - Analysis (10 min)
│  └─ Deep code analysis, plan migration
│
├─ 10:20 - 10:45: Phase 4 - Code Migration (25 min)
│  └─ Translate all .cs to .java files
│
├─ 10:45 - 10:55: Phase 5 - Configuration (10 min)
│  └─ Generate pom.xml, configs, etc
│
├─ 10:55 - 11:15: Phase 6 - Testing (20 min)
│  └─ Migrate and run all tests
│
├─ 11:15 - 11:20: Phase 7 - Validation (5 min)
│  └─ Compile, test, security check
│
├─ 11:20 - 11:25: Phase 8 - Documentation (5 min)
│  └─ Generate guides and reports
│
└─ 11:25: Phase 9 - Complete (✅ READY)
   └─ Project ready for deployment

TOTAL TIME: ~85 minutes
```

---

## How to Use This Prompt

**Command:**

```
@csharp-to-java-migrator migra todo automaticamente
```

Or:

```
@csharp-to-java-migrator #execute orquesta migración completa
```

**What happens:**

1. Agent explores your project
2. Creates organized migrated directory
3. Analyzes code and creates plan
4. Migrates all source files
5. Migrates configuration
6. Migrates tests
7. Validates everything
8. Generates complete documentation
9. Shows next steps

---

## Expected Outcomes

After running this orchestration, you'll have:

✅ **Complete Java project** in `[ProjectName]-migrated/`  
✅ **pom.xml** with all Maven dependencies  
✅ **Migrated source code** (all .cs → .java)  
✅ **Migrated tests** (xUnit → JUnit 5)  
✅ **Configuration files** (appsettings → properties)  
✅ **Azure Functions config** (function.json, host.json)  
✅ **Complete documentation** (guides, reports, API docs)  
✅ **Build-ready project** (mvn package ready)  
✅ **Deployment checklist** (for production)

---

## Tags

#orchestration #full-migration #automation #progress-tracking #end-to-end
