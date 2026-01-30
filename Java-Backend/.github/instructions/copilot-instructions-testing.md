# Testing Instructions for GitHub Copilot

## Core Testing Principles

**MANDATORY RULES:**
1. **ALWAYS** use `@DisplayName` annotation on every test
2. **ALWAYS** follow AAA (Arrange-Act-Assert) pattern
3. **ALWAYS** use descriptive test names: `should[ExpectedResult]When[StateUnderTest]`
4. **PREFER** parameterized tests over multiple similar tests
5. **ALWAYS** test edge cases and error scenarios

## Unit Tests (JUnit 5)

### Standard Test Structure
```java
// ✅ PERFECT: This is the template for ALL tests
class TransactionServiceTest {
    
    private TransactionRepository repository;
    private EventPublisher eventPublisher;
    private TransactionService service;
    
    @BeforeEach
    void setUp() {
        repository = mock(TransactionRepository.class);
        eventPublisher = mock(EventPublisher.class);
        service = new TransactionService(repository, eventPublisher);
    }
    
    @Test
    @DisplayName("Should process transaction when account has sufficient funds")
    void shouldProcessTransactionWhenSufficientFunds() {
        // Arrange (Given)
        var account = createAccountWithBalance(new BigDecimal("1000"));
        var transaction = createTransaction(new BigDecimal("100"));
        when(repository.findById(anyString())).thenReturn(Optional.of(account));
        when(repository.save(any())).thenAnswer(inv -> inv.getArgument(0));
        
        // Act (When)
        var result = service.processTransaction(transaction);
        
        // Assert (Then)
        assertThat(result.status()).isEqualTo(TransactionStatus.COMPLETED);
        assertThat(account.getBalance().amount()).isEqualByComparingTo("900");
        verify(eventPublisher).publish(any(TransactionCompletedEvent.class));
    }
    
    @Test
    @DisplayName("Should throw InsufficientFundsException when balance is insufficient")
    void shouldThrowInsufficientFundsExceptionWhenBalanceIsInsufficient() {
        // Arrange
        var account = createAccountWithBalance(new BigDecimal("50"));
        var transaction = createTransaction(new BigDecimal("100"));
        when(repository.findById(anyString())).thenReturn(Optional.of(account));
        
        // Act & Assert
        assertThatThrownBy(() -> service.processTransaction(transaction))
            .isInstanceOf(InsufficientFundsException.class)
            .hasMessageContaining("Insufficient funds")
            .hasFieldOrPropertyWithValue("available", new BigDecimal("50"))
            .hasFieldOrPropertyWithValue("required", new BigDecimal("100"));
    }
    
    // Helper methods at the bottom
    private Account createAccountWithBalance(BigDecimal balance) {
        return new Account(
            "ACC-001",
            "CUST-001",
            new Money(balance, Currency.getInstance("USD")),
            new ArrayList<>()
        );
    }
    
    private Transaction createTransaction(BigDecimal amount) {
        return new Transaction(
            UUID.randomUUID().toString(),
            "ACC-001",
            amount,
            TransactionType.WITHDRAWAL,
            Instant.now()
        );
    }
}
```

## Test Naming Convention

### Method Naming Pattern
**Format**: `should[ExpectedBehavior]When[StateUnderTest][_and[AdditionalContext]]`

```java
// ✅ GOOD Examples
@DisplayName("Should create account when valid request is provided")
void shouldCreateAccountWhenValidRequestIsProvided()

@DisplayName("Should throw ValidationException when account number is invalid")
void shouldThrowValidationExceptionWhenAccountNumberIsInvalid()

@DisplayName("Should update balance when transaction succeeds")
void shouldUpdateBalanceWhenTransactionSucceeds()

@DisplayName("Should send notification when transfer is completed and amount exceeds threshold")
void shouldSendNotificationWhenTransferIsCompletedAndAmountExceedsThreshold()

@DisplayName("Should return empty Optional when account is not found")
void shouldReturnEmptyOptionalWhenAccountIsNotFound()

// ❌ BAD Examples
void testCreateAccount()                    // ❌ No "should", no context
void createAccountTest()                    // ❌ Wrong format
void test_create_account_with_valid_data()  // ❌ Snake case, unclear
```

### DisplayName Best Practices
```java
// ✅ GOOD: Descriptive, business-focused
@DisplayName("Should reject transaction when daily limit is exceeded")

@DisplayName("Should calculate interest correctly for premium accounts")

@DisplayName("Should rollback transaction when payment gateway fails")

// ❌ BAD: Too technical or vague
@DisplayName("Test method works")
@DisplayName("Transaction test")
@DisplayName("Should work")
```

## Parameterized Tests

### ALWAYS Use Parameterized Tests When Testing Multiple Scenarios

```java
// ✅ PERFECT: Test multiple inputs with one test
@ParameterizedTest
@DisplayName("Should validate account numbers correctly for various formats")
@CsvSource({
    "1234567890,     true,  'Valid 10-digit account number'",
    "ABC1234567,     false, 'Contains non-numeric characters'",
    "123,            false, 'Too short'",
    "12345678901234, false, 'Too long'",
    "'',             false, 'Empty string'",
    "null,           false, 'Null value'"
})
void shouldValidateAccountNumberCorrectly(String accountNumber, boolean expectedValid, String scenario) {
    // Arrange & Act & Assert
    if (expectedValid) {
        assertDoesNotThrow(() -> validator.validate(accountNumber), scenario);
    } else {
        assertThrows(ValidationException.class, 
            () -> validator.validate(accountNumber), 
            scenario);
    }
}

// ✅ PERFECT: Test all enum values
@ParameterizedTest
@DisplayName("Should process all transaction types successfully")
@EnumSource(TransactionType.class)
void shouldProcessAllTransactionTypesSuccessfully(TransactionType type) {
    // Arrange
    var transaction = createTransactionOfType(type);
    
    // Act & Assert
    assertDoesNotThrow(() -> service.processTransaction(transaction));
}

// ✅ PERFECT: Test multiple amounts
@ParameterizedTest
@DisplayName("Should calculate fees correctly for different transaction amounts")
@MethodSource("transactionAmountProvider")
void shouldCalculateFeesCorrectlyForDifferentAmounts(BigDecimal amount, BigDecimal expectedFee) {
    // Arrange
    var transaction = createTransaction(amount);
    
    // Act
    var fee = feeCalculator.calculate(transaction);
    
    // Assert
    assertThat(fee).isEqualByComparingTo(expectedFee);
}

private static Stream<Arguments> transactionAmountProvider() {
    return Stream.of(
        Arguments.of(new BigDecimal("100"), new BigDecimal("2.50")),
        Arguments.of(new BigDecimal("1000"), new BigDecimal("15.00")),
        Arguments.of(new BigDecimal("10000"), new BigDecimal("100.00"))
    );
}

// ✅ PERFECT: Test boundary values
@ParameterizedTest
@DisplayName("Should handle balance boundary conditions correctly")
@ValueSource(longs = {0L, 1L, 999L, 1000L, Long.MAX_VALUE})
void shouldHandleBalanceBoundaryConditionsCorrectly(long balance) {
    // Arrange
    var account = createAccountWithBalance(BigDecimal.valueOf(balance));
    
    // Act
    var result = validator.validateBalance(account);
    
    // Assert
    assertThat(result.isValid()).isTrue();
}
```

## Test Organization with @Nested

```java
// ✅ PERFECT: Organized test class
@DisplayName("Account Service Tests")
class AccountServiceTest {
    
    private AccountService service;
    private AccountRepository repository;
    
    @BeforeEach
    void setUp() {
        repository = mock(AccountRepository.class);
        service = new AccountService(repository);
    }
    
    @Nested
    @DisplayName("Account creation tests")
    class AccountCreationTests {
        
        @Test
        @DisplayName("Should create account when valid request is provided")
        void shouldCreateAccountWhenValidRequestIsProvided() {
            // Test implementation
        }
        
        @ParameterizedTest
        @DisplayName("Should reject account creation when initial balance is invalid")
        @ValueSource(strings = {"-100", "-0.01", "-1000000"})
        void shouldRejectAccountCreationWhenInitialBalanceIsInvalid(String invalidBalance) {
            // Test implementation
        }
    }
    
    @Nested
    @DisplayName("Balance update tests")
    class BalanceUpdateTests {
        
        @Test
        @DisplayName("Should update balance when deposit is successful")
        void shouldUpdateBalanceWhenDepositIsSuccessful() {
            // Test implementation
        }
        
        @Test
        @DisplayName("Should rollback balance when transaction fails")
        void shouldRollbackBalanceWhenTransactionFails() {
            // Test implementation
        }
    }
    
    @Nested
    @DisplayName("Account closure tests")
    class AccountClosureTests {
        
        @Test
        @DisplayName("Should close account when balance is zero")
        void shouldCloseAccountWhenBalanceIsZero() {
            // Test implementation
        }
        
        @Test
        @DisplayName("Should prevent closure when balance is non-zero")
        void shouldPreventClosureWhenBalanceIsNonZero() {
            // Test implementation
        }
    }
}
```

## Testing Asynchronous Code

### CompletableFuture
```java
@Test
@DisplayName("Should process transaction asynchronously and complete successfully")
void shouldProcessTransactionAsynchronouslyAndCompleteSuccessfully() {
    // Arrange
    var transaction = createTransaction();
    
    // Act
    CompletableFuture<TransactionResult> future = service.processTransactionAsync(transaction);
    
    // Assert
    assertThat(future)
        .succeedsWithin(Duration.ofSeconds(5))
        .satisfies(result -> {
            assertThat(result.status()).isEqualTo(TransactionStatus.COMPLETED);
            assertThat(result.transactionId()).isNotBlank();
        });
}

@Test
@DisplayName("Should handle async errors gracefully when external service fails")
void shouldHandleAsyncErrorsGracefullyWhenExternalServiceFails() {
    // Arrange
    when(externalService.validate(any())).thenReturn(
        CompletableFuture.failedFuture(new ServiceUnavailableException())
    );
    
    // Act
    CompletableFuture<TransactionResult> future = service.processTransactionAsync(createTransaction());
    
    // Assert
    assertThat(future)
        .failsWithin(Duration.ofSeconds(5))
        .withThrowableOfType(ExecutionException.class)
        .withCauseInstanceOf(ServiceUnavailableException.class);
}
```

### Reactive Streams (Reactor)
```java
@Test
@DisplayName("Should emit transaction result when processing succeeds")
void shouldEmitTransactionResultWhenProcessingSucceeds() {
    // Arrange
    var transaction = createTransaction();
    when(repository.save(any())).thenReturn(Mono.just(transaction));
    
    // Act
    Mono<TransactionResult> result = service.processTransaction(transaction);
    
    // Assert
    StepVerifier.create(result)
        .expectNextMatches(r -> r.status() == TransactionStatus.COMPLETED)
        .verifyComplete();
}

@Test
@DisplayName("Should emit error when validation fails")
void shouldEmitErrorWhenValidationFails() {
    // Arrange
    var invalidTransaction = createInvalidTransaction();
    
    // Act
    Mono<TransactionResult> result = service.processTransaction(invalidTransaction);
    
    // Assert
    StepVerifier.create(result)
        .expectErrorMatches(error -> 
            error instanceof ValidationException &&
            error.getMessage().contains("Invalid transaction"))
        .verify();
}
```

### Reactive Streams (Mutiny - Quarkus)
```java
@Test
@DisplayName("Should complete successfully when transaction is valid")
void shouldCompleteSuccessfullyWhenTransactionIsValid() {
    // Arrange
    var transaction = createTransaction();
    
    // Act
    Uni<TransactionResult> result = service.processTransaction(transaction);
    
    // Assert
    result.subscribe().withSubscriber(UniAssertSubscriber.create())
        .assertCompleted()
        .assertItem(item -> {
            assertThat(item.status()).isEqualTo(TransactionStatus.COMPLETED);
            return true;
        });
}
```

## Integration Tests

```java
@Testcontainers
@DisplayName("Account Repository Integration Tests")
class AccountRepositoryIntegrationTest {
    
    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:15-alpine")
        .withDatabaseName("testdb")
        .withUsername("test")
        .withPassword("test");
    
    private AccountRepository repository;
    
    @BeforeEach
    void setUp() {
        DataSource dataSource = createDataSource(postgres);
        repository = new JdbcAccountRepository(dataSource);
    }
    
    @AfterEach
    void tearDown() {
        repository.deleteAll(); // Clean state for next test
    }
    
    @Test
    @DisplayName("Should save and retrieve account with all fields intact")
    void shouldSaveAndRetrieveAccountWithAllFieldsIntact() {
        // Arrange
        var account = new Account(
            UUID.randomUUID().toString(),
            "CUST-001",
            new Money(BigDecimal.valueOf(1000), Currency.getInstance("USD")),
            List.of()
        );
        
        // Act
        repository.save(account);
        var retrieved = repository.findById(account.getId());
        
        // Assert
        assertThat(retrieved).isPresent();
        assertThat(retrieved.get())
            .usingRecursiveComparison()
            .isEqualTo(account);
    }
    
    @Test
    @DisplayName("Should handle concurrent updates with optimistic locking")
    void shouldHandleConcurrentUpdatesWithOptimisticLocking() {
        // Arrange
        var account = repository.save(createAccount());
        
        // Act
        var account1 = repository.findById(account.getId()).orElseThrow();
        var account2 = repository.findById(account.getId()).orElseThrow();
        
        account1.deposit(new Money(BigDecimal.valueOf(100), Currency.getInstance("USD")));
        repository.save(account1); // This should succeed
        
        account2.deposit(new Money(BigDecimal.valueOf(200), Currency.getInstance("USD")));
        
        // Assert
        assertThatThrownBy(() -> repository.save(account2))
            .isInstanceOf(OptimisticLockException.class);
    }
}
```

## Test Coverage Requirements

### Coverage Goals
- **Domain Logic**: 100% coverage (all business rules)
- **Application Services**: 90%+ coverage
- **Infrastructure**: 70%+ coverage
- **Critical Paths** (security, financial): 100% coverage

### What to Test
✅ **MUST TEST:**
- All business logic and domain rules
- All error handling paths
- All edge cases and boundary conditions
- All security-critical code
- All financial calculations
- All state transitions
- All validation logic

❌ **DON'T TEST:**
- Framework code
- Simple getters/setters
- Trivial constructors
- Auto-generated code

## Best Practices Summary

### Mandatory Checklist for Every Test
- [ ] Has `@DisplayName` annotation
- [ ] Follows AAA pattern (Arrange-Act-Assert)
- [ ] Uses naming convention: `should[Expected]When[State]`
- [ ] Tests one thing only
- [ ] Is independent (can run in any order)
- [ ] Is repeatable (same result every time)
- [ ] Is fast (< 100ms for unit tests)
- [ ] Uses parameterized tests when testing multiple inputs
- [ ] Has clear, descriptive assertions
- [ ] Cleans up resources in `@AfterEach`

### Assertion Libraries
```java
// ✅ PREFER: AssertJ for fluent assertions
assertThat(account.getBalance())
    .isNotNull()
    .isEqualByComparingTo(new BigDecimal("1000.00"));

assertThat(result.getErrors())
    .hasSize(2)
    .extracting("code")
    .containsExactlyInAnyOrder("ERR_001", "ERR_002");

// ✅ GOOD: JUnit assertions for simple cases
assertEquals(TransactionStatus.COMPLETED, result.getStatus());
assertThrows(ValidationException.class, () -> service.process(invalid));
```

### Mock Verification
```java
// ✅ GOOD: Verify important interactions
verify(eventPublisher).publish(any(TransactionCompletedEvent.class));
verify(repository, times(1)).save(any(Account.class));
verify(notificationService, never()).sendEmail(anyString());

// ✅ GOOD: Verify with argument matchers
verify(auditLogger).log(
    eq("TRANSACTION_COMPLETED"),
    argThat(arg -> arg.contains("ACC-001"))
);
```

---

**Remember**: Tests are documentation. Write them as if someone else will maintain them tomorrow! 🚀
