# Retrofit Migration Prompt

## Context

You are helping migrate an existing Retrofit 2-based HTTP client to Quarkus REST Client Reactive.

## What We're Doing

Converting from **Retrofit (synchronous)** to **Quarkus REST Client Reactive (asynchronous with Mutiny)**.

### Key Transformations

```
OLD (Spring + Retrofit)          NEW (Quarkus REST Client)
┌──────────────────────────┐    ┌─────────────────────────────┐
│ @GET("endpoint")         │    │ @GET @Path("endpoint")      │
│ Observable<T> method()   │ → │ Uni<T> method()             │
│ .subscribeOn(io())       │    │ (auto-managed threading)    │
│ .observeOn(main())       │    │                             │
└──────────────────────────┘    └─────────────────────────────┘
```

## Required Changes

### 1. Dependencies

- ❌ Remove: `retrofit2:retrofit`, `converter-jackson`, `adapter-rxjava2`
- ✅ Add: `quarkus-rest-client-reactive`, `quarkus-mutiny`

### 2. Client Interface

- Change annotations: `@Path` instead of `@GET` in path
- Change: `Observable<T>` → `Uni<T>`
- Add: `@RegisterRestClient(configKey = "...")`
- Add: `@Path` class annotation with base path

### 3. Configuration

- Create `application.properties` entries:
  ```properties
  quarkus.rest-client.{configKey}.url=...
  quarkus.rest-client.{configKey}.connect-timeout=...
  quarkus.rest-client.{configKey}.read-timeout=...
  ```

### 4. Injection

- Change: `@Autowired` → `@Inject`
- Add: `@RestClient` qualifier
- No more manual Retrofit.Builder()

### 5. Threading

- Mutiny handles threading automatically
- No more `.subscribeOn()` or `.observeOn()`
- Subscribe in endpoints/services as needed

## Detailed Workflow

1. **Analyze Original Retrofit Interfaces**
   - List all interfaces with @GET, @POST, etc.
   - Identify return types (Observable, Single, Completable)
   - Document interceptors and custom logic
   - Note path parameters, query params, headers

2. **Create REST Client Interfaces**
   - Use Jakarta WS-RS annotations (not Retrofit)
   - Return Uni<T> instead of Observable
   - Add @RegisterRestClient with configKey
   - Maintain same method signatures

3. **Configure application.properties**
   - Base URL for each REST Client
   - Timeout settings
   - Any custom headers or auth

4. **Update Services/Controllers**
   - Inject with @Inject @RestClient
   - Remove Retrofit.Builder() code
   - Update return types to Uni
   - Adjust error handling

5. **Test & Validate**
   - Verify REST client can be injected
   - Test each endpoint
   - Validate error handling
   - Check timeout behavior

## Example Transformation

### BEFORE: Retrofit Interface

```java
import retrofit2.http.*;
import io.reactivex.Observable;

public interface UserApi {
    @GET("users/{id}")
    Observable<User> getUser(@Path("id") String id);

    @POST("users")
    Observable<User> createUser(@Body User user);

    @PUT("users/{id}")
    Observable<User> updateUser(@Path("id") String id, @Body User user);
}
```

### AFTER: Quarkus REST Client

```java
import jakarta.ws.rs.*;
import org.eclipse.microprofile.rest.client.inject.RegisterRestClient;
import io.smallrye.mutiny.Uni;

@RegisterRestClient(configKey = "user-api")
@Path("/users")
public interface UserApi {
    @GET
    @Path("/{id}")
    Uni<User> getUser(@PathParam("id") String id);

    @POST
    Uni<User> createUser(User user);

    @PUT
    @Path("/{id}")
    Uni<User> updateUser(@PathParam("id") String id, User user);
}
```

### Configuration

```properties
quarkus.rest-client.user-api.url=https://api.example.com
quarkus.rest-client.user-api.connect-timeout=5000
quarkus.rest-client.user-api.read-timeout=10000
```

### Injection & Usage

```java
@ApplicationScoped
public class UserService {
    @Inject
    @RestClient
    UserApi api;

    public Uni<User> getUserById(String id) {
        return api.getUser(id);
    }

    public Uni<User> saveUser(User user) {
        return api.createUser(user);
    }
}
```

## Common Pitfalls & Solutions

| Problem                       | Solution                                                  |
| ----------------------------- | --------------------------------------------------------- |
| `Observable` not found        | Use `Uni<T>` instead                                      |
| Can't subscribe in service    | Subscribe in REST endpoint, not service                   |
| Timeout not working           | Check `application.properties` config                     |
| Custom headers not sent       | Use interceptor or `@HeaderParam`                         |
| Threading deadlock            | Avoid blocking calls, use `.subscribeAsCompletionStage()` |
| Retrofit factory code remains | Delete all `Retrofit.Builder()` code                      |

## Validation Checklist

- [ ] All Retrofit imports removed
- [ ] All interfaces use @RegisterRestClient
- [ ] All methods return Uni instead of Observable
- [ ] application.properties has all REST client configs
- [ ] Services inject with @Inject @RestClient
- [ ] No Retrofit.Builder() in any code
- [ ] No RxJava subscribeOn/observeOn remaining
- [ ] Tests use Rest Assured for endpoints
- [ ] All tests pass
- [ ] Compilation has no warnings

## Next Steps

→ Once Retrofit migration complete:

1. Review [04-REACTIVE-STACK.md](../instructions/04-REACTIVE-STACK.md) for RxJava → Mutiny conversion
2. Run integration tests
3. Profile performance improvements
