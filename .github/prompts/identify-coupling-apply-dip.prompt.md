---
description: "Identificar acoplamiento innecesario y aplicar Dependency Inversion Principle (DIP) para desacoplar código"
agent: agent
---

# 🔌 DEPENDENCY INVERSION & DECOUPLING ANALYZER

Actúa como **arquitecto de software especializado en desacoplamiento, DIP (Dependency Inversion Principle) e inversión de control**.

Tu misión es **identificar acoplamiento innecesario y refactorizar aplicando DIP** para lograr:

- ✅ Bajo acoplamiento entre módulos
- ✅ Alta cohesión dentro de módulos
- ✅ Dependencias hacia abstracciones, no implementaciones
- ✅ Facilidad de testing (mocking)
- ✅ Flexibilidad para cambiar implementaciones
- ✅ Cumplimiento del principio DIP

---

## 🎯 DEPENDENCY INVERSION PRINCIPLE (DIP)

> **"Los módulos de alto nivel no deben depender de módulos de bajo nivel. Ambos deben depender de abstracciones."**
>
> **"Las abstracciones no deben depender de los detalles. Los detalles deben depender de las abstracciones."**

### Principio Fundamental

```java
// ❌ VIOLACIÓN DIP: Alto nivel depende de bajo nivel
public class OrderService {                    // Alto nivel
    private MySQLOrderRepository repository;   // ❌ Bajo nivel CONCRETO

    public OrderService() {
        this.repository = new MySQLOrderRepository(); // ❌ Instanciación directa
    }

    public void createOrder(Order order) {
        repository.save(order);
    }
}

// ✅ CUMPLE DIP: Ambos dependen de abstracción
public interface OrderRepository {            // Abstracción
    void save(Order order);
}

public class OrderService {                   // Alto nivel
    private final OrderRepository repository; // ✅ Depende de ABSTRACCIÓN

    public OrderService(OrderRepository repository) {
        this.repository = repository;         // ✅ Inyección de dependencia
    }

    public void createOrder(Order order) {
        repository.save(order);
    }
}

public class MySQLOrderRepository implements OrderRepository { // Bajo nivel
    @Override
    public void save(Order order) {
        // Implementación específica de MySQL
    }
}
```

---

## 🔍 TIPOS DE ACOPLAMIENTO A IDENTIFICAR

### 1️⃣ **Acoplamiento de Implementación (Tight Coupling)**

```java
// ❌ PROBLEMA: Dependencia directa de implementación concreta
@Service
public class PaymentProcessor {

    // Acoplamiento directo a implementaciones concretas
    private StripePaymentGateway stripeGateway = new StripePaymentGateway();
    private SMTPEmailService emailService = new SMTPEmailService();
    private MySQLAuditLogger auditLogger = new MySQLAuditLogger();

    public PaymentResult processPayment(Payment payment) {
        // Imposible cambiar implementación sin modificar esta clase
        stripeGateway.charge(payment);
        emailService.sendConfirmation(payment.getCustomerEmail());
        auditLogger.log("Payment processed: " + payment.getId());

        return new PaymentResult(PaymentStatus.SUCCESS);
    }
}

// ✅ SOLUCIÓN: Dependencia de abstracciones + Inyección
public interface PaymentGateway {
    PaymentResult charge(Payment payment);
}

public interface EmailService {
    void sendConfirmation(String email);
}

public interface AuditLogger {
    void log(String message);
}

@Service
public class PaymentProcessor {

    private final PaymentGateway paymentGateway;
    private final EmailService emailService;
    private final AuditLogger auditLogger;

    // Constructor injection
    public PaymentProcessor(
            PaymentGateway paymentGateway,
            EmailService emailService,
            AuditLogger auditLogger) {
        this.paymentGateway = paymentGateway;
        this.emailService = emailService;
        this.auditLogger = auditLogger;
    }

    public PaymentResult processPayment(Payment payment) {
        PaymentResult result = paymentGateway.charge(payment);
        emailService.sendConfirmation(payment.getCustomerEmail());
        auditLogger.log("Payment processed: " + payment.getId());
        return result;
    }
}

// Implementaciones
@Component
public class StripePaymentGateway implements PaymentGateway {
    @Override
    public PaymentResult charge(Payment payment) {
        // Stripe implementation
    }
}

@Component
public class SMTPEmailService implements EmailService {
    @Override
    public void sendConfirmation(String email) {
        // SMTP implementation
    }
}
```

### 2️⃣ **Acoplamiento a Frameworks Externos**

```java
// ❌ PROBLEMA: Lógica de negocio acoplada a framework
@RestController
@RequestMapping("/api/orders")
public class OrderController {

    @Autowired
    private OrderRepository orderRepository;

    @PostMapping
    public ResponseEntity<Order> createOrder(@RequestBody OrderRequest request) {
        // ❌ Lógica de negocio en el controller
        Order order = new Order();
        order.setCustomerId(request.getCustomerId());
        order.setAmount(request.getAmount());

        // ❌ Validación en controller
        if (order.getAmount() <= 0) {
            return ResponseEntity.badRequest().build();
        }

        // ❌ Acceso directo a repositorio desde controller
        Order saved = orderRepository.save(order);

        // ❌ Lógica de negocio adicional
        if (saved.getAmount() > 10000) {
            // Enviar notificación
        }

        return ResponseEntity.ok(saved);
    }
}

// ✅ SOLUCIÓN: Separar capas con abstracciones
// Domain Layer (sin dependencias de framework)
public class Order {
    private String id;
    private String customerId;
    private BigDecimal amount;
    private OrderStatus status;

    // Domain logic
    public void validate() {
        if (amount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new InvalidOrderException("Amount must be positive");
        }
    }

    public boolean isHighValue() {
        return amount.compareTo(new BigDecimal("10000")) > 0;
    }
}

// Application Layer
public interface OrderService {
    Order createOrder(CreateOrderCommand command);
}

@Service
public class OrderServiceImpl implements OrderService {

    private final OrderRepository orderRepository;
    private final NotificationService notificationService;

    public OrderServiceImpl(
            OrderRepository orderRepository,
            NotificationService notificationService) {
        this.orderRepository = orderRepository;
        this.notificationService = notificationService;
    }

    @Override
    public Order createOrder(CreateOrderCommand command) {
        Order order = new Order(
            command.customerId(),
            command.amount()
        );

        order.validate();

        Order saved = orderRepository.save(order);

        if (saved.isHighValue()) {
            notificationService.notifyHighValueOrder(saved);
        }

        return saved;
    }
}

// Presentation Layer (delgado, solo coordina)
@RestController
@RequestMapping("/api/orders")
public class OrderController {

    private final OrderService orderService;

    public OrderController(OrderService orderService) {
        this.orderService = orderService;
    }

    @PostMapping
    public ResponseEntity<OrderDto> createOrder(@RequestBody OrderRequest request) {
        CreateOrderCommand command = new CreateOrderCommand(
            request.getCustomerId(),
            request.getAmount()
        );

        Order order = orderService.createOrder(command);

        return ResponseEntity.ok(OrderDto.fromDomain(order));
    }
}
```

### 3️⃣ **Acoplamiento de Configuración**

```java
// ❌ PROBLEMA: Configuración hardcodeada
@Service
public class NotificationService {

    private final String smtpHost = "smtp.gmail.com";      // ❌ Hardcoded
    private final int smtpPort = 587;                      // ❌ Hardcoded
    private final String apiKey = "sk_live_abc123";        // ❌ Hardcoded

    public void sendEmail(String to, String subject, String body) {
        // Usar configuración hardcodeada
    }
}

// ✅ SOLUCIÓN: Inyectar configuración
@ConfigurationProperties(prefix = "notification")
public class NotificationConfig {
    private String smtpHost;
    private int smtpPort;
    private String apiKey;

    // Getters y setters
}

@Service
public class NotificationService {

    private final NotificationConfig config;

    public NotificationService(NotificationConfig config) {
        this.config = config;
    }

    public void sendEmail(String to, String subject, String body) {
        // Usar config.getSmtpHost(), config.getSmtpPort(), etc.
    }
}

// application.yml
// notification:
//   smtpHost: smtp.gmail.com
//   smtpPort: 587
//   apiKey: ${NOTIFICATION_API_KEY}
```

### 4️⃣ **Acoplamiento Temporal (Constructor Bloat)**

```java
// ❌ PROBLEMA: Constructor con muchas dependencias
@Service
public class OrderProcessingService {

    private final OrderRepository orderRepository;
    private final CustomerRepository customerRepository;
    private final ProductRepository productRepository;
    private final InventoryService inventoryService;
    private final PricingService pricingService;
    private final TaxCalculator taxCalculator;
    private final ShippingService shippingService;
    private final PaymentService paymentService;
    private final NotificationService notificationService;
    private final AuditLogger auditLogger;

    public OrderProcessingService(
            OrderRepository orderRepository,
            CustomerRepository customerRepository,
            ProductRepository productRepository,
            InventoryService inventoryService,
            PricingService pricingService,
            TaxCalculator taxCalculator,
            ShippingService shippingService,
            PaymentService paymentService,
            NotificationService notificationService,
            AuditLogger auditLogger) {
        // ❌ 10 dependencias = señal de SRP violation
        this.orderRepository = orderRepository;
        this.customerRepository = customerRepository;
        this.productRepository = productRepository;
        this.inventoryService = inventoryService;
        this.pricingService = pricingService;
        this.taxCalculator = taxCalculator;
        this.shippingService = shippingService;
        this.paymentService = paymentService;
        this.notificationService = notificationService;
        this.auditLogger = auditLogger;
    }
}

// ✅ SOLUCIÓN: Aplicar SRP + Facade Pattern
// Separar responsabilidades
@Service
public class OrderValidationService {
    private final OrderRepository orderRepository;
    private final CustomerRepository customerRepository;
    private final ProductRepository productRepository;

    // Constructor con 3 dependencias relacionadas
}

@Service
public class OrderPricingService {
    private final PricingService pricingService;
    private final TaxCalculator taxCalculator;

    // Constructor con 2 dependencias relacionadas
}

@Service
public class OrderFulfillmentService {
    private final InventoryService inventoryService;
    private final ShippingService shippingService;

    // Constructor con 2 dependencias relacionadas
}

// Facade para coordinar
@Service
public class OrderProcessingService {

    private final OrderValidationService validationService;
    private final OrderPricingService pricingService;
    private final OrderFulfillmentService fulfillmentService;
    private final PaymentService paymentService;
    private final NotificationService notificationService;

    // 5 dependencias de alto nivel (aceptable)
    public OrderProcessingService(
            OrderValidationService validationService,
            OrderPricingService pricingService,
            OrderFulfillmentService fulfillmentService,
            PaymentService paymentService,
            NotificationService notificationService) {
        this.validationService = validationService;
        this.pricingService = pricingService;
        this.fulfillmentService = fulfillmentService;
        this.paymentService = paymentService;
        this.notificationService = notificationService;
    }
}
```

### 5️⃣ **Acoplamiento a Detalles de Persistencia**

```java
// ❌ PROBLEMA: Lógica de negocio acoplada a JPA
@Service
public class UserService {

    @Autowired
    private EntityManager entityManager; // ❌ JPA en lógica de negocio

    public User updateUserStatus(String userId, UserStatus newStatus) {
        // ❌ Queries JPQL en servicio de negocio
        User user = entityManager
            .createQuery("SELECT u FROM User u WHERE u.id = :id", User.class)
            .setParameter("id", userId)
            .getSingleResult();

        user.setStatus(newStatus);

        entityManager.persist(user); // ❌ API de JPA expuesta
        entityManager.flush();

        return user;
    }
}

// ✅ SOLUCIÓN: Abstraer persistencia con Repository
public interface UserRepository {
    Optional<User> findById(String userId);
    User save(User user);
}

@Service
public class UserService {

    private final UserRepository userRepository;

    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public User updateUserStatus(String userId, UserStatus newStatus) {
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new UserNotFoundException(userId));

        user.updateStatus(newStatus); // Domain logic

        return userRepository.save(user);
    }
}

// Infrastructure Layer
@Repository
public class JpaUserRepository implements UserRepository {

    @PersistenceContext
    private EntityManager entityManager;

    @Override
    public Optional<User> findById(String userId) {
        // Detalles de JPA encapsulados
        try {
            User user = entityManager.find(User.class, userId);
            return Optional.ofNullable(user);
        } catch (Exception e) {
            return Optional.empty();
        }
    }

    @Override
    public User save(User user) {
        return entityManager.merge(user);
    }
}
```

### 6️⃣ **Acoplamiento por Herencia (Favor Composition)**

```java
// ❌ PROBLEMA: Herencia crea acoplamiento fuerte
public class FileLogger {
    public void log(String message) {
        // Write to file
    }

    public void rotate() {
        // Rotate log files
    }
}

public class EmailLogger extends FileLogger {
    @Override
    public void log(String message) {
        super.log(message);      // ❌ Acoplado a implementación padre
        sendEmail(message);      // Y también hace logging por email
    }

    private void sendEmail(String message) {
        // Send email
    }
}

// Problemas:
// - EmailLogger está acoplado a FileLogger
// - Hereda método rotate() que no necesita
// - Difícil de testear (debe mockear padre)
// - Violación de LSP si EmailLogger no puede reemplazar FileLogger

// ✅ SOLUCIÓN: Composición sobre herencia
public interface Logger {
    void log(String message);
}

public class FileLogger implements Logger {
    @Override
    public void log(String message) {
        // Write to file
    }

    public void rotate() {
        // Rotate log files
    }
}

public class EmailLogger implements Logger {
    @Override
    public void log(String message) {
        // Send email
    }
}

// Composite Logger para combinar
public class CompositeLogger implements Logger {

    private final List<Logger> loggers;

    public CompositeLogger(Logger... loggers) {
        this.loggers = Arrays.asList(loggers);
    }

    @Override
    public void log(String message) {
        loggers.forEach(logger -> logger.log(message));
    }
}

// Uso
Logger logger = new CompositeLogger(
    new FileLogger(),
    new EmailLogger()
);
```

### 7️⃣ **Acoplamiento por Static Methods**

```java
// ❌ PROBLEMA: Métodos estáticos imposibles de mockear
public class OrderService {

    public void processOrder(Order order) {
        // ❌ Llamada estática - no se puede mockear en tests
        double tax = TaxCalculator.calculateTax(order.getAmount(), order.getRegion());

        // ❌ Singleton pattern antiguo
        PaymentGateway gateway = PaymentGateway.getInstance();
        gateway.processPayment(order);

        // ❌ Utility estático
        String formatted = DateUtils.formatDate(order.getCreatedAt());
    }
}

// ✅ SOLUCIÓN: Inyectar como dependencias
public interface TaxCalculator {
    double calculateTax(BigDecimal amount, String region);
}

@Service
public class TaxCalculatorImpl implements TaxCalculator {
    @Override
    public double calculateTax(BigDecimal amount, String region) {
        // Implementation
    }
}

@Service
public class OrderService {

    private final TaxCalculator taxCalculator;
    private final PaymentGateway paymentGateway;
    private final DateFormatter dateFormatter;

    public OrderService(
            TaxCalculator taxCalculator,
            PaymentGateway paymentGateway,
            DateFormatter dateFormatter) {
        this.taxCalculator = taxCalculator;
        this.paymentGateway = paymentGateway;
        this.dateFormatter = dateFormatter;
    }

    public void processOrder(Order order) {
        // Ahora todo es mockeable
        double tax = taxCalculator.calculateTax(order.getAmount(), order.getRegion());
        paymentGateway.processPayment(order);
        String formatted = dateFormatter.format(order.getCreatedAt());
    }
}
```

---

## 📊 MÉTRICAS DE ACOPLAMIENTO

### Cómo Medir Acoplamiento

```java
// Métricas a analizar:

// 1. Afferent Coupling (Ca) - Cuántas clases dependen de esta
// 2. Efferent Coupling (Ce) - De cuántas clases depende esta
// 3. Instability (I) = Ce / (Ca + Ce)
//    - I = 0: Completamente estable (muchas dependencias hacia ella)
//    - I = 1: Completamente inestable (muchas dependencias hacia afuera)

// Objetivo: Alto nivel (services) debe tener I bajo
//           Bajo nivel (infrastructure) puede tener I alto
```

### Señales de Alto Acoplamiento

```
❌ SEÑALES DE ALERTA:

1. **Constructor con >5 dependencias**
   → Violación de SRP, dividir clase

2. **Uso de 'new' en lógica de negocio**
   → Inyectar dependencias

3. **Imports de packages de infraestructura en dominio**
   → Invertir dependencia

4. **Métodos estáticos para lógica de negocio**
   → Convertir en servicio inyectable

5. **try-catch de excepciones específicas de frameworks**
   → Abstraer detrás de interfaces

6. **Herencia profunda (>2 niveles)**
   → Usar composición

7. **Dependencias transitivas**
   → Explicitar dependencias directas

8. **Tests que requieren muchos mocks**
   → Simplificar dependencias
```

---

## 🎯 ESTRATEGIA DE DESACOPLAMIENTO

### Paso 1: Análisis de Dependencias

```
1. list_dir → Explorar estructura de paquetes
2. file_search → Buscar clases con muchas dependencias
3. grep_search → Buscar 'new', 'static', '@Autowired'
4. read_file → Analizar dependencias específicas
5. list_code_usages → Ver impacto de cambios
```

### Paso 2: Identificar Violaciones DIP

**Patterns a buscar:**

```java
// ❌ Violaciones comunes:
- new ConcreteClass()
- ConcreteClass variable
- import com.framework.specific.*
- extends ConcreteClass
- static methods for business logic
- @Autowired private (field injection)
```

### Paso 3: Aplicar Refactorización

**Orden recomendado:**

1. ✅ Extraer interfaces de clases acopladas
2. ✅ Aplicar constructor injection
3. ✅ Mover lógica de negocio a dominio
4. ✅ Introducir abstracciones donde haga falta
5. ✅ Eliminar dependencias circulares
6. ✅ Aplicar Dependency Inversion

### Paso 4: Validación

**Checklist:**

- [ ] ✅ Constructores con ≤5 dependencias
- [ ] ✅ Sin uso de 'new' en lógica de negocio
- [ ] ✅ Dependencias hacia interfaces, no clases
- [ ] ✅ Dominio sin imports de infraestructura
- [ ] ✅ Tests sin dependencias de frameworks
- [ ] ✅ Fácil mockear en tests

---

## 📋 FORMATO DE SALIDA

Para cada análisis proporciona:

### 1. Análisis de Acoplamiento

```
**Acoplamiento Identificado:**

Clase: `OrderService`
- ❌ Ce (Efferent Coupling): 8 dependencias
- ❌ 3 dependencias concretas: MySQLRepository, StripeGateway, SMTPEmail
- ❌ 2 instanciaciones con 'new'
- ❌ 1 llamada a método estático
- ❌ Lógica de negocio acoplada a JPA

**Violaciones DIP:**
1. Depende de MySQLOrderRepository (implementación concreta)
2. Instancia directamente EmailService con 'new'
3. Usa EntityManager (JPA) en lógica de negocio

**Impacto:**
- 🔴 Imposible testear sin base de datos
- 🔴 Imposible cambiar proveedor de email
- 🔴 Acoplado a framework de persistencia
```

### 2. Plan de Desacoplamiento

```
**Estrategia:**

1. **Extraer Interfaces:**
   - OrderRepository interface
   - EmailService interface
   - PaymentGateway interface

2. **Aplicar Constructor Injection:**
   - Inyectar dependencias en constructor
   - Usar final para inmutabilidad

3. **Mover Lógica:**
   - Validación → Order domain entity
   - Cálculos → Services específicos
   - Persistencia → Repository implementations

4. **Eliminar Acoplamiento:**
   - Reemplazar 'new' por dependency injection
   - Extraer métodos estáticos a servicios
   - Encapsular detalles de JPA en repositories
```

### 3. Código Refactorizado

```java
// ❌ ANTES: Alto acoplamiento
public class OrderService {
    private MySQLOrderRepository repository = new MySQLOrderRepository();
    private EmailService emailService = new EmailService();

    public void createOrder(Order order) {
        repository.save(order);
        emailService.send(order.getCustomerEmail());
    }
}

// ✅ DESPUÉS: Bajo acoplamiento (DIP aplicado)
// 1. Interfaces (abstracciones)
public interface OrderRepository {
    void save(Order order);
}

public interface EmailService {
    void send(String email);
}

// 2. Servicio desacoplado
@Service
public class OrderService {

    private final OrderRepository orderRepository;
    private final EmailService emailService;

    public OrderService(
            OrderRepository orderRepository,
            EmailService emailService) {
        this.orderRepository = orderRepository;
        this.emailService = emailService;
    }

    public void createOrder(Order order) {
        orderRepository.save(order);
        emailService.send(order.getCustomerEmail());
    }
}

// 3. Implementaciones (bajo nivel)
@Repository
public class MySQLOrderRepository implements OrderRepository {
    @Override
    public void save(Order order) {
        // MySQL specific implementation
    }
}

@Service
public class SMTPEmailService implements EmailService {
    @Override
    public void send(String email) {
        // SMTP specific implementation
    }
}
```

### 4. Beneficios Obtenidos

```
**Mejoras:**

**Acoplamiento:**
- ✅ Ce (Efferent Coupling): 8 → 3 (reducción 62%)
- ✅ Dependencias concretas: 3 → 0
- ✅ Instability (I): 0.89 → 0.45 (más estable)

**Testabilidad:**
- ✅ Fácil mockear dependencias
- ✅ Tests unitarios sin base de datos
- ✅ Coverage: 45% → 85%

**Flexibilidad:**
- ✅ Cambiar MySQL → PostgreSQL: 1 clase
- ✅ Cambiar SMTP → SendGrid: 1 clase
- ✅ Sin recompilar OrderService

**Mantenibilidad:**
- ✅ Responsabilidades claras
- ✅ Violaciones DIP: 3 → 0
- ✅ Principio Open/Closed cumplido
```

### 5. Diagrama de Dependencias

```
ANTES:
┌─────────────────┐
│  OrderService   │ (Alto nivel)
│                 │
│  - MySQLRepo    │ ─┐
│  - StripeGW     │ ─┼─→ ❌ Depende de bajo nivel
│  - SMTPEmail    │ ─┘
└─────────────────┘

DESPUÉS:
┌─────────────────┐
│  OrderService   │ (Alto nivel)
│                 │
│  - OrderRepo ◄──┼────────┐
│  - PaymentGW ◄──┼───┐    │
│  - EmailSvc  ◄──┼─┐ │    │
└─────────────────┘ │ │    │
                    │ │    │
     ┌──────────────┘ │    │
     │  ┌─────────────┘    │
     ▼  ▼                  ▼
┌─────────┐  ┌─────────┐  ┌──────────┐
│ Stripe  │  │  SMTP   │  │  MySQL   │ (Bajo nivel)
│ Gateway │  │ Email   │  │   Repo   │
└─────────┘  └─────────┘  └──────────┘

✅ Ambos niveles dependen de abstracciones
```

---

## 🎯 PATRONES DE DESACOPLAMIENTO

### Adapter Pattern

```java
// Adaptar API externa a nuestra abstracción
public interface PaymentGateway {
    PaymentResult process(Payment payment);
}

public class StripeAdapter implements PaymentGateway {
    private final StripeAPI stripeAPI; // Librería externa

    @Override
    public PaymentResult process(Payment payment) {
        StripeCharge charge = stripeAPI.charge(
            payment.getAmount(),
            payment.getCurrency()
        );
        return new PaymentResult(charge.getId(), charge.getStatus());
    }
}
```

### Repository Pattern

```java
// Abstraer persistencia
public interface UserRepository {
    Optional<User> findById(String id);
    List<User> findAll();
    User save(User user);
    void delete(String id);
}
```

### Strategy Pattern

```java
// Intercambiar algoritmos
public interface PricingStrategy {
    BigDecimal calculatePrice(Order order);
}

public class OrderService {
    private final PricingStrategy pricingStrategy;

    // Estrategia inyectada, fácil cambiar
}
```

### Factory Pattern

```java
// Abstraer creación de objetos
public interface ReportFactory {
    Report createReport(ReportType type);
}
```

---

## ⚠️ ADVERTENCIAS

### No Sobre-abstraer

```java
// ❌ Abstracción innecesaria
public interface StringWrapper {
    String getValue();
}

// ✅ Usar String directamente
```

### No Interfaces de 1 Método Sin Razón

```java
// ❌ Sin beneficio real
public interface UserIdProvider {
    String getUserId();
}

// ✅ Solo si hay múltiples implementaciones o testing
```

### Equilibrio entre Flexibilidad y Complejidad

- No crear interfaces "por si acaso"
- Aplicar DIP cuando hay acoplamiento real
- YAGNI (You Aren't Gonna Need It)

---

## 🎯 CHECKLIST DE DESACOPLAMIENTO

- [ ] ✅ Dependencias hacia abstracciones (interfaces)
- [ ] ✅ Constructor injection (no field injection)
- [ ] ✅ Sin 'new' en lógica de negocio
- [ ] ✅ Sin métodos estáticos para lógica
- [ ] ✅ Dominio sin dependencias de frameworks
- [ ] ✅ Máximo 5 dependencias por constructor
- [ ] ✅ Sin dependencias circulares
- [ ] ✅ Tests fáciles de escribir (mockeable)
- [ ] ✅ Composición sobre herencia
- [ ] ✅ Segregación de interfaces (ISP)

---

**💡 RECUERDA:** El desacoplamiento debe tener un propósito. No abstraigas prematuramente. Refactoriza hacia abstracciones cuando haya necesidad real de flexibilidad o testing.
