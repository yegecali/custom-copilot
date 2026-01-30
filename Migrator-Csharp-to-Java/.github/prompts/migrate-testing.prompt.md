# 🧪 Migrate Testing (xUnit to JUnit)

## Objective

Convert C# xUnit tests to Java JUnit 5 tests while maintaining 100% test coverage and assertion quality.

## Context

- Source: C# xUnit test classes
- Target: Java JUnit 5 test classes
- Must preserve all test cases
- Must maintain assertion quality
- Must follow AAA pattern (Arrange, Act, Assert)

## Instructions

You are a Java testing expert. When migrating tests:

### 1. Test Framework Mapping

```
C# xUnit              → Java JUnit 5
[Fact]               → @Test
[Theory]             → @ParameterizedTest
[InlineData]         → @ValueSource / @CsvSource
[ClassFixture]       → @ExtendWith
[CollectionFixture]  → @ExtendWith
Assert.X()           → org.junit.jupiter.api.Assertions
Throws<T>            → assertThrows(T.class)
xunit.runner.config  → junit-platform.properties
```

### 2. Basic Test Structure

#### Before (C# xUnit)

```csharp
public class PaymentServiceTests
{
    private readonly PaymentService _service;

    public PaymentServiceTests()
    {
        _service = new PaymentService();
    }

    [Fact]
    public async Task ProcessPayment_WithValidRequest_ReturnsSuccess()
    {
        // Arrange
        var request = new PaymentRequest { Amount = 100 };

        // Act
        var result = await _service.ProcessAsync(request);

        // Assert
        Assert.NotNull(result);
        Assert.True(result.Success);
        Assert.Equal(100, result.Amount);
    }
}
```

#### After (Java JUnit 5)

```java
public class PaymentServiceTests {
    private PaymentService service;

    @BeforeEach
    void setUp() {
        service = new PaymentService();
    }

    @Test
    void testProcessPaymentWithValidRequestReturnsSuccess() {
        // Arrange
        PaymentRequest request = new PaymentRequest()
            .setAmount(BigDecimal.valueOf(100));

        // Act
        PaymentResult result = service.process(request)
            .get(); // Handle CompletableFuture

        // Assert
        assertNotNull(result);
        assertTrue(result.isSuccess());
        assertEquals(BigDecimal.valueOf(100), result.getAmount());
    }
}
```

### 3. Assertion Mapping

```
C# xUnit                     → Java JUnit 5
Assert.Null(obj)            → assertNull(obj)
Assert.NotNull(obj)         → assertNotNull(obj)
Assert.True(condition)      → assertTrue(condition)
Assert.False(condition)     → assertFalse(condition)
Assert.Equal(expected, actual) → assertEquals(expected, actual)
Assert.NotEqual(exp, act)   → assertNotEquals(exp, act)
Assert.Same(exp, act)       → assertSame(exp, act)
Assert.NotSame(exp, act)    → assertNotSame(exp, act)
Assert.Empty(collection)    → assertTrue(collection.isEmpty())
Assert.NotEmpty(collection) → assertFalse(collection.isEmpty())
Assert.Contains(item, coll) → assertTrue(coll.contains(item))
Assert.Single(collection)   → assertEquals(1, coll.size())
Assert.Throws<T>()          → assertThrows(T.class, ...)
```

### 4. Parameterized Tests

#### Before (C# xUnit)

```csharp
[Theory]
[InlineData(100, true)]
[InlineData(0, false)]
[InlineData(-50, false)]
public void ProcessPayment_WithVariousAmounts_ValidatesCorrectly(decimal amount, bool expected)
{
    var result = _service.ValidateAmount(amount);
    Assert.Equal(expected, result);
}
```

#### After (Java JUnit 5)

```java
@ParameterizedTest
@ValueSource(strings = {"100", "0", "-50"})
void testProcessPaymentWithVariousAmounts(String amount) {
    // Implementation
}

// Or with multiple parameters
@ParameterizedTest
@CsvSource({
    "100, true",
    "0, false",
    "-50, false"
})
void testProcessPaymentValidatesCorrectly(String amount, String expected) {
    BigDecimal amt = new BigDecimal(amount);
    boolean exp = Boolean.parseBoolean(expected);
    boolean result = service.validateAmount(amt);
    assertEquals(exp, result);
}
```

### 5. Exception Testing

#### Before (C# xUnit)

```csharp
[Fact]
public async Task ProcessPayment_WithInvalidAmount_ThrowsException()
{
    var request = new PaymentRequest { Amount = -100 };

    await Assert.ThrowsAsync<ArgumentException>(
        () => _service.ProcessAsync(request));
}
```

#### After (Java JUnit 5)

```java
@Test
void testProcessPaymentWithInvalidAmountThrowsException() {
    PaymentRequest request = new PaymentRequest()
        .setAmount(BigDecimal.valueOf(-100));

    assertThrows(IllegalArgumentException.class, () -> {
        service.process(request).get();
    });
}
```

### 6. Mocking

#### Before (C# with Moq)

```csharp
public class PaymentServiceTests
{
    private readonly Mock<IRepository> _mockRepo;
    private readonly PaymentService _service;

    public PaymentServiceTests()
    {
        _mockRepo = new Mock<IRepository>();
        _service = new PaymentService(_mockRepo.Object);
    }

    [Fact]
    public async Task ProcessPayment_CallsRepository()
    {
        var request = new PaymentRequest { Amount = 100 };

        await _service.ProcessAsync(request);

        _mockRepo.Verify(x => x.SaveAsync(It.IsAny<PaymentResult>()), Times.Once);
    }
}
```

#### After (Java with Mockito)

```java
public class PaymentServiceTests {
    private Repository mockRepo;
    private PaymentService service;

    @BeforeEach
    void setUp() {
        mockRepo = mock(Repository.class);
        service = new PaymentService(mockRepo);
    }

    @Test
    void testProcessPaymentCallsRepository() {
        PaymentRequest request = new PaymentRequest()
            .setAmount(BigDecimal.valueOf(100));

        service.process(request).get();

        verify(mockRepo, times(1)).save(any(PaymentResult.class));
    }
}
```

### 7. Setup and Teardown

#### Before (C# xUnit)

```csharp
public class ServiceTests : IAsyncLifetime
{
    private Service _service;

    public async Task InitializeAsync()
    {
        _service = new Service();
        await _service.InitializeAsync();
    }

    public async Task DisposeAsync()
    {
        await _service.CloseAsync();
    }
}
```

#### After (Java JUnit 5)

```java
public class ServiceTests {
    private Service service;

    @BeforeEach
    void setUp() throws Exception {
        service = new Service();
        service.initialize();
    }

    @AfterEach
    void tearDown() throws Exception {
        service.close();
    }
}
```

### 8. Naming Convention

Java tests should follow this pattern:

```
test[MethodUnderTest]_[Scenario]_[ExpectedResult]
```

Examples:

```
testProcessPayment_WithValidRequest_ReturnsSuccess()
testValidateAmount_WithNegativeValue_ThrowsException()
testFindUser_WithExistingId_ReturnsUser()
testFindUser_WithNonExistingId_ReturnsEmpty()
```

## Migration Checklist

- ✅ All [Fact] converted to @Test
- ✅ All [Theory] converted to @ParameterizedTest
- ✅ All assertions updated to JUnit 5
- ✅ Mocks converted to Mockito
- ✅ Setup/Teardown converted to @BeforeEach/@AfterEach
- ✅ Exception handling with assertThrows
- ✅ Naming follows Java conventions
- ✅ AAA pattern maintained
- ✅ Test coverage preserved
- ✅ Dependencies added to pom.xml

## Test Dependencies Template

```xml
<!-- JUnit 5 -->
<dependency>
    <groupId>org.junit.jupiter</groupId>
    <artifactId>junit-jupiter-api</artifactId>
    <version>5.9.2</version>
    <scope>test</scope>
</dependency>
<dependency>
    <groupId>org.junit.jupiter</groupId>
    <artifactId>junit-jupiter-engine</artifactId>
    <version>5.9.2</version>
    <scope>test</scope>
</dependency>
<dependency>
    <groupId>org.junit.jupiter</groupId>
    <artifactId>junit-jupiter-params</artifactId>
    <version>5.9.2</version>
    <scope>test</scope>
</dependency>

<!-- Mockito -->
<dependency>
    <groupId>org.mockito</groupId>
    <artifactId>mockito-core</artifactId>
    <version>5.2.0</version>
    <scope>test</scope>
</dependency>
<dependency>
    <groupId>org.mockito</groupId>
    <artifactId>mockito-junit-jupiter</artifactId>
    <version>5.2.0</version>
    <scope>test</scope>
</dependency>

<!-- AssertJ (Optional but recommended) -->
<dependency>
    <groupId>org.assertj</groupId>
    <artifactId>assertj-core</artifactId>
    <version>3.24.1</version>
    <scope>test</scope>
</dependency>
```

## Tags

#testing #junit #xunit #migration #test-migration
