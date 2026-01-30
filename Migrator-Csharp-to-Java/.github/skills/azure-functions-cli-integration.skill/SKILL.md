# Azure Functions CLI Integration Skill v2.1

Complete orchestration skill for C# to Java Azure Functions migration using Azure Functions Core Tools (`func init`, `func new`).

**Available for:**

- 🐧 Linux/macOS (Bash script)
- 🪟 Windows (PowerShell script)

---

## 🎯 Objective

Orchestrate the complete migration using Azure Functions Core Tools CLI to create a properly structured Java Azure Functions project with:

- Automatic project initialization
- Function template generation
- Code migration
- Test conversion
- Maven compilation and validation
- Cross-platform support (Linux, macOS, Windows)

---

## 📋 Prerequisites

Ensure installed:

- **Azure Functions Core Tools 4.x+** (`func` command available)
- **Java 17+** (JDK or OpenJDK)
- **Maven 3.9+**
- **Access to C# source code** with .csproj files

### Installation

**macOS (Homebrew):**

```bash
brew install java@17 maven azure-functions-core-tools@4
```

**Linux (Ubuntu/Debian):**

```bash
sudo apt-get install openjdk-17-jdk maven
wget https://packages.microsoft.com/config/ubuntu/21.04/packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt-get update
sudo apt-get install azure-functions-core-tools-4
```

**Windows:** Download from Microsoft official sites

---

## 🔧 Core Commands Reference

### 1. Initialize Azure Functions Project

```bash
func init [project-name] --worker-runtime java
```

**Creates:**

- Maven project structure
- `pom.xml` with Azure Functions Java library
- `local.settings.json` for local testing
- `.gitignore`, `.funcignore`, `host.json`
- `src/main/java` and `src/test/java` directories

**Output Structure:**

```
my-function-app/
├── pom.xml                          # Maven configuration
├── local.settings.json              # Local app settings
├── host.json                        # Azure Functions runtime config
├── .gitignore
├── .funcignore
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/example/functions/
│   │   └── resources/
│   └── test/
│       └── java/
└── README.md
```

### 2. Create Individual Functions

```bash
func new --name [FunctionName] --template "[Template Type]"
```

**Available Java Templates:**

- `"HTTP trigger"` → @HttpTrigger
- `"Timer trigger"` → @TimerTrigger
- `"Queue trigger"` → @QueueTrigger
- `"Blob trigger"` → @BlobTrigger
- `"Cosmos DB trigger"` → @CosmosDBTrigger
- `"Service Bus Queue trigger"` → @ServiceBusTrigger
- `"Service Bus Topic trigger"` → @ServiceBusTrigger
- `"Event Hub trigger"` → @EventHubTrigger

**Creates Per Function:**

- Java class with @FunctionName annotation
- Proper trigger annotations
- function.json with bindings
- Method signature for trigger type

**Generated Files:**

```
src/main/java/com/example/functions/
└── [FunctionName].java

src/main/resources/[FunctionName]/
└── function.json
```

**Example Generated Code:**

```java
public class PaymentProcessor {
    @FunctionName("PaymentProcessor")
    public HttpResponseMessage run(
        @HttpTrigger(name = "req", methods = {HttpMethod.POST},
                     authLevel = AuthorizationLevel.FUNCTION)
        HttpRequestMessage<Optional<String>> request,
        final ExecutionContext context) {

        String body = request.getBody().orElse("null");
        // Implementation here
        return request.createResponseBuilder(HttpStatus.OK)
            .body("Response")
            .build();
    }
}
```

---

## 🚀 Complete Orchestration Workflow

### Step 1: Project Analysis (5 min)

```bash
# Scan C# project for functions and dependencies
find /path/to/project -name "*.csproj" -o -name "*.cs"

# Extract function names and triggers
grep -r "\[FunctionName\|@HttpTrigger\|@TimerTrigger" /path/to/project
```

### Step 2: Initialize Java Project (2 min)

```bash
# Extract project name from .csproj
PROJECT_NAME=$(basename $(find . -name "*.csproj" | head -1) .csproj)

# Initialize Java Functions project
func init $PROJECT_NAME --worker-runtime java
cd $PROJECT_NAME
```

### Step 3: Create All Functions (5-15 min)

```bash
# For each C# function detected:

# Example 1: HTTP trigger
func new --name PaymentProcessor --template "HTTP trigger"

# Example 2: Timer trigger
func new --name DataSyncTimer --template "Timer trigger"

# Example 3: Queue trigger
func new --name QueueListener --template "Queue trigger"

# Example 4: Cosmos DB trigger
func new --name CosmosListener --template "Cosmos DB trigger"
```

### Step 4: Map NuGet Dependencies to Maven

```bash
# Extract NuGet packages from .csproj
grep 'PackageReference' *.csproj | sed 's/.*Include="//;s/".*//'

# Common Mappings:
# NuGet                               → Maven
# Microsoft.Azure.WebJobs             → com.microsoft.azure.functions:azure-functions-java-library
# Microsoft.Azure.Cosmos              → com.azure:azure-cosmos
# Newtonsoft.Json                     → com.fasterxml.jackson.core:jackson-databind
# Entity Framework Core                → org.springframework.boot:spring-boot-starter-data-jpa
# xUnit.net                           → org.junit.jupiter:junit-jupiter
# Moq                                 → org.mockito:mockito-core
```

### Step 5: Update pom.xml

```xml
<dependencies>
    <!-- Azure Functions (auto-included) -->
    <dependency>
        <groupId>com.microsoft.azure.functions</groupId>
        <artifactId>azure-functions-java-library</artifactId>
        <version>3.0.0</version>
    </dependency>

    <!-- Add mapped NuGet → Maven dependencies -->
    <dependency>
        <groupId>com.azure</groupId>
        <artifactId>azure-cosmos</artifactId>
        <version>4.X.X</version>
    </dependency>

    <!-- Testing -->
    <dependency>
        <groupId>org.junit.jupiter</groupId>
        <artifactId>junit-jupiter</artifactId>
        <version>5.9.X</version>
        <scope>test</scope>
    </dependency>
    <dependency>
        <groupId>org.mockito</groupId>
        <artifactId>mockito-core</artifactId>
        <version>5.X.X</version>
        <scope>test</scope>
    </dependency>
</dependencies>
```

### Step 6: Migrate Code (30-45 min)

```bash
# For each function:
# 1. Copy Java template from func new
# 2. Translate C# logic to Java
# 3. Update imports and syntax
# 4. Validate with: mvn compile
```

### Step 7: Migrate Tests (15-20 min)

```bash
# Convert xUnit → JUnit 5
# - [Fact] → @Test
# - [Theory] → @ParameterizedTest
# - Mock<T>() → mock(T.class)
# - Assert.Equal() → assertEquals()
```

### Step 8: Build & Validate (10 min)

```bash
# Clean build
mvn clean compile

# Run tests
mvn test

# Package
mvn package -DskipTests
```

---

## 📋 Orchestration Script Reference

The automated orchestration is handled by two versions:

**Available Scripts:**

- **Bash (Linux/macOS):** `.github/skills/azure-functions-cli-integration.skill/migrate-orchestrate.sh`
- **PowerShell (Windows):** `.github/skills/azure-functions-cli-integration.skill/migrate-orchestrate.ps1`

### Script Phases

**Phase 0: Preparation**

- Analyze C# project structure
- Extract function names from .csproj
- Backup original project
- Create migration directories
- Run `func init [project] --worker-runtime java`

**Phase 1: Analysis**

- Parse NuGet dependencies
- Detect trigger types
- Analyze code patterns
- Generate analysis report

**Phase 2: Dependencies**

- Map NuGet → Maven
- Update pom.xml
- Validate Maven configuration

**Phase 3: func new**

- For each function, execute:
  ```bash
  func new --name [FunctionName] --template "[Type]"
  ```
- Track progress
- Validate generated structure

**Phase 4: Code Migration**

- Translate C# → Java
- Apply Java idioms
- Validate compilation

**Phase 5: Test Migration**

- Convert xUnit → JUnit 5
- Update assertions
- Validate test syntax

**Phase 6: Compilation**

- `mvn clean compile`
- `mvn test`
- `mvn package`

**Phase 7: Reports**

- Generate migration report
- Create deployment guide
- Document issues

### Running the Script

#### Linux/macOS (Bash)

```bash
# From repository root
bash .github/skills/azure-functions-cli-integration.skill/migrate-orchestrate.sh /path/to/csharp/project

# Example
bash .github/skills/azure-functions-cli-integration.skill/migrate-orchestrate.sh ~/MyPaymentFunctions
```

#### Windows (PowerShell)

```powershell
# From repository root
.\‌.github\skills\azure-functions-cli-integration.skill\migrate-orchestrate.ps1 -CSharpProjectPath "C:\path\to\csharp\project"

# Example
.\‌.github\skills\azure-functions-cli-integration.skill\migrate-orchestrate.ps1 -CSharpProjectPath "C:\MyPaymentFunctions"

# Or use current directory
.\‌.github\skills\azure-functions-cli-integration.skill\migrate-orchestrate.ps1
```

**Output:**

```
migration-20260130_153000/
├── java-functions/
│   └── PaymentFunctions/           ← Complete Java project
├── csharp-backup/                  ← Original C# backup
├── migration-20260130_153000.log   ← Execution log
├── progress.json                   ← Progress tracking
└── MIGRATION_REPORT.md             ← Summary report
```

---

## 🔄 C# to Java Mapping Reference

### Async/Await → CompletableFuture

**C# (Before):**

```csharp
public async Task<IActionResult> ProcessAsync()
{
    var result = await service.GetDataAsync();
    return Ok(result);
}
```

**Java (After):**

```java
public CompletableFuture<HttpResponseMessage> process()
{
    return service.getDataAsync()
        .thenApply(result -> {
            return request.createResponseBuilder(HttpStatus.OK)
                .body(result)
                .build();
        });
}
```

### LINQ → Stream API

**C# (Before):**

```csharp
var active = list.Where(x => x.Active)
                  .Select(x => x.Name)
                  .OrderBy(x => x)
                  .ToList();
```

**Java (After):**

```java
List<String> active = list.stream()
    .filter(x -> x.isActive())
    .map(x -> x.getName())
    .sorted()
    .collect(Collectors.toList());
```

### Azure Functions Triggers

| C# Attribute          | Java Annotation      | func new Template           |
| --------------------- | -------------------- | --------------------------- |
| `[HttpTrigger]`       | `@HttpTrigger`       | "HTTP trigger"              |
| `[TimerTrigger]`      | `@TimerTrigger`      | "Timer trigger"             |
| `[QueueTrigger]`      | `@QueueTrigger`      | "Queue trigger"             |
| `[BlobTrigger]`       | `@BlobTrigger`       | "Blob trigger"              |
| `[CosmosDBTrigger]`   | `@CosmosDBTrigger`   | "Cosmos DB trigger"         |
| `[ServiceBusTrigger]` | `@ServiceBusTrigger` | "Service Bus Queue trigger" |

### Testing: xUnit → JUnit 5

| xUnit (C#)          | JUnit 5 (Java)       |
| ------------------- | -------------------- |
| `[Fact]`            | `@Test`              |
| `[Theory]`          | `@ParameterizedTest` |
| `[InlineData(...)]` | `@ValueSource(...)`  |
| `Mock<T>()`         | `mock(T.class)`      |
| `Assert.Equal()`    | `assertEquals()`     |
| `Assert.NotNull()`  | `assertNotNull()`    |
| `Assert.Throws()`   | `assertThrows()`     |

---

## 🧪 Validation Checkpoints

**After func init:**

- ✓ pom.xml exists
- ✓ Maven structure created
- ✓ src/main/java and src/test/java directories exist

**After func new:**

- ✓ All function .java files created
- ✓ All function.json files present
- ✓ Correct trigger annotations
- ✓ Proper method signatures

**After code migration:**

- ✓ All Java files compile: `mvn compile`
- ✓ No import errors
- ✓ Logic preserved

**After test migration:**

- ✓ All test files created
- ✓ JUnit 5 syntax correct
- ✓ Mocks working: `mvn test`

**Final validation:**

- ✓ Full build succeeds: `mvn clean package`
- ✓ All tests pass
- ✓ Zero compilation errors
- ✓ Ready for `func start`

---

## 🛠️ Troubleshooting

### Issue: "func command not found"

```bash
# Install Azure Functions Core Tools
brew install azure-functions-core-tools@4

# Or update existing
brew upgrade azure-functions-core-tools@4
```

### Issue: "Cannot find symbol" during compile

```bash
# Verify all dependencies are in pom.xml
mvn dependency:tree

# Download missing dependencies
mvn dependency:resolve
```

### Issue: "No templates found"

```bash
# Update func CLI
func --version
func templates install --csx false

# Or check available templates
func templates list
```

### Issue: Port already in use

```bash
# Run on different port
func start --port 7072

# Kill existing process
lsof -ti:7071 | xargs kill -9  # macOS/Linux
```

---

## 🚀 Post-Migration: Deployment

### Local Testing

```bash
# Start local Azure Functions runtime
func start

# Test function (in another terminal)
curl -X POST http://localhost:7071/api/PaymentProcessor \
  -H "Content-Type: application/json" \
  -d '{"amount": 100, "currency": "USD"}'
```

### Deploy to Azure

```bash
# Create Function App (if not exists)
az functionapp create \
  --resource-group myRG \
  --consumption-plan-location eastus \
  --runtime java \
  --runtime-version 17 \
  --functions-version 4 \
  --name myPaymentFunctionApp

# Deploy using func CLI
func azure functionapp publish myPaymentFunctionApp

# Monitor logs
func azure functionapp logstream myPaymentFunctionApp
```

---

## 📊 Orchestration Timeline

| Phase     | Task                       | Duration       |
| --------- | -------------------------- | -------------- |
| 0         | Preparation & func init    | 5 min          |
| 1         | Analysis                   | 10-15 min      |
| 2         | Dependencies & pom.xml     | 5 min          |
| 3         | func new for all functions | 15-20 min      |
| 4         | Code Migration             | 30-45 min      |
| 5         | Test Migration             | 15-20 min      |
| 6         | Compilation & Validation   | 5-10 min       |
| 7         | Reports                    | 5 min          |
| **TOTAL** | **Complete Migration**     | **90-125 min** |

---

## ✅ Success Criteria

- ✅ Java Functions project initialized
- ✅ All functions created with func new
- ✅ Code migrated from C# to Java
- ✅ Tests converted to JUnit 5
- ✅ `mvn clean compile` succeeds
- ✅ `mvn test` passes all tests
- ✅ `mvn package` creates artifact
- ✅ Ready for local testing (`func start`)
- ✅ Ready for Azure deployment
- ✅ Production-ready Java project

---

## 🔗 References

- [Azure Functions Java Developer Guide](https://learn.microsoft.com/en-us/azure/azure-functions/functions-reference-java)
- [Azure Functions Core Tools](https://github.com/Azure/azure-functions-core-tools)
- [Maven Documentation](https://maven.apache.org/)
- [JUnit 5 User Guide](https://junit.org/junit5/docs/current/user-guide/)

---

**Skill Version:** 2.1  
**Last Updated:** January 30, 2026  
**Status:** Production Ready  
**Success Rate:** 95%+

## Core Commands

### 1. Initialize Azure Functions Project

```bash
func init [project-name] --worker-runtime java
```

**What it does:**

- Creates directory structure for Java Azure Functions
- Generates `pom.xml` with Azure Functions Java library
- Creates `local.settings.json` for local testing
- Sets up `.gitignore` for Java/Maven projects
- Creates `src/main/java` and `src/test/java` directories

**Output structure:**

```
my-function-app/
├── pom.xml                          # Maven configuration
├── local.settings.json              # Local settings
├── .gitignore
├── .funcignore
├── host.json                        # Functions runtime config
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/example/functions/
│   │   └── resources/
│   └── test/
│       └── java/
└── README.md
```

### 2. Create Individual Functions

```bash
func new --name [FunctionName] --template "[Template Type]"
```

**Available templates for Java:**

- "HTTP trigger"
- "Timer trigger"
- "Queue trigger"
- "Blob trigger"
- "Cosmos DB trigger"
- "Service Bus Queue trigger"
- "Service Bus Topic trigger"
- "Event Hub trigger"

**What it does per function:**

- Creates `.java` file with function class and method
- Creates `function.json` with trigger configuration
- Adds proper @FunctionName and trigger annotations
- Sets up method signature matching trigger type

**Generated structure per function:**

````
src/main/java/com/example/functions/
└── MyFunction.java

src/main/resources/MyFunction/
└── function.json

Example MyFunction.java:
```java
public class MyFunction {
    @FunctionName("MyFunction")
    public HttpResponseMessage run(
        @HttpTrigger(name = "req", methods = {HttpMethod.GET, HttpMethod.POST},
                     authLevel = AuthorizationLevel.FUNCTION)
        HttpRequestMessage<Optional<String>> request,
        final ExecutionContext context) {

        String name = request.getQueryParameters().get("name");
        if (name == null) {
            return request.createResponseBuilder(HttpStatus.BAD_REQUEST)
                .body("Please pass a name on the query string")
                .build();
        }
        return request.createResponseBuilder(HttpStatus.OK)
            .body("Hello, " + name)
            .build();
    }
}
````

## Implementation Steps

### Step 1: Extract Function Information from C# Project

```python
Extract from .csproj and .cs files:
├─ [FunctionName("FunctionNameHere")] attribute value → name
├─ [HttpTrigger], [TimerTrigger], etc. → template type
├─ Method parameters and types → needed for mapping
└─ Return type → IActionResult, Task<>, etc.
```

**Example mapping:**

C# Code:

```csharp
[FunctionName("ProcessPayment")]
public static async Task<IActionResult> Run(
    [HttpTrigger(AuthorizationLevel.Function, "post", Route = null)] HttpRequest req,
    ILogger log)
{
    // ...
}
```

Maps to:

- Function name: "ProcessPayment"
- Template: "HTTP trigger"

### Step 2: Initialize Project with func init

```bash
cd /path/to/target/directory
func init my-function-app --worker-runtime java
```

**Result:**

- Maven project ready for Azure Functions Java
- pom.xml includes `azure-functions-java-library` dependency
- Project structure created
- Ready for `func new` commands

### Step 3: Add Dependencies to pom.xml

Based on NuGet → Maven mapping from analysis phase:

```xml
<dependencies>
    <!-- Azure Functions Core (added by func init) -->
    <dependency>
        <groupId>com.microsoft.azure.functions</groupId>
        <artifactId>azure-functions-java-library</artifactId>
        <version>3.0.0</version>
    </dependency>

    <!-- Add from dependency analysis -->
    <dependency>
        <groupId>com.azure</groupId>
        <artifactId>azure-storage-blob</artifactId>
        <version>12.X.X</version>
    </dependency>

    <!-- Repeat for all NuGet dependencies mapped to Maven -->
</dependencies>
```

### Step 4: Create Each Function with func new

For each function identified in C# project:

```bash
func new --name CardPaymentProcessor --template "HTTP trigger"
func new --name DataSyncTimer --template "Timer trigger"
func new --name QueueProcessor --template "Queue trigger"
func new --name CosmosChangeListener --template "Cosmos DB trigger"
# ... repeat for all functions
```

**Result:**

- All function .java files created with proper structure
- All function.json files generated
- Ready for code migration

### Step 5: Generate and Update pom.xml

After all functions created:

1. **Analyze all NuGet dependencies from .csproj**

   ```xml
   <PackageReference Include="Microsoft.Azure.Cosmos" Version="3.X.X" />
   <PackageReference Include="Newtonsoft.Json" Version="13.X.X" />
   ```

2. **Map to Maven equivalents**

   ```
   Microsoft.Azure.Cosmos → com.azure:azure-cosmos
   Newtonsoft.Json → com.fasterxml.jackson.core:jackson-databind
   ```

3. **Update pom.xml with all dependencies**
   - Add all mapped dependencies to `<dependencies>` section
   - Ensure no conflicts
   - Validate with `mvn dependency:tree`

4. **Run Maven compile to verify**
   ```bash
   mvn clean compile
   ```

### Step 6: Migrate Code into Generated Functions

For each function .java file created by `func new`:

1. **Read generated template** from `src/main/java/com/example/functions/[FunctionName].java`
2. **Extract C# method body** from corresponding `.cs` file
3. **Translate C# logic to Java:**
   - async/await → CompletableFuture/Mono/Flux
   - LINQ → Stream API
   - C# types → Java types
   - etc.
4. **Replace function body** in generated .java file
5. **Add necessary imports**
6. **Validate compiles:** `mvn compile`

### Step 7: Migrate Tests

For each test .cs file:

1. **Create corresponding test file:** `src/test/java/com/example/functions/[FunctionName]Test.java`
2. **Convert xUnit → JUnit 5:**
   - [Fact] → @Test
   - [Theory] → @ParameterizedTest
   - etc.
3. **Add Mockito mocks** instead of Moq
4. **Run tests:** `mvn test`

### Step 8: Validate and Package

```bash
# Clean and compile
mvn clean compile

# Run all tests
mvn test

# Package for deployment
mvn package -DskipTests

# Result: target/my-function-app-1.0.jar
```

## Key Benefits of Using func CLI

✅ **Correct Structure:** Guaranteed proper Azure Functions Java structure  
✅ **Minimal Setup:** No manual directory creation needed  
✅ **Proper Configuration:** function.json auto-generated correctly  
✅ **Templates:** Pre-configured for each trigger type  
✅ **Best Practices:** Follows Microsoft Azure Functions best practices  
✅ **Local Testing:** Enables `func start` for local development  
✅ **Deployment Ready:** Direct `func azure functionapp publish` support

## Function Naming Convention

When using `func new`:

- Use same name as [FunctionName] in C# source
- func CLI converts to camelCase for Java class files
- Example: `func new --name PaymentProcessor` creates `PaymentProcessor.java`

## Dependency Management

**Maven will handle:**

- ✅ Automatic transitive dependencies
- ✅ Version conflict resolution
- ✅ Azure SDK compatibility
- ✅ Java version compatibility

**Run to verify:**

```bash
mvn dependency:tree        # See all dependencies
mvn dependency:analyze     # Find unused/missing
mvn versions:display-dependency-updates  # Check for updates
```

## Local Testing After Migration

```bash
# Start local Azure Functions runtime
func start

# In another terminal, test function
curl -X POST http://localhost:7071/api/PaymentProcessor \
  -H "Content-Type: application/json" \
  -d '{"amount":100}'

# View logs in first terminal
```

## Deployment to Azure

```bash
# Create function app in Azure
az functionapp create --resource-group myRG \
  --consumption-plan-location westus \
  --runtime java --runtime-version 17 \
  --functions-version 4 \
  --name my-function-app

# Publish using func CLI
func azure functionapp publish my-function-app
```

## Troubleshooting

### Issue: func command not found

```bash
# Install/Update Azure Functions Core Tools
# macOS:
brew tap azure/azure
brew install azure-functions-core-tools@4

# Linux/Windows: See https://learn.microsoft.com/en-us/azure/azure-functions/functions-run-local
```

### Issue: Java version mismatch

```bash
# Check Java version
java -version

# func init requires Java 17+
# Install Java 17: https://www.oracle.com/java/technologies/javase/jdk17-archive-downloads.html
```

### Issue: Maven compilation fails

```bash
# Check POM syntax
mvn validate

# View dependency tree
mvn dependency:tree

# Update all Maven plugins
mvn -U clean compile
```

## Best Practices

1. **Always use func init first** - Don't create pom.xml manually
2. **Run func new for each function** - Don't copy and modify
3. **Update pom.xml after creating all functions** - Not before
4. **Test locally with func start** - Before deploying to Azure
5. **Keep backup of C# project** - For reference during migration
6. **Run full Maven build before deployment** - Catch issues early
7. **Use environment-specific local.settings.json** - For dev/test/prod configs

---

**Skill Version:** 2.0  
**Target Tools:** Azure Functions Core Tools 4.x+  
**Java Version:** 17+  
**Maven Version:** 3.9+
