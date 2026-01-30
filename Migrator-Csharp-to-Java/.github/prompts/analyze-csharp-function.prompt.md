# 🔍 Analyze C# Azure Function

## Objective

Perform a comprehensive analysis of a C# Azure Function to understand its structure, dependencies, triggers, and business logic before migration.

## Context

- User has a C# Azure Function that needs to be migrated to Java
- We need to understand ALL aspects before starting the migration
- Analysis output will guide the translation process

## Instructions

You are an expert C# and Azure Functions specialist. When analyzing a C# function:

### 1. Function Structure Analysis

- **Function Name**: What is it called?
- **Trigger Type**: HTTP, Timer, Queue, Cosmos, Blob, Service Bus?
- **Input Bindings**: What data flows in?
- **Output Bindings**: What data flows out?
- **Authorization Level**: Anonymous, Function, Admin?

### 2. Code Structure

- **Method Signature**: Parameters and return type
- **Dependencies**: NuGet packages used
- **Configuration**: appsettings references
- **Logging**: How logging is implemented
- **Error Handling**: Exception handling strategy

### 3. Business Logic

- **Core Algorithm**: What does the function do?
- **Data Processing**: How is data transformed?
- **External Calls**: Database, API, Azure services?
- **Calculations**: Any complex math or business rules?

### 4. Async Patterns

- **async/await**: Where is it used?
- **Task<T>**: Return types used
- **Await Points**: What operations are awaited?

### 5. Dependencies & References

```csharp
// List all:
- using statements
- NuGet packages
- Injected services
- Static methods
- Extension methods
```

### 6. Data Models

- **Input Models**: Classes for input
- **Output Models**: Classes for output
- **Attributes**: Data annotations ([JsonProperty], [Required], etc.)

### 7. Performance & Security Concerns

- **Performance Issues**: N+1 queries, blocking calls?
- **Security Issues**: Input validation, authentication, authorization?
- **Data Sanitization**: How is user input handled?

### 8. Configuration & Environment

- **Configuration Keys**: Environment variables used
- **Settings Structure**: How config is organized
- **Secrets**: Sensitive data handling

## Output Format

Return a structured analysis:

````markdown
# C# Function Analysis Report: [FunctionName]

## 1. Function Overview

- **Name**:
- **Trigger**:
- **Authorization**:
- **Purpose**:

## 2. Function Signature

\`\`\`csharp
[FunctionName("...")]
public static async Task<IActionResult> Run(...)
\`\`\`

## 3. Input Bindings

| Binding | Type | Purpose |
| ------- | ---- | ------- |
| ...     | ...  | ...     |

## 4. Output Bindings

| Binding | Type | Purpose |
| ------- | ---- | ------- |
| ...     | ...  | ...     |

## 5. Dependencies (NuGet)

- Package: Version
- Purpose:

## 6. Code Structure

### Methods

- Method name and purpose

### Classes/Models

- Model name and fields

### Key Logic

```csharp
// Critical code snippets
```
````

## 7. Async Pattern

- Uses: async/await
- Task<T> usage:

## 8. Configuration Requirements

- Environment Variables:
- Secrets Needed:
- Connection Strings:

## 9. Data Flow

```
Input → [Processing] → Output
```

## 10. Potential Migration Challenges

- ⚠️ Challenge 1
- ⚠️ Challenge 2

## 11. Recommendations for Java Migration

- ✅ Use Spring Boot 3.x
- ✅ Use CompletableFuture for async
- ✅ Use Jackson for JSON
- ... more recommendations

````

## Examples

### Example 1: HTTP Trigger Function
When analyzing an HTTP trigger like:
```csharp
[FunctionName("GetUserById")]
public static async Task<IActionResult> Run(
    [HttpTrigger(AuthorizationLevel.Function, "get", Route = "users/{id}")]
    HttpRequest req,
    int id,
    ILogger log)
{
    log.LogInformation($"Getting user {id}");
    var user = await database.GetUserAsync(id);
    return new OkObjectResult(user);
}
````

Identify:

- ✅ HTTP GET method
- ✅ Route parameter: id
- ✅ Async database call
- ✅ JSON response
- ✅ Logging present
- ⚠️ No error handling

## Key Points to Identify

1. **Trigger Binding**: What azure Functions trigger?
2. **Binding Attributes**: [HttpTrigger], [TimerTrigger], etc.
3. **Parameter Binding**: Route, Query, Body bindings
4. **Async Points**: Where is Task/async used?
5. **Dependencies**: What NuGet packages?
6. **Configuration**: What settings are used?
7. **Models**: What data classes?
8. **Error Handling**: Try-catch or exception filters?
9. **Logging**: ILogger usage?
10. **Authorization**: What auth level?

## Tools to Use

- Use #read to get the C# file content
- Use #search to find related files
- Use #edit to explore dependencies

## Tags

#csharp #azure-functions #migration #analysis #code-understanding
