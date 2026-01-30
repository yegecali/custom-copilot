# GitHub Copilot Instructions - Quarkus

> **Quarkus Specific**: Use alongside `copilot-instructions-java.md` for pure Java standards.
> These instructions apply ONLY to Quarkus projects.

## Quarkus Version
- **Minimum**: Quarkus 3.6.x
- **Java**: 17+ (Required for Quarkus 3.x)
- **Focus**: Cloud-native, supersonic subatomic Java

## Dependency Injection (CDI)

### Constructor Injection (MANDATORY)
```java
// ✅ PERFECT: Constructor injection (no @Inject needed on constructor)
@ApplicationScoped
public class TransactionService {
    private final TransactionRepository repository;
    private final EventPublisher eventPublisher;
    private final TransactionValidator validator;
    
    // Constructor injection - @Inject is optional if only one constructor
    public TransactionService(
            TransactionRepository repository,
            EventPublisher eventPublisher,
            TransactionValidator validator) {
        this.repository = repository;
        this.eventPublisher = eventPublisher;
        this.validator = validator;
    }
}

// ❌ BAD: Field injection
@ApplicationScoped
public class TransactionService {
    @Inject // ❌ Field injection
    TransactionRepository repository;
    
    @Inject // ❌ Not testable
    EventPublisher eventPublisher;
}
```

### Bean Scopes
```java
// ✅ PERFECT: Appropriate scopes
@ApplicationScoped  // Singleton - use for stateless services
public class AccountService { }

@RequestScoped      // New instance per request
public class RequestContext { }

@Dependent          // New instance per injection point
public class TransactionValidator { }

@Singleton          // Eager singleton (initialized at startup)
public class ConfigurationService {
    
    void onStart(@Observes StartupEvent event) {
        // Initialization logic
    }
}
```

## REST Endpoints (JAX-RS)

### Resource Classes
```java
// ✅ PERFECT: RESTful resource
@Path("/api/v1/accounts")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class AccountResource {
    
    private final AccountService accountService;
    
    public AccountResource(AccountService accountService) {
        this.accountService = accountService;
    }
    
    @POST
    public Response createAccount(@Valid CreateAccountRequest request) {
        AccountDto account = accountService.createAccount(request);
        
        URI location = UriBuilder.fromPath("/api/v1/accounts/{id}")
            .build(account.accountId());
        
        return Response.created(location).entity(account).build();
    }
    
    @GET
    @Path("/{accountId}")
    public Response getAccount(@PathParam("accountId") @NotBlank String accountId) {
        return accountService.findById(accountId)
            .map(account -> Response.ok(account).build())
            .orElse(Response.status(Response.Status.NOT_FOUND).build());
    }
    
    @PUT
    @Path("/{accountId}")
    public Response updateAccount(
            @PathParam("accountId") @NotBlank String accountId,
            @Valid UpdateAccountRequest request) {
        
        AccountDto updated = accountService.update(accountId, request);
        return Response.ok(updated).build();
    }
    
    @DELETE
    @Path("/{accountId}")
    public Response deleteAccount(@PathParam("accountId") @NotBlank String accountId) {
        accountService.delete(accountId);
        return Response.noContent().build();
    }
}
```

### Exception Mapping
```java
// ✅ PERFECT: Exception mappers
@Provider
public class AccountNotFoundExceptionMapper 
        implements ExceptionMapper<AccountNotFoundException> {
    
    private static final Logger log = LoggerFactory.getLogger(AccountNotFoundExceptionMapper.class);
    
    @Override
    public Response toResponse(AccountNotFoundException exception) {
        log.warn("Account not found: {}", exception.getAccountId());
        
        ErrorResponse error = new ErrorResponse(
            "ACCOUNT_NOT_FOUND",
            exception.getMessage(),
            Instant.now(),
            List.of()
        );
        
        return Response.status(Response.Status.NOT_FOUND)
            .entity(error)
            .build();
    }
}

@Provider
public class ValidationExceptionMapper 
        implements ExceptionMapper<ConstraintViolationException> {
    
    @Override
    public Response toResponse(ConstraintViolationException exception) {
        List<FieldError> fieldErrors = exception.getConstraintViolations().stream()
            .map(violation -> new FieldError(
                violation.getPropertyPath().toString(),
                violation.getMessage()
            ))
            .toList();
        
        ErrorResponse error = new ErrorResponse(
            "VALIDATION_ERROR",
            "Validation failed",
            Instant.now(),
            fieldErrors
        );
        
        return Response.status(Response.Status.BAD_REQUEST)
            .entity(error)
            .build();
    }
}

@Provider
public class GenericExceptionMapper implements ExceptionMapper<Exception> {
    
    private static final Logger log = LoggerFactory.getLogger(GenericExceptionMapper.class);
    
    @Override
    public Response toResponse(Exception exception) {
        log.error("Unexpected error occurred", exception);
        
        ErrorResponse error = new ErrorResponse(
            "INTERNAL_ERROR",
            "An unexpected error occurred",
            Instant.now(),
            List.of()
        );
        
        return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
            .entity(error)
            .build();
    }
}
```

## Reactive Programming (Mutiny)

### Reactive Resources
```java
// ✅ PERFECT: Reactive JAX-RS resource
@Path("/api/v1/accounts")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class ReactiveAccountResource {
    
    private final ReactiveAccountService accountService;
    
    public ReactiveAccountResource(ReactiveAccountService accountService) {
        this.accountService = accountService;
    }
    
    @POST
    public Uni<Response> createAccount(@Valid CreateAccountRequest request) {
        return accountService.createAccount(request)
            .map(account -> {
                URI location = UriBuilder.fromPath("/api/v1/accounts/{id}")
                    .build(account.accountId());
                return Response.created(location).entity(account).build();
            });
    }
    
    @GET
    @Path("/{accountId}")
    public Uni<Response> getAccount(@PathParam("accountId") String accountId) {
        return accountService.findById(accountId)
            .map(account -> Response.ok(account).build())
            .onItem().ifNull().continueWith(
                Response.status(Response.Status.NOT_FOUND).build()
            );
    }
    
    @GET
    public Multi<AccountDto> getAllAccounts(
            @QueryParam("customerId") String customerId) {
        
        if (customerId != null) {
            return accountService.findByCustomerId(customerId);
        }
        return accountService.findAll();
    }
}
```

### Reactive Service with Mutiny
```java
// ✅ PERFECT: Reactive service using Mutiny
@ApplicationScoped
public class ReactiveAccountService {
    
    private final ReactiveAccountRepository repository;
    private final EventPublisher eventPublisher;
    
    public ReactiveAccountService(
            ReactiveAccountRepository repository,
            EventPublisher eventPublisher) {
        this.repository = repository;
        this.eventPublisher = eventPublisher;
    }
    
    public Uni<AccountDto> createAccount(CreateAccountRequest request) {
        Account account = new Account(
            UUID.randomUUID().toString(),
            request.customerId(),
            request.initialBalance()
        );
        
        return repository.persist(account)
            .flatMap(saved -> publishEvent(saved).replaceWith(saved))
            .map(this::toDto)
            .ifNoItem().after(Duration.ofSeconds(30))
                .fail()
            .onFailure(TimeoutException.class)
                .transform(e -> new ServiceUnavailableException("Account creation timeout"))
            .retry().atMost(3);
    }
    
    public Uni<AccountDto> findById(String id) {
        return repository.findById(id)
            .map(this::toDto)
            .onItem().ifNull().failWith(new AccountNotFoundException(id));
    }
    
    public Multi<AccountDto> findByCustomerId(String customerId) {
        return repository.findByCustomerId(customerId)
            .map(this::toDto);
    }
    
    private Uni<Void> publishEvent(Account account) {
        AccountCreatedEvent event = new AccountCreatedEvent(
            account.getId(),
            account.getCustomerId(),
            Instant.now()
        );
        return eventPublisher.publish(event);
    }
    
    private AccountDto toDto(Account account) {
        return new AccountDto(
            account.getId(),
            account.getCustomerId(),
            account.getBalance()
        );
    }
}
```

### Mutiny Best Practices
```java
// ✅ GOOD: Proper Mutiny usage
public Uni<TransactionResult> processTransaction(TransactionRequest request) {
    return validateRequest(request)
        .flatMap(this::executeTransaction)
        .flatMap(this::publishEvent)
        .ifNoItem().after(Duration.ofSeconds(30)).fail()
        .onFailure(TimeoutException.class).recoverWithItem(this::handleTimeout)
        .onFailure().invoke(error -> log.error("Transaction failed", error));
}

// ✅ GOOD: Combining multiple Uni
public Uni<AccountSummary> getAccountSummary(String accountId) {
    Uni<Account> accountUni = accountRepository.findById(accountId);
    Uni<List<Transaction>> transactionsUni = transactionRepository.findByAccountId(accountId);
    Uni<Customer> customerUni = customerRepository.findByAccountId(accountId);
    
    return Uni.combine().all()
        .unis(accountUni, transactionsUni, customerUni)
        .asTuple()
        .map(tuple -> new AccountSummary(
            tuple.getItem1(),
            tuple.getItem2(),
            tuple.getItem3()
        ));
}

// ❌ BAD: Blocking in reactive code
public Uni<Account> getAccount(String id) {
    Account account = repository.findById(id).await().indefinitely(); // ❌ NEVER BLOCK!
    return Uni.createFrom().item(account);
}
```

## Data Access (Panache)

### Panache Repository Pattern
```java
// ✅ PERFECT: Panache repository
@ApplicationScoped
public class AccountRepository implements PanacheRepository<Account> {
    
    public List<Account> findByCustomerId(String customerId) {
        return list("customerId = ?1 and status = 'ACTIVE'", customerId);
    }
    
    public Optional<Account> findByAccountNumber(String accountNumber) {
        return find("accountNumber", accountNumber).firstResultOptional();
    }
    
    public long countActiveAccounts() {
        return count("status", AccountStatus.ACTIVE);
    }
    
    @Transactional
    public void closeAccount(String accountId) {
        update("status = 'CLOSED' where id = ?1", accountId);
    }
}
```

### Reactive Panache
```java
// ✅ PERFECT: Reactive Panache repository
@ApplicationScoped
public class ReactiveAccountRepository implements PanacheRepositoryBase<Account, String> {
    
    public Uni<List<Account>> findByCustomerId(String customerId) {
        return list("customerId = ?1 and status = 'ACTIVE'", customerId);
    }
    
    public Uni<Account> findByAccountNumber(String accountNumber) {
        return find("accountNumber", accountNumber).firstResult();
    }
    
    public Uni<Long> countActiveAccounts() {
        return count("status", AccountStatus.ACTIVE);
    }
}
```

### Panache Entity (Active Record Pattern)
```java
// ✅ PERFECT: Panache entity with Active Record
@Entity
@Table(name = "accounts")
public class Account extends PanacheEntity {
    
    @Column(name = "customer_id", nullable = false)
    public String customerId;
    
    @Column(name = "balance", nullable = false, precision = 19, scale = 2)
    public BigDecimal balance;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    public AccountStatus status;
    
    @Version
    public Long version;
    
    // Static methods for queries
    public static List<Account> findByCustomerId(String customerId) {
        return list("customerId = ?1 and status = 'ACTIVE'", customerId);
    }
    
    public static Optional<Account> findByAccountNumber(String accountNumber) {
        return find("accountNumber", accountNumber).firstResultOptional();
    }
}

// Usage
List<Account> accounts = Account.findByCustomerId("CUST-001");
Account account = Account.findById(accountId);
account.persist();
```

## Configuration

### Application Properties
```properties
# application.properties

# Application
quarkus.application.name=account-service

# HTTP
quarkus.http.port=8080
quarkus.http.test-port=8081

# Datasource
quarkus.datasource.db-kind=postgresql
quarkus.datasource.username=${DB_USERNAME}
quarkus.datasource.password=${DB_PASSWORD}
quarkus.datasource.jdbc.url=${DB_URL}
quarkus.datasource.jdbc.min-size=5
quarkus.datasource.jdbc.max-size=20

# Hibernate ORM
quarkus.hibernate-orm.database.generation=validate
quarkus.hibernate-orm.log.sql=false
quarkus.hibernate-orm.jdbc.statement-batch-size=20

# Logging
quarkus.log.level=INFO
quarkus.log.category."com.bank".level=DEBUG
quarkus.log.console.format=%d{yyyy-MM-dd HH:mm:ss,SSS} %-5p [%c{3.}] (%t) %s%e%n

# Health
quarkus.smallrye-health.root-path=/health

# Metrics
quarkus.micrometer.enabled=true
quarkus.micrometer.export.prometheus.enabled=true

# Native build
quarkus.native.additional-build-args=--initialize-at-run-time=org.postgresql.Driver
```

### Config Mapping (Type-Safe Config)
```java
// ✅ PERFECT: Type-safe configuration
@ConfigMapping(prefix = "account")
public interface AccountConfig {
    
    BigDecimal dailyTransactionLimit();
    
    Duration transactionTimeout();
    
    int maxRetryAttempts();
    
    FeeConfig fee();
    
    interface FeeConfig {
        BigDecimal standardRate();
        BigDecimal premiumRate();
    }
}

// Usage
@ApplicationScoped
public class TransactionService {
    private final AccountConfig config;
    
    public TransactionService(AccountConfig config) {
        this.config = config;
    }
    
    public void processTransaction(Transaction transaction) {
        BigDecimal limit = config.dailyTransactionLimit();
        Duration timeout = config.transactionTimeout();
        // Use configuration
    }
}
```

## Transaction Management

### Declarative Transactions
```java
// ✅ PERFECT: Service with transactions
@ApplicationScoped
public class TransactionService {
    
    private final AccountRepository accountRepository;
    private final TransactionRepository transactionRepository;
    
    @Transactional
    public TransactionResult transfer(String fromAccountId, String toAccountId, Money amount) {
        Account fromAccount = accountRepository.findByIdOptional(fromAccountId)
            .orElseThrow(() -> new AccountNotFoundException(fromAccountId));
        
        Account toAccount = accountRepository.findByIdOptional(toAccountId)
            .orElseThrow(() -> new AccountNotFoundException(toAccountId));
        
        fromAccount.withdraw(amount);
        toAccount.deposit(amount);
        
        accountRepository.persist(fromAccount);
        accountRepository.persist(toAccount);
        
        Transaction transaction = new Transaction(
            UUID.randomUUID().toString(),
            fromAccountId,
            toAccountId,
            amount,
            TransactionType.TRANSFER
        );
        
        transactionRepository.persist(transaction);
        
        return new TransactionResult(transaction.getId(), TransactionStatus.COMPLETED);
    }
    
    @Transactional(Transactional.TxType.SUPPORTS)
    public List<Transaction> getTransactionHistory(String accountId) {
        return transactionRepository.findByAccountId(accountId);
    }
}
```

## Events (CDI Events)

### Event Publishing
```java
// ✅ PERFECT: Event-driven architecture
@ApplicationScoped
public class AccountService {
    
    @Inject
    Event<AccountCreatedEvent> accountCreatedEvent;
    
    @Transactional
    public Account createAccount(CreateAccountRequest request) {
        Account account = new Account(
            UUID.randomUUID().toString(),
            request.customerId(),
            request.initialBalance()
        );
        
        accountRepository.persist(account);
        
        // Fire event
        accountCreatedEvent.fire(new AccountCreatedEvent(
            account.getId(),
            account.getCustomerId(),
            Instant.now()
        ));
        
        return account;
    }
}

// Event consumer
@ApplicationScoped
public class AccountEventListener {
    
    private static final Logger log = LoggerFactory.getLogger(AccountEventListener.class);
    
    void onAccountCreated(@ObservesAsync AccountCreatedEvent event) {
        log.info("Account created: accountId={}, customerId={}", 
            event.accountId(), 
            event.customerId());
        
        // Send notification, update cache, etc.
    }
}
```

## Scheduling

### Scheduled Tasks
```java
// ✅ PERFECT: Scheduled jobs
@ApplicationScoped
public class AccountMaintenanceJob {
    
    private static final Logger log = LoggerFactory.getLogger(AccountMaintenanceJob.class);
    
    private final AccountRepository accountRepository;
    
    @Scheduled(cron = "0 0 2 * * ?") // Every day at 2 AM
    @Transactional
    void cleanupInactiveAccounts() {
        log.info("Starting cleanup of inactive accounts");
        
        Instant cutoffDate = Instant.now().minus(365, ChronoUnit.DAYS);
        long deleted = accountRepository.delete(
            "status = 'INACTIVE' and lastActivityDate < ?1", 
            cutoffDate
        );
        
        log.info("Cleaned up {} inactive accounts", deleted);
    }
    
    @Scheduled(every = "10m") // Every 10 minutes
    void updateAccountBalances() {
        log.debug("Updating cached account balances");
        // Implementation
    }
}
```

## Health Checks

### Custom Health Checks
```java
// ✅ PERFECT: Custom health check
@Liveness
@ApplicationScoped
public class DatabaseHealthCheck implements HealthCheck {
    
    @Inject
    AgroalDataSource dataSource;
    
    @Override
    public HealthCheckResponse call() {
        try (Connection connection = dataSource.getConnection()) {
            boolean valid = connection.isValid(2);
            
            return HealthCheckResponse.named("Database connection")
                .status(valid)
                .build();
        } catch (Exception e) {
            return HealthCheckResponse.named("Database connection")
                .down()
                .withData("error", e.getMessage())
                .build();
        }
    }
}

@Readiness
@ApplicationScoped
public class ExternalServiceHealthCheck implements HealthCheck {
    
    @Inject
    @RestClient
    PaymentGatewayClient paymentGateway;
    
    @Override
    public HealthCheckResponse call() {
        try {
            paymentGateway.ping();
            return HealthCheckResponse.up("Payment Gateway");
        } catch (Exception e) {
            return HealthCheckResponse.named("Payment Gateway")
                .down()
                .withData("error", e.getMessage())
                .build();
        }
    }
}
```

## REST Client

### Declarative REST Client
```java
// ✅ PERFECT: Type-safe REST client
@Path("/api/customers")
@RegisterRestClient(configKey = "customer-api")
public interface CustomerClient {
    
    @GET
    @Path("/{customerId}")
    @Produces(MediaType.APPLICATION_JSON)
    Uni<Customer> getCustomer(@PathParam("customerId") String customerId);
    
    @POST
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    Uni<Customer> createCustomer(CreateCustomerRequest request);
}

// Configuration
// application.properties
quarkus.rest-client.customer-api.url=https://customer-service.example.com
quarkus.rest-client.customer-api.scope=javax.inject.Singleton

// Usage
@ApplicationScoped
public class AccountService {
    
    @RestClient
    CustomerClient customerClient;
    
    public Uni<Account> createAccountForCustomer(String customerId) {
        return customerClient.getCustomer(customerId)
            .flatMap(customer -> createAccount(customer));
    }
}
```

## Quarkus Best Practices Checklist

- [ ] Constructor injection (no field injection)
- [ ] Appropriate bean scopes (@ApplicationScoped, @RequestScoped)
- [ ] Exception mappers with @Provider
- [ ] Use Mutiny for reactive code (Uni/Multi, never .await())
- [ ] Panache for simplified data access
- [ ] Type-safe config with @ConfigMapping
- [ ] @Transactional on service methods
- [ ] CDI events for decoupling
- [ ] Health checks (@Liveness, @Readiness)
- [ ] REST clients with @RegisterRestClient
- [ ] Native compilation considerations

---

**Quarkus - Supersonic Subatomic Java!** ⚡
