# Skill: Retrofit to REST Client Migration

## Propósito

Migrar interfaces y código Retrofit a Quarkus REST Client Reactive.

## Prerequisitos

- Proyecto Quarkus base creado
- Todas las interfaces Retrofit identificadas
- Documentación de configuración (base URLs, timeouts, etc.)

## Proceso

### Paso 1: Análisis de Interfaces Retrofit

**Script de búsqueda:**

```bash
cd original-spring/

# Encontrar todas las interfaces Retrofit
find . -type f -name "*.java" -exec grep -l "@GET\|@POST\|@PUT\|@DELETE" {} \;

# Mostrar contenido
grep -r "public interface.*Api" src/main/java
```

**Documentar:**

```
Interface: UserApi
├── BaseURL: https://api.example.com/users
├── Métodos:
│   ├── getUser(@Path("id")) → Observable<User>
│   ├── createUser(@Body) → Observable<User>
│   └── deleteUser(@Path("id")) → Completable
├── Interceptores: AuthInterceptor
└── Configuración: timeout=10s, retry=3
```

### Paso 2: Crear REST Client Interface

**Plantilla:**

```java
package com.example.client;

import org.eclipse.microprofile.rest.client.inject.RegisterRestClient;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import io.smallrye.mutiny.Uni;

@RegisterRestClient(configKey = "user-api")
@Path("/users")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public interface UserApi {

    // Conversión aquí:
    // Observable<T> → Uni<T>
    // @Path → @PathParam
    // @Query → @QueryParam

    @GET
    @Path("/{id}")
    Uni<User> getUser(@PathParam("id") String id);

    @POST
    Uni<User> createUser(User user);

    @DELETE
    @Path("/{id}")
    Uni<Void> deleteUser(@PathParam("id") String id);
}
```

### Paso 3: Configurar application.properties

```properties
# REST Client: User API
quarkus.rest-client.user-api.url=https://api.example.com
quarkus.rest-client.user-api.connect-timeout=5000
quarkus.rest-client.user-api.read-timeout=10000
quarkus.rest-client.user-api.scope=javax.inject.Singleton

# Si necesita auth
quarkus.rest-client.user-api.providers=com.example.client.AuthClientFilter
```

### Paso 4: Implementar Filtro de Autenticación (si aplica)

**Si el original tenía AuthInterceptor:**

```java
package com.example.client;

import org.jboss.resteasy.reactive.client.spi.ClientRequestContext;
import org.jboss.resteasy.reactive.client.spi.ClientRequestFilter;
import jakarta.annotation.Priority;
import jakarta.ws.rs.Priorities;
import jakarta.ws.rs.ext.Provider;

@Provider
@Priority(Priorities.AUTHENTICATION)
public class AuthClientFilter implements ClientRequestFilter {

    @Override
    public void filter(ClientRequestContext requestContext) {
        String token = getAuthToken(); // Obtener del contexto
        requestContext.getHeaders()
            .add("Authorization", "Bearer " + token);
    }

    private String getAuthToken() {
        // Implementar lógica de obtención de token
        return "token-value";
    }
}
```

### Paso 5: Actualizar Servicios

**Antes (Spring):**

```java
@Service
public class UserService {
    private UserApi api;

    public UserService(Retrofit retrofit) {
        this.api = retrofit.create(UserApi.class);
    }

    public Observable<User> getUserById(String id) {
        return api.getUser(id)
            .subscribeOn(Schedulers.io());
    }
}
```

**Después (Quarkus):**

```java
@ApplicationScoped
public class UserService {

    @Inject
    @RestClient
    UserApi api;

    public Uni<User> getUserById(String id) {
        return api.getUser(id);
    }
}
```

### Paso 6: Actualizar REST Resources

**Antes (Spring):**

```java
@RestController
@RequestMapping("/api/users")
public class UserController {

    @Autowired
    private UserService userService;

    @GetMapping("/{id}")
    public Observable<User> getUser(@PathVariable String id) {
        return userService.getUserById(id);
    }
}
```

**Después (Quarkus):**

```java
@Path("/users")
@Produces(MediaType.APPLICATION_JSON)
public class UserResource {

    @Inject
    UserService userService;

    @GET
    @Path("/{id}")
    public Uni<User> getUser(@PathParam("id") String id) {
        return userService.getUserById(id);
    }
}
```

### Paso 7: Tests

```java
@QuarkusTest
public class UserApiTest {

    @InjectMock
    @RestClient
    UserApi api;

    @Test
    void testGetUser() {
        // Arrange
        User expectedUser = new User("1", "John");
        when(api.getUser("1"))
            .thenReturn(Uni.createFrom().item(expectedUser));

        // Act & Assert
        Uni<User> result = api.getUser("1");
        UniAssertSubscriber<User> subscriber = result
            .subscribe()
            .withSubscriber(UniAssertSubscriber.create());

        subscriber.assertCompleted()
                  .assertItem(expectedUser);
    }
}
```

### Paso 8: Validación

```bash
cd quarkus-project/

# Compilar
mvn clean compile

# Ejecutar tests
mvn test

# Dev mode
mvn quarkus:dev

# Verificar en navegador
curl http://localhost:8080/api/users/1
```

## Salidas

✅ **Interfaces REST Client creadas:**

- Todas las interfaces Retrofit convertidas
- Anotaciones JAX-RS correctas
- Retornos Uni en lugar de Observable

✅ **Configuración completa:**

- application.properties con URLs
- Timeouts y retry policies
- Filtros de autenticación

✅ **Código actualizado:**

- Servicios usan @Inject @RestClient
- Resources devuelven Uni
- Tests funcionales

## Checklist

- [ ] Todas las interfaces Retrofit analizadas
- [ ] Interfaces REST Client creadas
- [ ] application.properties configurado
- [ ] Servicios actualizados
- [ ] Resources creados
- [ ] Tests implementados
- [ ] Compilación sin errores
- [ ] Todos los tests pasan
- [ ] API funcionando en dev mode
