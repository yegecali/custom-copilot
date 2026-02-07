---
agent: agent
---

# Combinator Pattern: Encadenamiento de Funciones Pequeñas

## Descripción

Implementa el patrón Combinator para construir lógica compleja encadenando funciones pequeñas y componibles, permitiendo crear DSLs (Domain-Specific Languages) expresivos y declarativos.

## Objetivos

- Crear combinadores básicos reutilizables
- Encadenar funciones pequeñas para construir lógica compleja
- Diseñar DSLs fluentes usando combinadores
- Componer validadores y parsers de forma declarativa
- Aplicar el patrón para crear APIs expresivas

---

## 1. Fundamentos del Patrón Combinator

### 1.1 Concepto Básico

```java
/**
 * Un combinator es una función que combina otras funciones
 * para crear nuevas funciones más complejas
 */
@FunctionalInterface
public interface Parser<T> {
    ParseResult<T> parse(String input);

    // Combinator: secuencia (this, then that)
    default <U> Parser<U> thenIgnore(Parser<U> next) {
        return input -> {
            ParseResult<T> first = this.parse(input);
            if (!first.isSuccess()) {
                return ParseResult.failure(first.getError());
            }
            return next.parse(first.getRemaining());
        };
    }

    // Combinator: alternativa (this or that)
    default Parser<T> or(Parser<T> alternative) {
        return input -> {
            ParseResult<T> result = this.parse(input);
            return result.isSuccess() ? result : alternative.parse(input);
        };
    }

    // Combinator: mapeo
    default <U> Parser<U> map(Function<T, U> mapper) {
        return input -> {
            ParseResult<T> result = this.parse(input);
            return result.isSuccess()
                ? ParseResult.success(mapper.apply(result.getValue()), result.getRemaining())
                : ParseResult.failure(result.getError());
        };
    }
}

record ParseResult<T>(
    boolean isSuccess,
    T value,
    String remaining,
    String error
) {
    public static <T> ParseResult<T> success(T value, String remaining) {
        return new ParseResult<>(true, value, remaining, null);
    }

    public static <T> ParseResult<T> failure(String error) {
        return new ParseResult<>(false, null, null, error);
    }

    public T getValue() {
        if (!isSuccess) throw new RuntimeException(error);
        return value;
    }

    public String getError() {
        return error;
    }

    public String getRemaining() {
        return remaining;
    }
}
```

---

## 2. Parser Combinators

### 2.1 Parsers Básicos

```java
/**
 * Librería de parser combinators básicos
 */
public class Parsers {

    // Parser que consume un carácter específico
    public static Parser<Character> char_(char c) {
        return input -> {
            if (input.isEmpty()) {
                return ParseResult.failure("Expected '" + c + "' but got EOF");
            }
            if (input.charAt(0) == c) {
                return ParseResult.success(c, input.substring(1));
            }
            return ParseResult.failure("Expected '" + c + "' but got '" + input.charAt(0) + "'");
        };
    }

    // Parser que consume cualquier carácter que cumpla un predicado
    public static Parser<Character> satisfy(Predicate<Character> predicate, String description) {
        return input -> {
            if (input.isEmpty()) {
                return ParseResult.failure("Expected " + description + " but got EOF");
            }
            char c = input.charAt(0);
            if (predicate.test(c)) {
                return ParseResult.success(c, input.substring(1));
            }
            return ParseResult.failure("Expected " + description + " but got '" + c + "'");
        };
    }

    // Parser que consume un dígito
    public static Parser<Character> digit() {
        return satisfy(Character::isDigit, "digit");
    }

    // Parser que consume una letra
    public static Parser<Character> letter() {
        return satisfy(Character::isLetter, "letter");
    }

    // Parser que consume espacios en blanco
    public static Parser<String> whitespace() {
        return input -> {
            int i = 0;
            while (i < input.length() && Character.isWhitespace(input.charAt(i))) {
                i++;
            }
            return ParseResult.success(input.substring(0, i), input.substring(i));
        };
    }

    // Parser que consume una cadena específica
    public static Parser<String> string(String expected) {
        return input -> {
            if (input.startsWith(expected)) {
                return ParseResult.success(expected, input.substring(expected.length()));
            }
            return ParseResult.failure("Expected '" + expected + "'");
        };
    }

    // Combinator: many (0 o más repeticiones)
    public static <T> Parser<List<T>> many(Parser<T> parser) {
        return input -> {
            List<T> results = new ArrayList<>();
            String remaining = input;

            while (true) {
                ParseResult<T> result = parser.parse(remaining);
                if (!result.isSuccess()) {
                    break;
                }
                results.add(result.getValue());
                remaining = result.getRemaining();
            }

            return ParseResult.success(results, remaining);
        };
    }

    // Combinator: many1 (1 o más repeticiones)
    public static <T> Parser<List<T>> many1(Parser<T> parser) {
        return input -> {
            ParseResult<List<T>> result = many(parser).parse(input);
            if (result.getValue().isEmpty()) {
                return ParseResult.failure("Expected at least one match");
            }
            return result;
        };
    }

    // Combinator: optional
    public static <T> Parser<Optional<T>> optional(Parser<T> parser) {
        return input -> {
            ParseResult<T> result = parser.parse(input);
            if (result.isSuccess()) {
                return ParseResult.success(Optional.of(result.getValue()), result.getRemaining());
            }
            return ParseResult.success(Optional.empty(), input);
        };
    }

    // Combinator: between (parsea algo entre dos delimitadores)
    public static <T> Parser<T> between(Parser<?> open, Parser<?> close, Parser<T> content) {
        return open.thenIgnore(content).map(t -> {
            // Consume close pero ignora su resultado
            return t;
        });
    }

    // Combinator: sepBy (elementos separados por delimitador)
    public static <T, S> Parser<List<T>> sepBy(Parser<T> element, Parser<S> separator) {
        return input -> {
            List<T> results = new ArrayList<>();
            String remaining = input;

            // Primer elemento
            ParseResult<T> first = element.parse(remaining);
            if (!first.isSuccess()) {
                return ParseResult.success(results, remaining); // Lista vacía
            }

            results.add(first.getValue());
            remaining = first.getRemaining();

            // Elementos siguientes precedidos por separador
            while (true) {
                ParseResult<S> sepResult = separator.parse(remaining);
                if (!sepResult.isSuccess()) {
                    break;
                }

                ParseResult<T> elemResult = element.parse(sepResult.getRemaining());
                if (!elemResult.isSuccess()) {
                    return ParseResult.failure("Expected element after separator");
                }

                results.add(elemResult.getValue());
                remaining = elemResult.getRemaining();
            }

            return ParseResult.success(results, remaining);
        };
    }
}
```

### 2.2 Ejemplo: Parser de Números

```java
public class NumberParser {

    // Parser de entero
    public static Parser<Integer> integer() {
        return Parsers.many1(Parsers.digit())
            .map(digits -> {
                String numberStr = digits.stream()
                    .map(String::valueOf)
                    .collect(Collectors.joining());
                return Integer.parseInt(numberStr);
            });
    }

    // Parser de decimal
    public static Parser<Double> decimal() {
        return integer()
            .thenIgnore(Parsers.char_('.'))
            .thenIgnore(integer())
            .map(parts -> {
                // Combinar parte entera y decimal
                return Double.parseDouble(parts.toString());
            });
    }

    public static void demo() {
        Parser<Integer> intParser = integer();
        ParseResult<Integer> result = intParser.parse("12345abc");

        System.out.println("Success: " + result.isSuccess());
        System.out.println("Value: " + result.getValue());
        System.out.println("Remaining: " + result.getRemaining());
    }
}
```

---

## 3. Validation Combinators

### 3.1 Sistema de Validación con Combinadores

```java
/**
 * Combinator para validaciones componibles
 */
@FunctionalInterface
public interface Validator<T> {
    ValidationResult validate(T value);

    // Combinator: AND (ambos deben pasar)
    default Validator<T> and(Validator<T> other) {
        return value -> {
            ValidationResult first = this.validate(value);
            if (!first.isValid()) {
                return first;
            }
            return other.validate(value);
        };
    }

    // Combinator: OR (al menos uno debe pasar)
    default Validator<T> or(Validator<T> other) {
        return value -> {
            ValidationResult first = this.validate(value);
            if (first.isValid()) {
                return first;
            }
            return other.validate(value);
        };
    }

    // Combinator: NOT (invertir resultado)
    default Validator<T> not() {
        return value -> {
            ValidationResult result = this.validate(value);
            return result.isValid()
                ? ValidationResult.failure("Validation should have failed")
                : ValidationResult.success();
        };
    }

    // Combinator: MAP (transformar input antes de validar)
    default <U> Validator<U> contramap(Function<U, T> mapper) {
        return value -> this.validate(mapper.apply(value));
    }
}

record ValidationResult(boolean isValid, List<String> errors) {
    public static ValidationResult success() {
        return new ValidationResult(true, List.of());
    }

    public static ValidationResult failure(String error) {
        return new ValidationResult(false, List.of(error));
    }

    public static ValidationResult failures(List<String> errors) {
        return new ValidationResult(false, errors);
    }

    public ValidationResult combine(ValidationResult other) {
        if (this.isValid && other.isValid) {
            return success();
        }
        List<String> allErrors = Stream.concat(
            this.errors.stream(),
            other.errors.stream()
        ).toList();
        return new ValidationResult(false, allErrors);
    }
}
```

### 3.2 Validadores Básicos

```java
/**
 * Librería de validadores combinables
 */
public class Validators {

    // Validator: not null
    public static <T> Validator<T> notNull() {
        return value -> value != null
            ? ValidationResult.success()
            : ValidationResult.failure("Value cannot be null");
    }

    // Validator: string not empty
    public static Validator<String> notEmpty() {
        return value -> value != null && !value.isEmpty()
            ? ValidationResult.success()
            : ValidationResult.failure("String cannot be empty");
    }

    // Validator: string min length
    public static Validator<String> minLength(int min) {
        return value -> value.length() >= min
            ? ValidationResult.success()
            : ValidationResult.failure("String must be at least " + min + " characters");
    }

    // Validator: string max length
    public static Validator<String> maxLength(int max) {
        return value -> value.length() <= max
            ? ValidationResult.success()
            : ValidationResult.failure("String must be at most " + max + " characters");
    }

    // Validator: matches regex
    public static Validator<String> matches(String regex, String description) {
        Pattern pattern = Pattern.compile(regex);
        return value -> pattern.matcher(value).matches()
            ? ValidationResult.success()
            : ValidationResult.failure("String must match " + description);
    }

    // Validator: in range
    public static <T extends Comparable<T>> Validator<T> inRange(T min, T max) {
        return value ->
            value.compareTo(min) >= 0 && value.compareTo(max) <= 0
                ? ValidationResult.success()
                : ValidationResult.failure("Value must be between " + min + " and " + max);
    }

    // Validator: greater than
    public static <T extends Comparable<T>> Validator<T> greaterThan(T threshold) {
        return value -> value.compareTo(threshold) > 0
            ? ValidationResult.success()
            : ValidationResult.failure("Value must be greater than " + threshold);
    }

    // Validator: predicate
    public static <T> Validator<T> predicate(Predicate<T> pred, String errorMessage) {
        return value -> pred.test(value)
            ? ValidationResult.success()
            : ValidationResult.failure(errorMessage);
    }

    // Combinator: all (todos deben pasar)
    @SafeVarargs
    public static <T> Validator<T> all(Validator<T>... validators) {
        return value -> Arrays.stream(validators)
            .map(v -> v.validate(value))
            .reduce(ValidationResult.success(), ValidationResult::combine);
    }

    // Combinator: any (al menos uno debe pasar)
    @SafeVarargs
    public static <T> Validator<T> any(Validator<T>... validators) {
        return value -> {
            for (Validator<T> validator : validators) {
                ValidationResult result = validator.validate(value);
                if (result.isValid()) {
                    return result;
                }
            }
            return ValidationResult.failure("None of the validators passed");
        };
    }
}
```

### 3.3 Uso de Validation Combinators

```java
public class UserValidation {

    record User(String username, String email, Integer age, String password) {}

    // Construir validadores complejos con combinadores
    public static Validator<String> usernameValidator() {
        return Validators.<String>notNull()
            .and(Validators.notEmpty())
            .and(Validators.minLength(3))
            .and(Validators.maxLength(20))
            .and(Validators.matches("^[a-zA-Z0-9_]+$", "alphanumeric and underscore only"));
    }

    public static Validator<String> emailValidator() {
        return Validators.<String>notNull()
            .and(Validators.notEmpty())
            .and(Validators.matches(
                "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$",
                "valid email format"
            ));
    }

    public static Validator<Integer> ageValidator() {
        return Validators.<Integer>notNull()
            .and(Validators.inRange(18, 120));
    }

    public static Validator<String> passwordValidator() {
        return Validators.<String>notNull()
            .and(Validators.minLength(8))
            .and(Validators.matches(".*[A-Z].*", "at least one uppercase letter"))
            .and(Validators.matches(".*[a-z].*", "at least one lowercase letter"))
            .and(Validators.matches(".*[0-9].*", "at least one digit"))
            .and(Validators.matches(".*[!@#$%^&*].*", "at least one special character"));
    }

    public static Validator<User> userValidator() {
        return user -> {
            ValidationResult usernameResult = usernameValidator()
                .contramap(User::username)
                .validate(user);

            ValidationResult emailResult = emailValidator()
                .contramap(User::email)
                .validate(user);

            ValidationResult ageResult = ageValidator()
                .contramap(User::age)
                .validate(user);

            ValidationResult passwordResult = passwordValidator()
                .contramap(User::password)
                .validate(user);

            return usernameResult
                .combine(emailResult)
                .combine(ageResult)
                .combine(passwordResult);
        };
    }

    public static void main(String[] args) {
        User validUser = new User(
            "john_doe",
            "john@example.com",
            25,
            "Password123!"
        );

        User invalidUser = new User(
            "ab",                      // Too short
            "invalid-email",           // Invalid format
            15,                        // Too young
            "weak"                     // Weak password
        );

        Validator<User> validator = userValidator();

        ValidationResult result1 = validator.validate(validUser);
        System.out.println("Valid user: " + result1.isValid());

        ValidationResult result2 = validator.validate(invalidUser);
        System.out.println("Invalid user: " + result2.isValid());
        System.out.println("Errors: " + result2.errors());
    }
}
```

---

## 4. Query Combinators

### 4.1 DSL para Construcción de Queries

```java
/**
 * Combinator para construir queries de forma declarativa
 */
public interface QueryBuilder<T> {
    Predicate<T> build();

    // Combinator: AND
    default QueryBuilder<T> and(QueryBuilder<T> other) {
        return () -> this.build().and(other.build());
    }

    // Combinator: OR
    default QueryBuilder<T> or(QueryBuilder<T> other) {
        return () -> this.build().or(other.build());
    }

    // Combinator: NOT
    default QueryBuilder<T> not() {
        return () -> this.build().negate();
    }

    // Factory methods
    static <T> QueryBuilder<T> where(Predicate<T> predicate) {
        return () -> predicate;
    }

    static <T, R> QueryBuilder<T> field(
            Function<T, R> extractor,
            Predicate<R> predicate) {
        return () -> t -> predicate.test(extractor.apply(t));
    }
}

/**
 * DSL fluente para queries
 */
public class Query<T> {
    private final QueryBuilder<T> builder;

    private Query(QueryBuilder<T> builder) {
        this.builder = builder;
    }

    public static <T> Query<T> select() {
        return new Query<>(QueryBuilder.where(t -> true));
    }

    public <R> Query<T> where(Function<T, R> extractor, Predicate<R> condition) {
        QueryBuilder<T> newBuilder = QueryBuilder.field(extractor, condition);
        return new Query<>(builder.and(newBuilder));
    }

    public Query<T> and(Function<T, Boolean> condition) {
        return new Query<>(builder.and(QueryBuilder.where(condition::apply)));
    }

    public Query<T> or(Function<T, Boolean> condition) {
        return new Query<>(builder.or(QueryBuilder.where(condition::apply)));
    }

    public Predicate<T> toPredicate() {
        return builder.build();
    }

    public List<T> from(List<T> source) {
        return source.stream()
            .filter(builder.build())
            .collect(Collectors.toList());
    }
}
```

### 4.2 Uso del Query DSL

```java
public class ProductQuery {

    record Product(
        String name,
        BigDecimal price,
        String category,
        boolean inStock,
        int rating
    ) {}

    public static void demonstrateQueryDSL() {
        List<Product> products = List.of(
            new Product("Laptop", new BigDecimal("999.99"), "Electronics", true, 5),
            new Product("Mouse", new BigDecimal("29.99"), "Electronics", true, 4),
            new Product("Desk", new BigDecimal("299.99"), "Furniture", false, 3),
            new Product("Chair", new BigDecimal("199.99"), "Furniture", true, 5),
            new Product("Monitor", new BigDecimal("399.99"), "Electronics", true, 4)
        );

        // Query usando DSL con combinadores
        List<Product> expensiveElectronics = Query.<Product>select()
            .where(Product::category, cat -> cat.equals("Electronics"))
            .where(Product::price, price -> price.compareTo(new BigDecimal("100")) > 0)
            .where(Product::inStock, inStock -> inStock)
            .from(products);

        System.out.println("Expensive Electronics in stock:");
        expensiveElectronics.forEach(System.out::println);

        // Query con OR
        List<Product> premiumProducts = Query.<Product>select()
            .where(Product::rating, rating -> rating >= 5)
            .or(p -> p.price().compareTo(new BigDecimal("500")) > 0)
            .from(products);

        System.out.println("\nPremium products:");
        premiumProducts.forEach(System.out::println);
    }
}
```

---

## 5. Builder Combinators

### 5.1 Fluent Builder con Combinadores

```java
/**
 * Builder que usa combinadores para construcción incremental
 */
public class HttpRequestBuilder {

    @FunctionalInterface
    interface RequestTransformer {
        HttpRequest apply(HttpRequest request);

        default RequestTransformer andThen(RequestTransformer after) {
            return request -> after.apply(this.apply(request));
        }

        static RequestTransformer identity() {
            return request -> request;
        }
    }

    record HttpRequest(
        String url,
        String method,
        Map<String, String> headers,
        Map<String, String> queryParams,
        String body
    ) {}

    private RequestTransformer transformer = RequestTransformer.identity();

    public HttpRequestBuilder url(String url) {
        transformer = transformer.andThen(req ->
            new HttpRequest(url, req.method(), req.headers(), req.queryParams(), req.body())
        );
        return this;
    }

    public HttpRequestBuilder method(String method) {
        transformer = transformer.andThen(req ->
            new HttpRequest(req.url(), method, req.headers(), req.queryParams(), req.body())
        );
        return this;
    }

    public HttpRequestBuilder header(String name, String value) {
        transformer = transformer.andThen(req -> {
            Map<String, String> newHeaders = new HashMap<>(req.headers());
            newHeaders.put(name, value);
            return new HttpRequest(req.url(), req.method(), newHeaders, req.queryParams(), req.body());
        });
        return this;
    }

    public HttpRequestBuilder queryParam(String name, String value) {
        transformer = transformer.andThen(req -> {
            Map<String, String> newParams = new HashMap<>(req.queryParams());
            newParams.put(name, value);
            return new HttpRequest(req.url(), req.method(), req.headers(), newParams, req.body());
        });
        return this;
    }

    public HttpRequestBuilder body(String body) {
        transformer = transformer.andThen(req ->
            new HttpRequest(req.url(), req.method(), req.headers(), req.queryParams(), body)
        );
        return this;
    }

    public HttpRequest build() {
        HttpRequest initial = new HttpRequest("", "GET", Map.of(), Map.of(), "");
        return transformer.apply(initial);
    }

    public static void example() {
        HttpRequest request = new HttpRequestBuilder()
            .url("https://api.example.com/users")
            .method("POST")
            .header("Content-Type", "application/json")
            .header("Authorization", "Bearer token123")
            .queryParam("page", "1")
            .queryParam("limit", "10")
            .body("{\"name\":\"John\"}")
            .build();

        System.out.println(request);
    }
}
```

---

## 6. Testing

```java
@ExtendWith(MockitoExtension.class)
class CombinatorTest {

    @Test
    @DisplayName("Parser combinator debe parsear enteros correctamente")
    void testIntegerParser() {
        // Arrange
        Parser<Integer> intParser = Parsers.many1(Parsers.digit())
            .map(digits -> Integer.parseInt(
                digits.stream()
                    .map(String::valueOf)
                    .collect(Collectors.joining())
            ));

        // Act
        ParseResult<Integer> result = intParser.parse("12345abc");

        // Assert
        assertThat(result.isSuccess()).isTrue();
        assertThat(result.getValue()).isEqualTo(12345);
        assertThat(result.getRemaining()).isEqualTo("abc");
    }

    @Test
    @DisplayName("Validation combinators deben componer correctamente")
    void testValidationCombinators() {
        // Arrange
        Validator<String> validator = Validators.<String>notNull()
            .and(Validators.notEmpty())
            .and(Validators.minLength(3))
            .and(Validators.maxLength(10));

        // Act & Assert
        assertThat(validator.validate("hello").isValid()).isTrue();
        assertThat(validator.validate("").isValid()).isFalse();
        assertThat(validator.validate("ab").isValid()).isFalse();
        assertThat(validator.validate("verylongstring").isValid()).isFalse();
    }

    @Test
    @DisplayName("Query combinators deben filtrar correctamente")
    void testQueryCombinators() {
        // Arrange
        record Person(String name, int age) {}

        List<Person> people = List.of(
            new Person("Alice", 25),
            new Person("Bob", 17),
            new Person("Charlie", 35)
        );

        // Act
        List<Person> adults = Query.<Person>select()
            .where(Person::age, age -> age >= 18)
            .from(people);

        // Assert
        assertThat(adults).hasSize(2);
        assertThat(adults).extracting(Person::name)
            .containsExactlyInAnyOrder("Alice", "Charlie");
    }
}
```

---

## 7. Best Practices

### ✅ DO

1. **Crear combinadores pequeños y componibles**

```java
// ✅ Bueno: Combinadores atómicos
public static <T> Parser<List<T>> many(Parser<T> parser) { ... }
public static <T> Parser<List<T>> many1(Parser<T> parser) { ... }
```

2. **Usar nombres descriptivos**

```java
// ✅ Bueno
Validator<String> emailValidator = notNull().and(notEmpty()).and(matches(...));
```

3. **Documentar combinadores complejos**

```java
/**
 * Combinator: sepBy
 * Parsea elementos separados por un delimitador
 * Ejemplo: "1,2,3" con sepBy(int, char(',')) → [1,2,3]
 */
public static <T, S> Parser<List<T>> sepBy(Parser<T> element, Parser<S> sep) { ... }
```

### ❌ DON'T

1. **No crear combinadores monolíticos**

```java
// ❌ Malo: Combinator que hace demasiado
public static Parser<ComplexObject> parseEverything() { ... }

// ✅ Mejor: Combinadores pequeños componibles
public static Parser<Name> parseName() { ... }
public static Parser<Email> parseEmail() { ... }
public static Parser<ComplexObject> parseObject() {
    return parseName().and(parseEmail()).map(ComplexObject::new);
}
```

---

## Conclusión

El patrón Combinator permite:

**Ventajas:**

- ✅ Construcción declarativa de lógica compleja
- ✅ Componentes pequeños y reutilizables
- ✅ DSLs expresivos y type-safe
- ✅ Testing simplificado de componentes individuales
- ✅ Composición flexible en runtime

**Cuándo usar:**

- Parsers de lenguajes o formatos
- Sistemas de validación complejos
- Query builders y DSLs
- Construcción de APIs fluentes
- Cualquier escenario donde la composición incremental es valiosa
