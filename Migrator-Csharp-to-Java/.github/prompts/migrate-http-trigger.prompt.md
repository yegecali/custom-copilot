# 📡 Migrate HTTP Trigger Azure Function

## Objective

Convert a C# HTTP trigger Azure Function to Java while preserving all functionality and improving performance.

## Context

- Source: C# Azure Function with [HttpTrigger]
- Target: Java Azure Function with @HttpTrigger
- Must maintain API contract (routes, methods, status codes)
- Must handle all HTTP scenarios (GET, POST, PUT, DELETE, etc.)

## Instructions

You are an Azure Functions expert specializing in HTTP triggers. When migrating:

### 1. Understand the C# HTTP Trigger

```csharp
[FunctionName("GetUser")]
public static async Task<IActionResult> Run(
    [HttpTrigger(AuthorizationLevel.Function, "get", Route = "users/{id}")]
    HttpRequest req,
    string id,
    ILogger log)
{
    // Implementation
}
```

Identify:

- **Route Pattern**: `users/{id}`
- **HTTP Methods**: GET, POST, PUT, DELETE, PATCH
- **Route Parameters**: {id}, {name}, etc.
- **Query Parameters**: ?page=1&size=10
- **Request Body**: JSON, XML, Form data
- **Response Type**: IActionResult subclass
- **Status Codes**: 200 OK, 400 Bad Request, 404 Not Found, etc.
- **Headers**: Content-Type, Authorization, Custom headers
- **Authorization Level**: Anonymous, Function, Admin

### 2. Map to Java Azure Functions

#### Function Signature

```java
@FunctionName("GetUser")
public HttpResponseMessage run(
    @HttpTrigger(
        name = "req",
        methods = {HttpMethod.GET},
        authLevel = AuthorizationLevel.FUNCTION,
        route = "users/{id}")
    HttpRequestMessage<Optional<String>> request,
    @BindingName("id") String id,
    final ExecutionContext context) {

    final Logger logger = context.getLogger();
    // Implementation
}
```

#### Key Mappings

```
C# HttpRequest          → Java HttpRequestMessage<T>
IActionResult           → HttpResponseMessage
req.Body                → request.getBody()
req.Query["key"]        → request.getQueryParameters().get("key")
req.Headers["key"]      → request.getHeaders().get("key")
req.HttpContext.Request → request (properties)
new OkResult()          → request.createResponseBuilder(HttpStatus.OK)
new BadRequestResult()  → request.createResponseBuilder(HttpStatus.BAD_REQUEST)
```

### 3. HTTP Methods Handling

```java
// Single method
@HttpTrigger(methods = {HttpMethod.GET})

// Multiple methods
@HttpTrigger(methods = {HttpMethod.GET, HttpMethod.POST, HttpMethod.PUT})

// All methods
@HttpTrigger(methods = {
    HttpMethod.GET,
    HttpMethod.POST,
    HttpMethod.PUT,
    HttpMethod.DELETE,
    HttpMethod.PATCH
})
```

### 4. Request/Response Building

#### Reading Request Data

```java
// From route parameter
@BindingName("id") String id

// From query parameters
Map<String, String> queryParams = request.getQueryParameters();
String page = queryParams.get("page");

// From headers
HttpHeaders headers = request.getHeaders();
String token = headers.get("Authorization");

// From body (JSON)
PaymentRequest body = request.getBody()
    .orElse(new PaymentRequest());
```

#### Building Response

```java
// Success responses
request.createResponseBuilder(HttpStatus.OK)
    .header("Content-Type", "application/json")
    .body(result)
    .build();

// Error responses
request.createResponseBuilder(HttpStatus.BAD_REQUEST)
    .body("Invalid input")
    .build();

// 404 Not Found
request.createResponseBuilder(HttpStatus.NOT_FOUND)
    .build();

// With headers
request.createResponseBuilder(HttpStatus.OK)
    .header("Content-Type", "application/json")
    .header("X-Custom-Header", "value")
    .body(result)
    .build();
```

### 5. Content Negotiation

```java
// Detect request content type
String contentType = request.getHeaders().get("Content-Type");

if (contentType != null && contentType.contains("application/json")) {
    // Handle JSON
} else if (contentType != null && contentType.contains("application/xml")) {
    // Handle XML
}

// Set response content type
request.createResponseBuilder(HttpStatus.OK)
    .header("Content-Type", "application/json")
    .body(result)
    .build();
```

### 6. Error Handling

```java
try {
    validateInput(request);
    Result result = processRequest(request);

    return request.createResponseBuilder(HttpStatus.OK)
        .body(result)
        .build();
} catch (IllegalArgumentException ex) {
    context.getLogger().warning("Invalid input: " + ex.getMessage());
    return request.createResponseBuilder(HttpStatus.BAD_REQUEST)
        .body("Invalid input: " + ex.getMessage())
        .build();
} catch (ResourceNotFoundException ex) {
    return request.createResponseBuilder(HttpStatus.NOT_FOUND)
        .body("Resource not found")
        .build();
} catch (Exception ex) {
    context.getLogger().severe("Internal error: " + ex.getMessage());
    return request.createResponseBuilder(HttpStatus.INTERNAL_SERVER_ERROR)
        .body("Internal server error")
        .build();
}
```

### 7. CORS Configuration

#### C# (Startup.cs)

```csharp
public override void Configure(IFunctionsHostBuilder builder)
{
    builder.Services.AddCors(options =>
    {
        options.AddPolicy("AllowOrigin", policy =>
        {
            policy.AllowAnyOrigin();
        });
    });
}
```

#### Java (function.json)

```json
{
  "scriptFile": "target/classes/com/example/PaymentProcessor.class",
  "bindings": [
    {
      "authLevel": "function",
      "type": "httpTrigger",
      "direction": "in",
      "name": "req",
      "methods": ["get", "post"],
      "route": "payments/{id}",
      "corsPolicy": "allowAnyOrigin"
    },
    {
      "type": "http",
      "direction": "out",
      "name": "$return"
    }
  ]
}
```

## Migration Checklist

- ✅ Route pattern preserved
- ✅ HTTP methods mapped
- ✅ Route parameters extracted with @BindingName
- ✅ Query parameters handled
- ✅ Request headers processed
- ✅ Request body deserialized
- ✅ All status codes covered
- ✅ Response headers set correctly
- ✅ Error handling implemented
- ✅ Logging added
- ✅ CORS configured
- ✅ Authorization level set

## Template

```java
@FunctionName("[FunctionName]")
public HttpResponseMessage run(
    @HttpTrigger(
        name = "req",
        methods = {HttpMethod.GET, HttpMethod.POST},
        authLevel = AuthorizationLevel.FUNCTION,
        route = "[route-pattern]")
    HttpRequestMessage<Optional<String>> request,
    final ExecutionContext context) {

    final Logger logger = context.getLogger();
    logger.info("HTTP request received");

    try {
        // Validation
        // Business logic
        // Response building

        return request.createResponseBuilder(HttpStatus.OK)
            .header("Content-Type", "application/json")
            .body(result)
            .build();
    } catch (Exception ex) {
        logger.severe("Error: " + ex.getMessage());
        return request.createResponseBuilder(HttpStatus.INTERNAL_SERVER_ERROR)
            .body("Internal server error")
            .build();
    }
}
```

## Tags

#azure-functions #http-trigger #rest-api #migration #java
