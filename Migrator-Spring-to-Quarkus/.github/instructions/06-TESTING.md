# Testing en Quarkus

## 🎯 Objetivo

Crear tests completos para proyecto Quarkus migrado, validando REST Client, endpoints y lógica reactiva.

## 📋 Cambios en Testing

| Spring                    | Quarkus         | Notas             |
| ------------------------- | --------------- | ----------------- |
| `@SpringBootTest`         | `@QuarkusTest`  | Test runtime      |
| `MockMvc`                 | `Rest Assured`  | Testing REST      |
| `@MockBean`               | `@InjectMock`   | Mock beans        |
| `TestRestTemplate`        | `Rest Assured`  | Cliente HTTP test |
| Reactor/RxJava assertions | Mutiny-specific | Assertions async  |

## 📝 Paso 1: Agregar Dependencias de Test

### pom.xml

```xml
<dependency>
    <groupId>io.quarkus</groupId>
    <artifactId>quarkus-junit5</artifactId>
    <scope>test</scope>
</dependency>

<dependency>
    <groupId>io.rest-assured</groupId>
    <artifactId>rest-assured</artifactId>
    <scope>test</scope>
</dependency>

<!-- Para mocking -->
<dependency>
    <groupId>org.mockito</groupId>
    <artifactId>mockito-inline</artifactId>
    <scope>test</scope>
</dependency>

<!-- Para testing reactivo -->
<dependency>
    <groupId>io.smallrye.reactive</groupId>
    <artifactId>smallrye-mutiny-junit5</artifactId>
    <scope>test</scope>
</dependency>
```

## 📝 Paso 2: Test Básico de REST Endpoint

### Antes (Spring)

```java
// original-spring/src/test/java/com/example/controller/PetControllerTest.java
package com.example.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.web.servlet.MockMvc;
import org.junit.jupiter.api.Test;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
public class PetControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void testListPets() throws Exception {
        mockMvc.perform(get("/api/pets")
                .param("limit", "10"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$[0].name").exists());
    }
}
```

### Después (Quarkus)

```java
// quarkus-project/src/test/java/com/example/resource/PetResourceTest.java
package com.example.resource;

import io.quarkus.test.junit.QuarkusTest;
import io.restassured.RestAssured;
import org.junit.jupiter.api.Test;

import static io.restassured.RestAssured.*;
import static org.hamcrest.Matchers.*;

@QuarkusTest
public class PetResourceTest {

    @Test
    void testListPets() {
        given()
            .queryParam("limit", 10)
        .when()
            .get("/api/pets")
        .then()
            .statusCode(200)
            .body("$", hasSize(greaterThan(0)))
            .body("[0].name", notNullValue());
    }

    @Test
    void testGetPetById() {
        given()
        .when()
            .get("/api/pets/1")
        .then()
            .statusCode(200)
            .body("id", equalTo(1))
            .body("name", notNullValue());
    }

    @Test
    void testCreatePet() {
        String pet = "{ \"name\": \"Fluffy\", \"type\": \"cat\" }";

        given()
            .contentType("application/json")
            .body(pet)
        .when()
            .post("/api/pets")
        .then()
            .statusCode(201)
            .body("name", equalTo("Fluffy"));
    }
}
```

## 📝 Paso 3: Test con Mock de REST Client

```java
// quarkus-project/src/test/java/com/example/service/PetServiceTest.java
package com.example.service;

import io.quarkus.test.junit.QuarkusTest;
import io.quarkus.test.InjectMock;
import io.smallrye.mutiny.Uni;
import org.eclipse.microprofile.rest.client.inject.RestClient;
import org.junit.jupiter.api.Test;

import com.example.client.PetStoreApi;
import com.example.api.generated.model.Pet;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@QuarkusTest
public class PetServiceTest {

    @InjectMock
    @RestClient
    PetStoreApi api;

    // El servicio se inyecta automáticamente con el mock
    private PetService service = new PetService(api);

    @Test
    void testGetPet() {
        // Arrange
        Pet expectedPet = new Pet();
        expectedPet.setId("123");
        expectedPet.setName("Fluffy");

        when(api.getPetById("123"))
            .thenReturn(Uni.createFrom().item(expectedPet));

        // Act
        Uni<Pet> result = service.getPet("123");
        Pet pet = result
            .subscribeAsCompletionStage()
            .toCompletableFuture()
            .join();

        // Assert
        assertNotNull(pet);
        assertEquals("Fluffy", pet.getName());
        verify(api, times(1)).getPetById("123");
    }

    @Test
    void testGetPetWithError() {
        // Arrange
        when(api.getPetById("999"))
            .thenReturn(Uni.createFrom().failure(
                new Exception("Pet not found")
            ));

        // Act & Assert
        Uni<Pet> result = service.getPet("999");

        result.subscribe().with(
            item -> fail("Should have failed"),
            failure -> assertEquals("Pet not found", failure.getMessage())
        );
    }
}
```

## 📝 Paso 4: Test Reactivo con Mutiny

```java
// quarkus-project/src/test/java/com/example/ReactiveTest.java
package com.example;

import io.quarkus.test.junit.QuarkusTest;
import io.smallrye.mutiny.Uni;
import io.smallrye.mutiny.helpers.test.UniAssertSubscriber;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

@QuarkusTest
public class ReactiveTest {

    @Test
    void testUniSuccess() {
        // Crear Uni
        Uni<String> uni = Uni.createFrom().item("Hello");

        // Hacer assert con subscriber
        UniAssertSubscriber<String> subscriber = uni
            .subscribe()
            .withSubscriber(UniAssertSubscriber.create());

        subscriber.assertCompleted()
                  .assertItem("Hello");
    }

    @Test
    void testUniWithTransformation() {
        Uni<Integer> uni = Uni.createFrom().item(5)
            .map(n -> n * 2)
            .map(n -> n + 1);

        UniAssertSubscriber<Integer> subscriber = uni
            .subscribe()
            .withSubscriber(UniAssertSubscriber.create());

        subscriber.assertCompleted()
                  .assertItem(11);
    }

    @Test
    void testUniWithError() {
        Uni<String> uni = Uni.createFrom()
            .failure(new Exception("Test error"));

        UniAssertSubscriber<String> subscriber = uni
            .subscribe()
            .withSubscriber(UniAssertSubscriber.create());

        subscriber.assertFailedWith(Exception.class, "Test error");
    }

    @Test
    void testUniFlatMap() {
        Uni<String> uni = Uni.createFrom().item("test")
            .flatMap(str -> Uni.createFrom().item(str.toUpperCase()));

        UniAssertSubscriber<String> subscriber = uni
            .subscribe()
            .withSubscriber(UniAssertSubscriber.create());

        subscriber.assertCompleted()
                  .assertItem("TEST");
    }
}
```

## 📝 Paso 5: Test de Integración

```java
// quarkus-project/src/test/java/com/example/IntegrationTest.java
package com.example;

import io.quarkus.test.common.QuarkusTestResource;
import io.quarkus.test.junit.QuarkusTest;
import io.restassured.RestAssured;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.testcontainers.containers.MySQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

import static io.restassured.RestAssured.*;
import static org.hamcrest.Matchers.*;

@QuarkusTest
@Testcontainers
@QuarkusTestResource(DatabaseTestResource.class)
public class IntegrationTest {

    @Container
    static MySQLContainer<?> database = new MySQLContainer<>(
        "mysql:8.0"
    ).withDatabaseName("petstore_test");

    @BeforeEach
    void setup() {
        RestAssured.basePath = "/api";
    }

    @Test
    void testFullFlow() {
        // 1. Crear mascota
        String petResponse = given()
            .contentType("application/json")
            .body("{ \"name\": \"Fluffy\", \"type\": \"cat\" }")
        .when()
            .post("/pets")
        .then()
            .statusCode(201)
            .extract()
            .asString();

        // 2. Obtener mascota
        given()
        .when()
            .get("/pets/1")
        .then()
            .statusCode(200)
            .body("name", equalTo("Fluffy"));

        // 3. Listar mascotas
        given()
        .when()
            .get("/pets")
        .then()
            .statusCode(200)
            .body("$", hasSize(greaterThan(0)));
    }
}
```

## 📝 Paso 6: Test Database Resource

```java
// quarkus-project/src/test/java/com/example/DatabaseTestResource.java
package com.example;

import io.quarkus.test.common.QuarkusTestResourceLifecycleManager;
import org.testcontainers.containers.MySQLContainer;

import java.util.Map;

public class DatabaseTestResource
    implements QuarkusTestResourceLifecycleManager {

    private MySQLContainer<?> mysql;

    @Override
    public Map<String, String> start() {
        mysql = new MySQLContainer<>("mysql:8.0")
            .withDatabaseName("petstore_test")
            .withUsername("test")
            .withPassword("test");

        mysql.start();

        return Map.of(
            "quarkus.datasource.jdbc.url", mysql.getJdbcUrl(),
            "quarkus.datasource.username", mysql.getUsername(),
            "quarkus.datasource.password", mysql.getPassword()
        );
    }

    @Override
    public void stop() {
        if (mysql != null) {
            mysql.stop();
        }
    }
}
```

## 📝 Paso 7: Test Profile Específico

**application-test.properties:**

```properties
quarkus.datasource.db-kind=h2
quarkus.datasource.jdbc.url=jdbc:h2:mem:test
quarkus.datasource.username=sa
quarkus.datasource.password=
quarkus.datasource.jdbc.driver=org.h2.Driver

quarkus.hibernate-orm.database.generation=create-drop
quarkus.hibernate-orm.log.sql=false

# Desactivar external APIs en tests
quarkus.rest-client.petstore-api.url=http://localhost:9999
```

## ✅ Checklist

- [ ] Dependencias de test agregadas
- [ ] Tests de REST endpoints creados
- [ ] Mocks de REST Client configurados
- [ ] Tests reactivos con UniAssertSubscriber
- [ ] Tests de integración con contenedores
- [ ] Profile de test configurado
- [ ] Todos los tests pasan
- [ ] Cobertura > 80%

## 🏃 Ejecutar Tests

```bash
# Todos los tests
mvn test

# Test específico
mvn test -Dtest=PetResourceTest

# Con cobertura
mvn test jacoco:report

# En modo watch
mvn quarkus:test
```

## 🔗 Documentación Migración Completa

Fases completadas:

1. ✅ [01-MIGRATION-OVERVIEW.md](01-MIGRATION-OVERVIEW.md)
2. ✅ [02-RETROFIT-MIGRATION.md](02-RETROFIT-MIGRATION.md)
3. ✅ [03-OPENAPI-MIGRATION.md](03-OPENAPI-MIGRATION.md)
4. ✅ [04-REACTIVE-STACK.md](04-REACTIVE-STACK.md)
5. ✅ [05-CONFIGURATION.md](05-CONFIGURATION.md)
6. ✅ [06-TESTING.md](06-TESTING.md) ← AQUÍ

---

**Próximo: Crear documentos skills y prompts**
