# Migración: Retrofit → Quarkus REST Client Reactive

## 🎯 Objetivo

Convertir cliente HTTP de Retrofit (sync) a Quarkus REST Client Reactive (async).

## 📋 Prerequisitos

- [ ] Proyecto original analizado
- [ ] Dependencias Retrofit documentadas
- [ ] Interfaces Retrofit identificadas
- [ ] Quarkus base creado

## 🔄 Mapeo de Conceptos

| Retrofit             | Quarkus REST Client                    | Diferencia                       |
| -------------------- | -------------------------------------- | -------------------------------- |
| `@GET`               | `@GET`                                 | Idéntico                         |
| `@POST`              | `@POST`                                | Idéntico                         |
| `@Path`              | `@PathParam`                           | Cambio de nombre                 |
| `@Query`             | `@QueryParam`                          | Cambio de nombre                 |
| `@Body`              | `@RestForm` o body                     | Cambio según tipo                |
| `Call<T>`            | `Uni<T>`                               | Async callback → Reactive stream |
| `Observable<T>`      | `Uni<T>` / `Multi<T>`                  | RxJava → Mutiny                  |
| `interface + @GET`   | `@RegisterRestClient interface + @GET` | Agregar registro                 |
| `Retrofit.Builder()` | `@RegisterRestClient`                  | Declarativo vs imperativo        |

## 📝 Paso 1: Agregar Dependencia Quarkus

### pom.xml

```xml
<dependency>
    <groupId>io.quarkus</groupId>
    <artifactId>quarkus-rest-client-reactive</artifactId>
</dependency>

<!-- Si usas JsonB para serialización -->
<dependency>
    <groupId>io.quarkus</groupId>
    <artifactId>quarkus-resteasy-reactive-jsonb</artifactId>
</dependency>

<!-- O Jackson -->
<dependency>
    <groupId>io.quarkus</groupId>
    <artifactId>quarkus-resteasy-reactive-jackson</artifactId>
</dependency>
```

### Remover dependencias Retrofit

```xml
<!-- REMOVER ESTO -->
<!-- <dependency>
    <groupId>com.squareup.retrofit2</groupId>
    <artifactId>retrofit</artifactId>
</dependency>
<dependency>
    <groupId>com.squareup.retrofit2</groupId>
    <artifactId>converter-jackson</artifactId>
</dependency>
<dependency>
    <groupId>com.squareup.retrofit2</groupId>
    <artifactId>adapter-rxjava2</artifactId>
</dependency> -->
```

## 📝 Paso 2: Convertir Interfaz Retrofit

### Ejemplo Original (Retrofit + RxJava)

```java
// original-spring/src/main/java/com/example/client/PetStoreApi.java
import retrofit2.http.*;
import io.reactivex.Observable;

public interface PetStoreApi {

    @GET("pets")
    Observable<List<Pet>> listPets(@Query("limit") int limit);

    @GET("pets/{petId}")
    Observable<Pet> getPetById(@Path("petId") String petId);

    @POST("pets")
    Observable<Pet> createPet(@Body Pet pet);

    @PUT("pets/{petId}")
    Observable<Pet> updatePet(
        @Path("petId") String petId,
        @Body Pet pet
    );

    @DELETE("pets/{petId}")
    Observable<Void> deletePet(@Path("petId") String petId);
}
```

### Nueva Interfaz (Quarkus REST Client)

```java
// quarkus-project/src/main/java/com/example/client/PetStoreApi.java
package com.example.client;

import org.eclipse.microprofile.rest.client.inject.RegisterRestClient;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import io.smallrye.mutiny.Uni;
import java.util.List;

@RegisterRestClient(configKey = "petstore-api")
@Path("/api")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public interface PetStoreApi {

    @GET
    @Path("/pets")
    Uni<List<Pet>> listPets(@QueryParam("limit") int limit);

    @GET
    @Path("/pets/{petId}")
    Uni<Pet> getPetById(@PathParam("petId") String petId);

    @POST
    @Path("/pets")
    Uni<Pet> createPet(Pet pet);

    @PUT
    @Path("/pets/{petId}")
    Uni<Pet> updatePet(
        @PathParam("petId") String petId,
        Pet pet
    );

    @DELETE
    @Path("/pets/{petId}")
    Uni<Void> deletePet(@PathParam("petId") String petId);
}
```

## 📝 Paso 3: Configurar Cliente en application.properties

### application.properties

```properties
# Configuración REST Client
quarkus.rest-client.petstore-api.url=https://petstore.api.example.com
quarkus.rest-client.petstore-api.connect-timeout=5000
quarkus.rest-client.petstore-api.read-timeout=10000

# Para desarrollo (desactivar SSL)
quarkus.rest-client.petstore-api.verify-host=false
quarkus.tls.trust-all=true

# Headers por defecto (si es necesario)
# quarkus.rest-client.petstore-api.default-header-X-API-Key=your-key
```

### application.yml (alternativa)

```yaml
quarkus:
  rest-client:
    petstore-api:
      url: https://petstore.api.example.com
      connect-timeout: 5000
      read-timeout: 10000
      verify-host: false
```

## 📝 Paso 4: Inyectar y Usar Cliente

### Service (Spring)

```java
// original-spring/
import org.springframework.stereotype.Service;
import retrofit2.Retrofit;

@Service
public class PetService {
    private PetStoreApi api;

    public PetService(Retrofit retrofit) {
        this.api = retrofit.create(PetStoreApi.class);
    }

    public Observable<List<Pet>> getAllPets(int limit) {
        return api.listPets(limit)
            .subscribeOn(Schedulers.io());
    }
}
```

### Service (Quarkus)

```java
// quarkus-project/
package com.example.service;

import org.eclipse.microprofile.rest.client.inject.RestClient;
import com.example.client.PetStoreApi;
import io.smallrye.mutiny.Uni;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import java.util.List;

@ApplicationScoped
public class PetService {

    @Inject
    @RestClient
    PetStoreApi api;

    public Uni<List<Pet>> getAllPets(int limit) {
        return api.listPets(limit);
    }

    public Uni<Pet> getPet(String id) {
        return api.getPetById(id);
    }

    public Uni<Pet> createPet(Pet pet) {
        return api.createPet(pet);
    }
}
```

## 📝 Paso 5: Usar en REST Endpoint

### Controller (Spring)

```java
// original-spring/
import org.springframework.web.bind.annotation.*;
import io.reactivex.Observable;

@RestController
@RequestMapping("/api/pets")
public class PetController {

    @Autowired
    private PetService petService;

    @GetMapping
    public Observable<List<Pet>> listPets(@RequestParam(defaultValue = "10") int limit) {
        return petService.getAllPets(limit);
    }

    @GetMapping("/{id}")
    public Observable<Pet> getPet(@PathVariable String id) {
        return petService.getPet(id);
    }
}
```

### Resource (Quarkus)

```java
// quarkus-project/
package com.example.resource;

import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import jakarta.inject.Inject;
import io.smallrye.mutiny.Uni;
import com.example.service.PetService;
import java.util.List;

@Path("/api/pets")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class PetResource {

    @Inject
    PetService petService;

    @GET
    public Uni<List<Pet>> listPets(
        @QueryParam("limit") @DefaultValue("10") int limit
    ) {
        return petService.getAllPets(limit);
    }

    @GET
    @Path("/{id}")
    public Uni<Pet> getPet(@PathParam("id") String id) {
        return petService.getPet(id);
    }

    @POST
    public Uni<Pet> createPet(Pet pet) {
        return petService.createPet(pet);
    }
}
```

## 📝 Paso 6: Manejo de Errores

### Con Retrofit

```java
Observable<Pet> pet = api.getPetById("123")
    .subscribeOn(Schedulers.io())
    .observeOn(Schedulers.mainThread())
    .subscribe(
        p -> System.out.println("Pet: " + p),
        e -> System.err.println("Error: " + e.getMessage())
    );
```

### Con Quarkus + Mutiny

```java
Uni<Pet> pet = api.getPetById("123")
    .onFailure()
    .recoverWithUni(error -> {
        System.err.println("Error: " + error.getMessage());
        return Uni.createFrom().failure(error);
    })
    .onItem()
    .ifNull().switchTo(Uni.createFrom().failure(
        new NotFoundException("Pet not found")
    ));

// O en REST endpoint (automático)
@GET
@Path("/{id}")
public Uni<Pet> getPet(@PathParam("id") String id) {
    return petService.getPet(id)
        .onFailure(NotFoundException.class)
        .recoverWithItem(Pet::empty);
}
```

## 📝 Paso 7: Interceptores (si los hay)

### Interceptor Retrofit

```java
// original-spring/
public class AuthInterceptor implements Interceptor {
    @Override
    public Response intercept(Chain chain) throws IOException {
        Request original = chain.request();
        Request request = original.newBuilder()
            .header("Authorization", "Bearer " + getToken())
            .build();
        return chain.proceed(request);
    }
}

// Registrado en Retrofit.Builder()
```

### Interceptor Quarkus

```java
// quarkus-project/
package com.example.client;

import org.eclipse.microprofile.rest.client.ext.ResponseExceptionMapper;
import org.jboss.resteasy.reactive.client.spi.ClientRequestContext;
import org.jboss.resteasy.reactive.client.spi.ClientRequestFilter;
import jakarta.annotation.Priority;
import jakarta.ws.rs.Priorities;
import jakarta.ws.rs.ext.Provider;

@Provider
@Priority(Priorities.AUTHENTICATION)
public class AuthClientRequestFilter implements ClientRequestFilter {

    @Override
    public void filter(ClientRequestContext requestContext) {
        requestContext.getHeaders()
            .add("Authorization", "Bearer " + getToken());
    }

    private String getToken() {
        // Obtener token
        return "token";
    }
}
```

## ✅ Checklist

- [ ] Dependencia `quarkus-rest-client-reactive` agregada
- [ ] Dependencias Retrofit removidas
- [ ] Interfaz REST Client creada con `@RegisterRestClient`
- [ ] Service inyectado con `@RestClient`
- [ ] application.properties configurado
- [ ] REST Resources creados y usan Uni
- [ ] Manejo de errores implementado
- [ ] Tests creados
- [ ] Compilación sin errores
- [ ] Tests pasan

## 🔗 Siguiente Paso

→ Ir a `03-OPENAPI-MIGRATION.md`
