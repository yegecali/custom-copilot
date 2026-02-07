# Logging Instructions for GitHub Copilot

## Core Logging Principles

**MANDATORY RULES:**
1. **ALWAYS** obfuscate sensitive data in logs
2. **NEVER** log passwords, PINs, CVVs, or full card numbers
3. **ALWAYS** use structured logging (key=value pairs)
4. **ALWAYS** use SLF4J API (framework-agnostic)
5. **ALWAYS** include correlation IDs for distributed tracing
6. **ALWAYS** use appropriate log levels

## Log Obfuscation (MANDATORY)

### Obfuscation Utility
```java
/**
 * MANDATORY: Use this class for ALL sensitive data logging
 */
public final class LogObfuscator {
    
    private LogObfuscator() {
        throw new UnsupportedOperationException("Utility class");
    }
    
    /**
     * Obfuscate account number - show only last 4 digits
     * Example: "1234567890" -> "******7890"
     */
    public static String obfuscateAccountNumber(String accountNumber) {
        if (accountNumber == null || accountNumber.length() < 4) {
            return "****";
        }
        int visibleDigits = 4;
        int maskedLength = accountNumber.length() - visibleDigits;
        return "*".repeat(maskedLength) + accountNumber.substring(maskedLength);
    }
    
    /**
     * Obfuscate card number - show first 6 and last 4 digits (BIN + last 4)
     * Example: "1234567890123456" -> "123456******3456"
     */
    public static String obfuscateCardNumber(String cardNumber) {
        if (cardNumber == null || cardNumber.length() < 10) {
            return "****-****-****-****";
        }
        
        String cleaned = cardNumber.replaceAll("[^0-9]", "");
        if (cleaned.length() < 10) {
            return "****-****-****-****";
        }
        
        return cleaned.substring(0, 6) + 
               "*".repeat(cleaned.length() - 10) + 
               cleaned.substring(cleaned.length() - 4);
    }
    
    /**
     * Obfuscate email address - show first char and domain
     * Example: "john.doe@bank.com" -> "j***@bank.com"
     */
    public static String obfuscateEmail(String email) {
        if (email == null || !email.contains("@")) {
            return "***@***.***";
        }
        
        String[] parts = email.split("@");
        if (parts[0].isEmpty()) {
            return "***@" + parts[1];
        }
        
        return parts[0].charAt(0) + "***@" + parts[1];
    }
    
    /**
     * Obfuscate phone number - show country code and last 4 digits
     * Example: "+1-555-123-4567" -> "+1-***-***-4567"
     */
    public static String obfuscatePhoneNumber(String phone) {
        if (phone == null || phone.length() < 4) {
            return "***-***-****";
        }
        
        String cleaned = phone.replaceAll("[^0-9+]", "");
        if (cleaned.length() < 4) {
            return "***-***-****";
        }
        
        // Keep country code (if present) and last 4 digits
        if (cleaned.startsWith("+")) {
            String countryCode = cleaned.substring(0, Math.min(3, cleaned.length()));
            String last4 = cleaned.substring(Math.max(cleaned.length() - 4, 0));
            return countryCode + "-***-***-" + last4;
        }
        
        String last4 = cleaned.substring(cleaned.length() - 4);
        return "***-***-" + last4;
    }
    
    /**
     * Obfuscate IP address - show first two octets only
     * Example: "192.168.1.100" -> "192.168.*.*"
     */
    public static String obfuscateIp(String ip) {
        if (ip == null || !ip.contains(".")) {
            return "*.*.*.*";
        }
        
        String[] octets = ip.split("\\.");
        if (octets.length != 4) {
            return "*.*.*.*";
        }
        
        return octets[0] + "." + octets[1] + ".*.*";
    }
    
    /**
     * Obfuscate IPv6 address - show first segment only
     * Example: "2001:0db8:85a3:0000:0000:8a2e:0370:7334" -> "2001:****:****:****:****:****:****:****"
     */
    public static String obfuscateIpv6(String ip) {
        if (ip == null || !ip.contains(":")) {
            return "****:****:****:****:****:****:****:****";
        }
        
        String[] segments = ip.split(":");
        if (segments.length < 2) {
            return "****:****:****:****:****:****:****:****";
        }
        
        return segments[0] + ":****:****:****:****:****:****:****";
    }
    
    /**
     * Obfuscate user ID - show first 4 characters
     * Example: "USER123456789" -> "USER*********"
     */
    public static String obfuscateUserId(String userId) {
        if (userId == null || userId.length() < 4) {
            return "****";
        }
        
        return userId.substring(0, 4) + "*".repeat(userId.length() - 4);
    }
    
    /**
     * Obfuscate username - show first and last character
     * Example: "johndoe" -> "j*****e"
     */
    public static String obfuscateUsername(String username) {
        if (username == null || username.length() < 2) {
            return "***";
        }
        
        if (username.length() == 2) {
            return username.charAt(0) + "*";
        }
        
        return username.charAt(0) + 
               "*".repeat(username.length() - 2) + 
               username.charAt(username.length() - 1);
    }
    
    /**
     * Obfuscate SSN - show only last 4 digits
     * Example: "123-45-6789" -> "***-**-6789"
     */
    public static String obfuscateSsn(String ssn) {
        if (ssn == null) {
            return "***-**-****";
        }
        
        String cleaned = ssn.replaceAll("[^0-9]", "");
        if (cleaned.length() < 4) {
            return "***-**-****";
        }
        
        return "***-**-" + cleaned.substring(cleaned.length() - 4);
    }
    
    /**
     * Complete obfuscation - use for highly sensitive data
     * ALWAYS use for: passwords, PINs, CVV, security answers, OTPs
     */
    public static String obfuscateCompletely(String sensitive) {
        return "[REDACTED]";
    }
    
    /**
     * Obfuscate monetary amount above threshold
     * Shows exact amount below threshold, obfuscated above
     */
    public static String obfuscateAmount(BigDecimal amount, BigDecimal threshold) {
        if (amount.compareTo(threshold) <= 0) {
            return amount.toString();
        }
        return ">=" + threshold.toString();
    }
}
```

## Structured Logging with SLF4J

### Standard Logging Pattern
```java
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.MDC;

public class TransactionService {
    private static final Logger log = LoggerFactory.getLogger(TransactionService.class);
    
    public Transaction processTransaction(TransactionRequest request) {
        // Set MDC for correlation
        MDC.put("correlationId", request.getCorrelationId());
        MDC.put("userId", LogObfuscator.obfuscateUserId(request.getUserId()));
        
        try {
            log.info("Processing transaction: transactionId={}, accountFrom={}, accountTo={}, amount={}, currency={}", 
                request.getTransactionId(),
                LogObfuscator.obfuscateAccountNumber(request.getAccountFrom()),
                LogObfuscator.obfuscateAccountNumber(request.getAccountTo()),
                request.getAmount(),
                request.getCurrency()
            );
            
            Transaction transaction = executeTransaction(request);
            
            log.info("Transaction completed: transactionId={}, status={}, duration={}ms", 
                transaction.getId(),
                transaction.getStatus(),
                transaction.getDurationMillis()
            );
            
            return transaction;
            
        } catch (InsufficientFundsException e) {
            log.warn("Transaction failed - insufficient funds: transactionId={}, available={}, required={}", 
                request.getTransactionId(),
                e.getAvailable(),
                e.getRequired()
            );
            throw e;
            
        } catch (Exception e) {
            log.error("Transaction failed unexpectedly: transactionId={}, errorType={}, message={}", 
                request.getTransactionId(),
                e.getClass().getSimpleName(),
                e.getMessage(),
                e  // Stack trace included
            );
            throw e;
            
        } finally {
            MDC.clear(); // MANDATORY: Clean up MDC
        }
    }
}
```

## Log Levels

### When to Use Each Level

#### TRACE
- Very detailed technical information
- Typically disabled in all environments
- Used only for deep debugging
```java
log.trace("Entering method: calculateInterest, principal={}, rate={}", principal, rate);
```

#### DEBUG
- Detailed information for debugging
- Enabled only in development/test
- Disabled in production
```java
if (log.isDebugEnabled()) {
    log.debug("Validation result: accountId={}, valid={}, violations={}", 
        LogObfuscator.obfuscateAccountNumber(accountId),
        isValid,
        violations
    );
}
```

#### INFO
- Important business events and milestones
- Normal application flow
- Enabled in production
```java
log.info("Account created: accountId={}, customerId={}, type={}", 
    LogObfuscator.obfuscateAccountNumber(account.getId()),
    LogObfuscator.obfuscateUserId(account.getCustomerId()),
    account.getType()
);
```

#### WARN
- Potentially harmful situations
- Degraded service
- Recoverable errors
```java
log.warn("Rate limit approaching: userId={}, current={}, limit={}", 
    LogObfuscator.obfuscateUserId(userId),
    currentRate,
    rateLimit
);
```

#### ERROR
- Error events that might still allow the application to continue
- Business exceptions
- Failed operations
```java
log.error("Failed to process payment: transactionId={}, reason={}", 
    transactionId,
    reason,
    exception
);
```

## MDC (Mapped Diagnostic Context)

### Always Include Correlation Data
```java
public class CorrelationIdFilter {
    
    public void filter(HttpServletRequest request, HttpServletResponse response, FilterChain chain) 
            throws IOException, ServletException {
        
        // Extract or generate correlation ID
        String correlationId = request.getHeader("X-Correlation-ID");
        if (correlationId == null || correlationId.isBlank()) {
            correlationId = UUID.randomUUID().toString();
        }
        
        // Set in MDC
        MDC.put("correlationId", correlationId);
        MDC.put("requestMethod", request.getMethod());
        MDC.put("requestUri", request.getRequestURI());
        MDC.put("clientIp", LogObfuscator.obfuscateIp(getClientIp(request)));
        
        // Add to response header for client tracing
        response.setHeader("X-Correlation-ID", correlationId);
        
        try {
            chain.doFilter(request, response);
        } finally {
            MDC.clear(); // CRITICAL: Always clean up
        }
    }
}

// All logs will now include these fields automatically
// [correlationId=abc-123, requestMethod=POST, requestUri=/api/transactions] Processing transaction
```

### Propagate MDC to Async Tasks
```java
public class MdcPropagatingExecutor implements Executor {
    private final Executor delegate;
    
    @Override
    public void execute(Runnable command) {
        // Capture current MDC context
        Map<String, String> contextMap = MDC.getCopyOfContextMap();
        
        delegate.execute(() -> {
            try {
                // Restore MDC in new thread
                if (contextMap != null) {
                    MDC.setContextMap(contextMap);
                }
                command.run();
            } finally {
                MDC.clear();
            }
        });
    }
}
```

## What to Log

### ✅ MUST Log
- **Business events**: Account created, transaction completed, user registered
- **Security events**: Login attempts, permission denials, suspicious activity
- **Integration points**: External API calls, message publishing/consuming
- **State transitions**: Order placed → processing → shipped → delivered
- **Performance metrics**: Operation duration, queue sizes
- **Error conditions**: Exceptions, validation failures, timeouts
- **Audit trail**: Who did what and when (with obfuscated PII)

### ❌ NEVER Log
- **Passwords** (plaintext or hashed)
- **PINs**
- **CVV/CVC codes**
- **Full credit card numbers** (only BIN + last 4)
- **Social Security Numbers** (only last 4 allowed)
- **Security questions/answers**
- **API keys/tokens**
- **Encryption keys**
- **Session IDs** (use correlation IDs instead)
- **OTP codes**
- **Private keys**
- **Biometric data**

## Security Event Logging

### Authentication Events
```java
public class AuthenticationService {
    private static final Logger log = LoggerFactory.getLogger(AuthenticationService.class);
    
    public void logSuccessfulLogin(String username, String ipAddress) {
        log.info("LOGIN_SUCCESS: username={}, ip={}, timestamp={}", 
            LogObfuscator.obfuscateUsername(username),
            LogObfuscator.obfuscateIp(ipAddress),
            Instant.now()
        );
    }
    
    public void logFailedLogin(String username, String ipAddress, String reason) {
        log.warn("LOGIN_FAILED: username={}, ip={}, reason={}, timestamp={}", 
            LogObfuscator.obfuscateUsername(username),
            LogObfuscator.obfuscateIp(ipAddress),
            reason,
            Instant.now()
        );
    }
    
    public void logAccountLockout(String username, int attempts) {
        log.error("ACCOUNT_LOCKED: username={}, attempts={}, timestamp={}", 
            LogObfuscator.obfuscateUsername(username),
            attempts,
            Instant.now()
        );
    }
}
```

### Authorization Events
```java
public class AuthorizationService {
    private static final Logger log = LoggerFactory.getLogger(AuthorizationService.class);
    
    public void logUnauthorizedAccess(String userId, String resource, String action) {
        log.warn("UNAUTHORIZED_ACCESS: userId={}, resource={}, action={}, ip={}", 
            LogObfuscator.obfuscateUserId(userId),
            resource,
            action,
            LogObfuscator.obfuscateIp(getCurrentIp())
        );
    }
    
    public void logPermissionDenied(String userId, String permission) {
        log.warn("PERMISSION_DENIED: userId={}, permission={}, ip={}", 
            LogObfuscator.obfuscateUserId(userId),
            permission,
            LogObfuscator.obfuscateIp(getCurrentIp())
        );
    }
}
```

### Data Access Events
```java
public class DataAccessLogger {
    private static final Logger log = LoggerFactory.getLogger(DataAccessLogger.class);
    
    public void logSensitiveDataAccess(String userId, String dataType, String recordId) {
        log.info("SENSITIVE_DATA_ACCESS: userId={}, dataType={}, recordId={}, timestamp={}", 
            LogObfuscator.obfuscateUserId(userId),
            dataType,
            LogObfuscator.obfuscateAccountNumber(recordId),
            Instant.now()
        );
    }
}
```

## Performance Logging

### Method Execution Time
```java
public class PerformanceLogger {
    private static final Logger log = LoggerFactory.getLogger(PerformanceLogger.class);
    
    public <T> T logExecutionTime(String operation, Supplier<T> supplier) {
        long startTime = System.currentTimeMillis();
        
        try {
            T result = supplier.get();
            long duration = System.currentTimeMillis() - startTime;
            
            if (duration > 1000) {
                log.warn("SLOW_OPERATION: operation={}, duration={}ms", operation, duration);
            } else {
                log.debug("Operation completed: operation={}, duration={}ms", operation, duration);
            }
            
            return result;
        } catch (Exception e) {
            long duration = System.currentTimeMillis() - startTime;
            log.error("OPERATION_FAILED: operation={}, duration={}ms, error={}", 
                operation, duration, e.getMessage(), e);
            throw e;
        }
    }
}
```

## External Service Call Logging

```java
public class ExternalServiceClient {
    private static final Logger log = LoggerFactory.getLogger(ExternalServiceClient.class);
    
    public Response callExternalService(String endpoint, Request request) {
        String requestId = UUID.randomUUID().toString();
        
        log.info("EXTERNAL_CALL_START: service={}, endpoint={}, requestId={}", 
            "PaymentGateway",
            endpoint,
            requestId
        );
        
        long startTime = System.currentTimeMillis();
        
        try {
            Response response = httpClient.post(endpoint, request);
            long duration = System.currentTimeMillis() - startTime;
            
            log.info("EXTERNAL_CALL_SUCCESS: service={}, endpoint={}, requestId={}, status={}, duration={}ms", 
                "PaymentGateway",
                endpoint,
                requestId,
                response.getStatusCode(),
                duration
            );
            
            return response;
            
        } catch (Exception e) {
            long duration = System.currentTimeMillis() - startTime;
            
            log.error("EXTERNAL_CALL_FAILED: service={}, endpoint={}, requestId={}, duration={}ms, error={}", 
                "PaymentGateway",
                endpoint,
                requestId,
                duration,
                e.getMessage(),
                e
            );
            
            throw e;
        }
    }
}
```

## Log Configuration Best Practices

### Logback Configuration Example
```xml
<configuration>
    <!-- Console appender for development -->
    <appender name="CONSOLE" class="ch.qos.logback.core.ConsoleAppender">
        <encoder>
            <pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} [%thread] %-5level %logger{36} [%X{correlationId}] - %msg%n</pattern>
        </encoder>
    </appender>
    
    <!-- File appender for production -->
    <appender name="FILE" class="ch.qos.logback.core.rolling.RollingFileAppender">
        <file>logs/application.log</file>
        <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
            <fileNamePattern>logs/application-%d{yyyy-MM-dd}.log.gz</fileNamePattern>
            <maxHistory>30</maxHistory>
            <totalSizeCap>10GB</totalSizeCap>
        </rollingPolicy>
        <encoder>
            <pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} [%thread] %-5level %logger{36} [%X{correlationId}] [%X{userId}] - %msg%n</pattern>
        </encoder>
    </appender>
    
    <!-- Separate file for security events -->
    <appender name="SECURITY" class="ch.qos.logback.core.rolling.RollingFileAppender">
        <file>logs/security.log</file>
        <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
            <fileNamePattern>logs/security-%d{yyyy-MM-dd}.log.gz</fileNamePattern>
            <maxHistory>90</maxHistory>
        </rollingPolicy>
        <encoder>
            <pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} [SECURITY] %msg%n</pattern>
        </encoder>
    </appender>
    
    <logger name="com.bank.security" level="INFO" additivity="false">
        <appender-ref ref="SECURITY"/>
    </logger>
    
    <root level="INFO">
        <appender-ref ref="CONSOLE"/>
        <appender-ref ref="FILE"/>
    </root>
</configuration>
```

## Logging Checklist

Before committing logging code:
- [ ] All sensitive data is obfuscated
- [ ] Using structured logging (key=value pairs)
- [ ] Appropriate log level selected
- [ ] MDC context is set and cleared
- [ ] Exception stack traces included where needed
- [ ] No passwords, PINs, or CVVs in logs
- [ ] Full card numbers are not logged (only BIN + last 4)
- [ ] Performance guards for expensive log operations
- [ ] Security events are logged
- [ ] Correlation IDs are propagated

---

**Logs are your eyes in production - make them secure and useful!** 🔍
