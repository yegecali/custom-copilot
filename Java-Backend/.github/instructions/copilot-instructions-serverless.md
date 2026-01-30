# GitHub Copilot Instructions - Serverless Functions

> **Serverless Functions**: Use alongside `copilot-instructions-java.md` for pure Java standards.
> These instructions apply to AWS Lambda, Azure Functions, Google Cloud Functions, etc.

## General Serverless Principles

### Core Requirements
- **Cold Start Optimization**: Minimize initialization time
- **Stateless**: Functions must be stateless
- **Idempotent**: Handle retries gracefully
- **Resource Efficient**: Minimize memory and execution time
- **Fail Fast**: Quick error detection and handling

### Common Patterns Across Platforms
```java
// ✅ PERFECT: Serverless function structure
public class AccountFunction {
    
    // Initialize dependencies ONCE (outside handler)
    private static final ObjectMapper OBJECT_MAPPER = new ObjectMapper()
        .registerModule(new JavaTimeModule());
    
    private static final AccountService ACCOUNT_SERVICE = initializeService();
    
    // Handler method - invoked on each request
    public Response handleRequest(Request request, Context context) {
        String requestId = context.getRequestId();
        
        try {
            // Process request
            AccountDto result = ACCOUNT_SERVICE.processAccount(request);
            
            return new Response(200, result);
            
        } catch (ValidationException e) {
            context.getLogger().log("Validation failed: " + e.getMessage());
            return new Response(400, new ErrorResponse("VALIDATION_ERROR", e.getMessage()));
            
        } catch (Exception e) {
            context.getLogger().log("Unexpected error: " + e.getMessage());
            return new Response(500, new ErrorResponse("INTERNAL_ERROR", "Processing failed"));
        }
    }
    
    private static AccountService initializeService() {
        // Initialize heavy objects once
        // Load configuration, establish connections, etc.
        return new AccountService();
    }
}
```

## AWS Lambda

### Lambda Handler (Java 17+)
```java
// ✅ PERFECT: AWS Lambda handler
public class CreateAccountLambda implements RequestHandler<APIGatewayProxyRequestEvent, APIGatewayProxyResponseEvent> {
    
    private static final Logger log = LoggerFactory.getLogger(CreateAccountLambda.class);
    private static final ObjectMapper MAPPER = new ObjectMapper()
        .registerModule(new JavaTimeModule());
    
    // Initialize outside handler for reuse across invocations
    private static final AccountService ACCOUNT_SERVICE = new AccountService();
    
    @Override
    public APIGatewayProxyResponseEvent handleRequest(
            APIGatewayProxyRequestEvent request, 
            Context context) {
        
        log.info("Processing request: requestId={}", context.getRequestId());
        
        try {
            // Parse request body
            CreateAccountRequest accountRequest = MAPPER.readValue(
                request.getBody(), 
                CreateAccountRequest.class
            );
            
            // Validate
            validateRequest(accountRequest);
            
            // Process
            AccountDto account = ACCOUNT_SERVICE.createAccount(accountRequest);
            
            // Build response
            return new APIGatewayProxyResponseEvent()
                .withStatusCode(201)
                .withHeaders(Map.of(
                    "Content-Type", "application/json",
                    "X-Request-ID", context.getRequestId()
                ))
                .withBody(MAPPER.writeValueAsString(account));
                
        } catch (ValidationException e) {
            log.warn("Validation failed: {}", e.getMessage());
            return buildErrorResponse(400, "VALIDATION_ERROR", e.getMessage());
            
        } catch (Exception e) {
            log.error("Unexpected error", e);
            return buildErrorResponse(500, "INTERNAL_ERROR", "Processing failed");
        }
    }
    
    private void validateRequest(CreateAccountRequest request) {
        if (request.customerId() == null || request.customerId().isBlank()) {
            throw new ValidationException("Customer ID is required");
        }
        if (request.initialBalance().compareTo(BigDecimal.ZERO) < 0) {
            throw new ValidationException("Initial balance cannot be negative");
        }
    }
    
    private APIGatewayProxyResponseEvent buildErrorResponse(
            int statusCode, 
            String code, 
            String message) {
        try {
            ErrorResponse error = new ErrorResponse(code, message, Instant.now());
            return new APIGatewayProxyResponseEvent()
                .withStatusCode(statusCode)
                .withHeaders(Map.of("Content-Type", "application/json"))
                .withBody(MAPPER.writeValueAsString(error));
        } catch (Exception e) {
            return new APIGatewayProxyResponseEvent()
                .withStatusCode(500)
                .withBody("{\"error\":\"Internal error\"}");
        }
    }
}
```

### Lambda with DynamoDB
```java
// ✅ PERFECT: Lambda with DynamoDB
public class GetAccountLambda implements RequestHandler<APIGatewayProxyRequestEvent, APIGatewayProxyResponseEvent> {
    
    private static final Logger log = LoggerFactory.getLogger(GetAccountLambda.class);
    
    // Initialize DynamoDB client once
    private static final DynamoDbClient DYNAMO_CLIENT = DynamoDbClient.builder()
        .region(Region.of(System.getenv("AWS_REGION")))
        .build();
    
    private static final String TABLE_NAME = System.getenv("ACCOUNTS_TABLE");
    
    @Override
    public APIGatewayProxyResponseEvent handleRequest(
            APIGatewayProxyRequestEvent request, 
            Context context) {
        
        String accountId = request.getPathParameters().get("accountId");
        
        try {
            // Query DynamoDB
            GetItemResponse response = DYNAMO_CLIENT.getItem(GetItemRequest.builder()
                .tableName(TABLE_NAME)
                .key(Map.of("accountId", AttributeValue.builder().s(accountId).build()))
                .build());
            
            if (!response.hasItem()) {
                return new APIGatewayProxyResponseEvent()
                    .withStatusCode(404)
                    .withBody("{\"error\":\"Account not found\"}");
            }
            
            // Convert to DTO
            AccountDto account = fromDynamoItem(response.item());
            
            return new APIGatewayProxyResponseEvent()
                .withStatusCode(200)
                .withHeaders(Map.of("Content-Type", "application/json"))
                .withBody(new ObjectMapper().writeValueAsString(account));
                
        } catch (Exception e) {
            log.error("Error retrieving account", e);
            return new APIGatewayProxyResponseEvent()
                .withStatusCode(500)
                .withBody("{\"error\":\"Internal error\"}");
        }
    }
    
    private AccountDto fromDynamoItem(Map<String, AttributeValue> item) {
        return new AccountDto(
            item.get("accountId").s(),
            item.get("customerId").s(),
            new BigDecimal(item.get("balance").n())
        );
    }
}
```

### Lambda with SQS Event
```java
// ✅ PERFECT: Lambda processing SQS messages
public class ProcessTransactionLambda implements RequestHandler<SQSEvent, Void> {
    
    private static final Logger log = LoggerFactory.getLogger(ProcessTransactionLambda.class);
    private static final ObjectMapper MAPPER = new ObjectMapper();
    
    private static final TransactionService TRANSACTION_SERVICE = new TransactionService();
    
    @Override
    public Void handleRequest(SQSEvent event, Context context) {
        
        for (SQSEvent.SQSMessage message : event.getRecords()) {
            try {
                // Parse message
                TransactionRequest request = MAPPER.readValue(
                    message.getBody(), 
                    TransactionRequest.class
                );
                
                // Process (idempotent!)
                TRANSACTION_SERVICE.processTransaction(request);
                
                log.info("Transaction processed: messageId={}, transactionId={}", 
                    message.getMessageId(), 
                    request.transactionId());
                
            } catch (Exception e) {
                log.error("Failed to process message: messageId={}", 
                    message.getMessageId(), e);
                // Message will be retried or sent to DLQ
                throw new RuntimeException("Processing failed", e);
            }
        }
        
        return null;
    }
}
```

## Azure Functions

### HTTP Trigger Function
```java
// ✅ PERFECT: Azure Function with HTTP trigger
public class CreateAccountFunction {
    
    private static final Logger log = LoggerFactory.getLogger(CreateAccountFunction.class);
    private static final ObjectMapper MAPPER = new ObjectMapper()
        .registerModule(new JavaTimeModule());
    
    private static final AccountService ACCOUNT_SERVICE = new AccountService();
    
    @FunctionName("CreateAccount")
    public HttpResponseMessage run(
            @HttpTrigger(
                name = "req",
                methods = {HttpMethod.POST},
                authLevel = AuthorizationLevel.FUNCTION,
                route = "accounts"
            ) HttpRequestMessage<Optional<String>> request,
            final ExecutionContext context) {
        
        context.getLogger().info("Processing account creation request");
        
        try {
            // Parse request
            CreateAccountRequest accountRequest = MAPPER.readValue(
                request.getBody().orElse("{}"), 
                CreateAccountRequest.class
            );
            
            // Validate
            validateRequest(accountRequest);
            
            // Process
            AccountDto account = ACCOUNT_SERVICE.createAccount(accountRequest);
            
            // Return response
            return request.createResponseBuilder(HttpStatus.CREATED)
                .header("Content-Type", "application/json")
                .body(account)
                .build();
                
        } catch (ValidationException e) {
            context.getLogger().warning("Validation failed: " + e.getMessage());
            return request.createResponseBuilder(HttpStatus.BAD_REQUEST)
                .body(new ErrorResponse("VALIDATION_ERROR", e.getMessage()))
                .build();
                
        } catch (Exception e) {
            context.getLogger().severe("Unexpected error: " + e.getMessage());
            return request.createResponseBuilder(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(new ErrorResponse("INTERNAL_ERROR", "Processing failed"))
                .build();
        }
    }
    
    private void validateRequest(CreateAccountRequest request) {
        if (request.customerId() == null || request.customerId().isBlank()) {
            throw new ValidationException("Customer ID is required");
        }
    }
}
```

### Queue Trigger Function
```java
// ✅ PERFECT: Azure Function with Queue trigger
public class ProcessTransactionFunction {
    
    private static final Logger log = LoggerFactory.getLogger(ProcessTransactionFunction.class);
    private static final ObjectMapper MAPPER = new ObjectMapper();
    
    private static final TransactionService TRANSACTION_SERVICE = new TransactionService();
    
    @FunctionName("ProcessTransaction")
    public void run(
            @QueueTrigger(
                name = "message",
                queueName = "transactions",
                connection = "AzureWebJobsStorage"
            ) String message,
            final ExecutionContext context) {
        
        context.getLogger().info("Processing transaction message");
        
        try {
            TransactionRequest request = MAPPER.readValue(message, TransactionRequest.class);
            
            // Process idempotently
            TRANSACTION_SERVICE.processTransaction(request);
            
            context.getLogger().info("Transaction processed: " + request.transactionId());
            
        } catch (Exception e) {
            context.getLogger().severe("Failed to process transaction: " + e.getMessage());
            throw new RuntimeException("Processing failed", e);
        }
    }
}
```

### Timer Trigger Function
```java
// ✅ PERFECT: Azure Function with Timer trigger
public class AccountMaintenanceFunction {
    
    private static final Logger log = LoggerFactory.getLogger(AccountMaintenanceFunction.class);
    private static final AccountMaintenanceService MAINTENANCE_SERVICE = new AccountMaintenanceService();
    
    @FunctionName("AccountMaintenance")
    public void run(
            @TimerTrigger(
                name = "timer",
                schedule = "0 0 2 * * *" // Daily at 2 AM
            ) String timerInfo,
            final ExecutionContext context) {
        
        context.getLogger().info("Starting account maintenance");
        
        try {
            int processed = MAINTENANCE_SERVICE.cleanupInactiveAccounts();
            context.getLogger().info("Processed " + processed + " inactive accounts");
            
        } catch (Exception e) {
            context.getLogger().severe("Maintenance failed: " + e.getMessage());
            throw new RuntimeException("Maintenance failed", e);
        }
    }
}
```

## Serverless Best Practices

### Cold Start Optimization
```java
// ✅ PERFECT: Minimize cold start time
public class OptimizedLambda implements RequestHandler<Request, Response> {
    
    // Static initialization - happens once per container
    private static final ObjectMapper MAPPER = createMapper();
    private static final HttpClient HTTP_CLIENT = createHttpClient();
    private static final AccountService SERVICE = createService();
    
    // Lazy initialization for expensive resources
    private static volatile DatabaseConnection dbConnection;
    
    @Override
    public Response handleRequest(Request request, Context context) {
        // Fast path - minimal overhead
        if (dbConnection == null) {
            synchronized (OptimizedLambda.class) {
                if (dbConnection == null) {
                    dbConnection = DatabaseConnection.create();
                }
            }
        }
        
        return SERVICE.process(request);
    }
    
    private static ObjectMapper createMapper() {
        return new ObjectMapper()
            .registerModule(new JavaTimeModule())
            .disable(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES);
    }
    
    private static HttpClient createHttpClient() {
        return HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(5))
            .build();
    }
    
    private static AccountService createService() {
        // Initialize service dependencies
        return new AccountService();
    }
}

// ❌ BAD: Initialization in handler
public Response handleRequest(Request request, Context context) {
    ObjectMapper mapper = new ObjectMapper(); // ❌ Created every invocation!
    HttpClient client = HttpClient.newHttpClient(); // ❌ Expensive!
    AccountService service = new AccountService(); // ❌ Recreated every time!
    return service.process(request);
}
```

### Idempotency
```java
// ✅ PERFECT: Idempotent function
public class IdempotentTransactionFunction 
        implements RequestHandler<TransactionRequest, Response> {
    
    private static final DynamoDbClient DYNAMO = DynamoDbClient.create();
    private static final String IDEMPOTENCY_TABLE = System.getenv("IDEMPOTENCY_TABLE");
    
    @Override
    public Response handleRequest(TransactionRequest request, Context context) {
        String idempotencyKey = request.idempotencyKey();
        
        // Check if already processed
        Optional<Response> cached = checkIdempotencyCache(idempotencyKey);
        if (cached.isPresent()) {
            context.getLogger().log("Request already processed: " + idempotencyKey);
            return cached.get();
        }
        
        try {
            // Process transaction
            Response response = processTransaction(request);
            
            // Store result for idempotency
            storeIdempotencyResult(idempotencyKey, response);
            
            return response;
            
        } catch (Exception e) {
            context.getLogger().log("Processing failed: " + e.getMessage());
            throw e;
        }
    }
    
    private Optional<Response> checkIdempotencyCache(String key) {
        try {
            GetItemResponse response = DYNAMO.getItem(GetItemRequest.builder()
                .tableName(IDEMPOTENCY_TABLE)
                .key(Map.of("idempotencyKey", AttributeValue.builder().s(key).build()))
                .build());
            
            if (response.hasItem()) {
                return Optional.of(deserializeResponse(response.item()));
            }
        } catch (Exception e) {
            // Log but don't fail - proceed with processing
        }
        return Optional.empty();
    }
    
    private void storeIdempotencyResult(String key, Response response) {
        try {
            DYNAMO.putItem(PutItemRequest.builder()
                .tableName(IDEMPOTENCY_TABLE)
                .item(Map.of(
                    "idempotencyKey", AttributeValue.builder().s(key).build(),
                    "response", AttributeValue.builder().s(serializeResponse(response)).build(),
                    "ttl", AttributeValue.builder().n(String.valueOf(
                        Instant.now().plus(24, ChronoUnit.HOURS).getEpochSecond()
                    )).build()
                ))
                .build());
        } catch (Exception e) {
            // Log but don't fail the request
        }
    }
}
```

### Environment Configuration
```java
// ✅ PERFECT: Configuration from environment
public class ConfigurableFunction implements RequestHandler<Request, Response> {
    
    // Read environment variables once
    private static final String DATABASE_URL = getEnv("DATABASE_URL");
    private static final String API_KEY = getEnv("API_KEY");
    private static final int MAX_RETRIES = Integer.parseInt(getEnv("MAX_RETRIES", "3"));
    private static final Duration TIMEOUT = Duration.ofSeconds(
        Long.parseLong(getEnv("TIMEOUT_SECONDS", "30"))
    );
    
    private static String getEnv(String key) {
        String value = System.getenv(key);
        if (value == null || value.isBlank()) {
            throw new IllegalStateException("Required environment variable not set: " + key);
        }
        return value;
    }
    
    private static String getEnv(String key, String defaultValue) {
        String value = System.getenv(key);
        return (value != null && !value.isBlank()) ? value : defaultValue;
    }
}
```

### Error Handling
```java
// ✅ PERFECT: Comprehensive error handling
public class RobustFunction implements RequestHandler<Request, Response> {
    
    private static final Logger log = LoggerFactory.getLogger(RobustFunction.class);
    
    @Override
    public Response handleRequest(Request request, Context context) {
        
        try {
            // Validate input
            validateRequest(request);
            
            // Process with retry
            return processWithRetry(request, 3);
            
        } catch (ValidationException e) {
            log.warn("Validation failed: {}", e.getMessage());
            return Response.error(400, "VALIDATION_ERROR", e.getMessage());
            
        } catch (ResourceNotFoundException e) {
            log.warn("Resource not found: {}", e.getMessage());
            return Response.error(404, "NOT_FOUND", e.getMessage());
            
        } catch (RetryableException e) {
            log.error("Retryable error after max attempts", e);
            // For async invocations, this will be retried by Lambda
            throw e;
            
        } catch (Exception e) {
            log.error("Unexpected error", e);
            return Response.error(500, "INTERNAL_ERROR", "Processing failed");
        }
    }
    
    private Response processWithRetry(Request request, int maxAttempts) {
        for (int attempt = 1; attempt <= maxAttempts; attempt++) {
            try {
                return doProcess(request);
            } catch (RetryableException e) {
                if (attempt == maxAttempts) {
                    throw e;
                }
                log.warn("Attempt {} failed, retrying...", attempt);
                sleep(Duration.ofMillis((long) Math.pow(2, attempt) * 100));
            }
        }
        throw new IllegalStateException("Should not reach here");
    }
    
    private void sleep(Duration duration) {
        try {
            Thread.sleep(duration.toMillis());
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new RuntimeException(e);
        }
    }
}
```

### Memory and Timeout Optimization
```java
// ✅ PERFECT: Resource-efficient function
public class EfficientFunction implements RequestHandler<Request, Response> {
    
    // Reuse connections and clients
    private static final HttpClient HTTP_CLIENT = HttpClient.newBuilder()
        .connectTimeout(Duration.ofSeconds(5))
        .build();
    
    @Override
    public Response handleRequest(Request request, Context context) {
        // Check remaining time
        int remainingMs = context.getRemainingTimeInMillis();
        if (remainingMs < 5000) {
            throw new RuntimeException("Insufficient time remaining");
        }
        
        // Process efficiently
        return processEfficiently(request);
    }
    
    private Response processEfficiently(Request request) {
        // Stream processing instead of loading all in memory
        // Use primitive types where possible
        // Close resources properly
        return new Response();
    }
}
```

## Serverless Best Practices Checklist

- [ ] Initialize heavy objects outside handler (static)
- [ ] Reuse HTTP clients, database connections
- [ ] Read environment variables once (static)
- [ ] Implement idempotency for retries
- [ ] Validate input early (fail fast)
- [ ] Handle errors gracefully
- [ ] Log with context (request ID, correlation ID)
- [ ] Monitor execution time and memory
- [ ] Use appropriate memory allocation
- [ ] Set reasonable timeouts
- [ ] Clean up resources (but don't close reusable connections)
- [ ] Minimize dependencies (faster cold starts)

---

**Serverless - Efficient, Scalable, Event-Driven** ⚡☁️
