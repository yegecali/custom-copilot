# Migración: Stack Reactivo (RxJava → Mutiny)

## 🎯 Objetivo

Convertir operaciones reactivas de RxJava/Reactor a Mutiny (stack reactivo nativo de Quarkus).

## 📋 Prerequisitos

- [ ] REST Client Reactive migrado
- [ ] DTOs/Modelos disponibles
- [ ] Dependencia Mutiny agregada

## 📚 Mapeo: RxJava → Mutiny

### Observable vs Uni/Multi

| RxJava          | Mutiny             | Caso                          |
| --------------- | ------------------ | ----------------------------- |
| `Observable<T>` | `Uni<T>`           | 1 o 0 items                   |
| `Flowable<T>`   | `Multi<T>`         | Múltiples items, backpressure |
| `Single<T>`     | `Uni<T>`           | Exactamente 1 item            |
| `Completable`   | `Uni<Void>`        | Sin retorno                   |
| `Maybe<T>`      | `Uni<Optional<T>>` | 0 o 1 item                    |

## 🔄 Operadores Comunes

| RxJava 2         | Mutiny         | Descripción            |
| ---------------- | -------------- | ---------------------- |
| `.subscribe()`   | `.subscribe()` | Suscribirse al stream  |
| `.map(f)`        | `.map(f)`      | Transformar items      |
| `.flatMap(f)`    | `.flatMap(f)`  | Transformar a otro Uni |
| `.filter(p)`     | `.filter(p)`   | Filtrar items          |
| `.onError()`     | `.onFailure()` | Manejar errores        |
| `.subscribeOn()` | (automático)   | Threading              |
| `.observeOn()`   | (automático)   | Threading              |
| `.timeout()`     | `.ifNoItem()`  | Timeout                |
| `.retry()`       | `.retry()`     | Reintentos             |
| `.cache()`       | `.cache()`     | Cachear resultado      |

## 📝 Paso 1: Agregar Dependencia Mutiny

### pom.xml

```xml
<dependency>
    <groupId>io.quarkus</groupId>
    <artifactId>quarkus-mutiny</artifactId>
</dependency>

<!-- Para integración con REST -->
<dependency>
    <groupId>io.quarkus</groupId>
    <artifactId>quarkus-resteasy-reactive</artifactId>
</dependency>
```

## 📝 Paso 2: Ejemplos de Conversión

### Ejemplo 1: Observable Simple → Uni

#### RxJava (Antes)

```java
public Observable<Pet> getPet(String id) {
    return api.getPetById(id)
        .subscribeOn(Schedulers.io())
        .observeOn(Schedulers.mainThread());
}

// Uso
getPet("123")
    .subscribe(
        pet -> System.out.println("Pet: " + pet),
        error -> System.err.println("Error: " + error)
    );
```

#### Mutiny (Después)

```java
public Uni<Pet> getPet(String id) {
    return api.getPetById(id);
    // Mutiny maneja threading automáticamente
}

// Uso
getPet("123")
    .subscribe()
    .with(
        pet -> System.out.println("Pet: " + pet),
        error -> System.err.println("Error: " + error)
    );

// O en REST endpoint (retorna directamente)
@GET
@Path("/{id}")
public Uni<Pet> getPet(@PathParam("id") String id) {
    return service.getPet(id);
}
```

### Ejemplo 2: FlatMap con múltiples llamadas

#### RxJava (Antes)

```java
public Observable<PetWithOwner> getPetWithOwner(String petId) {
    return api.getPetById(petId)
        .subscribeOn(Schedulers.io())
        .flatMap(pet ->
            api.getOwner(pet.getOwnerId())
                .map(owner -> new PetWithOwner(pet, owner))
        );
}

// Uso
getPetWithOwner("123")
    .subscribe(petWithOwner -> {
        System.out.println("Pet: " + petWithOwner.getPet());
        System.out.println("Owner: " + petWithOwner.getOwner());
    });
```

#### Mutiny (Después)

```java
public Uni<PetWithOwner> getPetWithOwner(String petId) {
    return api.getPetById(petId)
        .flatMap(pet ->
            api.getOwner(pet.getOwnerId())
                .map(owner -> new PetWithOwner(pet, owner))
        );
}

// Uso
getPetWithOwner("123")
    .subscribe()
    .with(petWithOwner -> {
        System.out.println("Pet: " + petWithOwner.getPet());
        System.out.println("Owner: " + petWithOwner.getOwner());
    });

// O en REST endpoint
@GET
@Path("/{id}/with-owner")
public Uni<PetWithOwner> getPetWithOwner(@PathParam("id") String id) {
    return service.getPetWithOwner(id);
}
```

### Ejemplo 3: Error Handling

#### RxJava (Antes)

```java
public Observable<Pet> getPetWithFallback(String id) {
    return api.getPetById(id)
        .subscribeOn(Schedulers.io())
        .onErrorResumeNext(error -> {
            if (error instanceof NotFoundException) {
                return Observable.just(new Pet());
            }
            return Observable.error(error);
        })
        .timeout(5, TimeUnit.SECONDS)
        .retry(3);
}
```

#### Mutiny (Después)

```java
public Uni<Pet> getPetWithFallback(String id) {
    return api.getPetById(id)
        .onFailure(NotFoundException.class)
        .recoverWithItem(new Pet())
        .ifNoItem()
        .after(Duration.ofSeconds(5))
        .fail()
        .retry()
        .withBackOff(Duration.ofMillis(100))
        .atMost(3);
}

// Alternativa con handler
public Uni<Pet> getPetWithFallback(String id) {
    return api.getPetById(id)
        .onFailure()
        .invoke(failure ->
            System.err.println("Error fetching pet: " + failure.getMessage())
        )
        .onFailure()
        .recoverWithItem(() -> createDefaultPet());
}
```

### Ejemplo 4: Múltiples operaciones en paralelo

#### RxJava (Antes)

```java
public Observable<PetStore> getPetStoreWithCounts(String storeId) {
    return Observable.combineLatest(
        api.getPetStoreById(storeId),
        api.countPetsInStore(storeId),
        api.countOrdersInStore(storeId),
        (store, petCount, orderCount) -> {
            store.setPetCount(petCount);
            store.setOrderCount(orderCount);
            return store;
        }
    );
}
```

#### Mutiny (Después)

```java
public Uni<PetStore> getPetStoreWithCounts(String storeId) {
    return Uni.combine().all()
        .unis(
            api.getPetStoreById(storeId),
            api.countPetsInStore(storeId),
            api.countOrdersInStore(storeId)
        )
        .asTuple()
        .map(tuple -> {
            PetStore store = tuple.getItem1();
            Integer petCount = tuple.getItem2();
            Integer orderCount = tuple.getItem3();

            store.setPetCount(petCount);
            store.setOrderCount(orderCount);
            return store;
        });
}
```

### Ejemplo 5: Operaciones en secuencia

#### RxJava (Antes)

```java
public Observable<String> createPetAndNotify(Pet pet, String ownerId) {
    return api.createPet(pet)
        .flatMap(createdPet ->
            api.assignOwner(createdPet.getId(), ownerId)
                .flatMap(v -> api.notifyOwner(ownerId, createdPet))
                .map(v -> "Pet created and owner notified")
        );
}
```

#### Mutiny (Después)

```java
public Uni<String> createPetAndNotify(Pet pet, String ownerId) {
    return api.createPet(pet)
        .flatMap(createdPet ->
            api.assignOwner(createdPet.getId(), ownerId)
                .flatMap(v -> api.notifyOwner(ownerId, createdPet))
                .map(v -> "Pet created and owner notified")
        );
}
```

## 📝 Paso 3: Trabajar con Streams (Multi)

### Flowable → Multi

#### RxJava (Antes)

```java
public Flowable<Pet> streamPets(String storeId) {
    return api.streamPets(storeId)
        .subscribeOn(Schedulers.io())
        .backpressure(BackpressureStrategy.BUFFER);
}

// Uso con buffer
streamPets("store-1")
    .buffer(10)
    .subscribe(pets -> System.out.println("Batch: " + pets));
```

#### Mutiny (Después)

```java
public Multi<Pet> streamPets(String storeId) {
    return api.streamPets(storeId);
}

// Uso con buffer
streamPets("store-1")
    .select().first(10)
    .collect()
    .asList()
    .subscribe()
    .with(pets -> System.out.println("Batch: " + pets));

// O directamente en streaming
@GET
@Path("/stream/{storeId}")
@Produces(MediaType.SERVER_SENT_EVENTS)
public Multi<Pet> streamPets(@PathParam("storeId") String storeId) {
    return service.streamPets(storeId);
}
```

## 📝 Paso 4: Testing con Mutiny

### Test básico

```java
// quarkus-project/src/test/java/com/example/PetServiceTest.java
package com.example;

import io.quarkus.test.junit.QuarkusTest;
import io.smallrye.mutiny.Uni;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

@QuarkusTest
public class PetServiceTest {

    @Test
    void testGetPet() {
        Uni<Pet> result = service.getPet("123");

        Pet pet = result
            .subscribeAsCompletionStage()
            .toCompletableFuture()
            .join();

        assertNotNull(pet);
    }

    // O más simple
    @Test
    void testGetPetSimple() {
        service.getPet("123")
            .subscribe()
            .with(
                pet -> assertNotNull(pet),
                failure -> fail("Should not fail: " + failure)
            );
    }
}
```

## 📝 Paso 5: Cambios en Application Properties

```properties
# Threading/Executor
quarkus.thread-pool.core-threads=10
quarkus.thread-pool.max-threads=50
quarkus.thread-pool.queue-size=100

# REST Reactive
quarkus.rest-client.connect-timeout=5000
quarkus.rest-client.read-timeout=10000

# Mutiny
quarkus.mutiny.log-skipped-exceptions=false
```

## ✅ Checklist

- [ ] Dependencia `quarkus-mutiny` agregada
- [ ] Observable → Uni convertidas
- [ ] flatMap implementado correctamente
- [ ] Error handling configurado
- [ ] Retry/timeout implementados
- [ ] Multi para streams (si aplica)
- [ ] Tests creados
- [ ] Compilación sin errores
- [ ] Comportamiento coincide con original

## 📚 Recursos

- [Mutiny Docs](https://smallrye.io/smallrye-mutiny/)
- [Mutiny Cheat Sheet](https://smallrye.io/smallrye-mutiny/guides/binding-events-guide)
- [Quarkus Reactive](https://quarkus.io/guides/getting-started-reactive)

## 🔗 Siguiente Paso

→ Ir a `05-CONFIGURATION.md`
