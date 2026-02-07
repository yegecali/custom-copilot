# Instrucciones de Desarrollo - RxJava, Retrofit y API First

## Principios Fundamentales

### 1. API First Approach

- **Definir la API primero**: Crear el contrato OpenAPI/Swagger antes de implementar
- **Validar el contrato**: Usar herramientas de validación de OpenAPI (swagger-validator)
- **Generar código**: Utilizar generadores de código desde la especificación OpenAPI
- **Mantener sincronización**: La especificación es la fuente única de verdad

### 2. Arquitectura Reactiva con RxJava

#### Principios de Programación Reactiva

- **No bloquear threads**: Usar operadores reactivos en lugar de código imperativo
- **Composición sobre iteración**: Encadenar operadores en lugar de bucles
- **Manejo de errores**: Usar `onErrorReturn`, `onErrorResumeNext`, `retry`
- **Programación declarativa**: Expresar "qué" hacer, no "cómo"

#### Patrones de Uso de RxJava

```java
// ✅ CORRECTO: Composición reactiva
public Observable<UserProfile> getUserProfile(String userId) {
    return userService.getUser(userId)
        .flatMap(user ->
            profileService.getProfile(user.getProfileId())
                .map(profile -> new UserProfile(user, profile))
        )
        .timeout(5, TimeUnit.SECONDS)
        .retry(2)
        .onErrorResumeNext(error -> {
            log.error("Error fetching user profile", error);
            return Observable.just(UserProfile.empty());
        });
}

// ❌ INCORRECTO: Bloqueo en código reactivo
public UserProfile getUserProfileBlocking(String userId) {
    User user = userService.getUser(userId).blockingFirst(); // NO HACER
    Profile profile = profileService.getProfile(user.getProfileId()).blockingFirst(); // NO HACER
    return new UserProfile(user, profile);
}
```

#### Operadores Esenciales

- **Transformación**: `map`, `flatMap`, `concatMap`, `switchMap`
- **Filtrado**: `filter`, `take`, `skip`, `distinct`
- **Combinación**: `zip`, `merge`, `concat`, `combineLatest`
- **Manejo de errores**: `onErrorReturn`, `onErrorResumeNext`, `retry`, `retryWhen`
- **Utilidad**: `timeout`, `delay`, `debounce`, `subscribeOn`, `observeOn`

### 3. Integración con Retrofit

#### Configuración Base

```java
@Configuration
public class RetrofitConfig {

    @Bean
    public OkHttpClient okHttpClient() {
        return new OkHttpClient.Builder()
            .connectTimeout(30, TimeUnit.SECONDS)
            .readTimeout(30, TimeUnit.SECONDS)
            .writeTimeout(30, TimeUnit.SECONDS)
            .addInterceptor(new LoggingInterceptor())
            .addInterceptor(new AuthInterceptor())
            .build();
    }

    @Bean
    public Retrofit retrofit(OkHttpClient client) {
        return new Retrofit.Builder()
            .baseUrl("https://api.example.com")
            .client(client)
            .addConverterFactory(GsonConverterFactory.create())
            .addCallAdapterFactory(RxJava3CallAdapterFactory.create())
            .build();
    }
}
```

#### Definición de APIs con Retrofit

```java
public interface UserApiClient {

    @GET("/users/{id}")
    Observable<User> getUser(@Path("id") String userId);

    @GET("/users")
    Observable<List<User>> getUsers(
        @Query("page") int page,
        @Query("size") int size
    );

    @POST("/users")
    Single<User> createUser(@Body CreateUserRequest request);

    @PUT("/users/{id}")
    Completable updateUser(
        @Path("id") String userId,
        @Body UpdateUserRequest request
    );

    @DELETE("/users/{id}")
    Completable deleteUser(@Path("id") String userId);
}
```

### 4. Estructura de Capas

```
src/main/java/
├── api/
│   ├── spec/           # Especificaciones OpenAPI
│   └── generated/      # Código generado desde OpenAPI
├── client/
│   ├── retrofit/       # Interfaces Retrofit
│   └── interceptor/    # Interceptores HTTP
├── service/
│   ├── impl/          # Implementaciones reactivas
│   └── mapper/        # Mappers DTO <-> Domain
├── domain/
│   ├── model/         # Modelos de dominio
│   └── repository/    # Interfaces de repositorio
└── config/
    └── RetrofitConfig.java
```

## Patrones de Implementación

### Patrón 1: Servicio Reactivo con Retrofit

```java
@Service
public class UserServiceImpl implements UserService {

    private final UserApiClient apiClient;
    private final UserMapper mapper;

    @Override
    public Observable<User> getUserById(String userId) {
        return apiClient.getUser(userId)
            .map(mapper::toDomain)
            .subscribeOn(Schedulers.io())
            .observeOn(AndroidSchedulers.mainThread())
            .doOnError(error -> log.error("Error fetching user {}", userId, error))
            .onErrorResumeNext(this::handleUserFetchError);
    }

    private Observable<User> handleUserFetchError(Throwable error) {
        if (error instanceof HttpException) {
            HttpException httpError = (HttpException) error;
            if (httpError.code() == 404) {
                return Observable.error(new UserNotFoundException());
            }
        }
        return Observable.error(new ServiceException("Error fetching user", error));
    }
}
```

### Patrón 2: Composición de Múltiples Llamadas

```java
@Service
public class OrderServiceImpl implements OrderService {

    private final OrderApiClient orderClient;
    private final UserApiClient userClient;
    private final ProductApiClient productClient;

    @Override
    public Observable<OrderDetails> getOrderDetails(String orderId) {
        return orderClient.getOrder(orderId)
            .flatMap(order ->
                Observable.zip(
                    userClient.getUser(order.getUserId()),
                    productClient.getProducts(order.getProductIds()),
                    (user, products) -> new OrderDetails(order, user, products)
                )
            )
            .timeout(10, TimeUnit.SECONDS)
            .retry(2);
    }
}
```

### Patrón 3: Manejo de Paginación

```java
@Service
public class ProductServiceImpl implements ProductService {

    private final ProductApiClient apiClient;

    @Override
    public Observable<Product> getAllProducts() {
        return Observable.range(0, Integer.MAX_VALUE)
            .concatMap(page ->
                apiClient.getProducts(page, 50)
                    .flatMapIterable(list -> list)
            )
            .takeWhile(product -> product != null);
    }

    @Override
    public Observable<List<Product>> getProductsPage(int page, int size) {
        return apiClient.getProducts(page, size)
            .subscribeOn(Schedulers.io());
    }
}
```

### Patrón 4: Caché Reactivo

```java
@Service
public class CachedUserService implements UserService {

    private final UserApiClient apiClient;
    private final Cache<String, User> cache;

    @Override
    public Observable<User> getUserById(String userId) {
        return Observable.defer(() -> {
            User cached = cache.getIfPresent(userId);
            if (cached != null) {
                return Observable.just(cached);
            }
            return apiClient.getUser(userId)
                .doOnNext(user -> cache.put(userId, user));
        })
        .subscribeOn(Schedulers.io());
    }
}
```

## Testing

### Test de Servicios Reactivos

```java
@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Mock
    private UserApiClient apiClient;

    @InjectMocks
    private UserServiceImpl userService;

    @Test
    void shouldGetUserById() {
        // Given
        String userId = "123";
        UserDto userDto = new UserDto(userId, "John Doe");
        when(apiClient.getUser(userId))
            .thenReturn(Observable.just(userDto));

        // When
        TestObserver<User> testObserver = userService
            .getUserById(userId)
            .test();

        // Then
        testObserver
            .assertComplete()
            .assertNoErrors()
            .assertValue(user -> user.getId().equals(userId));
    }

    @Test
    void shouldHandleErrorGracefully() {
        // Given
        String userId = "123";
        when(apiClient.getUser(userId))
            .thenReturn(Observable.error(new HttpException(
                Response.error(404, ResponseBody.create(null, ""))
            )));

        // When
        TestObserver<User> testObserver = userService
            .getUserById(userId)
            .test();

        // Then
        testObserver
            .assertError(UserNotFoundException.class);
    }
}
```

### Mock de Retrofit con WireMock

```java
@SpringBootTest(webEnvironment = WebEnvironment.RANDOM_PORT)
class UserApiIntegrationTest {

    @RegisterExtension
    static WireMockExtension wireMock = WireMockExtension.newInstance()
        .options(wireMockConfig().dynamicPort())
        .build();

    private UserApiClient apiClient;

    @BeforeEach
    void setup() {
        Retrofit retrofit = new Retrofit.Builder()
            .baseUrl(wireMock.baseUrl())
            .addConverterFactory(GsonConverterFactory.create())
            .addCallAdapterFactory(RxJava3CallAdapterFactory.create())
            .build();

        apiClient = retrofit.create(UserApiClient.class);
    }

    @Test
    void shouldFetchUser() {
        // Given
        wireMock.stubFor(get(urlEqualTo("/users/123"))
            .willReturn(aResponse()
                .withStatus(200)
                .withHeader("Content-Type", "application/json")
                .withBody("{\"id\":\"123\",\"name\":\"John Doe\"}")
            ));

        // When
        TestObserver<UserDto> testObserver = apiClient
            .getUser("123")
            .test();

        // Then
        testObserver
            .assertComplete()
            .assertValue(user -> user.getName().equals("John Doe"));
    }
}
```

## Mejores Prácticas

### 1. Schedulers

- **IO Operations**: Usar `Schedulers.io()` para llamadas de red y DB
- **Computation**: Usar `Schedulers.computation()` para cálculos CPU intensivos
- **Main Thread**: Usar `AndroidSchedulers.mainThread()` o equivalente para UI

### 2. Manejo de Errores

```java
// ✅ Manejo específico por tipo de error
observable
    .onErrorResumeNext(error -> {
        if (error instanceof NetworkException) {
            return retryWithBackoff();
        } else if (error instanceof AuthException) {
            return refreshTokenAndRetry();
        }
        return Observable.error(error);
    });
```

### 3. Timeouts y Reintentos

```java
// ✅ Configuración apropiada de timeouts y reintentos
observable
    .timeout(30, TimeUnit.SECONDS)
    .retryWhen(errors -> errors
        .zipWith(Observable.range(1, 3), (error, attempt) -> attempt)
        .flatMap(attempt -> Observable.timer(attempt * 2L, TimeUnit.SECONDS))
    );
```

### 4. Limpieza de Recursos

```java
// ✅ Siempre dispose subscriptions
public class MyActivity {
    private CompositeDisposable disposables = new CompositeDisposable();

    void loadData() {
        disposables.add(
            userService.getUserById("123")
                .subscribe(
                    user -> updateUI(user),
                    error -> showError(error)
                )
        );
    }

    @Override
    protected void onDestroy() {
        disposables.clear();
        super.onDestroy();
    }
}
```

### 5. API First - Flujo de Trabajo

1. **Diseñar la API** (OpenAPI/Swagger)

```yaml
openapi: 3.0.0
info:
  title: User API
  version: 1.0.0
paths:
  /users/{id}:
    get:
      operationId: getUser
      parameters:
        - name: id
          in: path
          required: true
          schema:
            type: string
      responses:
        "200":
          description: User found
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/User"
```

2. **Generar código** (Maven/Gradle plugin)

```xml
<plugin>
    <groupId>org.openapitools</groupId>
    <artifactId>openapi-generator-maven-plugin</artifactId>
    <version>6.6.0</version>
    <executions>
        <execution>
            <goals>
                <goal>generate</goal>
            </goals>
            <configuration>
                <inputSpec>${project.basedir}/src/main/resources/api/openapi.yaml</inputSpec>
                <generatorName>java</generatorName>
                <library>retrofit2</library>
                <configOptions>
                    <useRxJava3>true</useRxJava3>
                </configOptions>
            </configuration>
        </execution>
    </executions>
</plugin>
```

3. **Implementar servicios** usando código generado

4. **Validar en CI/CD** que la implementación cumple el contrato

## Dependencias Recomendadas

```xml
<dependencies>
    <!-- RxJava -->
    <dependency>
        <groupId>io.reactivex.rxjava3</groupId>
        <artifactId>rxjava</artifactId>
        <version>3.1.8</version>
    </dependency>

    <!-- Retrofit -->
    <dependency>
        <groupId>com.squareup.retrofit2</groupId>
        <artifactId>retrofit</artifactId>
        <version>2.9.0</version>
    </dependency>

    <dependency>
        <groupId>com.squareup.retrofit2</groupId>
        <artifactId>converter-gson</artifactId>
        <version>2.9.0</version>
    </dependency>

    <dependency>
        <groupId>com.squareup.retrofit2</groupId>
        <artifactId>adapter-rxjava3</artifactId>
        <version>2.9.0</version>
    </dependency>

    <!-- OkHttp -->
    <dependency>
        <groupId>com.squareup.okhttp3</groupId>
        <artifactId>okhttp</artifactId>
        <version>4.12.0</version>
    </dependency>

    <dependency>
        <groupId>com.squareup.okhttp3</groupId>
        <artifactId>logging-interceptor</artifactId>
        <version>4.12.0</version>
    </dependency>

    <!-- OpenAPI Generator -->
    <dependency>
        <groupId>org.openapitools</groupId>
        <artifactId>jackson-databind-nullable</artifactId>
        <version>0.2.6</version>
    </dependency>
</dependencies>
```

## Checklist de Desarrollo

- [ ] Especificación OpenAPI definida y validada
- [ ] Código generado desde OpenAPI
- [ ] Interfaces Retrofit definidas con tipos reactivos
- [ ] Servicios implementados con composición reactiva
- [ ] Manejo de errores específico por tipo
- [ ] Timeouts y reintentos configurados
- [ ] Tests unitarios con TestObserver
- [ ] Tests de integración con WireMock
- [ ] Schedulers apropiados para cada operación
- [ ] CompositeDisposable para limpieza de recursos
- [ ] Logging de operaciones y errores
- [ ] Interceptores para autenticación y logging
