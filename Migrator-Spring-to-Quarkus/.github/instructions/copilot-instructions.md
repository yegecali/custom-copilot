# Copilot Instructions for Spring to Quarkus Migration

**Version:** 1.0  
**Date:** 30 de enero de 2026  
**Purpose:** Detailed instructions for GitHub Copilot during Spring Boot to Quarkus migration

---

## Quick Reference Rules

### RULE 1: Interfaces MUST use @RegisterRestClient

```java
// WRONG
public interface ApiClient {
    @GET("/pets")
    Uni<List<Pet>> getPets();
}

// CORRECT
@RegisterRestClient(configKey = "pet-api")
@Path("/api")
@Produces(MediaType.APPLICATION_JSON)
public interface ApiClient {
    @GET
    @Path("/pets")
    Uni<List<Pet>> getPets();
}
```

### RULE 2: ALWAYS return Uni<T> from REST methods

```java
// WRONG
public List<Pet> getPets() { }
public Observable<Pet> getPet(String id) { }

// CORRECT
public Uni<List<Pet>> getPets() { }
public Uni<Pet> getPet(String id) { }
```

### RULE 3: NEVER use @Autowired, @Service, @Component

```java
// WRONG (Spring)
@Service
public class MyService {
    @Autowired
    private ApiClient client;
}

// CORRECT (Quarkus)
@ApplicationScoped
public class MyService {
    @Inject
    @RestClient
    ApiClient client;
}
```

### RULE 4: Injection MUST have @RestClient on client interfaces

```java
// WRONG
@Inject
ApiClient api;

// CORRECT
@Inject
@RestClient
ApiClient api;
```

### RULE 5: Endpoints MUST return Uni<T>

```java
// WRONG
@GET
@Path("/pets")
List<Pet> getPets() { }

// CORRECT
@GET
@Path("/pets")
Uni<List<Pet>> getPets() { }
```

### RULE 6: Parameter mapping changes

```java
// WRONG (Spring)
@RequestParam String name
@PathVariable String id
@RequestBody Pet pet

// CORRECT (Quarkus)
@QueryParam String name
@PathParam String id
Pet pet (direct parameter)
```

### RULE 7: HTTP method annotations change

```java
// WRONG (Spring)
@GetMapping
@PostMapping
@PutMapping
@DeleteMapping

// CORRECT (Quarkus)
@GET
@POST
@PUT
@DELETE
```

### RULE 8: NO subscribeOn/observeOn needed

```java
// WRONG - Threading handled automatically
return api.getPet(id)
    .subscribeOn(Schedulers.io())
    .observeOn(Schedulers.mainThread());

// CORRECT - Quarkus manages threading
return api.getPet(id);
```

---

## Transformation Patterns

### Pattern 1: Retrofit Interface to REST Client

```java
// BEFORE - Retrofit + RxJava
@GET("pets/{id}")
Observable<Pet> getPetById(@Path("id") String id);

@POST("pets")
Observable<Pet> createPet(@Body Pet pet);

@Query("limit")
Observable<List<Pet>> listPets(int limit);

// AFTER - Quarkus REST Client
@GET
@Path("/pets/{id}")
Uni<Pet> getPetById(@PathParam("id") String id);

@POST
@Path("/pets")
Uni<Pet> createPet(Pet pet);

@GET
@Path("/pets")
Uni<List<Pet>> listPets(@QueryParam("limit") int limit);
```

### Pattern 2: Spring Service to Quarkus Service

```java
// BEFORE - Spring
@Service
public class PetService {
    @Autowired
    private PetApi api;

    public Observable<Pet> getPet(String id) {
        return api.getPetById(id)
            .subscribeOn(Schedulers.io());
    }
}

// AFTER - Quarkus
@ApplicationScoped
public class PetService {
    @Inject
    @RestClient
    PetApi api;

    public Uni<Pet> getPet(String id) {
        return api.getPetById(id);
    }
}
```

### Pattern 3: Spring Controller to Quarkus Resource

```java
// BEFORE - Spring
@RestController
@RequestMapping("/api/pets")
public class PetController {
    @Autowired
    private PetService service;

    @GetMapping("/{id}")
    public Observable<Pet> getPet(@PathVariable String id) {
        return service.getPet(id);
    }

    @PostMapping
    public Observable<Pet> create(@RequestBody Pet pet) {
        return service.create(pet);
    }
}

// AFTER - Quarkus
@Path("/api/pets")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class PetResource {
    @Inject
    private PetService service;

    @GET
    @Path("/{id}")
    public Uni<Pet> getPet(@PathParam("id") String id) {
        return service.getPet(id);
    }

    @POST
    public Uni<Pet> create(Pet pet) {
        return service.create(pet);
    }
}
```

### Pattern 4: Observable Operators to Mutiny

```java
// MAP - Transform single value
Observable<Pet> obs = api.getPet(id).map(p -> { p.setName("X"); return p; });
Uni<Pet> uni = api.getPet(id).map(p -> { p.setName("X"); return p; });

// FLATMAP - Chain Uni
Observable<PetWithOwner> obs = api.getPet(id)
    .flatMap(pet -> api.getOwner(pet.getOwnerId())
        .map(owner -> new PetWithOwner(pet, owner)));
Uni<PetWithOwner> uni = api.getPet(id)
    .flatMap(pet -> api.getOwner(pet.getOwnerId())
        .map(owner -> new PetWithOwner(pet, owner)));

// TIMEOUT
Observable<Pet> obs = api.getPet(id).timeout(10, TimeUnit.SECONDS);
Uni<Pet> uni = api.getPet(id)
    .ifNoItem().after(Duration.ofSeconds(10)).fail();

// RETRY
Observable<Pet> obs = api.getPet(id).retry(3);
Uni<Pet> uni = api.getPet(id).retry().atMost(3);

// ERROR HANDLING
Observable<Pet> obs = api.getPet(id)
    .onErrorResumeNext(e -> Observable.just(new Pet()));
Uni<Pet> uni = api.getPet(id)
    .onFailure().recoverWithItem(() -> new Pet());
```

---

## Properties Transformation

```properties
# BEFORE - Spring
spring.datasource.url=jdbc:mysql://localhost:3306/db
spring.datasource.username=root
spring.jpa.hibernate.ddl-auto=update
spring.application.name=pet-api
server.port=8080
logging.level.root=INFO

# AFTER - Quarkus
quarkus.datasource.jdbc.url=jdbc:mysql://localhost:3306/db
quarkus.datasource.username=root
quarkus.hibernate-orm.database.generation=update
quarkus.application.name=pet-api
quarkus.http.port=8080
quarkus.log.level=INFO
quarkus.rest-client.pet-api.url=http://api.example.com
quarkus.rest-client.pet-api.connect-timeout=5000
```

---

## Component Instructions

### REST Client Interface

When creating a REST client interface:

1. Add `@RegisterRestClient(configKey = "...")`
2. Add `@Path` on class with base path
3. Use `@GET`, `@POST`, `@PUT`, `@DELETE` (not `@GET("path")`)
4. Change `@Path` params to `@PathParam`
5. Change `@Query` params to `@QueryParam`
6. Return `Uni<T>` (not Observable)
7. Add `@Produces`/`@Consumes` for JSON

### Quarkus Service

When creating a service:

1. Use `@ApplicationScoped`
2. Inject REST client with `@Inject @RestClient`
3. Return `Uni<T>` from public methods
4. Use `.map()` and `.flatMap()` for transformations
5. Add error handling with `.onFailure()`

### REST Endpoint/Resource

When creating a REST endpoint:

1. Use `@Path` (not @RestController)
2. Use `@GET`, `@POST`, `@PUT`, `@DELETE` (not @GetMapping)
3. Use `@QueryParam`, `@PathParam` (not @RequestParam, @PathVariable)
4. Return `Uni<T>` from endpoint methods
5. Add `@Produces`/`@Consumes` for JSON
6. Inject service with `@Inject`

### Configuration & Beans

When creating configuration:

1. Use `@ApplicationScoped` class
2. Use `@Singleton` method decorator for beans
3. Inject dependencies with `@Inject`
4. Return configured beans from public methods

---

## Validation Checklist

When Copilot generates code, VERIFY:

- [ ] REST Client has `@RegisterRestClient`
- [ ] REST Client has `@Path` on class
- [ ] All REST methods return `Uni<T>`
- [ ] No `Observable`, `Single`, `Flowable` used
- [ ] Service is `@ApplicationScoped` (not @Service)
- [ ] Service injection uses `@Inject` (not @Autowired)
- [ ] REST Client injection has `@RestClient`
- [ ] Endpoint is `@Path` (not @RestController)
- [ ] Endpoint methods return `Uni<T>`
- [ ] No `subscribeOn` or `observeOn` used
- [ ] Properties use `quarkus.*` prefix

---

## Common Prompts for Copilot

### Create REST Client

```
"Create a Quarkus REST Client interface for https://api.example.com/api/pets
using Mutiny Uni<T>. Include methods: listPets(limit), getPetById(id), createPet(pet)"
```

### Create Service

```
"Create a Quarkus service that injects PetApi REST Client and has methods:
getAllPets(), getPet(id), createPet(pet). All methods return Uni<T>"
```

### Create Endpoint

```
"Create a Quarkus REST endpoint with @Path(\"/api/pets\") that:
- GET /api/pets -> returns Uni<List<Pet>>
- GET /api/pets/{id} -> returns Uni<Pet>
- POST /api/pets -> returns Uni<Pet>"
```

### Convert Observable

```
"Convert this RxJava Observable code to Quarkus Mutiny Uni:
Observable<Pet> pet = api.getPet(id).subscribeOn(Schedulers.io())"
```

### Add Error Handling

```
"Add to this Uni<Pet>: timeout 10 seconds, 3 retries with backoff,
and fallback to empty Pet on failure"
```

### Create Test

```
"Create a Quarkus test for the PetResource endpoint. Test GET /api/pets
returns status 200 and has at least one pet"
```

---

## Annotation Quick Reference

| Purpose         | Spring          | Quarkus             |
| --------------- | --------------- | ------------------- |
| REST Controller | @RestController | @Path               |
| Route           | @RequestMapping | @Path               |
| GET Method      | @GetMapping     | @GET                |
| POST Method     | @PostMapping    | @POST               |
| Query Param     | @RequestParam   | @QueryParam         |
| Path Param      | @PathVariable   | @PathParam          |
| Request Body    | @RequestBody    | Direct param        |
| Service Bean    | @Service        | @ApplicationScoped  |
| Dependency      | @Autowired      | @Inject             |
| Config Class    | @Configuration  | @ApplicationScoped  |
| REST Client     | Retrofit        | @RegisterRestClient |

---

## Type Quick Reference

| Purpose        | Spring          | Quarkus      |
| -------------- | --------------- | ------------ |
| Async Single   | Observable      | Uni          |
| Async Multiple | Flowable        | Multi        |
| HTTP Client    | Retrofit        | REST Client  |
| Testing        | @SpringBootTest | @QuarkusTest |
| HTTP Testing   | MockMvc         | Rest Assured |
| Database       | Spring Data JPA | Panache ORM  |

---

## Migration Flow

1. **Interface REST Client** - Migrate Retrofit to REST Client
2. **Service** - Inject client, return Uni<T>, use map/flatMap
3. **Endpoint** - Create Resource, inject Service, return Uni<T>
4. **Configuration** - Setup properties with quarkus.\* prefix
5. **Tests** - Use @QuarkusTest, Rest Assured, mocks
6. **Validate** - Compile, test, verify startup time

---

## Key Differences

| Aspect       | Spring                | Quarkus            |
| ------------ | --------------------- | ------------------ |
| Startup      | 2-3 seconds           | < 1 second         |
| Memory       | 300-400 MB            | 50-120 MB          |
| HTTP Client  | Retrofit/RestTemplate | REST Client        |
| Reactive     | Optional (WebFlux)    | Native (Mutiny)    |
| Thread Model | subscribeOn/observeOn | Automatic          |
| Dependency   | @Autowired            | @Inject            |
| Beans        | @Service/@Component   | @ApplicationScoped |
| REST         | @RestController       | @Path              |

---

**Last Updated:** 30 de enero de 2026  
**Version:** 1.0  
**Status:** Ready for Copilot Integration
