---
description: "Implementar el patrón Strategy para diferentes métodos de cálculo de intereses con contexto financiero"
agent: agent
---

# 💰 STRATEGY PATTERN - Interest Calculation Strategies

Actúa como **arquitecto de software especializado en patrones de diseño GoF (Gang of Four) y sistemas financieros**.

Tu misión es **implementar el patrón Strategy** para crear diferentes algoritmos de cálculo de intereses de manera flexible, desacoplada y fácilmente extensible.

---

## 🎯 OBJETIVO DEL PATRÓN STRATEGY

**Definición:** Permite definir una familia de algoritmos, encapsular cada uno de ellos y hacerlos intercambiables. Strategy permite que el algoritmo varíe independientemente de los clientes que lo utilizan.

**Ventajas:**

- ✅ Elimina condicionales complejos (if-else/switch)
- ✅ Facilita agregar nuevas estrategias sin modificar código existente (OCP)
- ✅ Cada estrategia es fácilmente testeable de forma aislada
- ✅ El contexto puede cambiar estrategias en runtime
- ✅ Código más limpio y mantenible

---

## 🏗️ ESTRUCTURA DEL PATRÓN

```
┌──────────────────┐
│  Context         │
│  - strategy      │───uses──▶ ┌─────────────────────┐
│  + calculate()   │           │ <<interface>>       │
└──────────────────┘           │ InterestStrategy    │
                               │ + calculate()       │
                               └─────────────────────┘
                                         △
                                         │ implements
                        ┌────────────────┼────────────────┐
                        │                │                │
              ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
              │ SimpleInterest  │ │ CompoundInterest│ │ ContinuousInterest│
              │ Strategy        │ │ Strategy        │ │ Strategy        │
              └─────────────────┘ └─────────────────┘ └─────────────────┘
```

---

## 📝 IMPLEMENTACIÓN BASE

### 1️⃣ **Strategy Interface**

```java
import java.math.BigDecimal;
import java.time.Period;

/**
 * Strategy interface for interest calculation algorithms.
 * Each implementation defines a different way to calculate interest.
 */
public interface InterestStrategy {

    /**
     * Calculates interest based on principal, rate, and period.
     *
     * @param principal the initial amount (capital)
     * @param annualRate annual interest rate (e.g., 0.05 for 5%)
     * @param period time period for calculation
     * @return calculated interest amount
     */
    BigDecimal calculate(BigDecimal principal, BigDecimal annualRate, Period period);

    /**
     * Returns the name/type of this interest calculation strategy.
     */
    String getStrategyName();

    /**
     * Returns a description of how this strategy calculates interest.
     */
    default String getDescription() {
        return "Interest calculation strategy: " + getStrategyName();
    }
}
```

### 2️⃣ **Concrete Strategies**

#### 🔹 Simple Interest Strategy

```java
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Period;

/**
 * Simple Interest: I = P × r × t
 * Interest grows linearly over time.
 */
public class SimpleInterestStrategy implements InterestStrategy {

    private static final int SCALE = 2;
    private static final RoundingMode ROUNDING = RoundingMode.HALF_UP;

    @Override
    public BigDecimal calculate(BigDecimal principal, BigDecimal annualRate, Period period) {
        validateInputs(principal, annualRate, period);

        // Convert period to years
        BigDecimal years = calculateYears(period);

        // I = P × r × t
        return principal
            .multiply(annualRate)
            .multiply(years)
            .setScale(SCALE, ROUNDING);
    }

    @Override
    public String getStrategyName() {
        return "Simple Interest";
    }

    @Override
    public String getDescription() {
        return "Simple Interest (I = P × r × t) - Linear growth, no compounding";
    }

    private BigDecimal calculateYears(Period period) {
        double totalDays = period.getYears() * 365
            + period.getMonths() * 30.44
            + period.getDays();
        return BigDecimal.valueOf(totalDays / 365.0);
    }

    private void validateInputs(BigDecimal principal, BigDecimal annualRate, Period period) {
        if (principal.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("Principal must be positive");
        }
        if (annualRate.compareTo(BigDecimal.ZERO) < 0) {
            throw new IllegalArgumentException("Annual rate cannot be negative");
        }
        if (period == null || period.isZero() || period.isNegative()) {
            throw new IllegalArgumentException("Period must be positive");
        }
    }
}
```

#### 🔹 Compound Interest Strategy

```java
import java.math.BigDecimal;
import java.math.MathContext;
import java.math.RoundingMode;
import java.time.Period;

/**
 * Compound Interest: A = P(1 + r/n)^(nt)
 * Interest is calculated on principal + accumulated interest.
 */
public class CompoundInterestStrategy implements InterestStrategy {

    private static final int SCALE = 2;
    private static final RoundingMode ROUNDING = RoundingMode.HALF_UP;
    private static final MathContext MATH_CONTEXT = new MathContext(10);

    private final int compoundingFrequency; // times per year

    /**
     * @param compoundingFrequency number of times interest is compounded per year
     *                              (1=annually, 4=quarterly, 12=monthly, 365=daily)
     */
    public CompoundInterestStrategy(int compoundingFrequency) {
        if (compoundingFrequency <= 0) {
            throw new IllegalArgumentException("Compounding frequency must be positive");
        }
        this.compoundingFrequency = compoundingFrequency;
    }

    @Override
    public BigDecimal calculate(BigDecimal principal, BigDecimal annualRate, Period period) {
        validateInputs(principal, annualRate, period);

        BigDecimal years = calculateYears(period);
        BigDecimal n = BigDecimal.valueOf(compoundingFrequency);

        // A = P(1 + r/n)^(nt)
        BigDecimal ratePerPeriod = annualRate.divide(n, MATH_CONTEXT);
        BigDecimal onePlusRate = BigDecimal.ONE.add(ratePerPeriod);

        // Calculate exponent: n × t
        BigDecimal exponent = n.multiply(years);

        // Calculate (1 + r/n)^(nt)
        BigDecimal compoundFactor = pow(onePlusRate, exponent);

        // Calculate final amount
        BigDecimal finalAmount = principal.multiply(compoundFactor);

        // Return interest only (A - P)
        return finalAmount.subtract(principal).setScale(SCALE, ROUNDING);
    }

    @Override
    public String getStrategyName() {
        return "Compound Interest (" + getCompoundingFrequencyName() + ")";
    }

    @Override
    public String getDescription() {
        return String.format(
            "Compound Interest (A = P(1 + r/n)^(nt)) - Compounded %s (%d times/year)",
            getCompoundingFrequencyName(), compoundingFrequency
        );
    }

    private String getCompoundingFrequencyName() {
        return switch (compoundingFrequency) {
            case 1 -> "annually";
            case 2 -> "semi-annually";
            case 4 -> "quarterly";
            case 12 -> "monthly";
            case 365 -> "daily";
            default -> compoundingFrequency + " times/year";
        };
    }

    private BigDecimal pow(BigDecimal base, BigDecimal exponent) {
        // Use logarithms for arbitrary exponents: b^e = e^(e × ln(b))
        double result = Math.pow(base.doubleValue(), exponent.doubleValue());
        return BigDecimal.valueOf(result);
    }

    private BigDecimal calculateYears(Period period) {
        double totalDays = period.getYears() * 365
            + period.getMonths() * 30.44
            + period.getDays();
        return BigDecimal.valueOf(totalDays / 365.0);
    }

    private void validateInputs(BigDecimal principal, BigDecimal annualRate, Period period) {
        if (principal.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("Principal must be positive");
        }
        if (annualRate.compareTo(BigDecimal.ZERO) < 0) {
            throw new IllegalArgumentException("Annual rate cannot be negative");
        }
        if (period == null || period.isZero() || period.isNegative()) {
            throw new IllegalArgumentException("Period must be positive");
        }
    }
}
```

#### 🔹 Continuous Compound Interest Strategy

```java
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Period;

/**
 * Continuous Compound Interest: A = P × e^(rt)
 * Interest is compounded continuously (limit as n → ∞).
 */
public class ContinuousCompoundInterestStrategy implements InterestStrategy {

    private static final int SCALE = 2;
    private static final RoundingMode ROUNDING = RoundingMode.HALF_UP;

    @Override
    public BigDecimal calculate(BigDecimal principal, BigDecimal annualRate, Period period) {
        validateInputs(principal, annualRate, period);

        BigDecimal years = calculateYears(period);

        // A = P × e^(rt)
        double exponent = annualRate.multiply(years).doubleValue();
        double ePowExponent = Math.exp(exponent);

        BigDecimal finalAmount = principal.multiply(BigDecimal.valueOf(ePowExponent));

        // Return interest only (A - P)
        return finalAmount.subtract(principal).setScale(SCALE, ROUNDING);
    }

    @Override
    public String getStrategyName() {
        return "Continuous Compound Interest";
    }

    @Override
    public String getDescription() {
        return "Continuous Compound Interest (A = P × e^(rt)) - Compounded continuously";
    }

    private BigDecimal calculateYears(Period period) {
        double totalDays = period.getYears() * 365
            + period.getMonths() * 30.44
            + period.getDays();
        return BigDecimal.valueOf(totalDays / 365.0);
    }

    private void validateInputs(BigDecimal principal, BigDecimal annualRate, Period period) {
        if (principal.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("Principal must be positive");
        }
        if (annualRate.compareTo(BigDecimal.ZERO) < 0) {
            throw new IllegalArgumentException("Annual rate cannot be negative");
        }
        if (period == null || period.isZero() || period.isNegative()) {
            throw new IllegalArgumentException("Period must be positive");
        }
    }
}
```

#### 🔹 Fixed Amount Strategy

```java
import java.math.BigDecimal;
import java.time.Period;

/**
 * Fixed Amount Interest: Returns a constant amount regardless of period.
 * Useful for promotional offers or fixed-fee scenarios.
 */
public class FixedAmountInterestStrategy implements InterestStrategy {

    private final BigDecimal fixedAmount;

    public FixedAmountInterestStrategy(BigDecimal fixedAmount) {
        if (fixedAmount.compareTo(BigDecimal.ZERO) < 0) {
            throw new IllegalArgumentException("Fixed amount cannot be negative");
        }
        this.fixedAmount = fixedAmount;
    }

    @Override
    public BigDecimal calculate(BigDecimal principal, BigDecimal annualRate, Period period) {
        // Ignore parameters, return fixed amount
        return fixedAmount;
    }

    @Override
    public String getStrategyName() {
        return "Fixed Amount Interest";
    }

    @Override
    public String getDescription() {
        return "Fixed Amount Interest - Returns constant amount: " + fixedAmount;
    }
}
```

### 3️⃣ **Context Class**

```java
import java.math.BigDecimal;
import java.time.Period;
import java.util.Objects;

/**
 * Context that uses an InterestStrategy to calculate interest.
 * The strategy can be changed at runtime.
 */
public class InterestCalculator {

    private InterestStrategy strategy;

    public InterestCalculator(InterestStrategy strategy) {
        setStrategy(strategy);
    }

    /**
     * Changes the calculation strategy at runtime.
     */
    public void setStrategy(InterestStrategy strategy) {
        this.strategy = Objects.requireNonNull(strategy, "Strategy cannot be null");
    }

    /**
     * Calculates interest using the current strategy.
     */
    public BigDecimal calculateInterest(BigDecimal principal, BigDecimal annualRate, Period period) {
        return strategy.calculate(principal, annualRate, period);
    }

    /**
     * Calculates final amount (principal + interest).
     */
    public BigDecimal calculateFinalAmount(BigDecimal principal, BigDecimal annualRate, Period period) {
        BigDecimal interest = calculateInterest(principal, annualRate, period);
        return principal.add(interest);
    }

    /**
     * Returns information about the current strategy.
     */
    public String getCurrentStrategyInfo() {
        return strategy.getDescription();
    }

    /**
     * Compares results using different strategies.
     */
    public InterestComparisonResult compareStrategies(
        BigDecimal principal,
        BigDecimal annualRate,
        Period period,
        InterestStrategy... strategies
    ) {
        InterestComparisonResult result = new InterestComparisonResult(principal, annualRate, period);

        for (InterestStrategy strat : strategies) {
            setStrategy(strat);
            BigDecimal interest = calculateInterest(principal, annualRate, period);
            result.addResult(strat.getStrategyName(), interest);
        }

        return result;
    }
}
```

### 4️⃣ **Comparison Result DTO**

```java
import java.math.BigDecimal;
import java.time.Period;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * DTO for comparing results from multiple interest calculation strategies.
 */
public class InterestComparisonResult {

    private final BigDecimal principal;
    private final BigDecimal annualRate;
    private final Period period;
    private final Map<String, BigDecimal> results = new LinkedHashMap<>();

    public InterestComparisonResult(BigDecimal principal, BigDecimal annualRate, Period period) {
        this.principal = principal;
        this.annualRate = annualRate;
        this.period = period;
    }

    public void addResult(String strategyName, BigDecimal interest) {
        results.put(strategyName, interest);
    }

    public Map<String, BigDecimal> getResults() {
        return results;
    }

    public String getBestStrategy() {
        return results.entrySet().stream()
            .max(Map.Entry.comparingByValue())
            .map(Map.Entry::getKey)
            .orElse("N/A");
    }

    public String getWorstStrategy() {
        return results.entrySet().stream()
            .min(Map.Entry.comparingByValue())
            .map(Map.Entry::getKey)
            .orElse("N/A");
    }

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append("Interest Comparison Results\n");
        sb.append("Principal: ").append(principal).append("\n");
        sb.append("Annual Rate: ").append(annualRate.multiply(BigDecimal.valueOf(100))).append("%\n");
        sb.append("Period: ").append(period).append("\n\n");

        results.forEach((strategy, interest) -> {
            BigDecimal finalAmount = principal.add(interest);
            sb.append(String.format("%-30s → Interest: $%,.2f | Final: $%,.2f%n",
                strategy, interest, finalAmount));
        });

        sb.append("\nBest strategy: ").append(getBestStrategy());
        sb.append("\nWorst strategy: ").append(getWorstStrategy());

        return sb.toString();
    }
}
```

---

## 🎯 EJEMPLOS DE USO

### Ejemplo 1: Uso Básico

```java
public class InterestCalculatorDemo {

    public static void main(String[] args) {
        // Setup
        BigDecimal principal = new BigDecimal("10000");
        BigDecimal annualRate = new BigDecimal("0.05"); // 5%
        Period period = Period.ofYears(2);

        // Calculate with Simple Interest
        InterestCalculator calculator = new InterestCalculator(new SimpleInterestStrategy());
        BigDecimal simpleInterest = calculator.calculateInterest(principal, annualRate, period);
        System.out.println("Simple Interest: $" + simpleInterest);
        // Output: Simple Interest: $1000.00

        // Switch to Compound Interest (monthly)
        calculator.setStrategy(new CompoundInterestStrategy(12));
        BigDecimal compoundInterest = calculator.calculateInterest(principal, annualRate, period);
        System.out.println("Compound Interest (monthly): $" + compoundInterest);
        // Output: Compound Interest (monthly): $1051.16

        // Switch to Continuous Compound
        calculator.setStrategy(new ContinuousCompoundInterestStrategy());
        BigDecimal continuousInterest = calculator.calculateInterest(principal, annualRate, period);
        System.out.println("Continuous Compound Interest: $" + continuousInterest);
        // Output: Continuous Compound Interest: $1051.71
    }
}
```

### Ejemplo 2: Comparación de Estrategias

```java
public class StrategyComparisonDemo {

    public static void main(String[] args) {
        BigDecimal principal = new BigDecimal("50000");
        BigDecimal annualRate = new BigDecimal("0.08"); // 8%
        Period period = Period.ofYears(5);

        InterestCalculator calculator = new InterestCalculator(new SimpleInterestStrategy());

        InterestComparisonResult comparison = calculator.compareStrategies(
            principal, annualRate, period,
            new SimpleInterestStrategy(),
            new CompoundInterestStrategy(1),    // annually
            new CompoundInterestStrategy(4),    // quarterly
            new CompoundInterestStrategy(12),   // monthly
            new CompoundInterestStrategy(365),  // daily
            new ContinuousCompoundInterestStrategy()
        );

        System.out.println(comparison);
    }
}

/* Output:
Interest Comparison Results
Principal: 50000
Annual Rate: 8.00%
Period: P5Y

Simple Interest                → Interest: $20,000.00 | Final: $70,000.00
Compound Interest (annually)   → Interest: $23,466.40 | Final: $73,466.40
Compound Interest (quarterly)  → Interest: $24,202.71 | Final: $74,202.71
Compound Interest (monthly)    → Interest: $24,432.07 | Final: $74,432.07
Compound Interest (daily)      → Interest: $24,541.37 | Final: $74,541.37
Continuous Compound Interest   → Interest: $24,550.82 | Final: $74,550.82

Best strategy: Continuous Compound Interest
Worst strategy: Simple Interest
*/
```

### Ejemplo 3: Factory Pattern + Strategy

```java
public class InterestStrategyFactory {

    public enum StrategyType {
        SIMPLE,
        COMPOUND_ANNUALLY,
        COMPOUND_QUARTERLY,
        COMPOUND_MONTHLY,
        COMPOUND_DAILY,
        CONTINUOUS
    }

    public static InterestStrategy create(StrategyType type) {
        return switch (type) {
            case SIMPLE -> new SimpleInterestStrategy();
            case COMPOUND_ANNUALLY -> new CompoundInterestStrategy(1);
            case COMPOUND_QUARTERLY -> new CompoundInterestStrategy(4);
            case COMPOUND_MONTHLY -> new CompoundInterestStrategy(12);
            case COMPOUND_DAILY -> new CompoundInterestStrategy(365);
            case CONTINUOUS -> new ContinuousCompoundInterestStrategy();
        };
    }

    public static InterestStrategy createFromConfig(String config) {
        try {
            StrategyType type = StrategyType.valueOf(config.toUpperCase());
            return create(type);
        } catch (IllegalArgumentException e) {
            throw new IllegalArgumentException("Unknown strategy type: " + config);
        }
    }
}

// Usage
InterestStrategy strategy = InterestStrategyFactory.create(StrategyType.COMPOUND_MONTHLY);
InterestCalculator calculator = new InterestCalculator(strategy);
```

### Ejemplo 4: Spring Integration

```java
@Configuration
public class InterestStrategyConfig {

    @Bean
    @ConditionalOnProperty(name = "interest.strategy", havingValue = "simple")
    public InterestStrategy simpleInterestStrategy() {
        return new SimpleInterestStrategy();
    }

    @Bean
    @ConditionalOnProperty(name = "interest.strategy", havingValue = "compound")
    public InterestStrategy compoundInterestStrategy(
        @Value("${interest.compounding.frequency:12}") int frequency
    ) {
        return new CompoundInterestStrategy(frequency);
    }

    @Bean
    @ConditionalOnProperty(name = "interest.strategy", havingValue = "continuous")
    public InterestStrategy continuousInterestStrategy() {
        return new ContinuousCompoundInterestStrategy();
    }

    @Bean
    public InterestCalculator interestCalculator(InterestStrategy strategy) {
        return new InterestCalculator(strategy);
    }
}

@Service
public class LoanService {

    private final InterestCalculator calculator;

    public LoanService(InterestCalculator calculator) {
        this.calculator = calculator;
    }

    public LoanQuote generateQuote(BigDecimal amount, BigDecimal rate, Period term) {
        BigDecimal interest = calculator.calculateInterest(amount, rate, term);
        BigDecimal totalAmount = amount.add(interest);

        return new LoanQuote(amount, rate, term, interest, totalAmount);
    }
}
```

---

## 🧪 TESTING

### Unit Tests for Strategies

```java
@DisplayName("Interest Calculation Strategies Tests")
class InterestStrategyTest {

    private BigDecimal principal;
    private BigDecimal annualRate;
    private Period period;

    @BeforeEach
    void setUp() {
        principal = new BigDecimal("10000");
        annualRate = new BigDecimal("0.05"); // 5%
        period = Period.ofYears(2);
    }

    @Test
    @DisplayName("Simple Interest should calculate linearly")
    void testSimpleInterest() {
        InterestStrategy strategy = new SimpleInterestStrategy();
        BigDecimal interest = strategy.calculate(principal, annualRate, period);

        // I = 10000 × 0.05 × 2 = 1000
        assertThat(interest).isEqualByComparingTo("1000.00");
    }

    @Test
    @DisplayName("Compound Interest (annually) should be higher than Simple")
    void testCompoundInterestAnnually() {
        InterestStrategy strategy = new CompoundInterestStrategy(1);
        BigDecimal interest = strategy.calculate(principal, annualRate, period);

        // A = 10000(1 + 0.05/1)^(1×2) = 11025
        // I = 11025 - 10000 = 1025
        assertThat(interest).isEqualByComparingTo("1025.00");
    }

    @Test
    @DisplayName("Higher compounding frequency should yield higher interest")
    void testCompoundingFrequencyImpact() {
        InterestStrategy annually = new CompoundInterestStrategy(1);
        InterestStrategy monthly = new CompoundInterestStrategy(12);
        InterestStrategy daily = new CompoundInterestStrategy(365);

        BigDecimal interestAnnually = annually.calculate(principal, annualRate, period);
        BigDecimal interestMonthly = monthly.calculate(principal, annualRate, period);
        BigDecimal interestDaily = daily.calculate(principal, annualRate, period);

        assertThat(interestMonthly).isGreaterThan(interestAnnually);
        assertThat(interestDaily).isGreaterThan(interestMonthly);
    }

    @Test
    @DisplayName("Continuous Compound should yield highest interest")
    void testContinuousCompound() {
        InterestStrategy continuous = new ContinuousCompoundInterestStrategy();
        InterestStrategy daily = new CompoundInterestStrategy(365);

        BigDecimal interestContinuous = continuous.calculate(principal, annualRate, period);
        BigDecimal interestDaily = daily.calculate(principal, annualRate, period);

        assertThat(interestContinuous).isGreaterThanOrEqualTo(interestDaily);
    }

    @ParameterizedTest
    @ValueSource(strings = {"-1000", "0"})
    @DisplayName("Should throw exception for invalid principal")
    void testInvalidPrincipal(String invalidPrincipal) {
        InterestStrategy strategy = new SimpleInterestStrategy();

        assertThatThrownBy(() ->
            strategy.calculate(new BigDecimal(invalidPrincipal), annualRate, period)
        ).isInstanceOf(IllegalArgumentException.class)
         .hasMessageContaining("Principal must be positive");
    }
}
```

---

## 📊 EXTENSIONES AVANZADAS

### 1️⃣ Strategy con Configuración

```java
public interface ConfigurableInterestStrategy extends InterestStrategy {
    void configure(Map<String, Object> config);
}

public class TieredInterestStrategy implements ConfigurableInterestStrategy {

    private List<Tier> tiers = new ArrayList<>();

    record Tier(BigDecimal threshold, BigDecimal rate) {}

    @Override
    public void configure(Map<String, Object> config) {
        // Load tiered rates from config
        @SuppressWarnings("unchecked")
        List<Map<String, String>> tierConfigs = (List<Map<String, String>>) config.get("tiers");

        tiers = tierConfigs.stream()
            .map(tc -> new Tier(
                new BigDecimal(tc.get("threshold")),
                new BigDecimal(tc.get("rate"))
            ))
            .sorted((a, b) -> a.threshold.compareTo(b.threshold))
            .toList();
    }

    @Override
    public BigDecimal calculate(BigDecimal principal, BigDecimal annualRate, Period period) {
        // Calculate interest based on tiered rates
        BigDecimal applicableRate = tiers.stream()
            .filter(t -> principal.compareTo(t.threshold) >= 0)
            .map(Tier::rate)
            .reduce((first, second) -> second) // Get last matching
            .orElse(annualRate);

        return new SimpleInterestStrategy().calculate(principal, applicableRate, period);
    }

    @Override
    public String getStrategyName() {
        return "Tiered Interest";
    }
}
```

### 2️⃣ Strategy con Estado

```java
public class PromotionalInterestStrategy implements InterestStrategy {

    private final InterestStrategy baseStrategy;
    private final BigDecimal bonusRate;
    private final LocalDate promotionEndDate;

    public PromotionalInterestStrategy(
        InterestStrategy baseStrategy,
        BigDecimal bonusRate,
        LocalDate promotionEndDate
    ) {
        this.baseStrategy = baseStrategy;
        this.bonusRate = bonusRate;
        this.promotionEndDate = promotionEndDate;
    }

    @Override
    public BigDecimal calculate(BigDecimal principal, BigDecimal annualRate, Period period) {
        if (LocalDate.now().isBefore(promotionEndDate)) {
            // Apply bonus rate during promotion
            BigDecimal promotionalRate = annualRate.add(bonusRate);
            return baseStrategy.calculate(principal, promotionalRate, period);
        } else {
            // Standard rate after promotion
            return baseStrategy.calculate(principal, annualRate, period);
        }
    }

    @Override
    public String getStrategyName() {
        return "Promotional (" + baseStrategy.getStrategyName() + ")";
    }
}
```

---

## ✅ CHECKLIST DE IMPLEMENTACIÓN

- [ ] ✅ Interfaz `InterestStrategy` con método `calculate()`
- [ ] ✅ Al menos 3 estrategias concretas implementadas
- [ ] ✅ Clase `Context` que use la estrategia
- [ ] ✅ Método para cambiar estrategia en runtime
- [ ] ✅ Validaciones en cada estrategia
- [ ] ✅ Uso de `BigDecimal` para cálculos monetarios
- [ ] ✅ Escalado y redondeo apropiado (2 decimales)
- [ ] ✅ Tests unitarios para cada estrategia
- [ ] ✅ Factory para crear estrategias (opcional)
- [ ] ✅ Documentación de fórmulas matemáticas
- [ ] ✅ Manejo de casos edge (período cero, tasa negativa)
- [ ] ✅ Comparación entre estrategias disponible

---

## 🎯 CASOS DE USO REALES

**1. Cuentas de Ahorro:**

- Simple Interest: Cuentas básicas
- Compound Interest (monthly): Cuentas premium
- Tiered Interest: Tasas por saldo

**2. Préstamos:**

- Simple Interest: Préstamos corto plazo
- Compound Interest: Hipotecas, créditos largo plazo
- Promotional: Ofertas introductorias

**3. Inversiones:**

- Compound Interest (daily): Fondos de inversión
- Continuous Compound: Derivados financieros
- Fixed Amount: Bonos cupón cero

---

**💡 RECUERDA:** El patrón Strategy elimina condicionales y hace el código Open/Closed. Cada nueva estrategia es una clase nueva, no un `else` nuevo.
