---
description: "Crear tests reactivos completos usando StepVerifier (WebFlux), TestObserver (RxJava) y UniAssertSubscriber (Quarkus Mutiny)"
agent: agent
---

# 🧪 REACTIVE TESTING - WebFlux, RxJava & Quarkus Mutiny

Actúa como **experto en testing de aplicaciones reactivas multi-framework**.

Tu misión es **crear tests completos y robustos para código reactivo** usando las herramientas específicas de cada framework: **StepVerifier** (Project Reactor), **TestObserver** (RxJava), y **UniAssertSubscriber** (Quarkus Mutiny).

---

## 🎯 FRAMEWORKS CUBIERTOS

| Framework                    | Testing Tool                                   | Tipos Reactivos                                                        |
| ---------------------------- | ---------------------------------------------- | ---------------------------------------------------------------------- |
| **Spring WebFlux** (Reactor) | `StepVerifier`                                 | `Mono<T>`, `Flux<T>`                                                   |
| **RxJava 3**                 | `TestObserver`, `TestSubscriber`               | `Single<T>`, `Observable<T>`, `Completable`, `Maybe<T>`, `Flowable<T>` |
| **Quarkus Mutiny**           | `UniAssertSubscriber`, `MultiAssertSubscriber` | `Uni<T>`, `Multi<T>`                                                   |

---

## 📦 DEPENDENCIAS

### Maven

```xml
<dependencies>
    <!-- Spring WebFlux Testing -->
    <dependency>
        <groupId>io.projectreactor</groupId>
        <artifactId>reactor-test</artifactId>
        <scope>test</scope>
    </dependency>

    <!-- RxJava 3 (includes test support) -->
    <dependency>
        <groupId>io.reactivex.rxjava3</groupId>
        <artifactId>rxjava</artifactId>
        <version>3.1.8</version>
    </dependency>

    <!-- Quarkus Mutiny Testing -->
    <dependency>
        <groupId>io.smallrye.reactive</groupId>
        <artifactId>smallrye-mutiny-test-utils</artifactId>
        <scope>test</scope>
    </dependency>

    <!-- JUnit 5 -->
    <dependency>
        <groupId>org.junit.jupiter</groupId>
        <artifactId>junit-jupiter</artifactId>
        <scope>test</scope>
    </dependency>

    <!-- AssertJ for fluent assertions -->
    <dependency>
        <groupId>org.assertj</groupId>
        <artifactId>assertj-core</artifactId>
        <scope>test</scope>
    </dependency>
</dependencies>
```

### Gradle

```gradle
testImplementation 'io.projectreactor:reactor-test'
testImplementation 'io.reactivex.rxjava3:rxjava:3.1.8'
testImplementation 'io.smallrye.reactive:smallrye-mutiny-test-utils'
testImplementation 'org.junit.jupiter:junit-jupiter'
testImplementation 'org.assertj:assertj-core'
```

---

## 🔵 SPRING WEBFLUX - StepVerifier

### 1️⃣ Testing Mono - Valor Único

```java
import reactor.core.publisher.Mono;
import reactor.test.StepVerifier;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.DisplayName;

@DisplayName("Mono Reactive Tests")
class MonoReactiveTest {

    @Test
    @DisplayName("Should emit single value and complete")
    void testMonoEmitsValue() {
        // Given
        Mono<String> mono = Mono.just("Hello Reactive");

        // When/Then
        StepVerifier.create(mono)
            .expectNext("Hello Reactive")
            .verifyComplete();
    }

    @Test
    @DisplayName("Should emit value matching predicate")
    void testMonoWithPredicate() {
        Mono<Integer> mono = Mono.just(42);

        StepVerifier.create(mono)
            .expectNextMatches(value -> value > 40)
            .verifyComplete();
    }

    @Test
    @DisplayName("Should handle empty Mono")
    void testEmptyMono() {
        Mono<String> mono = Mono.empty();

        StepVerifier.create(mono)
            .expectComplete()
            .verify();
    }

    @Test
    @DisplayName("Should handle Mono with error")
    void testMonoWithError() {
        Mono<String> mono = Mono.error(new RuntimeException("Error occurred"));

        StepVerifier.create(mono)
            .expectError(RuntimeException.class)
            .verify();
    }

    @Test
    @DisplayName("Should verify error message")
    void testMonoErrorMessage() {
        Mono<String> mono = Mono.error(new IllegalArgumentException("Invalid input"));

        StepVerifier.create(mono)
            .expectErrorMatches(error ->
                error instanceof IllegalArgumentException &&
                error.getMessage().contains("Invalid input")
            )
            .verify();
    }

    @Test
    @DisplayName("Should test Mono with delay")
    void testMonoWithDelay() {
        Mono<String> mono = Mono.just("Delayed")
            .delayElement(Duration.ofSeconds(1));

        StepVerifier.create(mono)
            .expectNext("Delayed")
            .expectComplete()
            .verify(Duration.ofSeconds(2)); // Timeout
    }
}
```

### 2️⃣ Testing Flux - Múltiples Valores

```java
import reactor.core.publisher.Flux;
import reactor.test.StepVerifier;
import java.time.Duration;

@DisplayName("Flux Reactive Tests")
class FluxReactiveTest {

    @Test
    @DisplayName("Should emit multiple values in sequence")
    void testFluxEmitsMultipleValues() {
        Flux<Integer> flux = Flux.just(1, 2, 3, 4, 5);

        StepVerifier.create(flux)
            .expectNext(1)
            .expectNext(2)
            .expectNext(3)
            .expectNext(4)
            .expectNext(5)
            .verifyComplete();
    }

    @Test
    @DisplayName("Should emit values using expectNextSequence")
    void testFluxSequence() {
        Flux<String> flux = Flux.just("A", "B", "C");

        StepVerifier.create(flux)
            .expectNextSequence(List.of("A", "B", "C"))
            .verifyComplete();
    }

    @Test
    @DisplayName("Should emit specific number of values")
    void testFluxCount() {
        Flux<Integer> flux = Flux.range(1, 10);

        StepVerifier.create(flux)
            .expectNextCount(10)
            .verifyComplete();
    }

    @Test
    @DisplayName("Should test Flux with filter")
    void testFluxWithFilter() {
        Flux<Integer> flux = Flux.range(1, 10)
            .filter(n -> n % 2 == 0); // Even numbers only

        StepVerifier.create(flux)
            .expectNext(2, 4, 6, 8, 10)
            .verifyComplete();
    }

    @Test
    @DisplayName("Should test Flux with map transformation")
    void testFluxWithMap() {
        Flux<String> flux = Flux.just("a", "b", "c")
            .map(String::toUpperCase);

        StepVerifier.create(flux)
            .expectNext("A", "B", "C")
            .verifyComplete();
    }

    @Test
    @DisplayName("Should handle Flux with error in middle")
    void testFluxWithError() {
        Flux<Integer> flux = Flux.just(1, 2, 3)
            .concatWith(Flux.error(new RuntimeException("Error")))
            .concatWith(Flux.just(4, 5));

        StepVerifier.create(flux)
            .expectNext(1, 2, 3)
            .expectError(RuntimeException.class)
            .verify();
    }

    @Test
    @DisplayName("Should test Flux with virtual time")
    void testFluxWithVirtualTime() {
        // Use virtual time to avoid waiting
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
}
```

### 3️⃣ Testing Servicios Reactivos

```java
@DisplayName("User Service Reactive Tests")
class UserServiceTest {

    @Mock
    private UserRepository userRepository;

    @InjectMocks
    private UserService userService;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    @DisplayName("Should find user by id")
    void testFindUserById() {
        // Given
        User user = new User("1", "John Doe", "john@example.com");
        when(userRepository.findById("1")).thenReturn(Mono.just(user));

        // When
        Mono<User> result = userService.findById("1");

        // Then
        StepVerifier.create(result)
            .expectNextMatches(u ->
                u.getId().equals("1") &&
                u.getName().equals("John Doe") &&
                u.getEmail().equals("john@example.com")
            )
            .verifyComplete();

        verify(userRepository).findById("1");
    }

    @Test
    @DisplayName("Should return empty when user not found")
    void testUserNotFound() {
        when(userRepository.findById("999")).thenReturn(Mono.empty());

        Mono<User> result = userService.findById("999");

        StepVerifier.create(result)
            .expectComplete()
            .verify();
    }

    @Test
    @DisplayName("Should handle repository error")
    void testRepositoryError() {
        when(userRepository.findById("1"))
            .thenReturn(Mono.error(new DatabaseException("Connection failed")));

        Mono<User> result = userService.findById("1");

        StepVerifier.create(result)
            .expectErrorMatches(error ->
                error instanceof DatabaseException &&
                error.getMessage().contains("Connection failed")
            )
            .verify();
    }

    @Test
    @DisplayName("Should find all users with pagination")
    void testFindAllUsers() {
        List<User> users = List.of(
            new User("1", "John", "john@example.com"),
            new User("2", "Jane", "jane@example.com")
        );
        when(userRepository.findAll()).thenReturn(Flux.fromIterable(users));

        Flux<User> result = userService.findAll();

        StepVerifier.create(result)
            .expectNextCount(2)
            .verifyComplete();
    }

    @Test
    @DisplayName("Should test reactive retry on failure")
    void testRetryOnFailure() {
        when(userRepository.findById("1"))
            .thenReturn(Mono.error(new TransientException("Temporary error")))
            .thenReturn(Mono.error(new TransientException("Temporary error")))
            .thenReturn(Mono.just(new User("1", "John", "john@example.com")));

        Mono<User> result = userService.findByIdWithRetry("1");

        StepVerifier.create(result)
            .expectNextMatches(u -> u.getId().equals("1"))
            .verifyComplete();

        verify(userRepository, times(3)).findById("1");
    }
}
```

### 4️⃣ Testing con Context y Backpressure

```java
@Test
@DisplayName("Should test with context propagation")
void testWithContext() {
    Mono<String> mono = Mono.deferContextual(ctx ->
        Mono.just("User: " + ctx.get("username"))
    );

    StepVerifier.create(mono.contextWrite(Context.of("username", "john")))
        .expectNext("User: john")
        .verifyComplete();
}

@Test
@DisplayName("Should test backpressure")
void testBackpressure() {
    Flux<Integer> flux = Flux.range(1, 100);

    StepVerifier.create(flux, 10) // Request only 10 items
        .expectNextCount(10)
        .thenRequest(10) // Request 10 more
        .expectNextCount(10)
        .thenCancel()
        .verify();
}
```

---

## 🟠 RXJAVA 3 - TestObserver

### 1️⃣ Testing Single - Valor Único

```java
import io.reactivex.rxjava3.core.Single;
import io.reactivex.rxjava3.observers.TestObserver;
import org.junit.jupiter.api.Test;

@DisplayName("RxJava Single Tests")
class RxJavaSingleTest {

    @Test
    @DisplayName("Should emit single value successfully")
    void testSingleEmitsValue() {
        // Given
        Single<String> single = Single.just("Hello RxJava");

        // When
        TestObserver<String> testObserver = single.test();

        // Then
        testObserver
            .assertComplete()
            .assertNoErrors()
            .assertValue("Hello RxJava")
            .assertValueCount(1);
    }

    @Test
    @DisplayName("Should verify value with predicate")
    void testSingleWithPredicate() {
        Single<Integer> single = Single.just(42);

        TestObserver<Integer> testObserver = single.test();

        testObserver
            .assertComplete()
            .assertValue(value -> value > 40)
            .assertValue(value -> value % 2 == 0);
    }

    @Test
    @DisplayName("Should handle Single with error")
    void testSingleWithError() {
        Single<String> single = Single.error(new RuntimeException("Error"));

        TestObserver<String> testObserver = single.test();

        testObserver
            .assertNotComplete()
            .assertError(RuntimeException.class)
            .assertErrorMessage("Error");
    }

    @Test
    @DisplayName("Should test Single with delay")
    void testSingleWithDelay() throws InterruptedException {
        Single<String> single = Single.just("Delayed")
            .delay(100, TimeUnit.MILLISECONDS);

        TestObserver<String> testObserver = single.test();

        // Initially no values
        testObserver.assertNotComplete();

        // Wait and verify
        testObserver.await();
        testObserver.assertComplete().assertValue("Delayed");
    }
}
```

### 2️⃣ Testing Observable - Múltiples Valores

```java
import io.reactivex.rxjava3.core.Observable;
import io.reactivex.rxjava3.observers.TestObserver;

@DisplayName("RxJava Observable Tests")
class RxJavaObservableTest {

    @Test
    @DisplayName("Should emit multiple values")
    void testObservableEmitsMultipleValues() {
        Observable<Integer> observable = Observable.just(1, 2, 3, 4, 5);

        TestObserver<Integer> testObserver = observable.test();

        testObserver
            .assertComplete()
            .assertNoErrors()
            .assertValueCount(5)
            .assertValues(1, 2, 3, 4, 5);
    }

    @Test
    @DisplayName("Should test Observable with map")
    void testObservableWithMap() {
        Observable<String> observable = Observable.just("a", "b", "c")
            .map(String::toUpperCase);

        TestObserver<String> testObserver = observable.test();

        testObserver
            .assertComplete()
            .assertValues("A", "B", "C");
    }

    @Test
    @DisplayName("Should test Observable with filter")
    void testObservableWithFilter() {
        Observable<Integer> observable = Observable.range(1, 10)
            .filter(n -> n % 2 == 0);

        TestObserver<Integer> testObserver = observable.test();

        testObserver
            .assertComplete()
            .assertValues(2, 4, 6, 8, 10);
    }

    @Test
    @DisplayName("Should handle error in stream")
    void testObservableWithError() {
        Observable<Integer> observable = Observable.just(1, 2, 3)
            .concatWith(Observable.error(new RuntimeException("Error")));

        TestObserver<Integer> testObserver = observable.test();

        testObserver
            .assertNotComplete()
            .assertError(RuntimeException.class)
            .assertValues(1, 2, 3); // Values before error
    }

    @Test
    @DisplayName("Should test Observable with virtual time")
    void testObservableWithScheduler() {
        TestScheduler scheduler = new TestScheduler();

        Observable<Long> observable = Observable.interval(1, TimeUnit.SECONDS, scheduler)
            .take(3);

        TestObserver<Long> testObserver = observable.test();

        // Initially no values
        testObserver.assertValueCount(0);

        // Advance time by 1 second
        scheduler.advanceTimeBy(1, TimeUnit.SECONDS);
        testObserver.assertValues(0L);

        // Advance time by 2 more seconds
        scheduler.advanceTimeBy(2, TimeUnit.SECONDS);
        testObserver.assertComplete().assertValues(0L, 1L, 2L);
    }
}
```

### 3️⃣ Testing Completable y Maybe

```java
@DisplayName("RxJava Completable and Maybe Tests")
class RxJavaCompletableTest {

    @Test
    @DisplayName("Should complete successfully")
    void testCompletableSuccess() {
        Completable completable = Completable.complete();

        TestObserver<Void> testObserver = completable.test();

        testObserver
            .assertComplete()
            .assertNoErrors()
            .assertNoValues();
    }

    @Test
    @DisplayName("Should handle Completable error")
    void testCompletableError() {
        Completable completable = Completable.error(new RuntimeException("Failed"));

        TestObserver<Void> testObserver = completable.test();

        testObserver
            .assertNotComplete()
            .assertError(RuntimeException.class)
            .assertErrorMessage("Failed");
    }

    @Test
    @DisplayName("Should test Maybe with value")
    void testMaybeWithValue() {
        Maybe<String> maybe = Maybe.just("Value");

        TestObserver<String> testObserver = maybe.test();

        testObserver
            .assertComplete()
            .assertValue("Value");
    }

    @Test
    @DisplayName("Should test empty Maybe")
    void testEmptyMaybe() {
        Maybe<String> maybe = Maybe.empty();

        TestObserver<String> testObserver = maybe.test();

        testObserver
            .assertComplete()
            .assertNoValues();
    }
}
```

### 4️⃣ Testing Servicios con RxJava

```java
@DisplayName("Payment Service RxJava Tests")
class PaymentServiceTest {

    @Mock
    private PaymentGateway paymentGateway;

    @InjectMocks
    private PaymentService paymentService;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    @DisplayName("Should process payment successfully")
    void testProcessPayment() {
        // Given
        Payment payment = new Payment("100.00", "USD");
        PaymentResult result = new PaymentResult("TXN123", "SUCCESS");

        when(paymentGateway.process(payment))
            .thenReturn(Single.just(result));

        // When
        Single<PaymentResult> single = paymentService.processPayment(payment);

        // Then
        TestObserver<PaymentResult> testObserver = single.test();

        testObserver
            .assertComplete()
            .assertNoErrors()
            .assertValue(r -> r.getTransactionId().equals("TXN123"))
            .assertValue(r -> r.getStatus().equals("SUCCESS"));

        verify(paymentGateway).process(payment);
    }

    @Test
    @DisplayName("Should retry on transient failure")
    void testRetryOnFailure() {
        Payment payment = new Payment("100.00", "USD");

        when(paymentGateway.process(payment))
            .thenReturn(Single.error(new TransientException("Temporary error")))
            .thenReturn(Single.error(new TransientException("Temporary error")))
            .thenReturn(Single.just(new PaymentResult("TXN123", "SUCCESS")));

        Single<PaymentResult> single = paymentService.processPaymentWithRetry(payment);

        TestObserver<PaymentResult> testObserver = single.test();

        testObserver
            .assertComplete()
            .assertValue(r -> r.getStatus().equals("SUCCESS"));

        verify(paymentGateway, times(3)).process(payment);
    }

    @Test
    @DisplayName("Should handle permanent failure")
    void testPermanentFailure() {
        Payment payment = new Payment("100.00", "USD");

        when(paymentGateway.process(payment))
            .thenReturn(Single.error(new PaymentException("Invalid card")));

        Single<PaymentResult> single = paymentService.processPayment(payment);

        TestObserver<PaymentResult> testObserver = single.test();

        testObserver
            .assertNotComplete()
            .assertError(PaymentException.class)
            .assertErrorMessage("Invalid card");
    }
}
```

---

## 🟣 QUARKUS MUTINY - UniAssertSubscriber

### 1️⃣ Testing Uni - Valor Único

```java
import io.smallrye.mutiny.Uni;
import io.smallrye.mutiny.helpers.test.UniAssertSubscriber;
import org.junit.jupiter.api.Test;

@DisplayName("Mutiny Uni Tests")
class MutinyUniTest {

    @Test
    @DisplayName("Should emit single item")
    void testUniEmitsItem() {
        // Given
        Uni<String> uni = Uni.createFrom().item("Hello Mutiny");

        // When/Then
        uni.subscribe().withSubscriber(UniAssertSubscriber.create())
            .assertCompleted()
            .assertItem("Hello Mutiny");
    }

    @Test
    @DisplayName("Should verify item with assertion")
    void testUniWithAssertion() {
        Uni<Integer> uni = Uni.createFrom().item(42);

        uni.subscribe().withSubscriber(UniAssertSubscriber.create())
            .assertCompleted()
            .assertItem(42)
            .assertItem(value -> value > 40);
    }

    @Test
    @DisplayName("Should handle Uni failure")
    void testUniWithFailure() {
        Uni<String> uni = Uni.createFrom()
            .failure(new RuntimeException("Error occurred"));

        uni.subscribe().withSubscriber(UniAssertSubscriber.create())
            .assertFailedWith(RuntimeException.class, "Error occurred");
    }

    @Test
    @DisplayName("Should await item with timeout")
    void testUniWithTimeout() {
        Uni<String> uni = Uni.createFrom().item("Delayed")
            .onItem().delayIt().by(Duration.ofMillis(100));

        String result = uni.subscribe().withSubscriber(UniAssertSubscriber.create())
            .awaitItem(Duration.ofSeconds(1))
            .getItem();

        assertThat(result).isEqualTo("Delayed");
    }

    @Test
    @DisplayName("Should test Uni transformation")
    void testUniTransformation() {
        Uni<String> uni = Uni.createFrom().item("hello")
            .onItem().transform(String::toUpperCase);

        uni.subscribe().withSubscriber(UniAssertSubscriber.create())
            .assertCompleted()
            .assertItem("HELLO");
    }
}
```

### 2️⃣ Testing Multi - Múltiples Valores

```java
import io.smallrye.mutiny.Multi;
import io.smallrye.mutiny.helpers.test.AssertSubscriber;
import java.util.List;

@DisplayName("Mutiny Multi Tests")
class MutinyMultiTest {

    @Test
    @DisplayName("Should emit multiple items")
    void testMultiEmitsItems() {
        Multi<Integer> multi = Multi.createFrom().items(1, 2, 3, 4, 5);

        multi.subscribe().withSubscriber(AssertSubscriber.create(5))
            .assertCompleted()
            .assertItems(1, 2, 3, 4, 5);
    }

    @Test
    @DisplayName("Should emit items from iterable")
    void testMultiFromIterable() {
        List<String> items = List.of("A", "B", "C");
        Multi<String> multi = Multi.createFrom().iterable(items);

        multi.subscribe().withSubscriber(AssertSubscriber.create(3))
            .assertCompleted()
            .assertItems("A", "B", "C");
    }

    @Test
    @DisplayName("Should test Multi with filter")
    void testMultiWithFilter() {
        Multi<Integer> multi = Multi.createFrom().range(1, 11)
            .filter(n -> n % 2 == 0);

        multi.subscribe().withSubscriber(AssertSubscriber.create(10))
            .assertCompleted()
            .assertItems(2, 4, 6, 8, 10);
    }

    @Test
    @DisplayName("Should test Multi with map")
    void testMultiWithMap() {
        Multi<String> multi = Multi.createFrom().items("a", "b", "c")
            .onItem().transform(String::toUpperCase);

        multi.subscribe().withSubscriber(AssertSubscriber.create(3))
            .assertCompleted()
            .assertItems("A", "B", "C");
    }

    @Test
    @DisplayName("Should handle Multi with failure")
    void testMultiWithFailure() {
        Multi<Integer> multi = Multi.createFrom().items(1, 2, 3)
            .onItem().invoke(n -> {
                if (n == 3) throw new RuntimeException("Error at 3");
            });

        multi.subscribe().withSubscriber(AssertSubscriber.create(10))
            .assertFailedWith(RuntimeException.class, "Error at 3")
            .assertItems(1, 2);
    }

    @Test
    @DisplayName("Should test Multi with backpressure")
    void testMultiBackpressure() {
        Multi<Integer> multi = Multi.createFrom().range(1, 101);

        AssertSubscriber<Integer> subscriber = AssertSubscriber.create(10);
        multi.subscribe().withSubscriber(subscriber);

        // Only 10 items requested initially
        subscriber.assertNotTerminated().assertItems(List.of(1, 2, 3, 4, 5, 6, 7, 8, 9, 10));

        // Request 10 more
        subscriber.request(10);
        subscriber.assertItems(List.of(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20));
    }
}
```

### 3️⃣ Testing Servicios con Mutiny

```java
@DisplayName("Order Service Mutiny Tests")
class OrderServiceTest {

    @Mock
    private OrderRepository orderRepository;

    @InjectMocks
    private OrderService orderService;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    @DisplayName("Should create order successfully")
    void testCreateOrder() {
        // Given
        CreateOrderRequest request = new CreateOrderRequest("customer-1", List.of("item-1"));
        Order order = new Order("order-1", "customer-1", OrderStatus.PENDING);

        when(orderRepository.save(any(Order.class)))
            .thenReturn(Uni.createFrom().item(order));

        // When
        Uni<Order> result = orderService.createOrder(request);

        // Then
        result.subscribe().withSubscriber(UniAssertSubscriber.create())
            .assertCompleted()
            .assertItem(o -> o.getId().equals("order-1"))
            .assertItem(o -> o.getStatus() == OrderStatus.PENDING);

        verify(orderRepository).save(any(Order.class));
    }

    @Test
    @DisplayName("Should find order by id")
    void testFindOrderById() {
        Order order = new Order("order-1", "customer-1", OrderStatus.CONFIRMED);

        when(orderRepository.findById("order-1"))
            .thenReturn(Uni.createFrom().item(order));

        Uni<Order> result = orderService.findById("order-1");

        result.subscribe().withSubscriber(UniAssertSubscriber.create())
            .assertCompleted()
            .assertItem(order);
    }

    @Test
    @DisplayName("Should handle order not found")
    void testOrderNotFound() {
        when(orderRepository.findById("999"))
            .thenReturn(Uni.createFrom().nullItem());

        Uni<Order> result = orderService.findById("999");

        result.subscribe().withSubscriber(UniAssertSubscriber.create())
            .assertCompleted()
            .assertItem(null);
    }

    @Test
    @DisplayName("Should find all orders")
    void testFindAllOrders() {
        List<Order> orders = List.of(
            new Order("order-1", "customer-1", OrderStatus.PENDING),
            new Order("order-2", "customer-2", OrderStatus.CONFIRMED)
        );

        when(orderRepository.findAll())
            .thenReturn(Multi.createFrom().iterable(orders));

        Multi<Order> result = orderService.findAll();

        result.subscribe().withSubscriber(AssertSubscriber.create(10))
            .assertCompleted()
            .assertItems(orders.get(0), orders.get(1));
    }

    @Test
    @DisplayName("Should handle repository failure")
    void testRepositoryFailure() {
        when(orderRepository.findById("order-1"))
            .thenReturn(Uni.createFrom().failure(new DatabaseException("Connection failed")));

        Uni<Order> result = orderService.findById("order-1");

        result.subscribe().withSubscriber(UniAssertSubscriber.create())
            .assertFailedWith(DatabaseException.class, "Connection failed");
    }
}
```

### 4️⃣ Testing con Retry y Timeout

```java
@Test
@DisplayName("Should retry on failure")
void testRetryOnFailure() {
    when(orderRepository.findById("order-1"))
        .thenReturn(Uni.createFrom().failure(new TransientException("Temporary error")))
        .thenReturn(Uni.createFrom().failure(new TransientException("Temporary error")))
        .thenReturn(Uni.createFrom().item(new Order("order-1", "customer-1", OrderStatus.CONFIRMED)));

    Uni<Order> result = orderService.findByIdWithRetry("order-1");

    result.subscribe().withSubscriber(UniAssertSubscriber.create())
        .awaitItem(Duration.ofSeconds(5))
        .assertCompleted()
        .assertItem(o -> o.getId().equals("order-1"));

    verify(orderRepository, times(3)).findById("order-1");
}

@Test
@DisplayName("Should timeout after max duration")
void testTimeout() {
    Uni<String> uni = Uni.createFrom().item("Delayed")
        .onItem().delayIt().by(Duration.ofSeconds(10))
        .ifNoItem().after(Duration.ofSeconds(1)).fail();

    uni.subscribe().withSubscriber(UniAssertSubscriber.create())
        .awaitFailure(Duration.ofSeconds(2))
        .assertFailedWith(TimeoutException.class);
}
```

---

## 🔄 COMPARACIÓN DE FRAMEWORKS

| Feature             | WebFlux (StepVerifier) | RxJava (TestObserver)        | Mutiny (UniAssertSubscriber) |
| ------------------- | ---------------------- | ---------------------------- | ---------------------------- |
| **Single Value**    | `expectNext()`         | `assertValue()`              | `assertItem()`               |
| **Multiple Values** | `expectNext(1,2,3)`    | `assertValues(1,2,3)`        | `assertItems(1,2,3)`         |
| **Completion**      | `verifyComplete()`     | `assertComplete()`           | `assertCompleted()`          |
| **Error**           | `expectError()`        | `assertError()`              | `assertFailedWith()`         |
| **Count**           | `expectNextCount(n)`   | `assertValueCount(n)`        | Request n items              |
| **Predicate**       | `expectNextMatches()`  | `assertValue(predicate)`     | `assertItem(predicate)`      |
| **Virtual Time**    | `withVirtualTime()`    | `TestScheduler`              | Time-based delays            |
| **Timeout**         | `verify(Duration)`     | `await()` / `await(timeout)` | `awaitItem(Duration)`        |

---

## 🎯 PATRONES DE TESTING COMUNES

### 1️⃣ Testing Error Handling con Fallback

**WebFlux:**

```java
@Test
void testErrorWithFallback() {
    Mono<String> mono = Mono.error(new RuntimeException("Primary failed"))
        .onErrorResume(e -> Mono.just("Fallback"));

    StepVerifier.create(mono)
        .expectNext("Fallback")
        .verifyComplete();
}
```

**RxJava:**

```java
@Test
void testErrorWithFallback() {
    Single<String> single = Single.error(new RuntimeException("Primary failed"))
        .onErrorResumeNext(Single.just("Fallback"));

    single.test()
        .assertComplete()
        .assertValue("Fallback");
}
```

**Mutiny:**

```java
@Test
void testErrorWithFallback() {
    Uni<String> uni = Uni.createFrom().failure(new RuntimeException("Primary failed"))
        .onFailure().recoverWithItem("Fallback");

    uni.subscribe().withSubscriber(UniAssertSubscriber.create())
        .assertCompleted()
        .assertItem("Fallback");
}
```

### 2️⃣ Testing Transformaciones Encadenadas

**WebFlux:**

```java
@Test
void testChainedTransformations() {
    Flux<String> flux = Flux.just(1, 2, 3, 4, 5)
        .filter(n -> n % 2 == 0)
        .map(n -> "Number: " + n)
        .take(2);

    StepVerifier.create(flux)
        .expectNext("Number: 2")
        .expectNext("Number: 4")
        .verifyComplete();
}
```

**RxJava:**

```java
@Test
void testChainedTransformations() {
    Observable<String> observable = Observable.range(1, 5)
        .filter(n -> n % 2 == 0)
        .map(n -> "Number: " + n)
        .take(2);

    observable.test()
        .assertComplete()
        .assertValues("Number: 2", "Number: 4");
}
```

**Mutiny:**

```java
@Test
void testChainedTransformations() {
    Multi<String> multi = Multi.createFrom().range(1, 6)
        .filter(n -> n % 2 == 0)
        .onItem().transform(n -> "Number: " + n)
        .select().first(2);

    multi.subscribe().withSubscriber(AssertSubscriber.create(10))
        .assertCompleted()
        .assertItems("Number: 2", "Number: 4");
}
```

### 3️⃣ Testing Composición de Fuentes

**WebFlux (zip):**

```java
@Test
void testZipCombination() {
    Mono<String> firstName = Mono.just("John");
    Mono<String> lastName = Mono.just("Doe");

    Mono<String> fullName = Mono.zip(firstName, lastName,
        (first, last) -> first + " " + last);

    StepVerifier.create(fullName)
        .expectNext("John Doe")
        .verifyComplete();
}
```

**RxJava (zip):**

```java
@Test
void testZipCombination() {
    Single<String> firstName = Single.just("John");
    Single<String> lastName = Single.just("Doe");

    Single<String> fullName = Single.zip(firstName, lastName,
        (first, last) -> first + " " + last);

    fullName.test()
        .assertComplete()
        .assertValue("John Doe");
}
```

**Mutiny (combine):**

```java
@Test
void testCombination() {
    Uni<String> firstName = Uni.createFrom().item("John");
    Uni<String> lastName = Uni.createFrom().item("Doe");

    Uni<String> fullName = Uni.combine().all().unis(firstName, lastName)
        .asTuple()
        .onItem().transform(tuple -> tuple.getItem1() + " " + tuple.getItem2());

    fullName.subscribe().withSubscriber(UniAssertSubscriber.create())
        .assertCompleted()
        .assertItem("John Doe");
}
```

---

## 🧪 BEST PRACTICES

### ✅ DO

1. **Usa virtual time para tests largos**

```java
// ✅ Good: Completes instantly
StepVerifier.withVirtualTime(() -> Flux.interval(Duration.ofHours(1)).take(24))
    .thenAwait(Duration.ofDays(1))
    .expectNextCount(24)
    .verifyComplete();

// ❌ Bad: Takes 24 hours!
StepVerifier.create(Flux.interval(Duration.ofHours(1)).take(24))
    .expectNextCount(24)
    .verifyComplete();
```

2. **Verifica errores específicos**

```java
// ✅ Good: Specific error check
StepVerifier.create(mono)
    .expectErrorMatches(e ->
        e instanceof IllegalArgumentException &&
        e.getMessage().contains("Invalid")
    )
    .verify();

// ❌ Bad: Generic error check
StepVerifier.create(mono)
    .expectError()
    .verify();
```

3. **Usa predicates para validación compleja**

```java
// ✅ Good: Flexible validation
testObserver.assertValue(user ->
    user.getAge() >= 18 &&
    user.getEmail().contains("@") &&
    user.getName() != null
);
```

### ❌ DON'T

1. **No bloquees en tests reactivos**

```java
// ❌ Bad: Blocking defeats the purpose
String result = mono.block();
assertEquals("Expected", result);

// ✅ Good: Test reactively
StepVerifier.create(mono)
    .expectNext("Expected")
    .verifyComplete();
```

2. **No ignores errores**

```java
// ❌ Bad: Ignores potential errors
StepVerifier.create(flux)
    .expectNextCount(5)
    .verifyComplete();

// ✅ Good: Explicit error assertion
StepVerifier.create(flux)
    .expectNextCount(5)
    .expectComplete()
    .verify();
```

3. **No uses valores hardcoded cuando puedes validar lógica**

```java
// ❌ Bad: Hardcoded expectations
testObserver.assertValue("Result: 42");

// ✅ Good: Logic validation
testObserver.assertValue(result -> result.startsWith("Result:"));
```

---

## 📊 CHEATSHEET RÁPIDO

```java
// WEBFLUX
StepVerifier.create(mono).expectNext(value).verifyComplete();
StepVerifier.create(flux).expectNextCount(5).verifyComplete();
StepVerifier.create(mono).expectError(Exception.class).verify();

// RXJAVA
single.test().assertComplete().assertValue(value);
observable.test().assertComplete().assertValues(v1, v2, v3);
single.test().assertError(Exception.class);

// MUTINY
uni.subscribe().withSubscriber(UniAssertSubscriber.create()).assertItem(value);
multi.subscribe().withSubscriber(AssertSubscriber.create(10)).assertItems(v1, v2);
uni.subscribe().withSubscriber(UniAssertSubscriber.create()).assertFailedWith(Exception.class);
```

---

**💡 RECUERDA:** Testing reactivo requiere pensar de forma asíncrona. Usa las herramientas específicas de cada framework para validar streams completos, no solo valores individuales.
