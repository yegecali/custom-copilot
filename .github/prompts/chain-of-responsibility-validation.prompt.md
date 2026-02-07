---
description: "Implementar el patrón Chain of Responsibility para validación multinivel de reglas de negocio con manejo flexible de errores"
agent: agent
---

# 🔗 CHAIN OF RESPONSIBILITY - Business Rules Validation

Actúa como **experto en patrones de diseño GoF y arquitectura de sistemas empresariales**.

Tu misión es **implementar el patrón Chain of Responsibility** para crear un sistema de validación multinivel que procese reglas de negocio de forma secuencial, permitiendo que múltiples validadores procesen una solicitud en cadena.

---

## 🎯 PATRÓN CHAIN OF RESPONSIBILITY

**Definición:** Permite pasar solicitudes a lo largo de una cadena de manejadores. Cada manejador decide si procesa la solicitud o la pasa al siguiente en la cadena.

**Ventajas:**

- ✅ Desacopla emisores de receptores
- ✅ Facilita agregar/quitar validadores sin modificar código existente (OCP)
- ✅ Orden de validación configurable
- ✅ Cada validador tiene una única responsabilidad (SRP)
- ✅ Fácil testing de cada validador por separado

---

## 🏗️ ESTRUCTURA DEL PATRÓN

```
┌──────────────┐
│   Client     │
└──────┬───────┘
       │ request
       ▼
┌──────────────────┐        ┌──────────────────┐        ┌──────────────────┐
│  Validator 1     │───────▶│  Validator 2     │───────▶│  Validator 3     │
│  (Basic Check)   │  next  │  (Business Rule) │  next  │  (Complex Check) │
└──────────────────┘        └──────────────────┘        └──────────────────┘
       │                           │                           │
       └─────────────────┬─────────┴───────────────────────────┘
                         ▼
                  ┌──────────────┐
                  │  Validation  │
                  │    Result    │
                  └──────────────┘
```

---

## 📝 IMPLEMENTACIÓN BASE

### 1️⃣ Resultado de Validación

```java
import java.util.ArrayList;
import java.util.List;

/**
 * Resultado de la validación con soporte para múltiples errores.
 */
public class ValidationResult {

    private final boolean valid;
    private final List<ValidationError> errors;

    private ValidationResult(boolean valid, List<ValidationError> errors) {
        this.valid = valid;
        this.errors = new ArrayList<>(errors);
    }

    public static ValidationResult success() {
        return new ValidationResult(true, List.of());
    }

    public static ValidationResult failure(String message) {
        return new ValidationResult(false, List.of(new ValidationError(message)));
    }

    public static ValidationResult failure(String field, String message) {
        return new ValidationResult(false, List.of(new ValidationError(field, message)));
    }

    public static ValidationResult failure(List<ValidationError> errors) {
        return new ValidationResult(false, errors);
    }

    public boolean isValid() {
        return valid;
    }

    public List<ValidationError> getErrors() {
        return errors;
    }

    /**
     * Combina dos resultados de validación.
     */
    public ValidationResult and(ValidationResult other) {
        if (this.valid && other.valid) {
            return success();
        }

        List<ValidationError> combinedErrors = new ArrayList<>();
        combinedErrors.addAll(this.errors);
        combinedErrors.addAll(other.errors);

        return failure(combinedErrors);
    }

    @Override
    public String toString() {
        if (valid) {
            return "ValidationResult{valid=true}";
        }
        return "ValidationResult{valid=false, errors=" + errors + "}";
    }
}

/**
 * Error de validación individual.
 */
public record ValidationError(String field, String message, ErrorSeverity severity) {

    public ValidationError(String message) {
        this(null, message, ErrorSeverity.ERROR);
    }

    public ValidationError(String field, String message) {
        this(field, message, ErrorSeverity.ERROR);
    }

    public enum ErrorSeverity {
        WARNING, ERROR, CRITICAL
    }
}
```

### 2️⃣ Validador Base (Handler)

```java
/**
 * Abstract base class for validators in the chain.
 * Each validator decides whether to process and/or pass to next validator.
 */
public abstract class Validator<T> {

    protected Validator<T> next;

    /**
     * Sets the next validator in the chain.
     */
    public Validator<T> setNext(Validator<T> next) {
        this.next = next;
        return next;
    }

    /**
     * Main validation method. Calls doValidate() and then passes to next validator.
     */
    public final ValidationResult validate(T request) {
        ValidationResult result = doValidate(request);

        if (!result.isValid() && stopOnFailure()) {
            // Stop chain if validation failed and stopOnFailure is true
            return result;
        }

        if (next != null) {
            ValidationResult nextResult = next.validate(request);
            return result.and(nextResult);
        }

        return result;
    }

    /**
     * Template method: Override to implement specific validation logic.
     */
    protected abstract ValidationResult doValidate(T request);

    /**
     * Override to control whether chain should stop on failure.
     * Default: continue validation even if this validator fails.
     */
    protected boolean stopOnFailure() {
        return false;
    }

    /**
     * Returns the validator name for logging/debugging.
     */
    protected String getValidatorName() {
        return this.getClass().getSimpleName();
    }
}
```

### 3️⃣ Validador Builder

```java
/**
 * Fluent builder for constructing validation chains.
 */
public class ValidationChain<T> {

    private Validator<T> head;
    private Validator<T> tail;

    public ValidationChain<T> add(Validator<T> validator) {
        if (head == null) {
            head = validator;
            tail = validator;
        } else {
            tail.setNext(validator);
            tail = validator;
        }
        return this;
    }

    public ValidationResult validate(T request) {
        if (head == null) {
            return ValidationResult.success();
        }
        return head.validate(request);
    }

    public static <T> ValidationChain<T> create() {
        return new ValidationChain<>();
    }
}
```

---

## 💼 EJEMPLO COMPLETO: SISTEMA DE PRÉSTAMOS

### Contexto del Dominio

```java
import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * Loan application request.
 */
public class LoanApplication {

    private String applicantId;
    private String applicantName;
    private String email;
    private LocalDate dateOfBirth;
    private BigDecimal annualIncome;
    private int creditScore;
    private BigDecimal requestedAmount;
    private int termInMonths;
    private String purpose;
    private BigDecimal existingDebt;
    private EmploymentStatus employmentStatus;
    private int monthsEmployed;

    // Getters and Setters

    public enum EmploymentStatus {
        EMPLOYED, SELF_EMPLOYED, UNEMPLOYED, RETIRED, STUDENT
    }
}
```

### Validadores Específicos

#### 🔹 Validador 1: Campos Obligatorios

```java
/**
 * Validates that all required fields are present and non-empty.
 */
public class RequiredFieldsValidator extends Validator<LoanApplication> {

    @Override
    protected ValidationResult doValidate(LoanApplication application) {
        List<ValidationError> errors = new ArrayList<>();

        if (application.getApplicantName() == null || application.getApplicantName().isBlank()) {
            errors.add(new ValidationError("applicantName", "Applicant name is required"));
        }

        if (application.getEmail() == null || application.getEmail().isBlank()) {
            errors.add(new ValidationError("email", "Email is required"));
        }

        if (application.getDateOfBirth() == null) {
            errors.add(new ValidationError("dateOfBirth", "Date of birth is required"));
        }

        if (application.getRequestedAmount() == null) {
            errors.add(new ValidationError("requestedAmount", "Requested amount is required"));
        }

        if (application.getAnnualIncome() == null) {
            errors.add(new ValidationError("annualIncome", "Annual income is required"));
        }

        return errors.isEmpty()
            ? ValidationResult.success()
            : ValidationResult.failure(errors);
    }

    @Override
    protected boolean stopOnFailure() {
        return true; // Stop chain if required fields are missing
    }
}
```

#### 🔹 Validador 2: Formato de Datos

```java
/**
 * Validates data format and basic constraints.
 */
public class DataFormatValidator extends Validator<LoanApplication> {

    private static final Pattern EMAIL_PATTERN = Pattern.compile(
        "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
    );

    @Override
    protected ValidationResult doValidate(LoanApplication application) {
        List<ValidationError> errors = new ArrayList<>();

        // Email format
        if (!EMAIL_PATTERN.matcher(application.getEmail()).matches()) {
            errors.add(new ValidationError("email", "Invalid email format"));
        }

        // Positive amounts
        if (application.getRequestedAmount().compareTo(BigDecimal.ZERO) <= 0) {
            errors.add(new ValidationError("requestedAmount", "Requested amount must be positive"));
        }

        if (application.getAnnualIncome().compareTo(BigDecimal.ZERO) <= 0) {
            errors.add(new ValidationError("annualIncome", "Annual income must be positive"));
        }

        // Age range
        int age = Period.between(application.getDateOfBirth(), LocalDate.now()).getYears();
        if (age < 18) {
            errors.add(new ValidationError("dateOfBirth", "Applicant must be at least 18 years old"));
        }
        if (age > 80) {
            errors.add(new ValidationError("dateOfBirth", "Applicant cannot be older than 80 years"));
        }

        // Credit score range
        if (application.getCreditScore() < 300 || application.getCreditScore() > 850) {
            errors.add(new ValidationError("creditScore", "Credit score must be between 300 and 850"));
        }

        // Loan term
        if (application.getTermInMonths() < 6 || application.getTermInMonths() > 360) {
            errors.add(new ValidationError("termInMonths", "Loan term must be between 6 and 360 months"));
        }

        return errors.isEmpty()
            ? ValidationResult.success()
            : ValidationResult.failure(errors);
    }
}
```

#### 🔹 Validador 3: Límites de Negocio

```java
/**
 * Validates business rules and limits.
 */
public class BusinessLimitsValidator extends Validator<LoanApplication> {

    private static final BigDecimal MIN_LOAN_AMOUNT = new BigDecimal("1000");
    private static final BigDecimal MAX_LOAN_AMOUNT = new BigDecimal("500000");
    private static final BigDecimal MAX_LOAN_TO_INCOME_RATIO = new BigDecimal("5.0");

    @Override
    protected ValidationResult doValidate(LoanApplication application) {
        List<ValidationError> errors = new ArrayList<>();

        // Loan amount limits
        if (application.getRequestedAmount().compareTo(MIN_LOAN_AMOUNT) < 0) {
            errors.add(new ValidationError(
                "requestedAmount",
                "Minimum loan amount is $" + MIN_LOAN_AMOUNT
            ));
        }

        if (application.getRequestedAmount().compareTo(MAX_LOAN_AMOUNT) > 0) {
            errors.add(new ValidationError(
                "requestedAmount",
                "Maximum loan amount is $" + MAX_LOAN_AMOUNT
            ));
        }

        // Loan to income ratio
        BigDecimal loanToIncomeRatio = application.getRequestedAmount()
            .divide(application.getAnnualIncome(), 2, RoundingMode.HALF_UP);

        if (loanToIncomeRatio.compareTo(MAX_LOAN_TO_INCOME_RATIO) > 0) {
            errors.add(new ValidationError(
                "requestedAmount",
                "Loan amount cannot exceed " + MAX_LOAN_TO_INCOME_RATIO + "x annual income"
            ));
        }

        return errors.isEmpty()
            ? ValidationResult.success()
            : ValidationResult.failure(errors);
    }
}
```

#### 🔹 Validador 4: Solvencia Crediticia

```java
/**
 * Validates credit worthiness and debt-to-income ratio.
 */
public class CreditWorthinessValidator extends Validator<LoanApplication> {

    private static final int MIN_CREDIT_SCORE = 620;
    private static final BigDecimal MAX_DEBT_TO_INCOME_RATIO = new BigDecimal("0.43");

    @Override
    protected ValidationResult doValidate(LoanApplication application) {
        List<ValidationError> errors = new ArrayList<>();

        // Minimum credit score
        if (application.getCreditScore() < MIN_CREDIT_SCORE) {
            errors.add(new ValidationError(
                "creditScore",
                "Minimum credit score required is " + MIN_CREDIT_SCORE
            ));
        }

        // Debt-to-income ratio
        BigDecimal monthlyIncome = application.getAnnualIncome()
            .divide(BigDecimal.valueOf(12), 2, RoundingMode.HALF_UP);

        // Calculate estimated monthly payment (simplified)
        double monthlyRate = 0.05 / 12; // 5% annual rate
        int months = application.getTermInMonths();
        double loanAmount = application.getRequestedAmount().doubleValue();

        double monthlyPayment = loanAmount *
            (monthlyRate * Math.pow(1 + monthlyRate, months)) /
            (Math.pow(1 + monthlyRate, months) - 1);

        BigDecimal totalMonthlyDebt = application.getExistingDebt()
            .add(BigDecimal.valueOf(monthlyPayment));

        BigDecimal debtToIncomeRatio = totalMonthlyDebt
            .divide(monthlyIncome, 4, RoundingMode.HALF_UP);

        if (debtToIncomeRatio.compareTo(MAX_DEBT_TO_INCOME_RATIO) > 0) {
            errors.add(new ValidationError(
                "existingDebt",
                String.format("Debt-to-income ratio (%.2f%%) exceeds maximum allowed (%.2f%%)",
                    debtToIncomeRatio.multiply(BigDecimal.valueOf(100)),
                    MAX_DEBT_TO_INCOME_RATIO.multiply(BigDecimal.valueOf(100)))
            ));
        }

        return errors.isEmpty()
            ? ValidationResult.success()
            : ValidationResult.failure(errors);
    }
}
```

#### 🔹 Validador 5: Estado de Empleo

```java
/**
 * Validates employment status and stability.
 */
public class EmploymentValidator extends Validator<LoanApplication> {

    private static final int MIN_MONTHS_EMPLOYED = 6;
    private static final Set<LoanApplication.EmploymentStatus> ACCEPTABLE_STATUSES = Set.of(
        LoanApplication.EmploymentStatus.EMPLOYED,
        LoanApplication.EmploymentStatus.SELF_EMPLOYED
    );

    @Override
    protected ValidationResult doValidate(LoanApplication application) {
        List<ValidationError> errors = new ArrayList<>();

        // Employment status
        if (!ACCEPTABLE_STATUSES.contains(application.getEmploymentStatus())) {
            errors.add(new ValidationError(
                "employmentStatus",
                "Applicant must be employed or self-employed"
            ));
            return ValidationResult.failure(errors); // Early return
        }

        // Employment stability
        if (application.getMonthsEmployed() < MIN_MONTHS_EMPLOYED) {
            errors.add(new ValidationError(
                "monthsEmployed",
                "Applicant must be employed for at least " + MIN_MONTHS_EMPLOYED + " months"
            ));
        }

        // Self-employed additional check
        if (application.getEmploymentStatus() == LoanApplication.EmploymentStatus.SELF_EMPLOYED) {
            if (application.getMonthsEmployed() < 24) {
                errors.add(new ValidationError(
                    "monthsEmployed",
                    "Self-employed applicants must have 24+ months of business history",
                    ValidationError.ErrorSeverity.WARNING
                ));
            }
        }

        return errors.isEmpty()
            ? ValidationResult.success()
            : ValidationResult.failure(errors);
    }
}
```

#### 🔹 Validador 6: Reglas de Riesgo

```java
/**
 * Validates risk-related business rules.
 */
public class RiskAssessmentValidator extends Validator<LoanApplication> {

    private final RiskService riskService;

    public RiskAssessmentValidator(RiskService riskService) {
        this.riskService = riskService;
    }

    @Override
    protected ValidationResult doValidate(LoanApplication application) {
        List<ValidationError> errors = new ArrayList<>();

        // Check if applicant is in fraud database
        if (riskService.isInFraudDatabase(application.getApplicantId())) {
            errors.add(new ValidationError(
                "applicantId",
                "Applicant is flagged in fraud database",
                ValidationError.ErrorSeverity.CRITICAL
            ));
            return ValidationResult.failure(errors); // Critical - stop immediately
        }

        // Check if applicant has active loans
        int activeLoanCount = riskService.getActiveLoanCount(application.getApplicantId());
        if (activeLoanCount >= 3) {
            errors.add(new ValidationError(
                "applicantId",
                "Applicant already has " + activeLoanCount + " active loans"
            ));
        }

        // Check recent applications
        int recentApplications = riskService.getRecentApplicationCount(
            application.getApplicantId(),
            30
        );
        if (recentApplications > 5) {
            errors.add(new ValidationError(
                "applicantId",
                "Too many loan applications in the last 30 days",
                ValidationError.ErrorSeverity.WARNING
            ));
        }

        return errors.isEmpty()
            ? ValidationResult.success()
            : ValidationResult.failure(errors);
    }

    @Override
    protected boolean stopOnFailure() {
        return true; // Stop on risk issues
    }
}
```

---

## 🔧 CONSTRUCCIÓN DE LA CADENA

### Opción 1: Manual

```java
public class LoanValidationService {

    private final RiskService riskService;

    public LoanValidationService(RiskService riskService) {
        this.riskService = riskService;
    }

    public ValidationResult validateLoanApplication(LoanApplication application) {
        // Build chain manually
        Validator<LoanApplication> chain = new RequiredFieldsValidator();
        chain.setNext(new DataFormatValidator())
             .setNext(new BusinessLimitsValidator())
             .setNext(new CreditWorthinessValidator())
             .setNext(new EmploymentValidator())
             .setNext(new RiskAssessmentValidator(riskService));

        return chain.validate(application);
    }
}
```

### Opción 2: Fluent Builder

```java
public class LoanValidationService {

    private final RiskService riskService;

    public LoanValidationService(RiskService riskService) {
        this.riskService = riskService;
    }

    public ValidationResult validateLoanApplication(LoanApplication application) {
        return ValidationChain.<LoanApplication>create()
            .add(new RequiredFieldsValidator())
            .add(new DataFormatValidator())
            .add(new BusinessLimitsValidator())
            .add(new CreditWorthinessValidator())
            .add(new EmploymentValidator())
            .add(new RiskAssessmentValidator(riskService))
            .validate(application);
    }
}
```

### Opción 3: Spring Configuration

```java
@Configuration
public class ValidationConfig {

    @Bean
    public ValidationChain<LoanApplication> loanValidationChain(RiskService riskService) {
        return ValidationChain.<LoanApplication>create()
            .add(new RequiredFieldsValidator())
            .add(new DataFormatValidator())
            .add(new BusinessLimitsValidator())
            .add(new CreditWorthinessValidator())
            .add(new EmploymentValidator())
            .add(new RiskAssessmentValidator(riskService));
    }
}

@Service
public class LoanValidationService {

    private final ValidationChain<LoanApplication> validationChain;

    public LoanValidationService(ValidationChain<LoanApplication> validationChain) {
        this.validationChain = validationChain;
    }

    public ValidationResult validateLoanApplication(LoanApplication application) {
        return validationChain.validate(application);
    }
}
```

---

## 🎯 USO EN CONTROLLER

```java
@RestController
@RequestMapping("/api/loans")
public class LoanApplicationController {

    private final LoanValidationService validationService;
    private final LoanService loanService;

    public LoanApplicationController(
        LoanValidationService validationService,
        LoanService loanService
    ) {
        this.validationService = validationService;
        this.loanService = loanService;
    }

    @PostMapping("/applications")
    public ResponseEntity<?> submitApplication(@RequestBody LoanApplication application) {
        // Validate using chain
        ValidationResult validationResult = validationService.validateLoanApplication(application);

        if (!validationResult.isValid()) {
            return ResponseEntity
                .badRequest()
                .body(Map.of(
                    "success", false,
                    "errors", validationResult.getErrors()
                ));
        }

        // Process application
        Loan loan = loanService.processApplication(application);

        return ResponseEntity
            .status(HttpStatus.CREATED)
            .body(Map.of(
                "success", true,
                "loanId", loan.getId(),
                "status", loan.getStatus()
            ));
    }
}
```

---

## 🧪 TESTING

### Unit Tests - Validadores Individuales

```java
@DisplayName("Required Fields Validator Tests")
class RequiredFieldsValidatorTest {

    private Validator<LoanApplication> validator;

    @BeforeEach
    void setUp() {
        validator = new RequiredFieldsValidator();
    }

    @Test
    @DisplayName("Should pass when all required fields are present")
    void testAllFieldsPresent() {
        LoanApplication application = new LoanApplication();
        application.setApplicantName("John Doe");
        application.setEmail("john@example.com");
        application.setDateOfBirth(LocalDate.of(1990, 1, 1));
        application.setRequestedAmount(new BigDecimal("50000"));
        application.setAnnualIncome(new BigDecimal("80000"));

        ValidationResult result = validator.validate(application);

        assertThat(result.isValid()).isTrue();
        assertThat(result.getErrors()).isEmpty();
    }

    @Test
    @DisplayName("Should fail when required fields are missing")
    void testMissingFields() {
        LoanApplication application = new LoanApplication();
        // Leave fields empty

        ValidationResult result = validator.validate(application);

        assertThat(result.isValid()).isFalse();
        assertThat(result.getErrors()).hasSize(5);
        assertThat(result.getErrors())
            .extracting(ValidationError::field)
            .containsExactlyInAnyOrder(
                "applicantName",
                "email",
                "dateOfBirth",
                "requestedAmount",
                "annualIncome"
            );
    }

    @Test
    @DisplayName("Should fail when fields are blank")
    void testBlankFields() {
        LoanApplication application = new LoanApplication();
        application.setApplicantName("   ");
        application.setEmail("");

        ValidationResult result = validator.validate(application);

        assertThat(result.isValid()).isFalse();
        assertThat(result.getErrors())
            .extracting(ValidationError::field)
            .contains("applicantName", "email");
    }
}
```

### Integration Tests - Cadena Completa

```java
@DisplayName("Loan Validation Chain Integration Tests")
class LoanValidationChainTest {

    private ValidationChain<LoanApplication> validationChain;
    private RiskService riskService;

    @BeforeEach
    void setUp() {
        riskService = mock(RiskService.class);

        validationChain = ValidationChain.<LoanApplication>create()
            .add(new RequiredFieldsValidator())
            .add(new DataFormatValidator())
            .add(new BusinessLimitsValidator())
            .add(new CreditWorthinessValidator())
            .add(new EmploymentValidator())
            .add(new RiskAssessmentValidator(riskService));
    }

    @Test
    @DisplayName("Should pass all validations for valid application")
    void testValidApplication() {
        LoanApplication application = createValidApplication();

        when(riskService.isInFraudDatabase(anyString())).thenReturn(false);
        when(riskService.getActiveLoanCount(anyString())).thenReturn(0);
        when(riskService.getRecentApplicationCount(anyString(), anyInt())).thenReturn(1);

        ValidationResult result = validationChain.validate(application);

        assertThat(result.isValid()).isTrue();
        assertThat(result.getErrors()).isEmpty();
    }

    @Test
    @DisplayName("Should accumulate errors from multiple validators")
    void testMultipleValidationErrors() {
        LoanApplication application = new LoanApplication();
        application.setApplicantName("John Doe");
        application.setEmail("invalid-email"); // Invalid format
        application.setDateOfBirth(LocalDate.of(2010, 1, 1)); // Too young
        application.setRequestedAmount(new BigDecimal("100")); // Below minimum
        application.setAnnualIncome(new BigDecimal("20000"));
        application.setCreditScore(500); // Below minimum
        application.setTermInMonths(12);
        application.setExistingDebt(BigDecimal.ZERO);
        application.setEmploymentStatus(LoanApplication.EmploymentStatus.UNEMPLOYED); // Not acceptable
        application.setMonthsEmployed(0);

        ValidationResult result = validationChain.validate(application);

        assertThat(result.isValid()).isFalse();
        assertThat(result.getErrors().size()).isGreaterThan(3);

        // Check specific errors
        assertThat(result.getErrors())
            .extracting(ValidationError::field)
            .contains("email", "dateOfBirth", "requestedAmount", "creditScore", "employmentStatus");
    }

    @Test
    @DisplayName("Should stop chain when critical error occurs")
    void testStopOnCriticalError() {
        LoanApplication application = createValidApplication();

        when(riskService.isInFraudDatabase(anyString())).thenReturn(true);

        ValidationResult result = validationChain.validate(application);

        assertThat(result.isValid()).isFalse();
        assertThat(result.getErrors()).hasSize(1);
        assertThat(result.getErrors().get(0).severity())
            .isEqualTo(ValidationError.ErrorSeverity.CRITICAL);
    }

    private LoanApplication createValidApplication() {
        LoanApplication application = new LoanApplication();
        application.setApplicantId("APP-001");
        application.setApplicantName("John Doe");
        application.setEmail("john@example.com");
        application.setDateOfBirth(LocalDate.of(1985, 5, 15));
        application.setAnnualIncome(new BigDecimal("80000"));
        application.setCreditScore(720);
        application.setRequestedAmount(new BigDecimal("50000"));
        application.setTermInMonths(60);
        application.setPurpose("Home improvement");
        application.setExistingDebt(new BigDecimal("500"));
        application.setEmploymentStatus(LoanApplication.EmploymentStatus.EMPLOYED);
        application.setMonthsEmployed(36);
        return application;
    }
}
```

---

## 🎨 VARIACIONES DEL PATRÓN

### Variación 1: Chain con Logging

```java
public abstract class LoggingValidator<T> extends Validator<T> {

    private static final Logger logger = LoggerFactory.getLogger(LoggingValidator.class);

    @Override
    public final ValidationResult validate(T request) {
        String validatorName = getValidatorName();
        logger.info("Starting validation: {}", validatorName);

        long startTime = System.currentTimeMillis();
        ValidationResult result = super.validate(request);
        long duration = System.currentTimeMillis() - startTime;

        if (result.isValid()) {
            logger.info("Validation passed: {} ({}ms)", validatorName, duration);
        } else {
            logger.warn("Validation failed: {} with {} errors ({}ms)",
                validatorName, result.getErrors().size(), duration);
        }

        return result;
    }
}
```

### Variación 2: Chain Asíncrono

```java
public abstract class AsyncValidator<T> {

    protected AsyncValidator<T> next;

    public AsyncValidator<T> setNext(AsyncValidator<T> next) {
        this.next = next;
        return next;
    }

    public CompletableFuture<ValidationResult> validate(T request) {
        return doValidateAsync(request)
            .thenCompose(result -> {
                if (!result.isValid() && stopOnFailure()) {
                    return CompletableFuture.completedFuture(result);
                }

                if (next != null) {
                    return next.validate(request)
                        .thenApply(nextResult -> result.and(nextResult));
                }

                return CompletableFuture.completedFuture(result);
            });
    }

    protected abstract CompletableFuture<ValidationResult> doValidateAsync(T request);

    protected boolean stopOnFailure() {
        return false;
    }
}
```

### Variación 3: Chain con Contexto Compartido

```java
public class ValidationContext {
    private final Map<String, Object> data = new HashMap<>();

    public void put(String key, Object value) {
        data.put(key, value);
    }

    public <T> T get(String key, Class<T> type) {
        return type.cast(data.get(key));
    }
}

public abstract class ContextAwareValidator<T> extends Validator<T> {

    @Override
    public final ValidationResult validate(T request) {
        return validate(request, new ValidationContext());
    }

    public final ValidationResult validate(T request, ValidationContext context) {
        ValidationResult result = doValidate(request, context);

        if (!result.isValid() && stopOnFailure()) {
            return result;
        }

        if (next != null && next instanceof ContextAwareValidator) {
            ValidationResult nextResult = ((ContextAwareValidator<T>) next).validate(request, context);
            return result.and(nextResult);
        }

        return result;
    }

    protected abstract ValidationResult doValidate(T request, ValidationContext context);
}
```

---

## 📊 COMPARACIÓN CON OTROS PATRONES

| Aspecto                  | Chain of Responsibility    | Strategy                 | Command                |
| ------------------------ | -------------------------- | ------------------------ | ---------------------- |
| **Propósito**            | Procesar request en cadena | Algoritmo intercambiable | Encapsular operación   |
| **Número de handlers**   | Múltiples en secuencia     | Uno a la vez             | Uno por comando        |
| **Decisión de procesar** | Cada handler decide        | Cliente decide           | Invoker decide         |
| **Uso típico**           | Validación multinivel      | Cálculos alternativos    | Acciones/transacciones |
| **Flexibilidad**         | Alta (orden dinámico)      | Media                    | Media                  |

---

## ✅ BEST PRACTICES

### ✅ DO

1. **Usa validadores específicos y cohesivos**

```java
// ✅ Good: Single responsibility
class EmailFormatValidator extends Validator<User> { }
class AgeValidator extends Validator<User> { }

// ❌ Bad: Multiple responsibilities
class UserValidator extends Validator<User> {
    // Validates email, age, address, etc.
}
```

2. **Implementa stopOnFailure() apropiadamente**

```java
// ✅ Good: Stop on critical errors
class SecurityValidator extends Validator<Request> {
    @Override
    protected boolean stopOnFailure() {
        return true; // Security issues are critical
    }
}
```

3. **Usa builders para cadenas complejas**

```java
// ✅ Good: Readable and maintainable
ValidationChain.create()
    .add(new Step1())
    .add(new Step2())
    .add(new Step3())
    .validate(request);
```

4. **Retorna información útil en errores**

```java
// ✅ Good: Descriptive error
new ValidationError("creditScore", "Credit score (580) is below minimum required (620)");

// ❌ Bad: Vague error
new ValidationError("Invalid");
```

### ❌ DON'T

1. **No modifiques el request en validadores**

```java
// ❌ Bad: Side effect
@Override
protected ValidationResult doValidate(User user) {
    user.setEmail(user.getEmail().toLowerCase()); // DONT MODIFY!
    return ValidationResult.success();
}
```

2. **No ignores el orden de validadores**

```java
// ❌ Bad: RiskValidator before RequiredFieldsValidator
chain.add(new RiskAssessmentValidator()) // Might fail if fields are null
     .add(new RequiredFieldsValidator());

// ✅ Good: Basic validations first
chain.add(new RequiredFieldsValidator())
     .add(new RiskAssessmentValidator());
```

3. **No crees cadenas infinitas**

```java
// ❌ Bad: Circular reference
Validator v1 = new Validator1();
Validator v2 = new Validator2();
v1.setNext(v2);
v2.setNext(v1); // INFINITE LOOP!
```

---

## 🎯 CASOS DE USO ADICIONALES

1. **Validación de Formularios Web**
2. **Autenticación/Autorización Multinivel**
3. **Procesamiento de Pagos (fraud check → limit check → balance check)**
4. **Aprobación de Documentos (múltiples niveles de approval)**
5. **Sanitización de Inputs (XSS → SQL Injection → Format validation)**
6. **Pipeline CI/CD (lint → test → security scan → deploy)**

---

**💡 RECUERDA:** Chain of Responsibility permite construir pipelines de validación flexibles y extensibles. Cada validador debe tener una única responsabilidad y el orden de la cadena importa. Usa `stopOnFailure()` para controlar el flujo cuando sea necesario.
