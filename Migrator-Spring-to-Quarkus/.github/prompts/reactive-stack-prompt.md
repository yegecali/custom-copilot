# System Prompt: Reactive Stack Migration (RxJava → Mutiny)

## Context

You are helping transform a reactive codebase from RxJava/Reactor to Mutiny, Quarkus's preferred reactive library.

## Why Mutiny?

- **Designed for Quarkus** - Native integration, zero overhead
- **Simpler API** - Cleaner, more intuitive than RxJava
- **Better Performance** - Optimized for cloud-native workloads
- **Less Boilerplate** - Fewer operators, more straightforward code

## Core Concepts

### Uni vs Multi

**Uni<T>** = Single result or error (0 or 1 item)

```
Success: ──────→T└
Error:   ──────→✗
```

**Multi<T>** = Stream of items (0 to many items)

```
Items:   ──→T─→T─→T─→T└
Error:   ──→T─→T─→✗
Complete:──→T─→T─→T└
```

### Observable → Uni Decision Tree

```
Does it emit:
├─ Exactly 1 item? → Uni<T>
├─ 0 or 1 items (Maybe)? → Uni<Optional<T>>
├─ Many items? → Multi<T>
└─ Just complete (no items)? → Uni<Void>
```

## The Transformation Process

### 1. Identify Observable Types

```java
// COUNT THESE:
Observable<T>      // ← Usually becomes Uni<T>
Flowable<T>        // ← Usually becomes Multi<T>
Single<T>          // ← Becomes Uni<T>
Maybe<T>           // ← Becomes Uni<Optional<T>>
Completable        // ← Becomes Uni<Void>
```

### 2. Replace Types

```
Observable<User> → Uni<User>
Flowable<Message> → Multi<Message>
Single<Response> → Uni<Response>
Maybe<Data> → Uni<Optional<Data>>
Completable → Uni<Void>
```

### 3. Operator Mapping

| RxJava          | Mutiny                     | Equivalent            | Notes              |
| --------------- | -------------------------- | --------------------- | ------------------ |
| `.map(f)`       | `.map(f)`                  | Transform item        | Same behavior      |
| `.flatMap(f)`   | `.flatMap(f)`              | Chain Uni             | Same behavior      |
| `.filter(p)`    | `.filter(p)`               | Keep if true          | Same behavior      |
| `.switchMap(f)` | `.flatMap(f)`              | Flatten subscriptions | Similar            |
| `.onError*`     | `.onFailure()`             | Handle failure        | Different API      |
| `.retry(n)`     | `.retry()`                 | Retry on failure      | More flexible      |
| `.timeout()`    | `.ifNoItem()`              | Timeout handling      | Different approach |
| `.cache()`      | `.cache()`                 | Cache result          | Same behavior      |
| `.distinct()`   | `.skip(1)`                 | Remove duplicates     | Manual in Mutiny   |
| `.buffer()`     | `.group(n).collectAsUni()` | Batch items           | Different          |

### 4. Subscription Changes

#### RxJava Style

```java
observable.subscribe(
    item -> { /* handle */ },
    error -> { /* handle */ },
    () -> { /* complete */ }
);
```

#### Mutiny Style

```java
uni.subscribe()
    .with(
        item -> { /* handle */ },
        error -> { /* handle */ }
    );

// Or with separate callbacks:
uni.subscribe()
    .with(
        Emitter::complete,           // success
        Emitter::fail               // failure
    );
```

## Common Transformations

### 1. Simple Observable → Uni

**Before:**

```java
Observable<User> getUser(String id) {
    return api.getUser(id)
        .subscribeOn(Schedulers.io())
        .observeOn(Schedulers.mainThread());
}

// Usage
getUser("123").subscribe(
    user -> System.out.println(user),
    error -> error.printStackTrace()
);
```

**After:**

```java
Uni<User> getUser(String id) {
    return api.getUser(id);
    // Threading managed automatically
}

// Usage
getUser("123").subscribe()
    .with(
        user -> System.out.println(user),
        error -> error.printStackTrace()
    );
```

### 2. FlatMap Chain

**Before:**

```java
Observable<Order> getOrderWithItems(String orderId) {
    return api.getOrder(orderId)
        .flatMap(order ->
            api.getOrderItems(orderId)
                .map(items -> {
                    order.setItems(items);
                    return order;
                })
        );
}
```

**After:**

```java
Uni<Order> getOrderWithItems(String orderId) {
    return api.getOrder(orderId)
        .flatMap(order ->
            api.getOrderItems(orderId)
                .map(items -> {
                    order.setItems(items);
                    return order;
                })
        );
}
```

### 3. Error Recovery

**Before:**

```java
Observable<Data> getData(String id) {
    return api.getData(id)
        .timeout(5, TimeUnit.SECONDS)
        .retry(3)
        .onErrorResumeNext(error -> {
            if (error instanceof NotFoundException) {
                return Observable.just(new Data());
            }
            return Observable.error(error);
        });
}
```

**After:**

```java
Uni<Data> getData(String id) {
    return api.getData(id)
        .ifNoItem()
        .after(Duration.ofSeconds(5))
        .fail()
        .retry()
        .withBackOff(Duration.ofMillis(100))
        .atMost(3)
        .onFailure(NotFoundException.class)
        .recoverWithItem(new Data());
}
```

### 4. Flowable → Multi (Streaming)

**Before:**

```java
Flowable<Message> streamMessages(String channel) {
    return api.subscribeToChannel(channel)
        .subscribeOn(Schedulers.io())
        .buffer(50)
        .subscribe(batch -> processBatch(batch));
}
```

**After:**

```java
Multi<Message> streamMessages(String channel) {
    return api.subscribeToChannel(channel);
    // Threading automatic, backpressure built-in
}

// Usage in batches
streamMessages("channel")
    .select()
    .first(50)
    .collect()
    .asList()
    .subscribe()
    .with(batch -> processBatch(batch));
```

### 5. Combinelatest → Uni.combine

**Before:**

```java
Observable<Report> generateReport(String id) {
    return Observable.combineLatest(
        api.getSales(id),
        api.getCosts(id),
        api.getMetrics(id),
        (sales, costs, metrics) -> {
            Report r = new Report();
            r.setSales(sales);
            r.setCosts(costs);
            r.setMetrics(metrics);
            return r;
        }
    );
}
```

**After:**

```java
Uni<Report> generateReport(String id) {
    return Uni.combine().all()
        .unis(
            api.getSales(id),
            api.getCosts(id),
            api.getMetrics(id)
        )
        .asTuple()
        .map(tuple -> {
            Report r = new Report();
            r.setSales(tuple.getItem1());
            r.setCosts(tuple.getItem2());
            r.setMetrics(tuple.getItem3());
            return r;
        });
}
```

## Testing Reactive Code

### Before (RxJava)

```java
@Test
void testObservable() {
    observable.test()
        .assertValue(expected)
        .assertComplete()
        .assertNoErrors();
}
```

### After (Mutiny)

```java
@Test
void testUni() {
    UniAssertSubscriber<T> subscriber = uni
        .subscribe()
        .withSubscriber(UniAssertSubscriber.create());

    subscriber.assertCompleted()
              .assertItem(expected);
}
```

## Dependency Changes

**Remove:**

```xml
<!-- RxJava -->
<dependency>
    <groupId>io.reactivex.rxjava2</groupId>
    <artifactId>rxjava</artifactId>
</dependency>

<!-- Or RxJava3 -->
<dependency>
    <groupId>io.reactivex.rxjava3</groupId>
    <artifactId>rxjava</artifactId>
</dependency>

<!-- Reactor (if used) -->
<dependency>
    <groupId>org.springframework</groupId>
    <artifactId>spring-webflux</artifactId>
</dependency>
```

**Add:**

```xml
<!-- Mutiny -->
<dependency>
    <groupId>io.quarkus</groupId>
    <artifactId>quarkus-mutiny</artifactId>
</dependency>
```

## Validation Checklist

- [ ] All RxJava imports removed from code
- [ ] All Observable/Flowable replaced with Uni/Multi
- [ ] All subscribeOn/observeOn removed
- [ ] Error handling uses .onFailure()
- [ ] Retry logic uses .retry()
- [ ] Timeout handled with .ifNoItem().after()
- [ ] No RxJava dependencies in pom.xml
- [ ] Tests use UniAssertSubscriber
- [ ] All tests pass
- [ ] Code compiles without warnings

## Performance Expectations

After migration to Mutiny in Quarkus:

✅ **Startup Time:** 30-50% faster
✅ **Memory Usage:** 40-60% less
✅ **Throughput:** 2-5x higher
✅ **Latency:** More predictable
✅ **GC Pauses:** Significantly reduced

## Next Steps

1. Complete this reactive stack migration
2. Run all tests
3. Performance test comparison with original
4. Document any behavioral differences
