---
description: "Diseñar pipelines de Java Streams con filter-map-reduce para transformación eficiente de datos"
agent: agent
---

# 🌊 JAVA STREAMS PIPELINE - Filter-Map-Reduce Patterns

Actúa como **experto en programación funcional con Java Streams API**.

Tu misión es **diseñar pipelines eficientes y elegantes** usando las operaciones fundamentales de Streams: **filter**, **map**, y **reduce** para transformar colecciones de datos de forma declarativa y funcional.

---

## 🎯 ANATOMÍA DE UN STREAM PIPELINE

```
┌─────────────┐    ┌──────────┐    ┌────────┐    ┌────────┐    ┌──────────┐
│  Source     │───▶│  filter  │───▶│  map   │───▶│ reduce │───▶│  Result  │
│ Collection  │    │ (filter) │    │(transform)  │(combine)│   │  Output  │
└─────────────┘    └──────────┘    └────────┘    └────────┘    └──────────┘
   Stream            Intermediate    Intermediate   Terminal      Final
   Creation          Operation       Operation      Operation     Value
```

### Tipos de Operaciones:

**Intermediate Operations (lazy):**

- `filter()` - Filtra elementos según predicado
- `map()` - Transforma elementos
- `flatMap()` - Transforma y aplana streams anidados
- `distinct()` - Elimina duplicados
- `sorted()` - Ordena elementos
- `limit()` / `skip()` - Limita o salta elementos

**Terminal Operations (eager):**

- `reduce()` - Combina elementos en un solo resultado
- `collect()` - Acumula elementos en una colección
- `forEach()` - Ejecuta acción sobre cada elemento
- `count()` - Cuenta elementos
- `anyMatch()` / `allMatch()` / `noneMatch()` - Predicados

---

## 🔍 FILTER - Filtrado de Datos

### Conceptos Básicos

```java
import java.util.List;
import java.util.stream.Collectors;

public class FilterExamples {

    // 1️⃣ Filtrado Simple
    public List<Integer> filterEvenNumbers(List<Integer> numbers) {
        return numbers.stream()
            .filter(n -> n % 2 == 0)
            .collect(Collectors.toList());
    }

    // 2️⃣ Filtrado con Múltiples Condiciones
    public List<Product> filterProducts(List<Product> products) {
        return products.stream()
            .filter(p -> p.getPrice().compareTo(new BigDecimal("100")) > 0)
            .filter(Product::isAvailable)
            .filter(p -> !p.isDiscontinued())
            .collect(Collectors.toList());
    }

    // 3️⃣ Filtrado con Predicates Reutilizables
    public List<User> filterActiveAdultUsers(List<User> users) {
        Predicate<User> isAdult = user -> user.getAge() >= 18;
        Predicate<User> isActive = User::isActive;
        Predicate<User> hasEmail = user -> user.getEmail() != null;

        return users.stream()
            .filter(isAdult.and(isActive).and(hasEmail))
            .collect(Collectors.toList());
    }

    // 4️⃣ Filtrado con Pattern Matching (Java 21+)
    public List<Shape> filterCircles(List<Shape> shapes) {
        return shapes.stream()
            .filter(shape -> shape instanceof Circle)
            .collect(Collectors.toList());
    }

    // 5️⃣ Filtrado Negativo (Exclusión)
    public List<String> filterOutEmptyStrings(List<String> strings) {
        return strings.stream()
            .filter(s -> s != null && !s.isEmpty())
            .collect(Collectors.toList());
    }
}
```

### Predicates Complejos

```java
public class ComplexFilterExamples {

    // Predicates Encadenados con AND
    public List<Order> findHighValueRecentOrders(List<Order> orders) {
        return orders.stream()
            .filter(order -> order.getTotal().compareTo(new BigDecimal("1000")) > 0)
            .filter(order -> order.getCreatedAt().isAfter(LocalDateTime.now().minusDays(30)))
            .filter(order -> order.getStatus() == OrderStatus.CONFIRMED)
            .collect(Collectors.toList());
    }

    // Predicates con OR
    public List<Transaction> findImportantTransactions(List<Transaction> transactions) {
        Predicate<Transaction> isHighValue = t -> t.getAmount().compareTo(new BigDecimal("10000")) > 0;
        Predicate<Transaction> isInternational = Transaction::isInternational;
        Predicate<Transaction> isSuspicious = Transaction::isFlagged;

        return transactions.stream()
            .filter(isHighValue.or(isInternational).or(isSuspicious))
            .collect(Collectors.toList());
    }

    // Filtrado con Lógica de Negocio Compleja
    public List<Loan> findEligibleLoans(List<Loan> loans) {
        return loans.stream()
            .filter(loan -> {
                // Multi-step validation
                if (loan.getAmount().compareTo(BigDecimal.ZERO) <= 0) {
                    return false;
                }

                double debtToIncomeRatio = loan.getMonthlyPayment()
                    .divide(loan.getApplicant().getMonthlyIncome(), 2, RoundingMode.HALF_UP)
                    .doubleValue();

                return debtToIncomeRatio < 0.43 &&
                       loan.getApplicant().getCreditScore() >= 650;
            })
            .collect(Collectors.toList());
    }
}
```

---

## 🔄 MAP - Transformación de Datos

### Transformaciones Básicas

```java
public class MapExamples {

    // 1️⃣ Transformación Simple: Tipo → Tipo
    public List<String> getUserNames(List<User> users) {
        return users.stream()
            .map(User::getName)
            .collect(Collectors.toList());
    }

    // 2️⃣ Transformación con Método: String → Integer
    public List<Integer> getStringLengths(List<String> strings) {
        return strings.stream()
            .map(String::length)
            .collect(Collectors.toList());
    }

    // 3️⃣ Transformación Compleja: Entity → DTO
    public List<UserDto> convertToDto(List<User> users) {
        return users.stream()
            .map(user -> new UserDto(
                user.getId(),
                user.getName(),
                user.getEmail(),
                user.getCreatedAt()
            ))
            .collect(Collectors.toList());
    }

    // 4️⃣ Transformación con Cálculo
    public List<BigDecimal> calculateDiscountedPrices(List<Product> products, BigDecimal discountRate) {
        return products.stream()
            .map(Product::getPrice)
            .map(price -> price.multiply(BigDecimal.ONE.subtract(discountRate)))
            .collect(Collectors.toList());
    }

    // 5️⃣ Transformación con Función Auxiliar
    public List<String> formatUserInfo(List<User> users) {
        return users.stream()
            .map(this::formatUser)
            .collect(Collectors.toList());
    }

    private String formatUser(User user) {
        return String.format("%s (%s)", user.getName(), user.getEmail());
    }
}
```

### FlatMap - Aplanando Streams

```java
public class FlatMapExamples {

    // 1️⃣ Aplanar Lista de Listas
    public List<String> getAllTags(List<Article> articles) {
        return articles.stream()
            .flatMap(article -> article.getTags().stream())
            .distinct()
            .collect(Collectors.toList());
    }

    // 2️⃣ Expandir Relaciones
    public List<OrderItem> getAllOrderItems(List<Order> orders) {
        return orders.stream()
            .flatMap(order -> order.getItems().stream())
            .collect(Collectors.toList());
    }

    // 3️⃣ Transformar y Aplanar
    public List<String> getAllEmails(List<Department> departments) {
        return departments.stream()
            .flatMap(dept -> dept.getEmployees().stream())
            .map(Employee::getEmail)
            .collect(Collectors.toList());
    }

    // 4️⃣ FlatMap con Optional
    public List<String> getMiddleNames(List<Person> people) {
        return people.stream()
            .map(Person::getMiddleName) // Returns Optional<String>
            .flatMap(Optional::stream)   // Flatten Optional to Stream
            .collect(Collectors.toList());
    }

    // 5️⃣ Procesamiento Complejo
    public List<Transaction> getAllTransactions(List<Account> accounts) {
        return accounts.stream()
            .filter(Account::isActive)
            .flatMap(account -> account.getTransactions().stream())
            .filter(tx -> tx.getAmount().compareTo(BigDecimal.ZERO) > 0)
            .collect(Collectors.toList());
    }
}
```

---

## 🎯 REDUCE - Combinación de Datos

### Reduce Básico

```java
public class ReduceExamples {

    // 1️⃣ Suma de Números
    public int sumNumbers(List<Integer> numbers) {
        return numbers.stream()
            .reduce(0, Integer::sum);
    }

    // 2️⃣ Producto de Números
    public int multiplyNumbers(List<Integer> numbers) {
        return numbers.stream()
            .reduce(1, (a, b) -> a * b);
    }

    // 3️⃣ Encontrar Máximo
    public Optional<Integer> findMax(List<Integer> numbers) {
        return numbers.stream()
            .reduce(Integer::max);
    }

    // 4️⃣ Encontrar Mínimo
    public Optional<BigDecimal> findMinPrice(List<Product> products) {
        return products.stream()
            .map(Product::getPrice)
            .reduce(BigDecimal::min);
    }

    // 5️⃣ Concatenar Strings
    public String concatenateNames(List<User> users) {
        return users.stream()
            .map(User::getName)
            .reduce("", (a, b) -> a.isEmpty() ? b : a + ", " + b);
    }

    // Mejor con Collectors.joining()
    public String concatenateNamesBetter(List<User> users) {
        return users.stream()
            .map(User::getName)
            .collect(Collectors.joining(", "));
    }
}
```

### Reduce Avanzado

```java
public class AdvancedReduceExamples {

    // 1️⃣ Suma de Montos con BigDecimal
    public BigDecimal calculateTotalRevenue(List<Order> orders) {
        return orders.stream()
            .map(Order::getTotal)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    // 2️⃣ Reduce con Tres Parámetros (Parallel-safe)
    public BigDecimal calculateTotalParallel(List<Order> orders) {
        return orders.parallelStream()
            .map(Order::getTotal)
            .reduce(
                BigDecimal.ZERO,           // Identity
                BigDecimal::add,           // Accumulator
                BigDecimal::add            // Combiner (for parallel)
            );
    }

    // 3️⃣ Construcción de Objeto Acumulado
    public Statistics calculateStatistics(List<Integer> numbers) {
        return numbers.stream()
            .reduce(
                new Statistics(0, 0, 0),
                (stats, num) -> new Statistics(
                    stats.count + 1,
                    stats.sum + num,
                    Math.max(stats.max, num)
                ),
                (stats1, stats2) -> new Statistics(
                    stats1.count + stats2.count,
                    stats1.sum + stats2.sum,
                    Math.max(stats1.max, stats2.max)
                )
            );
    }

    record Statistics(int count, int sum, int max) {
        double average() {
            return count == 0 ? 0 : (double) sum / count;
        }
    }

    // 4️⃣ Combinar Maps
    public Map<String, Integer> mergeInventories(List<Map<String, Integer>> inventories) {
        return inventories.stream()
            .flatMap(map -> map.entrySet().stream())
            .collect(Collectors.toMap(
                Map.Entry::getKey,
                Map.Entry::getValue,
                Integer::sum  // Merge function
            ));
    }
}
```

---

## 🚀 PIPELINES COMPLETOS - Ejemplos del Mundo Real

### Ejemplo 1: Sistema de E-commerce

```java
public class EcommerceAnalytics {

    /**
     * Encuentra los 5 productos más vendidos del último mes
     */
    public List<ProductSalesReport> getTopSellingProducts(List<Order> orders) {
        LocalDateTime lastMonth = LocalDateTime.now().minusMonths(1);

        return orders.stream()
            // Filter: Solo órdenes del último mes completadas
            .filter(order -> order.getCreatedAt().isAfter(lastMonth))
            .filter(order -> order.getStatus() == OrderStatus.COMPLETED)

            // FlatMap: Expandir items de todas las órdenes
            .flatMap(order -> order.getItems().stream())

            // Group by product: Agrupar por producto y sumar cantidades
            .collect(Collectors.groupingBy(
                OrderItem::getProductId,
                Collectors.summingInt(OrderItem::getQuantity)
            ))
            .entrySet().stream()

            // Map: Convertir a DTO
            .map(entry -> new ProductSalesReport(
                entry.getKey(),
                entry.getValue()
            ))

            // Sort: Ordenar por cantidad vendida (descendente)
            .sorted(Comparator.comparing(ProductSalesReport::quantitySold).reversed())

            // Limit: Top 5
            .limit(5)

            .collect(Collectors.toList());
    }

    /**
     * Calcula el revenue total por categoría
     */
    public Map<String, BigDecimal> getRevenueByCategory(List<Order> orders, List<Product> products) {
        // Crear mapa de product ID → category
        Map<String, String> productCategories = products.stream()
            .collect(Collectors.toMap(Product::getId, Product::getCategory));

        return orders.stream()
            .filter(order -> order.getStatus() == OrderStatus.COMPLETED)
            .flatMap(order -> order.getItems().stream())

            // Map: Convertir a par (category, revenue)
            .map(item -> {
                String category = productCategories.get(item.getProductId());
                BigDecimal revenue = item.getPrice().multiply(BigDecimal.valueOf(item.getQuantity()));
                return Map.entry(category, revenue);
            })

            // Group by category y sumar revenue
            .collect(Collectors.groupingBy(
                Map.Entry::getKey,
                Collectors.reducing(
                    BigDecimal.ZERO,
                    Map.Entry::getValue,
                    BigDecimal::add
                )
            ));
    }

    /**
     * Encuentra clientes VIP (más de $10,000 en compras)
     */
    public List<CustomerReport> findVIPCustomers(List<Order> orders) {
        return orders.stream()
            .filter(order -> order.getStatus() == OrderStatus.COMPLETED)

            // Group by customer
            .collect(Collectors.groupingBy(
                Order::getCustomerId,
                Collectors.collectingAndThen(
                    Collectors.toList(),
                    customerOrders -> {
                        BigDecimal totalSpent = customerOrders.stream()
                            .map(Order::getTotal)
                            .reduce(BigDecimal.ZERO, BigDecimal::add);

                        int orderCount = customerOrders.size();

                        return new CustomerReport(
                            customerOrders.get(0).getCustomerId(),
                            totalSpent,
                            orderCount,
                            totalSpent.divide(BigDecimal.valueOf(orderCount), 2, RoundingMode.HALF_UP)
                        );
                    }
                )
            ))
            .values().stream()

            // Filter: Solo VIP (> $10,000)
            .filter(report -> report.totalSpent().compareTo(new BigDecimal("10000")) > 0)

            // Sort: Por gasto total (descendente)
            .sorted(Comparator.comparing(CustomerReport::totalSpent).reversed())

            .collect(Collectors.toList());
    }

    record ProductSalesReport(String productId, int quantitySold) {}
    record CustomerReport(String customerId, BigDecimal totalSpent, int orderCount, BigDecimal avgOrderValue) {}
}
```

### Ejemplo 2: Sistema Financiero

```java
public class FinancialAnalytics {

    /**
     * Calcula métricas de transacciones por tipo
     */
    public Map<TransactionType, TransactionMetrics> analyzeTransactionsByType(
        List<Transaction> transactions
    ) {
        return transactions.stream()
            // Filter: Solo transacciones completadas del último año
            .filter(tx -> tx.getStatus() == TransactionStatus.COMPLETED)
            .filter(tx -> tx.getDate().isAfter(LocalDate.now().minusYears(1)))

            // Group by type
            .collect(Collectors.groupingBy(
                Transaction::getType,
                Collectors.collectingAndThen(
                    Collectors.toList(),
                    txList -> calculateMetrics(txList)
                )
            ));
    }

    private TransactionMetrics calculateMetrics(List<Transaction> transactions) {
        int count = transactions.size();

        BigDecimal total = transactions.stream()
            .map(Transaction::getAmount)
            .reduce(BigDecimal.ZERO, BigDecimal::add);

        BigDecimal average = count > 0
            ? total.divide(BigDecimal.valueOf(count), 2, RoundingMode.HALF_UP)
            : BigDecimal.ZERO;

        BigDecimal max = transactions.stream()
            .map(Transaction::getAmount)
            .max(BigDecimal::compareTo)
            .orElse(BigDecimal.ZERO);

        BigDecimal min = transactions.stream()
            .map(Transaction::getAmount)
            .min(BigDecimal::compareTo)
            .orElse(BigDecimal.ZERO);

        return new TransactionMetrics(count, total, average, max, min);
    }

    /**
     * Detecta transacciones sospechosas
     */
    public List<Transaction> findSuspiciousTransactions(List<Transaction> transactions) {
        // Calcular estadísticas para detección de anomalías
        DoubleSummaryStatistics stats = transactions.stream()
            .mapToDouble(tx -> tx.getAmount().doubleValue())
            .summaryStatistics();

        double mean = stats.getAverage();
        double max = stats.getMax();

        // Threshold: 3 veces la media o cantidad muy alta
        double suspiciousThreshold = Math.min(mean * 3, max * 0.8);

        return transactions.stream()
            .filter(tx -> {
                double amount = tx.getAmount().doubleValue();

                return amount > suspiciousThreshold ||
                       tx.isInternational() && amount > mean * 2 ||
                       tx.getDescription().toLowerCase().contains("urgent") ||
                       tx.getLocation() != null && tx.getLocation().isHighRisk();
            })
            .sorted(Comparator.comparing(Transaction::getAmount).reversed())
            .collect(Collectors.toList());
    }

    /**
     * Calcula balance mensual
     */
    public Map<YearMonth, BigDecimal> calculateMonthlyBalance(List<Transaction> transactions) {
        return transactions.stream()
            // Group by year-month
            .collect(Collectors.groupingBy(
                tx -> YearMonth.from(tx.getDate()),
                TreeMap::new,  // Sorted by date
                Collectors.reducing(
                    BigDecimal.ZERO,
                    tx -> tx.getType() == TransactionType.CREDIT
                        ? tx.getAmount()
                        : tx.getAmount().negate(),
                    BigDecimal::add
                )
            ));
    }

    record TransactionMetrics(
        int count,
        BigDecimal total,
        BigDecimal average,
        BigDecimal max,
        BigDecimal min
    ) {}
}
```

### Ejemplo 3: Sistema de Recursos Humanos

```java
public class HRAnalytics {

    /**
     * Obtiene estadísticas salariales por departamento
     */
    public Map<String, SalaryStats> getSalaryStatsByDepartment(List<Employee> employees) {
        return employees.stream()
            .filter(Employee::isActive)
            .collect(Collectors.groupingBy(
                Employee::getDepartment,
                Collectors.collectingAndThen(
                    Collectors.toList(),
                    deptEmployees -> {
                        DoubleSummaryStatistics stats = deptEmployees.stream()
                            .mapToDouble(e -> e.getSalary().doubleValue())
                            .summaryStatistics();

                        return new SalaryStats(
                            stats.getCount(),
                            BigDecimal.valueOf(stats.getAverage()),
                            BigDecimal.valueOf(stats.getMin()),
                            BigDecimal.valueOf(stats.getMax()),
                            calculateMedian(deptEmployees)
                        );
                    }
                )
            ));
    }

    private BigDecimal calculateMedian(List<Employee> employees) {
        List<BigDecimal> sortedSalaries = employees.stream()
            .map(Employee::getSalary)
            .sorted()
            .collect(Collectors.toList());

        int size = sortedSalaries.size();
        if (size == 0) return BigDecimal.ZERO;

        if (size % 2 == 0) {
            return sortedSalaries.get(size / 2 - 1)
                .add(sortedSalaries.get(size / 2))
                .divide(BigDecimal.valueOf(2), 2, RoundingMode.HALF_UP);
        } else {
            return sortedSalaries.get(size / 2);
        }
    }

    /**
     * Encuentra empleados elegibles para promoción
     */
    public List<PromotionCandidate> findPromotionCandidates(
        List<Employee> employees,
        List<PerformanceReview> reviews
    ) {
        // Crear mapa de employee ID → promedio de reviews
        Map<String, Double> avgRatings = reviews.stream()
            .collect(Collectors.groupingBy(
                PerformanceReview::getEmployeeId,
                Collectors.averagingDouble(PerformanceReview::getRating)
            ));

        return employees.stream()
            .filter(Employee::isActive)
            .filter(emp -> {
                // Criterios de elegibilidad
                long yearsInCompany = ChronoUnit.YEARS.between(
                    emp.getHireDate(),
                    LocalDate.now()
                );

                long yearsInPosition = ChronoUnit.YEARS.between(
                    emp.getCurrentPositionStartDate(),
                    LocalDate.now()
                );

                double avgRating = avgRatings.getOrDefault(emp.getId(), 0.0);

                return yearsInCompany >= 2 &&
                       yearsInPosition >= 1 &&
                       avgRating >= 4.0 &&
                       !emp.isOnPIP();
            })
            .map(emp -> new PromotionCandidate(
                emp.getId(),
                emp.getName(),
                emp.getDepartment(),
                emp.getCurrentPosition(),
                avgRatings.get(emp.getId())
            ))
            .sorted(Comparator.comparing(PromotionCandidate::avgRating).reversed())
            .collect(Collectors.toList());
    }

    /**
     * Calcula distribución de edad por departamento
     */
    public Map<String, Map<AgeRange, Long>> getAgeDistribution(List<Employee> employees) {
        return employees.stream()
            .filter(Employee::isActive)
            .collect(Collectors.groupingBy(
                Employee::getDepartment,
                Collectors.groupingBy(
                    emp -> AgeRange.fromAge(emp.getAge()),
                    Collectors.counting()
                )
            ));
    }

    enum AgeRange {
        UNDER_25, AGE_25_34, AGE_35_44, AGE_45_54, AGE_55_PLUS;

        static AgeRange fromAge(int age) {
            if (age < 25) return UNDER_25;
            if (age < 35) return AGE_25_34;
            if (age < 45) return AGE_35_44;
            if (age < 55) return AGE_45_54;
            return AGE_55_PLUS;
        }
    }

    record SalaryStats(long count, BigDecimal avg, BigDecimal min, BigDecimal max, BigDecimal median) {}
    record PromotionCandidate(String id, String name, String department, String position, double avgRating) {}
}
```

---

## ⚡ OPTIMIZACIÓN Y PERFORMANCE

### Parallel Streams

```java
public class ParallelStreamExamples {

    // ✅ Good use case: CPU-intensive operations
    public List<String> processLargeDataset(List<String> data) {
        return data.parallelStream()
            .filter(s -> s.length() > 10)
            .map(this::expensiveComputation)
            .collect(Collectors.toList());
    }

    // ❌ Bad use case: I/O operations (use async instead)
    public List<User> fetchUsers(List<String> userIds) {
        return userIds.parallelStream()
            .map(this::fetchUserFromDatabase) // BLOCKING I/O!
            .collect(Collectors.toList());
    }

    // ✅ Better: Control parallelism
    public BigDecimal calculateTotal(List<Order> orders) {
        ForkJoinPool customPool = new ForkJoinPool(4);

        try {
            return customPool.submit(() ->
                orders.parallelStream()
                    .map(Order::getTotal)
                    .reduce(BigDecimal.ZERO, BigDecimal::add)
            ).get();
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}
```

### Lazy Evaluation

```java
public class LazyEvaluationExamples {

    // ✅ Lazy: Only processes until match found
    public Optional<User> findFirstActiveAdmin(List<User> users) {
        return users.stream()
            .filter(User::isActive)
            .filter(user -> user.getRole() == Role.ADMIN)
            .findFirst(); // Short-circuits!
    }

    // ✅ Lazy: Filter antes de map (más eficiente)
    public List<String> getActiveUserNames(List<User> users) {
        return users.stream()
            .filter(User::isActive)  // Filter first (cheap)
            .map(User::getName)      // Map only active users
            .collect(Collectors.toList());
    }

    // ❌ Eager: Mapea todos antes de filtrar (ineficiente)
    public List<String> getActiveUserNamesBad(List<User> users) {
        return users.stream()
            .map(User::getName)      // Maps ALL users
            .filter(name -> users.stream()
                .anyMatch(u -> u.getName().equals(name) && u.isActive()))
            .collect(Collectors.toList());
    }
}
```

---

## 📊 COLLECTORS AVANZADOS

```java
public class AdvancedCollectors {

    // 1️⃣ Partitioning: Divide en dos grupos
    public Map<Boolean, List<Product>> partitionByAvailability(List<Product> products) {
        return products.stream()
            .collect(Collectors.partitioningBy(Product::isAvailable));
    }

    // 2️⃣ Grouping con downstream collectors
    public Map<String, DoubleSummaryStatistics> getPriceStatsByCategory(List<Product> products) {
        return products.stream()
            .collect(Collectors.groupingBy(
                Product::getCategory,
                Collectors.summarizingDouble(p -> p.getPrice().doubleValue())
            ));
    }

    // 3️⃣ Collector personalizado
    public String toCommaSeparatedString(List<String> items) {
        return items.stream()
            .collect(Collectors.joining(", ", "[", "]"));
    }

    // 4️⃣ Multifaceted grouping
    public Map<String, Map<PriceRange, List<Product>>> groupByCategoryAndPriceRange(
        List<Product> products
    ) {
        return products.stream()
            .collect(Collectors.groupingBy(
                Product::getCategory,
                Collectors.groupingBy(
                    product -> PriceRange.fromPrice(product.getPrice())
                )
            ));
    }

    enum PriceRange {
        BUDGET, MID_RANGE, PREMIUM;

        static PriceRange fromPrice(BigDecimal price) {
            if (price.compareTo(new BigDecimal("50")) < 0) return BUDGET;
            if (price.compareTo(new BigDecimal("200")) < 0) return MID_RANGE;
            return PREMIUM;
        }
    }

    // 5️⃣ toMap con merge function
    public Map<String, Integer> mergeDuplicateKeys(List<Product> products) {
        return products.stream()
            .collect(Collectors.toMap(
                Product::getName,
                Product::getStock,
                Integer::sum  // Merge duplicates by summing stock
            ));
    }
}
```

---

## ✅ BEST PRACTICES

### ✅ DO

1. **Usa method references cuando sea posible**

```java
// ✅ Good
users.stream().map(User::getName)

// ❌ Bad
users.stream().map(user -> user.getName())
```

2. **Filtra antes de mapear**

```java
// ✅ Good: Filter first (cheap)
users.stream()
    .filter(User::isActive)
    .map(this::toDto)

// ❌ Bad: Map all, then filter
users.stream()
    .map(this::toDto)
    .filter(dto -> dto.isActive())
```

3. **Usa findFirst() para short-circuit**

```java
// ✅ Good: Stops at first match
Optional<User> admin = users.stream()
    .filter(u -> u.getRole() == Role.ADMIN)
    .findFirst();
```

4. **Evita side effects en lambdas**

```java
// ❌ Bad: Side effect
List<String> names = new ArrayList<>();
users.stream().forEach(u -> names.add(u.getName()));

// ✅ Good: Pure functional
List<String> names = users.stream()
    .map(User::getName)
    .collect(Collectors.toList());
```

### ❌ DON'T

1. **No modifiques la colección original**

```java
// ❌ DANGEROUS!
users.stream()
    .forEach(user -> users.remove(user));
```

2. **No uses parallel streams con operaciones bloqueantes**

```java
// ❌ Bad: Blocking I/O
ids.parallelStream()
    .map(this::fetchFromDatabase)
```

3. **No uses streams para iteraciones simples**

```java
// ❌ Overkill
List<Integer> list = Arrays.asList(1, 2, 3);
list.stream().forEach(System.out::println);

// ✅ Simple for loop is fine
for (int i : list) {
    System.out.println(i);
}
```

---

## 🎯 CHEATSHEET

```java
// FILTER
.filter(x -> x > 10)                    // Condición simple
.filter(Objects::nonNull)               // Eliminar nulls
.filter(distinctByKey(User::getEmail))  // Distinct por propiedad

// MAP
.map(String::toUpperCase)               // Transformación simple
.map(x -> x * 2)                        // Cálculo
.map(this::toDto)                       // Conversión

// FLATMAP
.flatMap(order -> order.getItems().stream())  // Aplanar
.flatMap(Optional::stream)                     // Aplanar Optional

// REDUCE
.reduce(0, Integer::sum)                // Suma
.reduce(1, (a, b) -> a * b)            // Producto
.reduce(String::concat)                 // Concatenar

// COLLECTORS
.collect(Collectors.toList())           // Lista
.collect(Collectors.toSet())            // Set
.collect(Collectors.toMap(k, v))        // Map
.collect(Collectors.groupingBy(f))      // Agrupar
.collect(Collectors.joining(", "))      // String separado

// TERMINAL OPERATIONS
.forEach(System.out::println)           // Iterar
.count()                                // Contar
.anyMatch(x -> x > 10)                 // Alguno cumple
.allMatch(x -> x > 0)                  // Todos cumplen
.noneMatch(Objects::isNull)            // Ninguno cumple
.findFirst()                            // Primero
.findAny()                              // Cualquiera (parallel)
```

---

**💡 RECUERDA:** Los Streams son inmutables y lazy. Las operaciones intermedias no se ejecutan hasta que se invoca una operación terminal. Usa parallel streams solo para operaciones CPU-intensive en grandes datasets.
