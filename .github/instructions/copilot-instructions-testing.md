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

### Reactive Streams (Reactor - Spring WebFlux)

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

@Test
@DisplayName("Should emit multiple items when fetching all accounts")
void shouldEmitMultipleItemsWhenFetchingAllAccounts() {
    // Arrange
    var accounts = List.of(
        createAccount("ACC-001"),
        createAccount("ACC-002"),
        createAccount("ACC-003")
    );
    when(repository.findAll()).thenReturn(Flux.fromIterable(accounts));

    // Act
    Flux<Account> result = service.findAllAccounts();

    // Assert
    StepVerifier.create(result)
        .expectNextCount(3)
        .verifyComplete();
}

@Test
@DisplayName("Should timeout when operation takes too long")
void shouldTimeoutWhenOperationTakesTooLong() {
    // Arrange
    when(repository.findById(anyString()))
        .thenReturn(Mono.delay(Duration.ofSeconds(10)).then(Mono.just(createAccount())));

    // Act
    Mono<Account> result = service.findAccountById("ACC-001")
        .timeout(Duration.ofSeconds(2));

    // Assert
    StepVerifier.create(result)
        .expectError(TimeoutException.class)
        .verify();
}

@Test
@DisplayName("Should retry when operation fails temporarily")
void shouldRetryWhenOperationFailsTemporarily() {
    // Arrange
    when(repository.save(any()))
        .thenReturn(Mono.error(new TransientException()))
        .thenReturn(Mono.error(new TransientException()))
        .thenReturn(Mono.just(createAccount()));

    // Act
    Mono<Account> result = service.saveAccount(createAccount())
        .retry(3);

    // Assert
    StepVerifier.create(result)
        .expectNextCount(1)
        .verifyComplete();

    verify(repository, times(3)).save(any());
}

@Test
@DisplayName("Should combine multiple reactive streams successfully")
void shouldCombineMultipleReactiveStreamsSuccessfully() {
    // Arrange
    when(userRepository.findById("USER-001")).thenReturn(Mono.just(createUser()));
    when(accountRepository.findByUserId("USER-001")).thenReturn(Flux.just(createAccount(), createAccount()));
    when(transactionRepository.findByUserId("USER-001")).thenReturn(Flux.just(createTransaction()));

    // Act
    Mono<UserProfile> result = service.getUserProfile("USER-001");

    // Assert
    StepVerifier.create(result)
        .expectNextMatches(profile ->
            profile.user() != null &&
            profile.accounts().size() == 2 &&
            profile.transactions().size() == 1
        )
        .verifyComplete();
}
```

### Reactive Streams (Mutiny - Quarkus)

```java
@Test
@DisplayName("Should complete successfully when transaction is valid")
void shouldCompleteSuccessfullyWhenTransactionIsValid() {
    // Arrange
    var transaction = createTransaction();
    when(repository.persist(any())).thenReturn(Uni.createFrom().item(transaction));

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

@Test
@DisplayName("Should fail when validation error occurs")
void shouldFailWhenValidationErrorOccurs() {
    // Arrange
    var invalidTransaction = createInvalidTransaction();

    // Act
    Uni<TransactionResult> result = service.processTransaction(invalidTransaction);

    // Assert
    result.subscribe().withSubscriber(UniAssertSubscriber.create())
        .assertFailedWith(ValidationException.class, "Invalid transaction");
}

@Test
@DisplayName("Should emit all accounts when querying by customer")
void shouldEmitAllAccountsWhenQueryingByCustomer() {
    // Arrange
    var accounts = List.of(
        createAccount("ACC-001"),
        createAccount("ACC-002")
    );
    when(repository.findByCustomerId("CUST-001"))
        .thenReturn(Multi.createFrom().iterable(accounts));

    // Act
    Multi<Account> result = service.findAccountsByCustomer("CUST-001");

    // Assert
    result.subscribe().withSubscriber(MultiAssertSubscriber.create(2))
        .assertCompleted()
        .assertItems(accounts.get(0), accounts.get(1));
}

@Test
@DisplayName("Should handle timeout gracefully when operation is slow")
void shouldHandleTimeoutGracefullyWhenOperationIsSlow() {
    // Arrange
    when(repository.findById(anyString()))
        .thenReturn(Uni.createFrom().item(createAccount())
            .onItem().delayIt().by(Duration.ofSeconds(10)));

    // Act
    Uni<Account> result = service.findAccountById("ACC-001")
        .ifNoItem().after(Duration.ofSeconds(2))
        .fail();

    // Assert
    result.subscribe().withSubscriber(UniAssertSubscriber.create())
        .assertFailedWith(TimeoutException.class);
}

@Test
@DisplayName("Should retry on failure and succeed eventually")
void shouldRetryOnFailureAndSucceedEventually() {
    // Arrange
    when(repository.persist(any()))
        .thenReturn(Uni.createFrom().failure(new TransientException()))
        .thenReturn(Uni.createFrom().failure(new TransientException()))
        .thenReturn(Uni.createFrom().item(createAccount()));

    // Act
    Uni<Account> result = service.saveAccount(createAccount())
        .onFailure().retry().atMost(3);

    // Assert
    result.subscribe().withSubscriber(UniAssertSubscriber.create())
        .assertCompleted()
        .assertItem(account -> account != null);

    verify(repository, times(3)).persist(any());
}

@Test
@DisplayName("Should combine multiple Unis successfully")
void shouldCombineMultipleUnisSuccessfully() {
    // Arrange
    when(userRepository.findById("USER-001")).thenReturn(Uni.createFrom().item(createUser()));
    when(accountRepository.findById("ACC-001")).thenReturn(Uni.createFrom().item(createAccount()));
    when(transactionRepository.count()).thenReturn(Uni.createFrom().item(5L));

    // Act
    Uni<Dashboard> result = service.getDashboard("USER-001", "ACC-001");

    // Assert
    result.subscribe().withSubscriber(UniAssertSubscriber.create())
        .assertCompleted()
        .assertItem(dashboard -> {
            assertThat(dashboard.user()).isNotNull();
            assertThat(dashboard.account()).isNotNull();
            assertThat(dashboard.transactionCount()).isEqualTo(5L);
            return true;
        });
}

@Test
@DisplayName("Should handle empty Multi stream correctly")
void shouldHandleEmptyMultiStreamCorrectly() {
    // Arrange
    when(repository.findByCustomerId("CUST-999"))
        .thenReturn(Multi.createFrom().empty());

    // Act
    Multi<Account> result = service.findAccountsByCustomer("CUST-999");

    // Assert
    result.subscribe().withSubscriber(MultiAssertSubscriber.create())
        .assertCompleted()
        .assertHasNotReceivedAnyItem();
}

@Test
@DisplayName("Should collect Multi items into List")
void shouldCollectMultiItemsIntoList() {
    // Arrange
    var accounts = List.of(createAccount("ACC-001"), createAccount("ACC-002"));
    when(repository.findAll()).thenReturn(Multi.createFrom().iterable(accounts));

    // Act
    Uni<List<Account>> result = service.findAllAccounts()
        .collect().asList();

    // Assert
    result.subscribe().withSubscriber(UniAssertSubscriber.create())
        .assertCompleted()
        .assertItem(list -> {
            assertThat(list).hasSize(2);
            return true;
        });
}
```

### RxJava Testing

```java
@Test
@DisplayName("Should emit transaction result when processing succeeds")
void shouldEmitTransactionResultWhenProcessingSucceeds() {
    // Arrange
    var transaction = createTransaction();
    when(repository.save(any())).thenReturn(Observable.just(transaction));

    // Act
    Observable<TransactionResult> result = service.processTransaction(transaction);

    // Assert
    TestObserver<TransactionResult> testObserver = result.test();

    testObserver
        .assertComplete()
        .assertNoErrors()
        .assertValueCount(1)
        .assertValue(r -> r.status() == TransactionStatus.COMPLETED);
}

@Test
@DisplayName("Should handle error when validation fails")
void shouldHandleErrorWhenValidationFails() {
    // Arrange
    var invalidTransaction = createInvalidTransaction();
    when(validator.validate(any())).thenReturn(Observable.error(new ValidationException("Invalid")));

    // Act
    Observable<TransactionResult> result = service.processTransaction(invalidTransaction);

    // Assert
    TestObserver<TransactionResult> testObserver = result.test();

    testObserver
        .assertNotComplete()
        .assertError(ValidationException.class)
        .assertErrorMessage("Invalid");
}

@Test
@DisplayName("Should emit multiple items when fetching all accounts")
void shouldEmitMultipleItemsWhenFetchingAllAccounts() {
    // Arrange
    var accounts = List.of(
        createAccount("ACC-001"),
        createAccount("ACC-002"),
        createAccount("ACC-003")
    );
    when(repository.findAll()).thenReturn(Observable.fromIterable(accounts));

    // Act
    Observable<Account> result = service.findAllAccounts();

    // Assert
    TestObserver<Account> testObserver = result.test();

    testObserver
        .assertComplete()
        .assertNoErrors()
        .assertValueCount(3)
        .assertValues(accounts.toArray(new Account[0]));
}

@Test
@DisplayName("Should timeout when operation takes too long")
void shouldTimeoutWhenOperationTakesTooLong() {
    // Arrange
    when(repository.findById(anyString()))
        .thenReturn(Observable.timer(10, TimeUnit.SECONDS)
            .map(i -> createAccount()));

    // Act
    Observable<Account> result = service.findAccountById("ACC-001")
        .timeout(2, TimeUnit.SECONDS);

    // Assert
    TestObserver<Account> testObserver = result.test();

    testObserver
        .await()
        .assertError(TimeoutException.class);
}

@Test
@DisplayName("Should retry when operation fails temporarily")
void shouldRetryWhenOperationFailsTemporarily() {
    // Arrange
    when(repository.save(any()))
        .thenReturn(Observable.error(new TransientException()))
        .thenReturn(Observable.error(new TransientException()))
        .thenReturn(Observable.just(createAccount()));

    // Act
    Observable<Account> result = service.saveAccount(createAccount())
        .retry(3);

    // Assert
    TestObserver<Account> testObserver = result.test();

    testObserver
        .assertComplete()
        .assertNoErrors()
        .assertValueCount(1);

    verify(repository, times(3)).save(any());
}

@Test
@DisplayName("Should combine multiple observables with zip")
void shouldCombineMultipleObservablesWithZip() {
    // Arrange
    when(userRepository.findById("USER-001")).thenReturn(Observable.just(createUser()));
    when(accountRepository.findById("ACC-001")).thenReturn(Observable.just(createAccount()));
    when(transactionRepository.count()).thenReturn(Observable.just(5L));

    // Act
    Observable<Dashboard> result = Observable.zip(
        userRepository.findById("USER-001"),
        accountRepository.findById("ACC-001"),
        transactionRepository.count(),
        Dashboard::new
    );

    // Assert
    TestObserver<Dashboard> testObserver = result.test();

    testObserver
        .assertComplete()
        .assertValue(dashboard ->
            dashboard.user() != null &&
            dashboard.account() != null &&
            dashboard.transactionCount() == 5L
        );
}

@Test
@DisplayName("Should flat map nested observables correctly")
void shouldFlatMapNestedObservablesCorrectly() {
    // Arrange
    var user = createUser();
    var accounts = List.of(createAccount("ACC-001"), createAccount("ACC-002"));

    when(userRepository.findById("USER-001")).thenReturn(Observable.just(user));
    when(accountRepository.findByUserId("USER-001"))
        .thenReturn(Observable.fromIterable(accounts));

    // Act
    Observable<Account> result = userRepository.findById("USER-001")
        .flatMap(u -> accountRepository.findByUserId(u.getId()));

    // Assert
    TestObserver<Account> testObserver = result.test();

    testObserver
        .assertComplete()
        .assertValueCount(2)
        .assertValues(accounts.toArray(new Account[0]));
}

@Test
@DisplayName("Should handle empty observable stream")
void shouldHandleEmptyObservableStream() {
    // Arrange
    when(repository.findByCustomerId("CUST-999"))
        .thenReturn(Observable.empty());

    // Act
    Observable<Account> result = service.findAccountsByCustomer("CUST-999");

    // Assert
    TestObserver<Account> testObserver = result.test();

    testObserver
        .assertComplete()
        .assertNoErrors()
        .assertNoValues();
}

@Test
@DisplayName("Should use Single for operations returning one item")
void shouldUseSingleForOperationsReturningOneItem() {
    // Arrange
    var account = createAccount();
    when(repository.save(any())).thenReturn(Single.just(account));

    // Act
    Single<Account> result = service.createAccount(createAccountRequest());

    // Assert
    TestObserver<Account> testObserver = result.test();

    testObserver
        .assertComplete()
        .assertValue(account);
}

@Test
@DisplayName("Should use Completable for operations without return value")
void shouldUseCompletableForOperationsWithoutReturnValue() {
    // Arrange
    when(repository.delete(anyString())).thenReturn(Completable.complete());

    // Act
    Completable result = service.deleteAccount("ACC-001");

    // Assert
    TestObserver<Void> testObserver = result.test();

    testObserver
        .assertComplete()
        .assertNoErrors();

    verify(repository).delete("ACC-001");
}

@Test
@DisplayName("Should test on correct scheduler")
void shouldTestOnCorrectScheduler() {
    // Arrange
    var account = createAccount();
    when(repository.findById(anyString())).thenReturn(Observable.just(account));

    // Act
    Observable<Account> result = service.findAccountById("ACC-001")
        .subscribeOn(Schedulers.io())
        .observeOn(Schedulers.computation());

    // Assert
    TestObserver<Account> testObserver = result.test();

    testObserver
        .awaitDone(5, TimeUnit.SECONDS)
        .assertComplete()
        .assertValue(account);
}
```

## Reactive Testing Best Practices

### General Guidelines for Reactive Tests

```java
// ✅ PERFECT: Always use framework-specific test utilities
// Spring WebFlux → StepVerifier
// Quarkus Mutiny → UniAssertSubscriber, MultiAssertSubscriber
// RxJava → TestObserver, TestSubscriber

// ✅ GOOD: Test timeouts explicitly
@Test
@DisplayName("Should handle timeout scenarios appropriately")
void shouldHandleTimeoutScenariosAppropriately() {
    // Spring WebFlux
    StepVerifier.create(slowOperation.timeout(Duration.ofSeconds(2)))
        .expectError(TimeoutException.class)
        .verify(Duration.ofSeconds(5)); // Max wait time for test itself

    // Quarkus Mutiny
    slowOperation.ifNoItem().after(Duration.ofSeconds(2)).fail()
        .subscribe().withSubscriber(UniAssertSubscriber.create())
        .assertFailedWith(TimeoutException.class);

    // RxJava
    slowOperation.timeout(2, TimeUnit.SECONDS)
        .test()
        .await()
        .assertError(TimeoutException.class);
}

// ✅ GOOD: Test backpressure handling (for Flux/Multi/Observable)
@Test
@DisplayName("Should handle backpressure correctly")
void shouldHandleBackpressureCorrectly() {
    // Spring WebFlux
    Flux<Integer> flux = service.generateLargeStream();

    StepVerifier.create(flux, 10) // Request only 10 items
        .expectNextCount(10)
        .thenCancel()
        .verify();
}

// ✅ GOOD: Test error recovery strategies
@Test
@DisplayName("Should recover from errors using fallback")
void shouldRecoverFromErrorsUsingFallback() {
    // Spring WebFlux
    Mono<Account> result = service.getAccount("ACC-001")
        .onErrorResume(AccountNotFoundException.class,
            e -> Mono.just(Account.defaultAccount()));

    StepVerifier.create(result)
        .expectNext(Account.defaultAccount())
        .verifyComplete();

    // Quarkus Mutiny
    Uni<Account> mutinyResult = service.getAccount("ACC-001")
        .onFailure(AccountNotFoundException.class)
        .recoverWithItem(Account.defaultAccount());

    mutinyResult.subscribe().withSubscriber(UniAssertSubscriber.create())
        .assertItem(Account.defaultAccount());

    // RxJava
    Observable<Account> rxResult = service.getAccount("ACC-001")
        .onErrorReturnItem(Account.defaultAccount());

    rxResult.test()
        .assertValue(Account.defaultAccount())
        .assertComplete();
}

// ✅ GOOD: Test retry logic with proper verification
@Test
@DisplayName("Should retry with exponential backoff")
void shouldRetryWithExponentialBackoff() {
    // Arrange
    AtomicInteger attempts = new AtomicInteger(0);
    when(repository.save(any())).thenAnswer(inv -> {
        if (attempts.incrementAndGet() < 3) {
            return Mono.error(new TransientException());
        }
        return Mono.just(createAccount());
    });

    // Act & Assert - Spring WebFlux
    StepVerifier.create(
        service.saveAccount(createAccount())
            .retryWhen(Retry.backoff(3, Duration.ofMillis(100)))
    )
    .expectNextCount(1)
    .verifyComplete();

    assertThat(attempts.get()).isEqualTo(3);
}

// ❌ BAD: Blocking in reactive tests
@Test
void badReactiveTest() {
    Mono<Account> result = service.getAccount("ACC-001");
    Account account = result.block(); // ❌ NEVER BLOCK!
    assertThat(account).isNotNull();
}

// ❌ BAD: Not using test utilities
@Test
void anotherBadReactiveTest() {
    Mono<Account> result = service.getAccount("ACC-001");
    result.subscribe(account -> {
        // ❌ Assertions in subscribe callback are problematic
        assertThat(account).isNotNull();
    });
}
```

### Virtual Time Testing

```java
// ✅ PERFECT: Testing time-based operations without actual delays
@Test
@DisplayName("Should emit values at scheduled intervals using virtual time")
void shouldEmitValuesAtScheduledIntervalsUsingVirtualTime() {
    // Spring WebFlux
    StepVerifier.withVirtualTime(() ->
        Flux.interval(Duration.ofHours(1))
            .take(3)
    )
    .expectSubscription()
    .expectNoEvent(Duration.ofHours(1))
    .expectNext(0L)
    .thenAwait(Duration.ofHours(1))
    .expectNext(1L)
    .thenAwait(Duration.ofHours(1))
    .expectNext(2L)
    .verifyComplete();
}

@Test
@DisplayName("Should delay execution correctly")
void shouldDelayExecutionCorrectly() {
    // RxJava with TestScheduler
    TestScheduler scheduler = new TestScheduler();

    Observable<Long> delayed = Observable.timer(5, TimeUnit.SECONDS, scheduler);

    TestObserver<Long> testObserver = delayed.test();

    // Verify nothing emitted yet
    testObserver.assertNoValues();

    // Advance time
    scheduler.advanceTimeBy(5, TimeUnit.SECONDS);

    // Verify emission
    testObserver.assertValue(0L).assertComplete();
}
```

### Testing Reactive REST Controllers

```java
// ✅ PERFECT: Spring WebFlux Controller Test
@WebFluxTest(AccountController.class)
@DisplayName("Account Controller Reactive Tests")
class AccountControllerTest {

    @Autowired
    private WebTestClient webClient;

    @MockBean
    private AccountService accountService;

    @Test
    @DisplayName("Should return account when found")
    void shouldReturnAccountWhenFound() {
        // Arrange
        var account = new AccountDto("ACC-001", "CUST-001", BigDecimal.valueOf(1000));
        when(accountService.findById("ACC-001")).thenReturn(Mono.just(account));

        // Act & Assert
        webClient.get()
            .uri("/api/v1/accounts/{id}", "ACC-001")
            .exchange()
            .expectStatus().isOk()
            .expectBody(AccountDto.class)
            .value(response -> {
                assertThat(response.accountId()).isEqualTo("ACC-001");
                assertThat(response.balance()).isEqualByComparingTo("1000");
            });
    }

    @Test
    @DisplayName("Should return 404 when account not found")
    void shouldReturn404WhenAccountNotFound() {
        // Arrange
        when(accountService.findById("ACC-999"))
            .thenReturn(Mono.empty());

        // Act & Assert
        webClient.get()
            .uri("/api/v1/accounts/{id}", "ACC-999")
            .exchange()
            .expectStatus().isNotFound();
    }

    @Test
    @DisplayName("Should stream all accounts")
    void shouldStreamAllAccounts() {
        // Arrange
        var accounts = List.of(
            new AccountDto("ACC-001", "CUST-001", BigDecimal.valueOf(1000)),
            new AccountDto("ACC-002", "CUST-001", BigDecimal.valueOf(2000))
        );
        when(accountService.findAll()).thenReturn(Flux.fromIterable(accounts));

        // Act & Assert
        webClient.get()
            .uri("/api/v1/accounts")
            .exchange()
            .expectStatus().isOk()
            .expectBodyList(AccountDto.class)
            .hasSize(2)
            .contains(accounts.toArray(new AccountDto[0]));
    }
}

// ✅ PERFECT: Quarkus REST Assured with Mutiny
@QuarkusTest
@DisplayName("Account Resource Reactive Tests")
class AccountResourceTest {

    @InjectMock
    AccountService accountService;

    @Test
    @DisplayName("Should return account when found")
    void shouldReturnAccountWhenFound() {
        // Arrange
        var account = new AccountDto("ACC-001", "CUST-001", BigDecimal.valueOf(1000));
        when(accountService.findById("ACC-001"))
            .thenReturn(Uni.createFrom().item(account));

        // Act & Assert
        given()
            .when().get("/api/v1/accounts/ACC-001")
            .then()
            .statusCode(200)
            .body("accountId", equalTo("ACC-001"))
            .body("balance", comparesEqualTo(1000));
    }

    @Test
    @DisplayName("Should return 404 when account not found")
    void shouldReturn404WhenAccountNotFound() {
        // Arrange
        when(accountService.findById("ACC-999"))
            .thenReturn(Uni.createFrom().nullItem());

        // Act & Assert
        given()
            .when().get("/api/v1/accounts/ACC-999")
            .then()
            .statusCode(404);
    }
}
```

### Testing Reactive Database Operations

```java
// ✅ PERFECT: R2DBC Repository Test (Spring)
@DataR2dbcTest
@DisplayName("Reactive Account Repository Tests")
class ReactiveAccountRepositoryTest {

    @Autowired
    private ReactiveAccountRepository repository;

    @Autowired
    private DatabaseClient databaseClient;

    @BeforeEach
    void setUp() {
        databaseClient.sql("DELETE FROM accounts").fetch().rowsUpdated().block();
    }

    @Test
    @DisplayName("Should save and retrieve account reactively")
    void shouldSaveAndRetrieveAccountReactively() {
        // Arrange
        var account = new Account(
            UUID.randomUUID().toString(),
            "CUST-001",
            BigDecimal.valueOf(1000)
        );

        // Act & Assert
        StepVerifier.create(
            repository.save(account)
                .flatMap(saved -> repository.findById(saved.getId()))
        )
        .expectNextMatches(retrieved ->
            retrieved.getId().equals(account.getId()) &&
            retrieved.getBalance().compareTo(account.getBalance()) == 0
        )
        .verifyComplete();
    }

    @Test
    @DisplayName("Should handle concurrent saves with optimistic locking")
    void shouldHandleConcurrentSavesWithOptimisticLocking() {
        // Arrange
        var account = repository.save(createAccount()).block();

        // Act
        Mono<Account> update1 = repository.findById(account.getId())
            .doOnNext(a -> a.setBalance(BigDecimal.valueOf(1100)))
            .flatMap(repository::save);

        Mono<Account> update2 = repository.findById(account.getId())
            .doOnNext(a -> a.setBalance(BigDecimal.valueOf(1200)))
            .flatMap(repository::save);

        // Assert
        StepVerifier.create(Mono.zip(update1, update2))
            .expectError(OptimisticLockingFailureException.class)
            .verify();
    }
}

// ✅ PERFECT: Panache Reactive Repository Test (Quarkus)
@QuarkusTest
@DisplayName("Reactive Panache Repository Tests")
class ReactiveAccountRepositoryTest {

    @Inject
    ReactiveAccountRepository repository;

    @BeforeEach
    @Transactional
    void setUp() {
        repository.deleteAll().await().indefinitely();
    }

    @Test
    @DisplayName("Should persist and find account")
    void shouldPersistAndFindAccount() {
        // Arrange
        var account = new Account(
            UUID.randomUUID().toString(),
            "CUST-001",
            BigDecimal.valueOf(1000)
        );

        // Act
        Uni<Account> result = repository.persist(account)
            .flatMap(saved -> repository.findById(saved.getId()));

        // Assert
        result.subscribe().withSubscriber(UniAssertSubscriber.create())
            .assertCompleted()
            .assertItem(retrieved -> {
                assertThat(retrieved.getId()).isEqualTo(account.getId());
                assertThat(retrieved.getBalance()).isEqualByComparingTo(account.getBalance());
                return true;
            });
    }
}
```

### Reactive Test Dependencies

```xml
<!-- Spring WebFlux Testing -->
<dependency>
    <groupId>io.projectreactor</groupId>
    <artifactId>reactor-test</artifactId>
    <scope>test</scope>
</dependency>

<!-- Quarkus Reactive Testing -->
<dependency>
    <groupId>io.smallrye.reactive</groupId>
    <artifactId>smallrye-mutiny-test-utils</artifactId>
    <scope>test</scope>
</dependency>

<!-- RxJava Testing -->
<dependency>
    <groupId>io.reactivex.rxjava3</groupId>
    <artifactId>rxjava</artifactId>
    <version>3.1.8</version>
    <scope>test</scope>
</dependency>
```

### Reactive Testing Checklist

- [ ] Use appropriate test utilities (StepVerifier, UniAssertSubscriber, TestObserver)
- [ ] Never use `.block()` or `.await().indefinitely()` in reactive tests
- [ ] Test timeout scenarios explicitly
- [ ] Test error handling and recovery strategies
- [ ] Verify retry logic with attempt counters
- [ ] Test backpressure handling for streaming operations
- [ ] Use virtual time for time-based operations
- [ ] Test empty streams and null scenarios
- [ ] Verify proper cleanup and cancellation
- [ ] Test concurrent operations and race conditions
- [ ] Mock reactive dependencies to return reactive types
- [ ] Test schedulers/thread switching when applicable

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
