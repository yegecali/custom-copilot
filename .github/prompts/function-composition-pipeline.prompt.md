---
agent: agent
---

# Pipeline Funcional con Function Composition usando andThen y compose

## Descripción

Crea pipelines funcionales componiendo transformaciones usando los métodos `andThen` y `compose` de la interfaz `Function`, permitiendo construir cadenas de procesamiento declarativas y reutilizables.

## Objetivos

- Componer funciones usando `andThen` (left-to-right)
- Componer funciones usando `compose` (right-to-left)
- Crear pipelines de transformación declarativos
- Construir funciones complejas a partir de funciones simples
- Aplicar composición funcional para procesamiento de datos

---

## 1. Fundamentos de Composición de Funciones

### 1.1 andThen vs compose

```java
/**
 * Comparación entre andThen y compose
 */
public class FunctionCompositionBasics {

    public static void demonstrateComposition() {
        // Funciones simples
        Function<String, String> trim = String::trim;
        Function<String, String> toLowerCase = String::toLowerCase;
        Function<String, Integer> length = String::length;

        // andThen: ejecuta de izquierda a derecha (f.andThen(g) = g(f(x)))
        Function<String, Integer> pipeline1 = trim
            .andThen(toLowerCase)
            .andThen(length);

        // compose: ejecuta de derecha a izquierda (f.compose(g) = f(g(x)))
        Function<String, Integer> pipeline2 = length
            .compose(toLowerCase)
            .compose(trim);

        String input = "  HELLO  ";

        System.out.println("Input: '" + input + "'");
        System.out.println("andThen result: " + pipeline1.apply(input)); // 5
        System.out.println("compose result: " + pipeline2.apply(input)); // 5

        // Ambos son equivalentes pero con orden de lectura diferente
    }
}
```

### 1.2 Composición Básica

```java
/**
 * Ejemplos básicos de composición
 */
public class BasicComposition {

    // Funciones atómicas reutilizables
    public static final Function<String, String> TRIM = String::trim;
    public static final Function<String, String> TO_UPPER = String::toUpperCase;
    public static final Function<String, String> TO_LOWER = String::toLowerCase;
    public static final Function<String, Integer> LENGTH = String::length;
    public static final Function<Integer, Integer> DOUBLE = n -> n * 2;
    public static final Function<Integer, Boolean> IS_EVEN = n -> n % 2 == 0;

    public static void examples() {
        // Ejemplo 1: Pipeline simple con andThen
        Function<String, Integer> stringProcessor = TRIM
            .andThen(TO_LOWER)
            .andThen(LENGTH)
            .andThen(DOUBLE);

        System.out.println(stringProcessor.apply("  HELLO  ")); // 10

        // Ejemplo 2: Pipeline con compose (orden inverso)
        Function<String, Boolean> isEvenLength = TRIM
            .andThen(LENGTH)
            .andThen(IS_EVEN);

        System.out.println(isEvenLength.apply("  test  ")); // true (4 chars)

        // Ejemplo 3: Composición parcial
        Function<String, String> normalizeString = TRIM.andThen(TO_LOWER);

        System.out.println(normalizeString.apply("  MixedCase  ")); // "mixedcase"
    }
}
```

---

## 2. Pipeline Builder para Transformaciones

### 2.1 Builder Genérico

```java
/**
 * Builder fluente para crear pipelines de transformación
 */
public class FunctionPipeline<T, R> {
    private Function<T, R> function;

    private FunctionPipeline(Function<T, R> function) {
        this.function = function;
    }

    public static <T> FunctionPipeline<T, T> start() {
        return new FunctionPipeline<>(Function.identity());
    }

    public static <T, R> FunctionPipeline<T, R> startWith(Function<T, R> function) {
        return new FunctionPipeline<>(function);
    }

    public <V> FunctionPipeline<T, V> then(Function<R, V> next) {
        return new FunctionPipeline<>(function.andThen(next));
    }

    public <V> FunctionPipeline<T, V> map(Function<R, V> mapper) {
        return then(mapper);
    }

    public FunctionPipeline<T, R> filter(Predicate<R> predicate, R defaultValue) {
        return new FunctionPipeline<>(
            t -> {
                R result = function.apply(t);
                return predicate.test(result) ? result : defaultValue;
            }
        );
    }

    public FunctionPipeline<T, R> peek(Consumer<R> action) {
        return new FunctionPipeline<>(
            t -> {
                R result = function.apply(t);
                action.accept(result);
                return result;
            }
        );
    }

    public <E extends Exception> FunctionPipeline<T, R> onError(
            Class<E> exceptionClass,
            Function<E, R> handler) {
        return new FunctionPipeline<>(
            t -> {
                try {
                    return function.apply(t);
                } catch (Exception e) {
                    if (exceptionClass.isInstance(e)) {
                        return handler.apply(exceptionClass.cast(e));
                    }
                    throw e;
                }
            }
        );
    }

    public FunctionPipeline<T, Optional<R>> toOptional() {
        return new FunctionPipeline<>(
            t -> Optional.ofNullable(function.apply(t))
        );
    }

    public Function<T, R> build() {
        return function;
    }

    public R apply(T input) {
        return function.apply(input);
    }
}
```

### 2.2 Uso del Pipeline Builder

```java
public class PipelineExamples {

    record User(String name, int age, String email) {}
    record UserDTO(String displayName, int age, String email) {}

    public static void demonstratePipeline() {
        // Pipeline para procesar nombres de usuario
        Function<String, String> normalizeUsername = FunctionPipeline.<String>start()
            .then(String::trim)
            .then(String::toLowerCase)
            .peek(name -> System.out.println("Processing: " + name))
            .then(name -> name.replaceAll("\\s+", "_"))
            .filter(name -> !name.isEmpty(), "anonymous")
            .build();

        String result = normalizeUsername.apply("  John Doe  ");
        System.out.println("Result: " + result); // "john_doe"

        // Pipeline para transformar User a UserDTO
        Function<User, UserDTO> userToDTO = FunctionPipeline.<User, UserDTO>startWith(
            user -> new UserDTO(
                user.name().toUpperCase(),
                user.age(),
                user.email()
            )
        )
        .peek(dto -> System.out.println("Created DTO: " + dto))
        .build();

        User user = new User("Alice", 25, "alice@example.com");
        UserDTO dto = userToDTO.apply(user);
    }
}
```

---

## 3. Pipelines de Procesamiento de Datos

### 3.1 Pipeline para Validación y Transformación

```java
/**
 * Sistema de validación y transformación usando pipelines
 */
public class DataProcessingPipeline {

    record ValidationResult<T>(T value, List<String> errors) {
        public boolean isValid() {
            return errors.isEmpty();
        }

        public static <T> ValidationResult<T> success(T value) {
            return new ValidationResult<>(value, List.of());
        }

        public static <T> ValidationResult<T> failure(T value, String error) {
            return new ValidationResult<>(value, List.of(error));
        }
    }

    public static class ValidatingPipeline<T> {
        private final List<Function<T, ValidationResult<T>>> validators;

        public ValidatingPipeline() {
            this.validators = new ArrayList<>();
        }

        public ValidatingPipeline<T> validate(
                Predicate<T> condition,
                String errorMessage) {
            validators.add(value ->
                condition.test(value)
                    ? ValidationResult.success(value)
                    : ValidationResult.failure(value, errorMessage)
            );
            return this;
        }

        public ValidatingPipeline<T> transform(Function<T, T> transformer) {
            validators.add(value ->
                ValidationResult.success(transformer.apply(value))
            );
            return this;
        }

        public Function<T, ValidationResult<T>> build() {
            return input -> {
                T current = input;
                List<String> allErrors = new ArrayList<>();

                for (Function<T, ValidationResult<T>> validator : validators) {
                    ValidationResult<T> result = validator.apply(current);
                    if (!result.isValid()) {
                        allErrors.addAll(result.errors());
                    }
                    current = result.value();
                }

                return allErrors.isEmpty()
                    ? ValidationResult.success(current)
                    : new ValidationResult<>(current, allErrors);
            };
        }
    }

    // Ejemplo de uso
    public static void validateEmail() {
        Function<String, ValidationResult<String>> emailValidator =
            new ValidatingPipeline<String>()
                .validate(Objects::nonNull, "Email cannot be null")
                .transform(String::trim)
                .validate(s -> !s.isEmpty(), "Email cannot be empty")
                .transform(String::toLowerCase)
                .validate(s -> s.contains("@"), "Email must contain @")
                .validate(
                    s -> s.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$"),
                    "Invalid email format"
                )
                .build();

        ValidationResult<String> result = emailValidator.apply("  JOHN@EXAMPLE.COM  ");
        System.out.println("Valid: " + result.isValid());
        System.out.println("Value: " + result.value());
        System.out.println("Errors: " + result.errors());
    }
}
```

### 3.2 Pipeline de Procesamiento de Texto

```java
/**
 * Pipeline para procesamiento de texto complejo
 */
public class TextProcessingPipeline {

    // Funciones atómicas
    public static final Function<String, String> NORMALIZE_WHITESPACE =
        text -> text.replaceAll("\\s+", " ");

    public static final Function<String, String> REMOVE_SPECIAL_CHARS =
        text -> text.replaceAll("[^a-zA-Z0-9\\s]", "");

    public static final Function<String, String> CAPITALIZE_WORDS =
        text -> Arrays.stream(text.split("\\s+"))
            .map(word -> word.substring(0, 1).toUpperCase() + word.substring(1).toLowerCase())
            .collect(Collectors.joining(" "));

    public static final Function<String, String> REMOVE_EXTRA_SPACES =
        text -> text.trim().replaceAll("\\s+", " ");

    public static final Function<String, List<String>> TOKENIZE =
        text -> Arrays.asList(text.split("\\s+"));

    public static final Function<List<String>, List<String>> REMOVE_STOPWORDS =
        tokens -> {
            Set<String> stopwords = Set.of("the", "a", "an", "and", "or", "but");
            return tokens.stream()
                .filter(token -> !stopwords.contains(token.toLowerCase()))
                .collect(Collectors.toList());
        };

    public static final Function<List<String>, Map<String, Long>> COUNT_FREQUENCY =
        tokens -> tokens.stream()
            .collect(Collectors.groupingBy(
                Function.identity(),
                Collectors.counting()
            ));

    // Pipeline completo
    public static Function<String, String> createNormalizationPipeline() {
        return FunctionPipeline.<String>start()
            .then(String::trim)
            .then(NORMALIZE_WHITESPACE)
            .then(String::toLowerCase)
            .then(REMOVE_SPECIAL_CHARS)
            .then(REMOVE_EXTRA_SPACES)
            .build();
    }

    public static Function<String, List<String>> createTokenizationPipeline() {
        return FunctionPipeline.<String>start()
            .then(createNormalizationPipeline())
            .then(TOKENIZE)
            .then(REMOVE_STOPWORDS)
            .build();
    }

    public static Function<String, Map<String, Long>> createWordFrequencyPipeline() {
        return FunctionPipeline.<String>start()
            .then(createTokenizationPipeline())
            .then(COUNT_FREQUENCY)
            .build();
    }

    public static void example() {
        String text = "The quick brown fox jumps over the lazy dog. The dog was really lazy!";

        // Usar pipeline de normalización
        String normalized = createNormalizationPipeline().apply(text);
        System.out.println("Normalized: " + normalized);

        // Usar pipeline de tokenización
        List<String> tokens = createTokenizationPipeline().apply(text);
        System.out.println("Tokens: " + tokens);

        // Usar pipeline de frecuencia
        Map<String, Long> frequency = createWordFrequencyPipeline().apply(text);
        System.out.println("Frequency: " + frequency);
    }
}
```

---

## 4. Composición con Múltiples Tipos

### 4.1 Transformaciones Encadenadas

```java
/**
 * Pipeline que transforma entre múltiples tipos
 */
public class MultiTypeTransformation {

    record RawData(String payload, Instant timestamp) {}
    record ParsedData(JsonNode json, Instant timestamp) {}
    record ValidatedData(Map<String, Object> data, Instant timestamp) {}
    record EnrichedData(Map<String, Object> data, Instant timestamp, String userId) {}
    record StorageData(String id, byte[] content, Instant timestamp) {}

    // Funciones de transformación
    public static final Function<RawData, ParsedData> PARSE_JSON =
        raw -> {
            try {
                ObjectMapper mapper = new ObjectMapper();
                JsonNode json = mapper.readTree(raw.payload());
                return new ParsedData(json, raw.timestamp());
            } catch (Exception e) {
                throw new RuntimeException("Failed to parse JSON", e);
            }
        };

    public static final Function<ParsedData, ValidatedData> VALIDATE =
        parsed -> {
            Map<String, Object> data = new HashMap<>();
            // Validar y extraer campos
            if (parsed.json().has("name") && parsed.json().has("email")) {
                data.put("name", parsed.json().get("name").asText());
                data.put("email", parsed.json().get("email").asText());
                return new ValidatedData(data, parsed.timestamp());
            }
            throw new RuntimeException("Validation failed");
        };

    public static final Function<ValidatedData, EnrichedData> ENRICH =
        validated -> {
            String userId = UUID.randomUUID().toString();
            return new EnrichedData(
                validated.data(),
                validated.timestamp(),
                userId
            );
        };

    public static final Function<EnrichedData, StorageData> SERIALIZE =
        enriched -> {
            try {
                ObjectMapper mapper = new ObjectMapper();
                Map<String, Object> fullData = new HashMap<>(enriched.data());
                fullData.put("userId", enriched.userId());
                fullData.put("timestamp", enriched.timestamp().toString());

                byte[] content = mapper.writeValueAsBytes(fullData);
                return new StorageData(enriched.userId(), content, enriched.timestamp());
            } catch (Exception e) {
                throw new RuntimeException("Failed to serialize", e);
            }
        };

    // Pipeline completo
    public static Function<RawData, StorageData> createDataPipeline() {
        return FunctionPipeline.<RawData, StorageData>startWith(PARSE_JSON)
            .then(VALIDATE)
            .then(ENRICH)
            .peek(enriched -> System.out.println("Enriched: " + enriched.userId()))
            .then(SERIALIZE)
            .peek(storage -> System.out.println("Stored: " + storage.id()))
            .build();
    }

    public static void processData() {
        RawData input = new RawData(
            "{\"name\":\"John\",\"email\":\"john@example.com\"}",
            Instant.now()
        );

        Function<RawData, StorageData> pipeline = createDataPipeline();
        StorageData result = pipeline.apply(input);

        System.out.println("Final result ID: " + result.id());
    }
}
```

---

## 5. Composición con Manejo de Errores

### 5.1 Try Monad para Composición Segura

```java
/**
 * Try monad para composición funcional con manejo de errores
 */
public abstract class Try<T> {

    public abstract boolean isSuccess();
    public abstract T get();
    public abstract Exception getError();

    public static <T> Try<T> of(Supplier<T> supplier) {
        try {
            return new Success<>(supplier.get());
        } catch (Exception e) {
            return new Failure<>(e);
        }
    }

    public <R> Try<R> map(Function<T, R> mapper) {
        if (isSuccess()) {
            return Try.of(() -> mapper.apply(get()));
        }
        return (Try<R>) this;
    }

    public <R> Try<R> flatMap(Function<T, Try<R>> mapper) {
        if (isSuccess()) {
            try {
                return mapper.apply(get());
            } catch (Exception e) {
                return new Failure<>(e);
            }
        }
        return (Try<R>) this;
    }

    public Try<T> recover(Function<Exception, T> recovery) {
        if (!isSuccess()) {
            try {
                return new Success<>(recovery.apply(getError()));
            } catch (Exception e) {
                return new Failure<>(e);
            }
        }
        return this;
    }

    public T getOrElse(T defaultValue) {
        return isSuccess() ? get() : defaultValue;
    }

    public T getOrElse(Supplier<T> defaultSupplier) {
        return isSuccess() ? get() : defaultSupplier.get();
    }

    private static class Success<T> extends Try<T> {
        private final T value;

        Success(T value) {
            this.value = value;
        }

        @Override
        public boolean isSuccess() {
            return true;
        }

        @Override
        public T get() {
            return value;
        }

        @Override
        public Exception getError() {
            throw new UnsupportedOperationException("Success has no error");
        }
    }

    private static class Failure<T> extends Try<T> {
        private final Exception exception;

        Failure(Exception exception) {
            this.exception = exception;
        }

        @Override
        public boolean isSuccess() {
            return false;
        }

        @Override
        public T get() {
            throw new RuntimeException("Cannot get value from Failure", exception);
        }

        @Override
        public Exception getError() {
            return exception;
        }
    }
}
```

### 5.2 Pipeline con Try

```java
public class SafePipeline {

    // Funciones que pueden fallar
    public static Try<String> parseJson(String json) {
        return Try.of(() -> {
            ObjectMapper mapper = new ObjectMapper();
            JsonNode node = mapper.readTree(json);
            return node.toString();
        });
    }

    public static Try<Map<String, Object>> extractData(String json) {
        return Try.of(() -> {
            ObjectMapper mapper = new ObjectMapper();
            return mapper.readValue(json, new TypeReference<Map<String, Object>>() {});
        });
    }

    public static Try<String> validateData(Map<String, Object> data) {
        return Try.of(() -> {
            if (!data.containsKey("name") || !data.containsKey("email")) {
                throw new IllegalArgumentException("Missing required fields");
            }
            return "Validation passed";
        });
    }

    // Pipeline seguro
    public static Try<String> processUserData(String rawJson) {
        return parseJson(rawJson)
            .flatMap(json -> extractData(json))
            .flatMap(data -> validateData(data))
            .recover(error -> "Failed: " + error.getMessage());
    }

    public static void example() {
        String validJson = "{\"name\":\"John\",\"email\":\"john@example.com\"}";
        String invalidJson = "{invalid json}";

        Try<String> result1 = processUserData(validJson);
        System.out.println("Result 1: " + result1.getOrElse("Error"));

        Try<String> result2 = processUserData(invalidJson);
        System.out.println("Result 2: " + result2.getOrElse("Error"));
    }
}
```

---

## 6. Composición Avanzada

### 6.1 Lifting Functions

```java
/**
 * Lifting: convertir funciones regulares a funciones que operan en contextos
 */
public class FunctionLifting {

    // Lift a Optional context
    public static <T, R> Function<Optional<T>, Optional<R>> liftOptional(
            Function<T, R> function) {
        return optional -> optional.map(function);
    }

    // Lift to List context
    public static <T, R> Function<List<T>, List<R>> liftList(
            Function<T, R> function) {
        return list -> list.stream()
            .map(function)
            .collect(Collectors.toList());
    }

    // Lift to Try context
    public static <T, R> Function<Try<T>, Try<R>> liftTry(
            Function<T, R> function) {
        return tryValue -> tryValue.map(function);
    }

    // Ejemplo de uso
    public static void demonstrateLifting() {
        Function<String, Integer> length = String::length;

        // Lift a Optional
        Function<Optional<String>, Optional<Integer>> optionalLength =
            liftOptional(length);

        Optional<String> maybeString = Optional.of("Hello");
        Optional<Integer> maybeLength = optionalLength.apply(maybeString);
        System.out.println("Optional length: " + maybeLength.orElse(0));

        // Lift a List
        Function<List<String>, List<Integer>> listLength = liftList(length);

        List<String> strings = List.of("a", "bb", "ccc");
        List<Integer> lengths = listLength.apply(strings);
        System.out.println("List lengths: " + lengths);
    }
}
```

### 6.2 Function Currying

```java
/**
 * Currying: transformar función de múltiples parámetros en funciones unarias encadenadas
 */
public class FunctionCurrying {

    // Curry una BiFunction
    public static <T, U, R> Function<T, Function<U, R>> curry(
            BiFunction<T, U, R> biFunction) {
        return t -> u -> biFunction.apply(t, u);
    }

    // Uncurry: reverso de curry
    public static <T, U, R> BiFunction<T, U, R> uncurry(
            Function<T, Function<U, R>> curriedFunction) {
        return (t, u) -> curriedFunction.apply(t).apply(u);
    }

    // Curry para 3 parámetros
    public static <T, U, V, R> Function<T, Function<U, Function<V, R>>> curry3(
            TriFunction<T, U, V, R> triFunction) {
        return t -> u -> v -> triFunction.apply(t, u, v);
    }

    @FunctionalInterface
    interface TriFunction<T, U, V, R> {
        R apply(T t, U u, V v);
    }

    // Ejemplos
    public static void demonstrateCurrying() {
        // Función suma de 2 números
        BiFunction<Integer, Integer, Integer> add = (a, b) -> a + b;

        // Curry: convertir a funciones unarias encadenadas
        Function<Integer, Function<Integer, Integer>> curriedAdd = curry(add);

        // Aplicación parcial
        Function<Integer, Integer> add5 = curriedAdd.apply(5);
        System.out.println("5 + 3 = " + add5.apply(3)); // 8
        System.out.println("5 + 7 = " + add5.apply(7)); // 12

        // Función con 3 parámetros
        TriFunction<String, String, String, String> concat =
            (a, b, c) -> a + b + c;

        Function<String, Function<String, Function<String, String>>> curriedConcat =
            curry3(concat);

        Function<String, Function<String, String>> concatHello =
            curriedConcat.apply("Hello");
        Function<String, String> concatHelloWorld =
            concatHello.apply(" World");

        System.out.println(concatHelloWorld.apply("!")); // "Hello World!"
    }
}
```

---

## 7. Testing

```java
@ExtendWith(MockitoExtension.class)
class FunctionCompositionTest {

    @Test
    @DisplayName("andThen debe componer funciones de izquierda a derecha")
    void testAndThen() {
        // Arrange
        Function<String, String> trim = String::trim;
        Function<String, String> upper = String::toUpperCase;
        Function<String, Integer> length = String::length;

        Function<String, Integer> pipeline = trim.andThen(upper).andThen(length);

        // Act
        Integer result = pipeline.apply("  hello  ");

        // Assert
        assertThat(result).isEqualTo(5);
    }

    @Test
    @DisplayName("compose debe componer funciones de derecha a izquierda")
    void testCompose() {
        // Arrange
        Function<String, Integer> length = String::length;
        Function<String, String> upper = String::toUpperCase;
        Function<String, String> trim = String::trim;

        Function<String, Integer> pipeline = length.compose(upper).compose(trim);

        // Act
        Integer result = pipeline.apply("  hello  ");

        // Assert
        assertThat(result).isEqualTo(5);
    }

    @Test
    @DisplayName("Pipeline builder debe crear funciones compuestas correctamente")
    void testPipelineBuilder() {
        // Arrange
        Function<String, String> pipeline = FunctionPipeline.<String>start()
            .then(String::trim)
            .then(String::toLowerCase)
            .then(s -> s.replaceAll("\\s+", "_"))
            .build();

        // Act
        String result = pipeline.apply("  Hello World  ");

        // Assert
        assertThat(result).isEqualTo("hello_world");
    }

    @Test
    @DisplayName("Try monad debe manejar errores en pipeline")
    void testTryPipeline() {
        // Arrange
        Function<String, Try<Integer>> safeParseInt =
            str -> Try.of(() -> Integer.parseInt(str));

        // Act
        Try<Integer> success = safeParseInt.apply("123");
        Try<Integer> failure = safeParseInt.apply("not a number");

        // Assert
        assertThat(success.isSuccess()).isTrue();
        assertThat(success.get()).isEqualTo(123);

        assertThat(failure.isSuccess()).isFalse();
        assertThat(failure.getOrElse(-1)).isEqualTo(-1);
    }
}
```

---

## 8. Best Practices

### ✅ DO

1. **Usar andThen para lectura natural de izquierda a derecha**

```java
// ✅ Bueno: Se lee en orden de ejecución
Function<String, Integer> pipeline = trim
    .andThen(toLowerCase)
    .andThen(length);
```

2. **Crear funciones atómicas reutilizables**

```java
// ✅ Bueno: Funciones pequeñas y componibles
public static final Function<String, String> TRIM = String::trim;
public static final Function<String, String> TO_LOWER = String::toLowerCase;
```

3. **Nombrar pipelines con nombres descriptivos**

```java
// ✅ Bueno
Function<User, UserDTO> userToDTO = ...;
Function<String, ValidationResult> emailValidator = ...;
```

### ❌ DON'T

1. **No crear pipelines demasiado largos**

```java
// ❌ Malo: Pipeline gigante difícil de leer
Function<String, String> giant = f1.andThen(f2).andThen(f3).andThen(f4)
    .andThen(f5).andThen(f6).andThen(f7).andThen(f8);

// ✅ Mejor: Dividir en sub-pipelines
Function<String, String> normalization = f1.andThen(f2).andThen(f3);
Function<String, String> transformation = f4.andThen(f5);
Function<String, String> validation = f6.andThen(f7).andThen(f8);
Function<String, String> complete = normalization.andThen(transformation).andThen(validation);
```

---

## Conclusión

La composición de funciones con `andThen` y `compose` permite:

**Ventajas:**

- ✅ Pipelines declarativos y legibles
- ✅ Funciones atómicas reutilizables
- ✅ Transformaciones type-safe encadenadas
- ✅ Separación clara de responsabilidades
- ✅ Testing simplificado de etapas individuales

**Cuándo usar:**

- Procesamiento de datos en múltiples etapas
- Validación y transformación de inputs
- Construcción de DSLs declarativos
- ETL (Extract-Transform-Load) pipelines
