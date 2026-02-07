---
agent: agent
---

# Funciones de Orden Superior con Predicados Compuestos

## Descripción

Implementa funciones de orden superior que reciban predicados como parámetros y retornen nuevas funciones compuestas, permitiendo crear lógica de validación y filtrado compleja de forma declarativa y reutilizable.

## Objetivos

- Crear funciones que acepten y retornen otras funciones (Higher-Order Functions)
- Componer predicados usando operadores lógicos (AND, OR, NOT)
- Construir validadores complejos de forma declarativa
- Aplicar composición funcional para crear filtros reutilizables
- Eliminar código boilerplate usando composición de predicados

---

## 1. Fundamentos de Funciones de Orden Superior

### 1.1 Definición Básica

```java
/**
 * Función de orden superior que recibe un predicado y retorna otro predicado
 */
public class PredicateComposer {

    // Función que recibe función y retorna función
    public static <T> Predicate<T> negate(Predicate<T> predicate) {
        return predicate.negate();
    }

    // Función que recibe múltiples funciones y retorna una función compuesta
    @SafeVarargs
    public static <T> Predicate<T> allOf(Predicate<T>... predicates) {
        return Arrays.stream(predicates)
            .reduce(Predicate::and)
            .orElse(t -> true);
    }

    @SafeVarargs
    public static <T> Predicate<T> anyOf(Predicate<T>... predicates) {
        return Arrays.stream(predicates)
            .reduce(Predicate::or)
            .orElse(t -> false);
    }
}
```

### 1.2 Ejemplo de Uso Básico

```java
public class PredicateExample {

    public static void main(String[] args) {
        List<String> names = List.of("Alice", "Bob", "Charlie", "David", "Eve");

        // Predicados simples
        Predicate<String> startsWithA = s -> s.startsWith("A");
        Predicate<String> hasMoreThan3Chars = s -> s.length() > 3;

        // Composición usando HOF
        Predicate<String> complex = PredicateComposer.allOf(
            startsWithA,
            hasMoreThan3Chars
        );

        // Uso
        List<String> filtered = names.stream()
            .filter(complex)
            .collect(Collectors.toList());

        System.out.println(filtered); // [Alice]
    }
}
```

---

## 2. Composición Avanzada de Predicados

### 2.1 Builder de Predicados

```java
/**
 * Builder fluente para crear predicados complejos
 */
public class PredicateBuilder<T> {
    private Predicate<T> predicate;

    private PredicateBuilder(Predicate<T> initial) {
        this.predicate = initial;
    }

    public static <T> PredicateBuilder<T> of(Predicate<T> predicate) {
        return new PredicateBuilder<>(predicate);
    }

    public static <T> PredicateBuilder<T> accepting() {
        return new PredicateBuilder<>(t -> true);
    }

    public static <T> PredicateBuilder<T> rejecting() {
        return new PredicateBuilder<>(t -> false);
    }

    public PredicateBuilder<T> and(Predicate<T> other) {
        predicate = predicate.and(other);
        return this;
    }

    public PredicateBuilder<T> or(Predicate<T> other) {
        predicate = predicate.or(other);
        return this;
    }

    public PredicateBuilder<T> negate() {
        predicate = predicate.negate();
        return this;
    }

    public PredicateBuilder<T> andNot(Predicate<T> other) {
        return and(other.negate());
    }

    public PredicateBuilder<T> orNot(Predicate<T> other) {
        return or(other.negate());
    }

    public Predicate<T> build() {
        return predicate;
    }
}
```

### 2.2 Uso del Builder

```java
public class UserValidation {

    public static Predicate<User> createComplexValidator() {
        return PredicateBuilder.<User>accepting()
            .and(user -> user.getAge() >= 18)
            .and(user -> user.getEmail() != null)
            .and(user -> user.getEmail().contains("@"))
            .andNot(user -> user.isBlocked())
            .and(user -> user.hasVerifiedEmail())
            .or(user -> user.isPremium())  // Premium users bypass some checks
            .build();
    }

    public static void validateUsers(List<User> users) {
        Predicate<User> validator = createComplexValidator();

        List<User> validUsers = users.stream()
            .filter(validator)
            .collect(Collectors.toList());

        System.out.println("Valid users: " + validUsers.size());
    }
}
```

---

## 3. Funciones de Orden Superior para Transformaciones

### 3.1 Composición de Transformaciones

```java
/**
 * Funciones de orden superior para transformar predicados
 */
public class PredicateTransformers {

    /**
     * Convierte un predicado de un tipo a otro usando una función extractora
     */
    public static <T, R> Predicate<T> on(
            Function<T, R> extractor,
            Predicate<R> predicate) {
        return t -> predicate.test(extractor.apply(t));
    }

    /**
     * Crea un predicado que verifica si un valor está en una colección
     */
    public static <T> Predicate<T> in(Collection<T> collection) {
        return collection::contains;
    }

    /**
     * Crea un predicado que verifica si un valor NO está en una colección
     */
    public static <T> Predicate<T> notIn(Collection<T> collection) {
        return in(collection).negate();
    }

    /**
     * Crea un predicado que verifica múltiples condiciones en secuencia
     * Retorna false en la primera falla (short-circuit)
     */
    @SafeVarargs
    public static <T> Predicate<T> chain(Predicate<T>... predicates) {
        return t -> {
            for (Predicate<T> predicate : predicates) {
                if (!predicate.test(t)) {
                    return false;
                }
            }
            return true;
        };
    }

    /**
     * Crea un predicado con logging para debugging
     */
    public static <T> Predicate<T> withLogging(
            String name,
            Predicate<T> predicate) {
        return t -> {
            boolean result = predicate.test(t);
            System.out.printf("[%s] Input: %s, Result: %s%n", name, t, result);
            return result;
        };
    }

    /**
     * Crea un predicado que cuenta cuántas veces fue evaluado
     */
    public static <T> Predicate<T> counted(
            Predicate<T> predicate,
            AtomicInteger counter) {
        return t -> {
            counter.incrementAndGet();
            return predicate.test(t);
        };
    }

    /**
     * Crea un predicado que cachea resultados para inputs idénticos
     */
    public static <T> Predicate<T> memoized(Predicate<T> predicate) {
        Map<T, Boolean> cache = new ConcurrentHashMap<>();
        return t -> cache.computeIfAbsent(t, predicate::test);
    }
}
```

### 3.2 Ejemplos de Uso

```java
public class TransformerExamples {

    record Product(String name, BigDecimal price, String category, boolean inStock) {}

    public static void demonstrateTransformers() {
        List<Product> products = List.of(
            new Product("Laptop", new BigDecimal("999.99"), "Electronics", true),
            new Product("Mouse", new BigDecimal("29.99"), "Electronics", true),
            new Product("Desk", new BigDecimal("299.99"), "Furniture", false),
            new Product("Chair", new BigDecimal("199.99"), "Furniture", true)
        );

        // 1. Predicado usando extractor
        Predicate<Product> expensiveElectronics = PredicateTransformers
            .on(Product::category, cat -> cat.equals("Electronics"))
            .and(PredicateTransformers.on(
                Product::price,
                price -> price.compareTo(new BigDecimal("50")) > 0
            ));

        // 2. Predicado usando colección
        Set<String> allowedCategories = Set.of("Electronics", "Books");
        Predicate<Product> allowedCategory = PredicateTransformers
            .on(Product::category, PredicateTransformers.in(allowedCategories));

        // 3. Chain con short-circuit
        Predicate<Product> availableAndReasonable = PredicateTransformers.chain(
            Product::inStock,
            p -> p.price().compareTo(new BigDecimal("1000")) < 0,
            p -> !p.category().equals("Restricted")
        );

        // 4. Con logging para debugging
        Predicate<Product> debuggable = PredicateTransformers.withLogging(
            "ProductFilter",
            expensiveElectronics
        );

        // 5. Contador de evaluaciones
        AtomicInteger counter = new AtomicInteger(0);
        Predicate<Product> counted = PredicateTransformers.counted(
            allowedCategory,
            counter
        );

        // Aplicar filtros
        List<Product> filtered = products.stream()
            .filter(debuggable.and(availableAndReasonable))
            .collect(Collectors.toList());

        System.out.println("Filtered products: " + filtered);
        System.out.println("Evaluations: " + counter.get());
    }
}
```

---

## 4. Validadores Complejos con HOF

### 4.1 Sistema de Validación Declarativo

```java
/**
 * Sistema de validación usando funciones de orden superior
 */
public class ValidationSystem {

    @FunctionalInterface
    public interface Validator<T> {
        ValidationResult validate(T value);

        default Validator<T> and(Validator<T> other) {
            return value -> {
                ValidationResult result = this.validate(value);
                return result.isValid()
                    ? other.validate(value)
                    : result;
            };
        }

        default Validator<T> or(Validator<T> other) {
            return value -> {
                ValidationResult result = this.validate(value);
                return result.isValid()
                    ? result
                    : other.validate(value);
            };
        }
    }

    public record ValidationResult(
        boolean isValid,
        List<String> errors
    ) {
        public static ValidationResult success() {
            return new ValidationResult(true, List.of());
        }

        public static ValidationResult failure(String error) {
            return new ValidationResult(false, List.of(error));
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

    /**
     * Funciones de orden superior para crear validadores
     */
    public static class Validators {

        public static <T> Validator<T> notNull(String fieldName) {
            return value -> value != null
                ? ValidationResult.success()
                : ValidationResult.failure(fieldName + " cannot be null");
        }

        public static <T, R> Validator<T> field(
                String fieldName,
                Function<T, R> extractor,
                Predicate<R> predicate,
                String errorMessage) {
            return value -> {
                R fieldValue = extractor.apply(value);
                return predicate.test(fieldValue)
                    ? ValidationResult.success()
                    : ValidationResult.failure(fieldName + ": " + errorMessage);
            };
        }

        public static <T> Validator<T> predicate(
                Predicate<T> predicate,
                String errorMessage) {
            return value -> predicate.test(value)
                ? ValidationResult.success()
                : ValidationResult.failure(errorMessage);
        }

        @SafeVarargs
        public static <T> Validator<T> all(Validator<T>... validators) {
            return value -> Arrays.stream(validators)
                .map(v -> v.validate(value))
                .reduce(ValidationResult.success(), ValidationResult::combine);
        }

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
}
```

### 4.2 Uso del Sistema de Validación

```java
public class UserValidator {

    record User(String username, String email, Integer age, String password) {}

    public static Validator<User> createUserValidator() {
        return Validators.all(
            // Username validations
            Validators.field(
                "username",
                User::username,
                username -> username != null && username.length() >= 3,
                "must be at least 3 characters"
            ),

            Validators.field(
                "username",
                User::username,
                username -> username != null && username.matches("^[a-zA-Z0-9_]+$"),
                "can only contain letters, numbers, and underscores"
            ),

            // Email validations
            Validators.field(
                "email",
                User::email,
                email -> email != null && email.contains("@"),
                "must be a valid email"
            ),

            // Age validations
            Validators.field(
                "age",
                User::age,
                age -> age != null && age >= 18 && age <= 120,
                "must be between 18 and 120"
            ),

            // Password validations
            Validators.field(
                "password",
                User::password,
                pwd -> pwd != null && pwd.length() >= 8,
                "must be at least 8 characters"
            ),

            Validators.field(
                "password",
                User::password,
                pwd -> pwd != null && pwd.matches(".*[A-Z].*"),
                "must contain at least one uppercase letter"
            ),

            Validators.field(
                "password",
                User::password,
                pwd -> pwd != null && pwd.matches(".*[0-9].*"),
                "must contain at least one digit"
            )
        );
    }

    public static void validateUser(User user) {
        Validator<User> validator = createUserValidator();
        ValidationResult result = validator.validate(user);

        if (result.isValid()) {
            System.out.println("✅ User is valid");
        } else {
            System.out.println("❌ Validation failed:");
            result.errors().forEach(error -> System.out.println("  - " + error));
        }
    }

    public static void main(String[] args) {
        User validUser = new User("john_doe", "john@example.com", 25, "Password123");
        User invalidUser = new User("ab", "invalid-email", 15, "weak");

        validateUser(validUser);
        validateUser(invalidUser);
    }
}
```

---

## 5. Predicados con Contexto y Estado

### 5.1 Predicados Statefull

```java
/**
 * Predicados que mantienen estado entre evaluaciones
 */
public class StatefulPredicates {

    /**
     * Predicado que acepta solo los primeros N elementos
     */
    public static <T> Predicate<T> takeFirst(int n) {
        AtomicInteger counter = new AtomicInteger(0);
        return t -> counter.incrementAndGet() <= n;
    }

    /**
     * Predicado que salta los primeros N elementos
     */
    public static <T> Predicate<T> skipFirst(int n) {
        AtomicInteger counter = new AtomicInteger(0);
        return t -> counter.incrementAndGet() > n;
    }

    /**
     * Predicado que acepta elementos en posiciones pares/impares
     */
    public static <T> Predicate<T> evenPositions() {
        AtomicInteger counter = new AtomicInteger(0);
        return t -> counter.getAndIncrement() % 2 == 0;
    }

    public static <T> Predicate<T> oddPositions() {
        AtomicInteger counter = new AtomicInteger(0);
        return t -> counter.getAndIncrement() % 2 != 0;
    }

    /**
     * Predicado que acepta cada N-ésimo elemento
     */
    public static <T> Predicate<T> everyNth(int n) {
        AtomicInteger counter = new AtomicInteger(0);
        return t -> counter.incrementAndGet() % n == 0;
    }

    /**
     * Predicado que detiene después de encontrar N coincidencias
     */
    public static <T> Predicate<T> stopAfter(Predicate<T> predicate, int maxMatches) {
        AtomicInteger matches = new AtomicInteger(0);
        return t -> {
            if (matches.get() >= maxMatches) {
                return false;
            }
            boolean result = predicate.test(t);
            if (result) {
                matches.incrementAndGet();
            }
            return result;
        };
    }

    /**
     * Predicado que acepta elementos hasta que uno falle la condición
     */
    public static <T> Predicate<T> takeWhile(Predicate<T> predicate) {
        AtomicBoolean failed = new AtomicBoolean(false);
        return t -> {
            if (failed.get()) {
                return false;
            }
            boolean result = predicate.test(t);
            if (!result) {
                failed.set(true);
            }
            return result;
        };
    }

    /**
     * Predicado que acepta elementos diferentes consecutivos
     */
    public static <T> Predicate<T> distinctConsecutive() {
        AtomicReference<T> previous = new AtomicReference<>();
        return t -> {
            T prev = previous.getAndSet(t);
            return !Objects.equals(t, prev);
        };
    }
}
```

### 5.2 Uso de Predicados Statefull

```java
public class StatefulPredicatesDemo {

    public static void main(String[] args) {
        List<Integer> numbers = IntStream.rangeClosed(1, 20)
            .boxed()
            .collect(Collectors.toList());

        // 1. Tomar primeros 5
        System.out.println("First 5:");
        numbers.stream()
            .filter(StatefulPredicates.takeFirst(5))
            .forEach(System.out::println);

        // 2. Saltar primeros 5
        System.out.println("\nSkip first 5:");
        numbers.stream()
            .filter(StatefulPredicates.skipFirst(5))
            .forEach(System.out::println);

        // 3. Posiciones pares
        System.out.println("\nEven positions:");
        numbers.stream()
            .filter(StatefulPredicates.evenPositions())
            .forEach(System.out::println);

        // 4. Cada 3er elemento
        System.out.println("\nEvery 3rd:");
        numbers.stream()
            .filter(StatefulPredicates.everyNth(3))
            .forEach(System.out::println);

        // 5. Detener después de 3 números pares
        System.out.println("\nFirst 3 even numbers:");
        numbers.stream()
            .filter(StatefulPredicates.stopAfter(n -> n % 2 == 0, 3))
            .forEach(System.out::println);

        // 6. Tomar mientras < 10
        System.out.println("\nTake while < 10:");
        numbers.stream()
            .filter(StatefulPredicates.takeWhile(n -> n < 10))
            .forEach(System.out::println);

        // 7. Consecutivos distintos
        List<Integer> withDuplicates = List.of(1, 1, 2, 2, 3, 1, 1, 4);
        System.out.println("\nDistinct consecutive:");
        withDuplicates.stream()
            .filter(StatefulPredicates.distinctConsecutive())
            .forEach(System.out::println);
    }
}
```

---

## 6. Predicados Genéricos Reutilizables

### 6.1 Librería de Predicados Comunes

```java
/**
 * Colección de predicados reutilizables
 */
public class CommonPredicates {

    // String predicates
    public static Predicate<String> isEmpty() {
        return String::isEmpty;
    }

    public static Predicate<String> isBlank() {
        return String::isBlank;
    }

    public static Predicate<String> startsWith(String prefix) {
        return s -> s.startsWith(prefix);
    }

    public static Predicate<String> endsWith(String suffix) {
        return s -> s.endsWith(suffix);
    }

    public static Predicate<String> contains(String substring) {
        return s -> s.contains(substring);
    }

    public static Predicate<String> matches(String regex) {
        Pattern pattern = Pattern.compile(regex);
        return s -> pattern.matcher(s).matches();
    }

    public static Predicate<String> lengthBetween(int min, int max) {
        return s -> s.length() >= min && s.length() <= max;
    }

    // Numeric predicates
    public static <T extends Comparable<T>> Predicate<T> between(T min, T max) {
        return value -> value.compareTo(min) >= 0 && value.compareTo(max) <= 0;
    }

    public static <T extends Comparable<T>> Predicate<T> greaterThan(T threshold) {
        return value -> value.compareTo(threshold) > 0;
    }

    public static <T extends Comparable<T>> Predicate<T> lessThan(T threshold) {
        return value -> value.compareTo(threshold) < 0;
    }

    // Collection predicates
    public static <T> Predicate<Collection<T>> hasSize(int size) {
        return collection -> collection.size() == size;
    }

    public static <T> Predicate<Collection<T>> isEmptyCollection() {
        return Collection::isEmpty;
    }

    public static <T> Predicate<Collection<T>> containsElement(T element) {
        return collection -> collection.contains(element);
    }

    public static <T> Predicate<Collection<T>> containsAll(Collection<T> elements) {
        return collection -> collection.containsAll(elements);
    }

    // Optional predicates
    public static <T> Predicate<Optional<T>> isPresent() {
        return Optional::isPresent;
    }

    public static <T> Predicate<Optional<T>> isEmpty() {
        return Optional::isEmpty;
    }

    // Null safety
    public static <T> Predicate<T> isNull() {
        return Objects::isNull;
    }

    public static <T> Predicate<T> nonNull() {
        return Objects::nonNull;
    }

    // Type predicates
    public static <T> Predicate<Object> isInstanceOf(Class<T> clazz) {
        return clazz::isInstance;
    }

    // Composite predicates
    public static <T> Predicate<T> always() {
        return t -> true;
    }

    public static <T> Predicate<T> never() {
        return t -> false;
    }
}
```

### 6.2 Uso de la Librería

```java
public class CommonPredicatesDemo {

    record Person(String name, int age, String email) {}

    public static void main(String[] args) {
        List<Person> people = List.of(
            new Person("Alice", 25, "alice@example.com"),
            new Person("Bob", 17, "bob@test.com"),
            new Person("Charlie", 35, "charlie@example.com"),
            new Person("", 30, "invalid-email")
        );

        // Crear validador complejo usando predicados reutilizables
        Predicate<Person> validPerson = PredicateBuilder.<Person>accepting()
            .and(PredicateTransformers.on(
                Person::name,
                CommonPredicates.<String>nonNull()
                    .and(CommonPredicates.isBlank().negate())
                    .and(CommonPredicates.lengthBetween(2, 50))
            ))
            .and(PredicateTransformers.on(
                Person::age,
                CommonPredicates.between(18, 100)
            ))
            .and(PredicateTransformers.on(
                Person::email,
                CommonPredicates.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$")
            ))
            .build();

        // Filtrar personas válidas
        List<Person> validPeople = people.stream()
            .filter(validPerson)
            .collect(Collectors.toList());

        System.out.println("Valid people: " + validPeople);
    }
}
```

---

## 7. Testing

### 7.1 Test de Composición de Predicados

```java
class PredicateComposerTest {

    @Test
    @DisplayName("allOf debe retornar true solo si todos los predicados son true")
    void testAllOf() {
        // Arrange
        Predicate<Integer> isPositive = n -> n > 0;
        Predicate<Integer> isEven = n -> n % 2 == 0;
        Predicate<Integer> lessThan100 = n -> n < 100;

        Predicate<Integer> combined = PredicateComposer.allOf(
            isPositive, isEven, lessThan100
        );

        // Act & Assert
        assertThat(combined.test(50)).isTrue();
        assertThat(combined.test(-2)).isFalse();  // not positive
        assertThat(combined.test(51)).isFalse();  // not even
        assertThat(combined.test(200)).isFalse(); // not < 100
    }

    @Test
    @DisplayName("anyOf debe retornar true si al menos un predicado es true")
    void testAnyOf() {
        // Arrange
        Predicate<String> startsWithA = s -> s.startsWith("A");
        Predicate<String> endsWithZ = s -> s.endsWith("Z");

        Predicate<String> combined = PredicateComposer.anyOf(
            startsWithA, endsWithZ
        );

        // Act & Assert
        assertThat(combined.test("Alice")).isTrue();    // starts with A
        assertThat(combined.test("Buzz")).isTrue();     // ends with Z
        assertThat(combined.test("AtoZ")).isTrue();     // both
        assertThat(combined.test("Bob")).isFalse();     // neither
    }

    @Test
    @DisplayName("negate debe invertir el resultado del predicado")
    void testNegate() {
        // Arrange
        Predicate<Integer> isEven = n -> n % 2 == 0;
        Predicate<Integer> isOdd = PredicateComposer.negate(isEven);

        // Act & Assert
        assertThat(isOdd.test(3)).isTrue();
        assertThat(isOdd.test(4)).isFalse();
    }
}
```

### 7.2 Test del Builder

```java
class PredicateBuilderTest {

    record User(String name, int age, boolean active) {}

    @Test
    @DisplayName("Builder debe encadenar predicados correctamente")
    void testBuilderChaining() {
        // Arrange
        Predicate<User> validator = PredicateBuilder.<User>accepting()
            .and(u -> u.age() >= 18)
            .and(u -> u.name() != null)
            .and(u -> !u.name().isEmpty())
            .build();

        User validUser = new User("Alice", 25, true);
        User underageUser = new User("Bob", 15, true);
        User nullNameUser = new User(null, 25, true);

        // Act & Assert
        assertThat(validator.test(validUser)).isTrue();
        assertThat(validator.test(underageUser)).isFalse();
        assertThat(validator.test(nullNameUser)).isFalse();
    }

    @Test
    @DisplayName("Builder debe manejar OR correctamente")
    void testOrChaining() {
        // Arrange
        Predicate<User> validator = PredicateBuilder.<User>rejecting()
            .or(u -> u.age() >= 18)
            .or(u -> u.active())
            .build();

        User adult = new User("Alice", 25, false);
        User minor = new User("Bob", 15, true);
        User inactiveMinor = new User("Charlie", 15, false);

        // Act & Assert
        assertThat(validator.test(adult)).isTrue();          // is adult
        assertThat(validator.test(minor)).isTrue();          // is active
        assertThat(validator.test(inactiveMinor)).isFalse(); // neither
    }
}
```

### 7.3 Test de Predicados Statefull

```java
class StatefulPredicatesTest {

    @Test
    @DisplayName("takeFirst debe aceptar solo los primeros N elementos")
    void testTakeFirst() {
        // Arrange
        List<Integer> numbers = List.of(1, 2, 3, 4, 5, 6, 7, 8, 9, 10);
        Predicate<Integer> takeFirst3 = StatefulPredicates.takeFirst(3);

        // Act
        List<Integer> result = numbers.stream()
            .filter(takeFirst3)
            .collect(Collectors.toList());

        // Assert
        assertThat(result).containsExactly(1, 2, 3);
    }

    @Test
    @DisplayName("distinctConsecutive debe eliminar duplicados consecutivos")
    void testDistinctConsecutive() {
        // Arrange
        List<Integer> numbers = List.of(1, 1, 2, 2, 2, 3, 1, 1);

        // Act
        List<Integer> result = numbers.stream()
            .filter(StatefulPredicates.distinctConsecutive())
            .collect(Collectors.toList());

        // Assert
        assertThat(result).containsExactly(1, 2, 3, 1);
    }

    @Test
    @DisplayName("everyNth debe aceptar cada N-ésimo elemento")
    void testEveryNth() {
        // Arrange
        List<Integer> numbers = IntStream.rangeClosed(1, 10)
            .boxed()
            .collect(Collectors.toList());

        // Act
        List<Integer> result = numbers.stream()
            .filter(StatefulPredicates.everyNth(3))
            .collect(Collectors.toList());

        // Assert
        assertThat(result).containsExactly(3, 6, 9);
    }
}
```

---

## 8. Best Practices

### ✅ DO

1. **Crear predicados pequeños y componibles**

```java
// ✅ Bueno
Predicate<User> isAdult = u -> u.getAge() >= 18;
Predicate<User> hasEmail = u -> u.getEmail() != null;
Predicate<User> validUser = isAdult.and(hasEmail);
```

2. **Usar nombres descriptivos**

```java
// ✅ Bueno
Predicate<String> isValidEmail = email -> email.contains("@");
Predicate<Integer> isPositiveEven = n -> n > 0 && n % 2 == 0;
```

3. **Extraer predicados complejos a constantes**

```java
// ✅ Bueno
public class UserPredicates {
    public static final Predicate<User> IS_ADULT = u -> u.getAge() >= 18;
    public static final Predicate<User> IS_VERIFIED = User::isVerified;
    public static final Predicate<User> HAS_EMAIL = u -> u.getEmail() != null;
}
```

### ❌ DON'T

1. **No crear predicados monolíticos**

```java
// ❌ Malo
Predicate<User> complexValidation = u ->
    u.getAge() >= 18 &&
    u.getEmail() != null &&
    u.getEmail().contains("@") &&
    !u.isBlocked() &&
    u.hasVerifiedEmail();

// ✅ Mejor
Predicate<User> isValid = PredicateBuilder.<User>accepting()
    .and(IS_ADULT)
    .and(HAS_VALID_EMAIL)
    .andNot(IS_BLOCKED)
    .and(IS_VERIFIED)
    .build();
```

2. **No ignorar null safety**

```java
// ❌ Malo: NPE si name es null
Predicate<User> startsWithA = u -> u.getName().startsWith("A");

// ✅ Bueno: Null-safe
Predicate<User> startsWithA = u ->
    u.getName() != null && u.getName().startsWith("A");
```

---

## Conclusión

Las funciones de orden superior con predicados proporcionan:

**Ventajas:**

- ✅ Composición declarativa de lógica compleja
- ✅ Reutilización de predicados en múltiples contextos
- ✅ Código más legible y mantenible
- ✅ Testing simplificado de lógica individual
- ✅ Eliminación de código boilerplate

**Cuándo usar:**

- Validaciones complejas con múltiples reglas
- Filtrado dinámico de colecciones
- Construcción de DSLs para reglas de negocio
- Lógica condicional que varía en runtime
