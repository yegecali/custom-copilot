---
agent: agent
---

# Decorator Pattern para Agregar Funcionalidad a Servicios en Runtime

## Descripción

Implementa el patrón Decorator para agregar responsabilidades adicionales a objetos de forma dinámica en tiempo de ejecución, proporcionando una alternativa flexible a la herencia para extender funcionalidad.

## Objetivos

- Agregar funcionalidad a servicios sin modificar su código
- Componer comportamientos de forma flexible y dinámica
- Seguir el principio Open/Closed (abierto para extensión, cerrado para modificación)
- Crear decoradores reutilizables y combinables
- Mantener la interfaz del componente decorado

---

## 1. Implementación Básica del Patrón Decorator

### 1.1 Componente Base (Interface)

```java
/**
 * Interfaz base que define el contrato del servicio
 */
public interface NotificationService {
    void send(String recipient, String message);
    NotificationResult getResult();
}
```

### 1.2 Componente Concreto

```java
/**
 * Implementación básica del servicio
 */
public class SimpleNotificationService implements NotificationService {
    private NotificationResult result;

    @Override
    public void send(String recipient, String message) {
        System.out.println("Enviando mensaje a: " + recipient);
        System.out.println("Mensaje: " + message);

        this.result = NotificationResult.builder()
            .success(true)
            .timestamp(Instant.now())
            .recipient(recipient)
            .build();
    }

    @Override
    public NotificationResult getResult() {
        return result;
    }
}
```

### 1.3 Decorador Base Abstracto

```java
/**
 * Decorador base abstracto que implementa la interfaz
 * y delega al componente envuelto
 */
public abstract class NotificationDecorator implements NotificationService {
    protected final NotificationService wrapped;

    protected NotificationDecorator(NotificationService wrapped) {
        this.wrapped = Objects.requireNonNull(wrapped, "Wrapped service cannot be null");
    }

    @Override
    public void send(String recipient, String message) {
        wrapped.send(recipient, message);
    }

    @Override
    public NotificationResult getResult() {
        return wrapped.getResult();
    }
}
```

---

## 2. Decoradores Concretos

### 2.1 Logging Decorator

```java
/**
 * Decorador que agrega logging antes y después de la operación
 */
public class LoggingNotificationDecorator extends NotificationDecorator {
    private static final Logger log = LoggerFactory.getLogger(LoggingNotificationDecorator.class);

    public LoggingNotificationDecorator(NotificationService wrapped) {
        super(wrapped);
    }

    @Override
    public void send(String recipient, String message) {
        log.info("📧 [START] Enviando notificación a: {}", recipient);
        log.debug("Mensaje preview: {}",
            message.length() > 50 ? message.substring(0, 50) + "..." : message);

        long startTime = System.currentTimeMillis();

        try {
            wrapped.send(recipient, message);

            long duration = System.currentTimeMillis() - startTime;
            log.info("✅ [SUCCESS] Notificación enviada en {}ms", duration);

        } catch (Exception e) {
            long duration = System.currentTimeMillis() - startTime;
            log.error("❌ [ERROR] Fallo al enviar notificación después de {}ms", duration, e);
            throw e;
        }
    }
}
```

### 2.2 Retry Decorator

```java
/**
 * Decorador que agrega lógica de reintentos con backoff exponencial
 */
public class RetryNotificationDecorator extends NotificationDecorator {
    private static final Logger log = LoggerFactory.getLogger(RetryNotificationDecorator.class);

    private final int maxRetries;
    private final long initialDelayMs;
    private final double backoffMultiplier;

    public RetryNotificationDecorator(
            NotificationService wrapped,
            int maxRetries,
            long initialDelayMs,
            double backoffMultiplier) {
        super(wrapped);
        this.maxRetries = maxRetries;
        this.initialDelayMs = initialDelayMs;
        this.backoffMultiplier = backoffMultiplier;
    }

    @Override
    public void send(String recipient, String message) {
        int attempt = 0;
        long delay = initialDelayMs;
        Exception lastException = null;

        while (attempt < maxRetries) {
            try {
                if (attempt > 0) {
                    log.info("🔄 Reintento #{} después de {}ms", attempt, delay);
                    Thread.sleep(delay);
                }

                wrapped.send(recipient, message);

                if (attempt > 0) {
                    log.info("✅ Éxito en reintento #{}", attempt);
                }
                return;

            } catch (Exception e) {
                lastException = e;
                attempt++;
                log.warn("❌ Intento #{} falló: {}", attempt, e.getMessage());

                if (attempt < maxRetries) {
                    delay = (long) (delay * backoffMultiplier);
                }
            }
        }

        log.error("💥 Falló después de {} intentos", maxRetries);
        throw new RuntimeException(
            String.format("Failed after %d retries", maxRetries),
            lastException
        );
    }
}
```

### 2.3 Caching Decorator

```java
/**
 * Decorador que cachea resultados para evitar operaciones repetidas
 */
public class CachingNotificationDecorator extends NotificationDecorator {
    private static final Logger log = LoggerFactory.getLogger(CachingNotificationDecorator.class);

    private final Cache<String, NotificationResult> cache;
    private final Duration cacheTtl;

    public CachingNotificationDecorator(
            NotificationService wrapped,
            Duration cacheTtl,
            int maxSize) {
        super(wrapped);
        this.cacheTtl = cacheTtl;
        this.cache = Caffeine.newBuilder()
            .expireAfterWrite(cacheTtl)
            .maximumSize(maxSize)
            .recordStats()
            .build();
    }

    @Override
    public void send(String recipient, String message) {
        String cacheKey = buildCacheKey(recipient, message);

        NotificationResult cached = cache.getIfPresent(cacheKey);
        if (cached != null) {
            log.debug("💾 Cache HIT para: {}", recipient);
            return; // Ya se envió recientemente
        }

        log.debug("⚡ Cache MISS para: {}", recipient);
        wrapped.send(recipient, message);

        cache.put(cacheKey, wrapped.getResult());
    }

    @Override
    public NotificationResult getResult() {
        return wrapped.getResult();
    }

    private String cacheKey(String recipient, String message) {
        return recipient + ":" + message.hashCode();
    }

    public CacheStats getStats() {
        return cache.stats();
    }
}
```

### 2.4 Security/Validation Decorator

```java
/**
 * Decorador que valida y sanitiza inputs antes de enviar
 */
public class SecurityNotificationDecorator extends NotificationDecorator {
    private static final Logger log = LoggerFactory.getLogger(SecurityNotificationDecorator.class);

    private static final Pattern EMAIL_PATTERN =
        Pattern.compile("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$");
    private static final int MAX_MESSAGE_LENGTH = 10000;
    private final Set<String> blockedRecipients;

    public SecurityNotificationDecorator(
            NotificationService wrapped,
            Set<String> blockedRecipients) {
        super(wrapped);
        this.blockedRecipients = new HashSet<>(blockedRecipients);
    }

    @Override
    public void send(String recipient, String message) {
        // Validar recipient
        if (recipient == null || recipient.trim().isEmpty()) {
            throw new IllegalArgumentException("Recipient cannot be null or empty");
        }

        if (!EMAIL_PATTERN.matcher(recipient).matches()) {
            throw new IllegalArgumentException("Invalid email format: " + recipient);
        }

        if (blockedRecipients.contains(recipient.toLowerCase())) {
            log.warn("🚫 Intento de enviar a recipient bloqueado: {}", recipient);
            throw new SecurityException("Recipient is blocked: " + recipient);
        }

        // Validar mensaje
        if (message == null) {
            throw new IllegalArgumentException("Message cannot be null");
        }

        if (message.length() > MAX_MESSAGE_LENGTH) {
            throw new IllegalArgumentException(
                String.format("Message too long: %d (max: %d)",
                    message.length(), MAX_MESSAGE_LENGTH)
            );
        }

        // Sanitizar mensaje (eliminar scripts maliciosos)
        String sanitized = sanitizeMessage(message);

        log.debug("✅ Validación y sanitización completa");
        wrapped.send(recipient, sanitized);
    }

    private String sanitizeMessage(String message) {
        return message
            .replaceAll("<script[^>]*>.*?</script>", "")
            .replaceAll("<iframe[^>]*>.*?</iframe>", "")
            .replaceAll("javascript:", "")
            .trim();
    }
}
```

### 2.5 Metrics/Monitoring Decorator

```java
/**
 * Decorador que registra métricas de uso
 */
public class MetricsNotificationDecorator extends NotificationDecorator {
    private final MeterRegistry meterRegistry;
    private final Counter successCounter;
    private final Counter failureCounter;
    private final Timer executionTimer;

    public MetricsNotificationDecorator(
            NotificationService wrapped,
            MeterRegistry meterRegistry) {
        super(wrapped);
        this.meterRegistry = meterRegistry;

        this.successCounter = Counter.builder("notification.success")
            .description("Successful notifications sent")
            .register(meterRegistry);

        this.failureCounter = Counter.builder("notification.failure")
            .description("Failed notifications")
            .register(meterRegistry);

        this.executionTimer = Timer.builder("notification.duration")
            .description("Notification execution time")
            .register(meterRegistry);
    }

    @Override
    public void send(String recipient, String message) {
        Timer.Sample sample = Timer.start(meterRegistry);

        try {
            wrapped.send(recipient, message);
            successCounter.increment();

        } catch (Exception e) {
            failureCounter.increment();
            throw e;

        } finally {
            sample.stop(executionTimer);
        }
    }
}
```

### 2.6 Async Decorator

```java
/**
 * Decorador que ejecuta el servicio de forma asíncrona
 */
public class AsyncNotificationDecorator extends NotificationDecorator {
    private static final Logger log = LoggerFactory.getLogger(AsyncNotificationDecorator.class);

    private final ExecutorService executor;

    public AsyncNotificationDecorator(NotificationService wrapped, ExecutorService executor) {
        super(wrapped);
        this.executor = executor;
    }

    @Override
    public void send(String recipient, String message) {
        // Fire and forget
        executor.submit(() -> {
            try {
                log.debug("🔄 Ejecutando notificación async para: {}", recipient);
                wrapped.send(recipient, message);
            } catch (Exception e) {
                log.error("Error en notificación async", e);
            }
        });

        log.debug("✅ Notificación encolada para: {}", recipient);
    }

    // Para casos donde necesitas esperar
    public CompletableFuture<Void> sendAsync(String recipient, String message) {
        return CompletableFuture.runAsync(
            () -> wrapped.send(recipient, message),
            executor
        );
    }
}
```

### 2.7 Rate Limiting Decorator

```java
/**
 * Decorador que limita la tasa de llamadas usando sliding window
 */
public class RateLimitingNotificationDecorator extends NotificationDecorator {
    private static final Logger log = LoggerFactory.getLogger(RateLimitingNotificationDecorator.class);

    private final int maxRequestsPerWindow;
    private final Duration windowDuration;
    private final Queue<Instant> requestTimestamps;

    public RateLimitingNotificationDecorator(
            NotificationService wrapped,
            int maxRequestsPerWindow,
            Duration windowDuration) {
        super(wrapped);
        this.maxRequestsPerWindow = maxRequestsPerWindow;
        this.windowDuration = windowDuration;
        this.requestTimestamps = new ConcurrentLinkedQueue<>();
    }

    @Override
    public synchronized void send(String recipient, String message) {
        Instant now = Instant.now();
        Instant windowStart = now.minus(windowDuration);

        // Limpiar timestamps fuera de la ventana
        requestTimestamps.removeIf(timestamp -> timestamp.isBefore(windowStart));

        if (requestTimestamps.size() >= maxRequestsPerWindow) {
            Instant oldestRequest = requestTimestamps.peek();
            Duration waitTime = Duration.between(windowStart, oldestRequest);

            log.warn("🚦 Rate limit alcanzado. Esperar {}ms", waitTime.toMillis());
            throw new RateLimitExceededException(
                String.format("Rate limit exceeded. Wait %dms", waitTime.toMillis())
            );
        }

        requestTimestamps.offer(now);
        wrapped.send(recipient, message);
    }

    public int getCurrentRequestCount() {
        Instant windowStart = Instant.now().minus(windowDuration);
        requestTimestamps.removeIf(timestamp -> timestamp.isBefore(windowStart));
        return requestTimestamps.size();
    }
}
```

---

## 3. Composición de Decoradores

### 3.1 Builder para Composición Fluente

```java
/**
 * Builder fluente para componer decoradores de forma legible
 */
public class NotificationServiceBuilder {
    private NotificationService service;

    private NotificationServiceBuilder(NotificationService baseService) {
        this.service = baseService;
    }

    public static NotificationServiceBuilder create(NotificationService baseService) {
        return new NotificationServiceBuilder(baseService);
    }

    public NotificationServiceBuilder withLogging() {
        service = new LoggingNotificationDecorator(service);
        return this;
    }

    public NotificationServiceBuilder withRetry(int maxRetries, long initialDelayMs) {
        service = new RetryNotificationDecorator(service, maxRetries, initialDelayMs, 2.0);
        return this;
    }

    public NotificationServiceBuilder withCaching(Duration ttl, int maxSize) {
        service = new CachingNotificationDecorator(service, ttl, maxSize);
        return this;
    }

    public NotificationServiceBuilder withSecurity(Set<String> blockedRecipients) {
        service = new SecurityNotificationDecorator(service, blockedRecipients);
        return this;
    }

    public NotificationServiceBuilder withMetrics(MeterRegistry registry) {
        service = new MetricsNotificationDecorator(service, registry);
        return this;
    }

    public NotificationServiceBuilder withAsync(ExecutorService executor) {
        service = new AsyncNotificationDecorator(service, executor);
        return this;
    }

    public NotificationServiceBuilder withRateLimit(int maxRequests, Duration window) {
        service = new RateLimitingNotificationDecorator(service, maxRequests, window);
        return this;
    }

    public NotificationService build() {
        return service;
    }
}
```

### 3.2 Uso del Builder

```java
public class NotificationServiceFactory {

    public static NotificationService createProductionService(
            MeterRegistry meterRegistry,
            ExecutorService executor,
            Set<String> blockedEmails) {

        return NotificationServiceBuilder
            .create(new SimpleNotificationService())
            .withSecurity(blockedEmails)              // 1. Validar primero
            .withCaching(Duration.ofMinutes(5), 1000) // 2. Cachear para evitar duplicados
            .withRateLimit(100, Duration.ofMinutes(1))// 3. Limitar tasa
            .withRetry(3, 100)                        // 4. Reintentar si falla
            .withMetrics(meterRegistry)               // 5. Registrar métricas
            .withLogging()                            // 6. Loggear todo
            .withAsync(executor)                      // 7. Ejecutar async (último)
            .build();
    }

    public static NotificationService createTestService() {
        return NotificationServiceBuilder
            .create(new SimpleNotificationService())
            .withLogging()
            .build();
    }
}
```

---

## 4. Configuración con Spring

### 4.1 Configuración de Beans

```java
@Configuration
public class NotificationConfig {

    @Bean
    @ConditionalOnProperty(name = "notification.async.enabled", havingValue = "true")
    public ExecutorService notificationExecutor(
            @Value("${notification.async.threads:10}") int threads) {
        return Executors.newFixedThreadPool(threads,
            new ThreadFactoryBuilder()
                .setNameFormat("notification-%d")
                .build());
    }

    @Bean
    public NotificationService notificationService(
            MeterRegistry meterRegistry,
            @Value("${notification.cache.ttl:PT5M}") Duration cacheTtl,
            @Value("${notification.cache.maxSize:1000}") int cacheMaxSize,
            @Value("${notification.retry.maxAttempts:3}") int maxRetries,
            @Value("${notification.ratelimit.maxRequests:100}") int maxRequests,
            @Value("${notification.ratelimit.window:PT1M}") Duration rateLimitWindow,
            @Autowired(required = false) ExecutorService executor) {

        NotificationServiceBuilder builder = NotificationServiceBuilder
            .create(new SimpleNotificationService())
            .withSecurity(loadBlockedEmails())
            .withCaching(cacheTtl, cacheMaxSize)
            .withRateLimit(maxRequests, rateLimitWindow)
            .withRetry(maxRetries, 100)
            .withMetrics(meterRegistry)
            .withLogging();

        if (executor != null) {
            builder.withAsync(executor);
        }

        return builder.build();
    }

    private Set<String> loadBlockedEmails() {
        // Cargar desde BD, archivo, etc.
        return Set.of("spam@example.com", "blocked@test.com");
    }
}
```

### 4.2 application.yml

```yaml
notification:
  async:
    enabled: true
    threads: 10
  cache:
    ttl: PT5M # 5 minutos
    maxSize: 1000
  retry:
    maxAttempts: 3
  ratelimit:
    maxRequests: 100
    window: PT1M # 1 minuto
```

---

## 5. Ejemplo Avanzado: Payment Service

### 5.1 Interfaz del Servicio

```java
public interface PaymentService {
    PaymentResult processPayment(PaymentRequest request);
}
```

### 5.2 Implementación Base

```java
public class StripePaymentService implements PaymentService {
    private final StripeClient stripeClient;

    public StripePaymentService(StripeClient stripeClient) {
        this.stripeClient = stripeClient;
    }

    @Override
    public PaymentResult processPayment(PaymentRequest request) {
        ChargeResult charge = stripeClient.charge(
            request.getAmount(),
            request.getCurrency(),
            request.getPaymentMethod()
        );

        return PaymentResult.builder()
            .transactionId(charge.getId())
            .status(charge.getStatus())
            .amount(request.getAmount())
            .timestamp(Instant.now())
            .build();
    }
}
```

### 5.3 Decoradores Específicos

```java
/**
 * Decorador que valida montos antes de procesar
 */
public class AmountValidationPaymentDecorator extends PaymentDecorator {
    private final BigDecimal minAmount;
    private final BigDecimal maxAmount;

    public AmountValidationPaymentDecorator(
            PaymentService wrapped,
            BigDecimal minAmount,
            BigDecimal maxAmount) {
        super(wrapped);
        this.minAmount = minAmount;
        this.maxAmount = maxAmount;
    }

    @Override
    public PaymentResult processPayment(PaymentRequest request) {
        BigDecimal amount = request.getAmount();

        if (amount.compareTo(minAmount) < 0) {
            throw new InvalidAmountException(
                String.format("Amount %s below minimum %s", amount, minAmount)
            );
        }

        if (amount.compareTo(maxAmount) > 0) {
            throw new InvalidAmountException(
                String.format("Amount %s exceeds maximum %s", amount, maxAmount)
            );
        }

        return wrapped.processPayment(request);
    }
}

/**
 * Decorador que detecta fraude antes de procesar
 */
public class FraudDetectionPaymentDecorator extends PaymentDecorator {
    private final FraudDetectionService fraudService;

    public FraudDetectionPaymentDecorator(
            PaymentService wrapped,
            FraudDetectionService fraudService) {
        super(wrapped);
        this.fraudService = fraudService;
    }

    @Override
    public PaymentResult processPayment(PaymentRequest request) {
        FraudScore score = fraudService.evaluate(request);

        if (score.getRisk() == RiskLevel.HIGH) {
            throw new FraudDetectedException(
                String.format("High fraud risk: %.2f", score.getScore())
            );
        }

        if (score.getRisk() == RiskLevel.MEDIUM) {
            // Requerir verificación adicional (MFA, etc.)
            request.setRequireAdditionalVerification(true);
        }

        return wrapped.processPayment(request);
    }
}

/**
 * Decorador que guarda auditoría de todas las transacciones
 */
public class AuditPaymentDecorator extends PaymentDecorator {
    private final AuditRepository auditRepository;

    public AuditPaymentDecorator(
            PaymentService wrapped,
            AuditRepository auditRepository) {
        super(wrapped);
        this.auditRepository = auditRepository;
    }

    @Override
    public PaymentResult processPayment(PaymentRequest request) {
        AuditLog auditLog = AuditLog.builder()
            .timestamp(Instant.now())
            .userId(request.getUserId())
            .action("PAYMENT_INITIATED")
            .amount(request.getAmount())
            .currency(request.getCurrency())
            .build();

        try {
            PaymentResult result = wrapped.processPayment(request);

            auditLog.setStatus("SUCCESS");
            auditLog.setTransactionId(result.getTransactionId());
            auditRepository.save(auditLog);

            return result;

        } catch (Exception e) {
            auditLog.setStatus("FAILED");
            auditLog.setErrorMessage(e.getMessage());
            auditRepository.save(auditLog);
            throw e;
        }
    }
}
```

### 5.4 Composición del Payment Service

```java
@Configuration
public class PaymentConfig {

    @Bean
    public PaymentService paymentService(
            StripeClient stripeClient,
            FraudDetectionService fraudService,
            AuditRepository auditRepository,
            MeterRegistry meterRegistry) {

        PaymentService base = new StripePaymentService(stripeClient);

        return new PaymentServiceBuilder(base)
            .withAmountValidation(
                new BigDecimal("1.00"),      // min: $1
                new BigDecimal("100000.00")  // max: $100k
            )
            .withFraudDetection(fraudService)
            .withAudit(auditRepository)
            .withRetry(3, 500)
            .withMetrics(meterRegistry)
            .withLogging()
            .build();
    }
}
```

---

## 6. Testing

### 6.1 Test del Componente Base

```java
@ExtendWith(MockitoExtension.class)
class SimpleNotificationServiceTest {

    private SimpleNotificationService service;

    @BeforeEach
    void setUp() {
        service = new SimpleNotificationService();
    }

    @Test
    @DisplayName("Debe enviar notificación correctamente")
    void shouldSendNotification() {
        // Arrange
        String recipient = "user@example.com";
        String message = "Test message";

        // Act
        service.send(recipient, message);
        NotificationResult result = service.getResult();

        // Assert
        assertThat(result).isNotNull();
        assertThat(result.isSuccess()).isTrue();
        assertThat(result.getRecipient()).isEqualTo(recipient);
        assertThat(result.getTimestamp()).isNotNull();
    }
}
```

### 6.2 Test de Decorador Individual

```java
@ExtendWith(MockitoExtension.class)
class SecurityNotificationDecoratorTest {

    @Mock
    private NotificationService wrapped;

    private SecurityNotificationDecorator decorator;

    @BeforeEach
    void setUp() {
        Set<String> blockedEmails = Set.of("blocked@test.com");
        decorator = new SecurityNotificationDecorator(wrapped, blockedEmails);
    }

    @Test
    @DisplayName("Debe rechazar email inválido")
    void shouldRejectInvalidEmail() {
        // Arrange
        String invalidEmail = "not-an-email";
        String message = "Test";

        // Act & Assert
        assertThatThrownBy(() -> decorator.send(invalidEmail, message))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("Invalid email format");

        verify(wrapped, never()).send(anyString(), anyString());
    }

    @Test
    @DisplayName("Debe rechazar recipient bloqueado")
    void shouldRejectBlockedRecipient() {
        // Arrange
        String blockedEmail = "blocked@test.com";
        String message = "Test";

        // Act & Assert
        assertThatThrownBy(() -> decorator.send(blockedEmail, message))
            .isInstanceOf(SecurityException.class)
            .hasMessageContaining("Recipient is blocked");

        verify(wrapped, never()).send(anyString(), anyString());
    }

    @Test
    @DisplayName("Debe sanitizar mensaje con scripts")
    void shouldSanitizeMessage() {
        // Arrange
        String recipient = "user@example.com";
        String maliciousMessage = "Hello <script>alert('xss')</script> World";

        // Act
        decorator.send(recipient, maliciousMessage);

        // Assert
        ArgumentCaptor<String> messageCaptor = ArgumentCaptor.forClass(String.class);
        verify(wrapped).send(eq(recipient), messageCaptor.capture());

        String sanitized = messageCaptor.getValue();
        assertThat(sanitized).doesNotContain("<script>");
        assertThat(sanitized).contains("Hello");
        assertThat(sanitized).contains("World");
    }

    @Test
    @DisplayName("Debe permitir email válido")
    void shouldAllowValidEmail() {
        // Arrange
        String validEmail = "user@example.com";
        String message = "Test message";

        // Act
        decorator.send(validEmail, message);

        // Assert
        verify(wrapped).send(validEmail, message);
    }
}
```

### 6.3 Test de Composición de Decoradores

```java
@ExtendWith(MockitoExtension.class)
class DecoratorCompositionTest {

    @Mock
    private NotificationService baseService;

    @Mock
    private MeterRegistry meterRegistry;

    @Captor
    private ArgumentCaptor<String> recipientCaptor;

    @Captor
    private ArgumentCaptor<String> messageCaptor;

    @BeforeEach
    void setUp() {
        when(meterRegistry.counter(anyString())).thenReturn(mock(Counter.class));
        when(meterRegistry.timer(anyString())).thenReturn(mock(Timer.class));
    }

    @Test
    @DisplayName("Debe aplicar decoradores en el orden correcto")
    void shouldApplyDecoratorsInCorrectOrder() {
        // Arrange
        NotificationService composed = NotificationServiceBuilder
            .create(baseService)
            .withSecurity(Set.of())
            .withLogging()
            .withMetrics(meterRegistry)
            .build();

        String recipient = "user@example.com";
        String message = "Test";

        // Act
        composed.send(recipient, message);

        // Assert
        verify(baseService).send(recipientCaptor.capture(), messageCaptor.capture());
        assertThat(recipientCaptor.getValue()).isEqualTo(recipient);
        assertThat(messageCaptor.getValue()).isEqualTo(message);
    }

    @Test
    @DisplayName("Debe fallar en primer decorador si validación falla")
    void shouldFailAtFirstDecoratorIfValidationFails() {
        // Arrange
        NotificationService composed = NotificationServiceBuilder
            .create(baseService)
            .withSecurity(Set.of("blocked@test.com"))
            .withLogging()
            .build();

        // Act & Assert
        assertThatThrownBy(() -> composed.send("blocked@test.com", "Test"))
            .isInstanceOf(SecurityException.class);

        verify(baseService, never()).send(anyString(), anyString());
    }
}
```

### 6.4 Test de Rate Limiting

```java
class RateLimitingDecoratorTest {

    private NotificationService baseService;
    private RateLimitingNotificationDecorator decorator;

    @BeforeEach
    void setUp() {
        baseService = mock(NotificationService.class);
        decorator = new RateLimitingNotificationDecorator(
            baseService,
            3,  // max 3 requests
            Duration.ofSeconds(1)  // per second
        );
    }

    @Test
    @DisplayName("Debe permitir requests dentro del límite")
    void shouldAllowRequestsWithinLimit() {
        // Act
        decorator.send("user1@test.com", "msg1");
        decorator.send("user2@test.com", "msg2");
        decorator.send("user3@test.com", "msg3");

        // Assert
        verify(baseService, times(3)).send(anyString(), anyString());
    }

    @Test
    @DisplayName("Debe rechazar cuando se excede rate limit")
    void shouldRejectWhenRateLimitExceeded() {
        // Arrange
        decorator.send("user1@test.com", "msg1");
        decorator.send("user2@test.com", "msg2");
        decorator.send("user3@test.com", "msg3");

        // Act & Assert
        assertThatThrownBy(() -> decorator.send("user4@test.com", "msg4"))
            .isInstanceOf(RateLimitExceededException.class);

        verify(baseService, times(3)).send(anyString(), anyString());
    }

    @Test
    @DisplayName("Debe permitir nuevos requests después de que pase la ventana")
    void shouldAllowNewRequestsAfterWindowExpires() throws InterruptedException {
        // Arrange
        decorator.send("user1@test.com", "msg1");
        decorator.send("user2@test.com", "msg2");
        decorator.send("user3@test.com", "msg3");

        // Act
        Thread.sleep(1100); // Esperar que expire la ventana
        decorator.send("user4@test.com", "msg4");

        // Assert
        verify(baseService, times(4)).send(anyString(), anyString());
    }
}
```

### 6.5 Test de Retry Decorator

```java
@ExtendWith(MockitoExtension.class)
class RetryDecoratorTest {

    @Mock
    private NotificationService wrapped;

    private RetryNotificationDecorator decorator;

    @BeforeEach
    void setUp() {
        decorator = new RetryNotificationDecorator(wrapped, 3, 10, 2.0);
    }

    @Test
    @DisplayName("Debe tener éxito en primer intento")
    void shouldSucceedOnFirstAttempt() {
        // Arrange
        String recipient = "user@test.com";
        String message = "test";

        // Act
        decorator.send(recipient, message);

        // Assert
        verify(wrapped, times(1)).send(recipient, message);
    }

    @Test
    @DisplayName("Debe reintentar después de fallo")
    void shouldRetryAfterFailure() {
        // Arrange
        String recipient = "user@test.com";
        String message = "test";

        doThrow(new RuntimeException("Network error"))
            .doNothing()
            .when(wrapped).send(recipient, message);

        // Act
        decorator.send(recipient, message);

        // Assert
        verify(wrapped, times(2)).send(recipient, message);
    }

    @Test
    @DisplayName("Debe fallar después de agotar reintentos")
    void shouldFailAfterExhaustingRetries() {
        // Arrange
        String recipient = "user@test.com";
        String message = "test";

        doThrow(new RuntimeException("Network error"))
            .when(wrapped).send(recipient, message);

        // Act & Assert
        assertThatThrownBy(() -> decorator.send(recipient, message))
            .isInstanceOf(RuntimeException.class)
            .hasMessageContaining("Failed after 3 retries");

        verify(wrapped, times(3)).send(recipient, message);
    }
}
```

---

## 7. Patrones Relacionados

### 7.1 Comparación: Decorator vs Proxy

```java
/**
 * PROXY: Controla acceso al objeto (lazy loading, access control)
 * Mismo interfaz pero REEMPLAZA el objeto original
 */
public class LazyLoadingProxy implements NotificationService {
    private NotificationService realService;
    private final Supplier<NotificationService> serviceSupplier;

    @Override
    public void send(String recipient, String message) {
        if (realService == null) {
            realService = serviceSupplier.get(); // Lazy initialization
        }
        realService.send(recipient, message);
    }
}

/**
 * DECORATOR: Agrega funcionalidad sin reemplazar
 * Envuelve el objeto y EXTIENDE su comportamiento
 */
public class LoggingDecorator extends NotificationDecorator {
    @Override
    public void send(String recipient, String message) {
        log.info("Before send");
        wrapped.send(recipient, message); // Delega + agrega
        log.info("After send");
    }
}
```

### 7.2 Comparación: Decorator vs Strategy

```java
/**
 * STRATEGY: Cambia el algoritmo completo
 * Se inyecta una implementación diferente
 */
public class NotificationContext {
    private NotificationStrategy strategy;

    public void setStrategy(NotificationStrategy strategy) {
        this.strategy = strategy; // REEMPLAZA la estrategia
    }

    public void send(String recipient, String message) {
        strategy.execute(recipient, message);
    }
}

/**
 * DECORATOR: Compone funcionalidades
 * Se apilan múltiples decoradores
 */
public class DecoratorApproach {
    public NotificationService create() {
        return new LoggingDecorator(
            new RetryDecorator(
                new CachingDecorator(
                    new SimpleNotificationService()
                )
            )
        ); // COMPONE múltiples responsabilidades
    }
}
```

---

## 8. Best Practices

### ✅ DO

1. **Mantener decoradores pequeños y cohesivos**

```java
// ✅ Bueno: Una responsabilidad
public class LoggingDecorator extends NotificationDecorator {
    @Override
    public void send(String recipient, String message) {
        log.info("Sending to {}", recipient);
        wrapped.send(recipient, message);
    }
}
```

2. **Usar composición en lugar de herencia profunda**

```java
// ✅ Bueno: Composición flexible
NotificationService service = NotificationServiceBuilder
    .create(baseService)
    .withLogging()
    .withRetry(3, 100)
    .withMetrics(registry)
    .build();
```

3. **Hacer decoradores independientes**

```java
// ✅ Bueno: No depende de otros decoradores
public class CachingDecorator extends NotificationDecorator {
    // Solo se preocupa de cachear, no sabe de logging, retry, etc.
}
```

4. **Proporcionar constructores claros**

```java
// ✅ Bueno: Constructor claro con validación
public RetryDecorator(
        NotificationService wrapped,
        int maxRetries,
        long initialDelayMs,
        double backoffMultiplier) {
    super(wrapped);
    if (maxRetries < 1) {
        throw new IllegalArgumentException("maxRetries must be >= 1");
    }
    this.maxRetries = maxRetries;
}
```

5. **Documentar el orden de aplicación cuando importa**

```java
/**
 * IMPORTANTE: El orden importa:
 * 1. Security primero (validar inputs)
 * 2. Caching después (evitar duplicados)
 * 3. RateLimiting
 * 4. Retry antes de métricas (para capturar reintentos)
 * 5. Metrics antes de logging
 * 6. Async al final (fire and forget)
 */
public NotificationService createService() {
    return builder
        .withSecurity(blockedList)
        .withCaching(ttl, size)
        .withRateLimit(max, window)
        .withRetry(3, 100)
        .withMetrics(registry)
        .withLogging()
        .withAsync(executor)
        .build();
}
```

### ❌ DON'T

1. **No crear decoradores con muchas responsabilidades**

```java
// ❌ Malo: Hace logging, retry, metrics y caching
public class SuperDecorator extends NotificationDecorator {
    @Override
    public void send(String recipient, String message) {
        log.info("Starting");
        if (cache.contains(recipient)) return;
        for (int i = 0; i < 3; i++) {
            try {
                metrics.increment();
                wrapped.send(recipient, message);
                break;
            } catch (Exception e) { }
        }
    }
}
```

2. **No modificar la semántica del componente base**

```java
// ❌ Malo: Cambia el comportamiento fundamental
public class BadDecorator extends NotificationDecorator {
    @Override
    public void send(String recipient, String message) {
        // Envía a otro recipient en lugar del solicitado
        wrapped.send("admin@company.com", message); // ❌ Malo
    }
}
```

3. **No crear dependencias entre decoradores**

```java
// ❌ Malo: LoggingDecorator depende de MetricsDecorator
public class LoggingDecorator extends NotificationDecorator {
    @Override
    public void send(String recipient, String message) {
        if (wrapped instanceof MetricsDecorator) { // ❌ Acoplamiento
            // hacer algo específico
        }
        wrapped.send(recipient, message);
    }
}
```

4. **No ignorar null en el wrapped**

```java
// ❌ Malo: No valida null
public class BadDecorator extends NotificationDecorator {
    public BadDecorator(NotificationService wrapped) {
        super(wrapped); // ¿Qué pasa si wrapped es null?
    }
}

// ✅ Bueno: Valida en constructor
protected NotificationDecorator(NotificationService wrapped) {
    this.wrapped = Objects.requireNonNull(wrapped, "Wrapped service cannot be null");
}
```

5. **No crear cadenas circulares**

```java
// ❌ Malo: Referencia circular
NotificationService a = new LoggingDecorator(b);
NotificationService b = new MetricsDecorator(a); // ❌ StackOverflow
```

---

## 9. Anti-Patterns

### ❌ Decorator Hell (Demasiados decoradores)

```java
// ❌ Malo: 10+ decoradores apilados
NotificationService service = new AsyncDecorator(
    new LoggingDecorator(
        new MetricsDecorator(
            new RetryDecorator(
                new CachingDecorator(
                    new SecurityDecorator(
                        new ValidationDecorator(
                            new RateLimitDecorator(
                                new TimeoutDecorator(
                                    new CircuitBreakerDecorator(
                                        new BaseService()
                                    )
                                )
                            )
                        )
                    )
                )
            )
        )
    )
);

// ✅ Mejor: Agrupar responsabilidades relacionadas
NotificationService service = builder
    .create(baseService)
    .withSecurity()      // Agrupa: validation + rate limit
    .withResilience()    // Agrupa: retry + timeout + circuit breaker
    .withObservability() // Agrupa: logging + metrics
    .withAsync()
    .build();
```

### ❌ Leaky Abstraction

```java
// ❌ Malo: Expone detalles de implementación
public class CachingDecorator extends NotificationDecorator {
    private Cache cache;

    public Cache getCache() { // ❌ Rompe abstracción
        return cache;
    }
}

// ✅ Bueno: Solo expone lo necesario
public class CachingDecorator extends NotificationDecorator {
    private Cache cache;

    public CacheStats getStats() { // ✅ API controlada
        return cache.stats();
    }
}
```

---

## 10. Use Cases Reales

### 10.1 API Gateway con Decoradores

```java
@Configuration
public class ApiGatewayConfig {

    @Bean
    public HttpClient decoratedHttpClient(
            MeterRegistry metrics,
            CircuitBreakerRegistry circuitBreakers) {

        return HttpClientBuilder
            .create(OkHttpClient())
            .withConnectionPool(100, Duration.ofMinutes(5))
            .withTimeout(Duration.ofSeconds(30))
            .withRetry(3, Duration.ofMillis(100))
            .withCircuitBreaker(circuitBreakers.circuitBreaker("gateway"))
            .withMetrics(metrics)
            .withLogging()
            .build();
    }
}
```

### 10.2 Database Repository con Cache y Metrics

```java
public interface UserRepository {
    Optional<User> findById(Long id);
    User save(User user);
}

@Bean
public UserRepository decoratedUserRepository(
        JpaUserRepository jpaRepo,
        MeterRegistry metrics) {

    return RepositoryBuilder
        .create(jpaRepo)
        .withCaching(Duration.ofMinutes(5), 10_000)
        .withMetrics(metrics)
        .withLogging()
        .build();
}
```

### 10.3 Message Publisher con Retry y DLQ

```java
public interface MessagePublisher {
    void publish(Message message);
}

@Bean
public MessagePublisher messagePublisher(
        KafkaTemplate<String, Message> kafka,
        DeadLetterQueue dlq) {

    return MessagePublisherBuilder
        .create(new KafkaMessagePublisher(kafka))
        .withValidation()
        .withRetry(3, Duration.ofSeconds(1))
        .withDeadLetterQueue(dlq)  // Si falla después de reintentos
        .withMetrics(metrics)
        .withAsync(executor)
        .build();
}
```

---

## Conclusión

El patrón Decorator proporciona una forma flexible y elegante de extender funcionalidad en runtime sin modificar el código existente:

**Ventajas:**

- ✅ Extensible: Agregar nuevos decoradores sin tocar código existente
- ✅ Composable: Combinar decoradores de forma flexible
- ✅ Single Responsibility: Cada decorador hace una cosa
- ✅ Open/Closed: Abierto para extensión, cerrado para modificación
- ✅ Runtime: Cambiar comportamiento en tiempo de ejecución

**Cuándo usar:**

- Necesitas agregar responsabilidades de forma dinámica
- Quieres evitar jerarquías de herencia profundas
- Las responsabilidades pueden combinarse de diferentes formas
- Necesitas cross-cutting concerns (logging, caching, security)

**Cuándo NO usar:**

- Si el orden de aplicación es muy complejo y confuso
- Si hay pocas variaciones de funcionalidad
- Si la herencia simple es suficiente
- Si necesitas cambiar el algoritmo completo (usa Strategy)
