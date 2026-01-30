# Security Instructions for GitHub Copilot

## Core Security Principle

**ALL CODE MUST BE FREE OF VULNERABILITIES** detected by:
- ✅ **SpotBugs** (FindBugs successor)
- ✅ **SonarQube** / **SonarLint**
- ✅ **Fortify** (Static Application Security Testing)
- ✅ **Checkmarx** (SAST)
- ✅ **CAST** (Application Intelligence Platform)
- ✅ **OWASP** (Top 10 vulnerabilities)

## Banking Security Requirements

### Critical Rules
1. **NEVER** log sensitive data (even masked - use secure logging)
2. **ALWAYS** validate and sanitize ALL inputs
3. **ALWAYS** use parameterized queries (prevent SQL injection)
4. **ALWAYS** encrypt sensitive data at rest and in transit
5. **ALWAYS** implement proper authentication and authorization
6. **NEVER** expose stack traces to end users
7. **ALWAYS** use secure random for cryptographic operations

## OWASP Top 10 Prevention

### A01:2021 - Broken Access Control
```java
// ✅ SECURE: Check authorization before operations
public class AccountService {
    private final SecurityContext securityContext;
    
    public Account getAccount(String accountId) {
        // MANDATORY: Check if user owns this account
        if (!securityContext.canAccessAccount(accountId)) {
            throw new ForbiddenException("Access denied to account: " + accountId);
        }
        
        return repository.findById(accountId)
            .orElseThrow(() -> new AccountNotFoundException(accountId));
    }
    
    public Transaction createTransaction(TransactionRequest request) {
        // MANDATORY: Verify user permissions
        requirePermission("TRANSACTION_CREATE");
        
        // MANDATORY: Validate ownership
        validateAccountOwnership(request.getAccountId());
        
        return processTransaction(request);
    }
    
    private void requirePermission(String permission) {
        if (!securityContext.hasPermission(permission)) {
            auditLogger.logUnauthorizedAccess(securityContext.getUserId(), permission);
            throw new ForbiddenException("Missing permission: " + permission);
        }
    }
}

// ❌ INSECURE: Direct access without checks
public Account getAccount(String accountId) {
    return repository.findById(accountId).orElse(null); // ❌ No authorization!
}
```

### A02:2021 - Cryptographic Failures
```java
// ✅ SECURE: Proper encryption
public class SecureDataService {
    private static final String ALGORITHM = "AES/GCM/NoPadding";
    private static final int GCM_TAG_LENGTH = 128;
    private static final int GCM_IV_LENGTH = 12;
    
    private final SecretKey secretKey;
    
    public String encrypt(String plaintext) {
        try {
            Cipher cipher = Cipher.getInstance(ALGORITHM);
            
            // Generate secure random IV
            byte[] iv = new byte[GCM_IV_LENGTH];
            SecureRandom random = SecureRandom.getInstanceStrong();
            random.nextBytes(iv);
            
            GCMParameterSpec parameterSpec = new GCMParameterSpec(GCM_TAG_LENGTH, iv);
            cipher.init(Cipher.ENCRYPT_MODE, secretKey, parameterSpec);
            
            byte[] ciphertext = cipher.doFinal(plaintext.getBytes(StandardCharsets.UTF_8));
            
            // Prepend IV to ciphertext
            ByteBuffer byteBuffer = ByteBuffer.allocate(iv.length + ciphertext.length);
            byteBuffer.put(iv);
            byteBuffer.put(ciphertext);
            
            return Base64.getEncoder().encodeToString(byteBuffer.array());
        } catch (Exception e) {
            throw new CryptographicException("Encryption failed", e);
        }
    }
    
    public String decrypt(String encrypted) {
        try {
            byte[] decoded = Base64.getDecoder().decode(encrypted);
            ByteBuffer byteBuffer = ByteBuffer.wrap(decoded);
            
            byte[] iv = new byte[GCM_IV_LENGTH];
            byteBuffer.get(iv);
            
            byte[] ciphertext = new byte[byteBuffer.remaining()];
            byteBuffer.get(ciphertext);
            
            Cipher cipher = Cipher.getInstance(ALGORITHM);
            GCMParameterSpec parameterSpec = new GCMParameterSpec(GCM_TAG_LENGTH, iv);
            cipher.init(Cipher.DECRYPT_MODE, secretKey, parameterSpec);
            
            byte[] plaintext = cipher.doFinal(ciphertext);
            return new String(plaintext, StandardCharsets.UTF_8);
        } catch (Exception e) {
            throw new CryptographicException("Decryption failed", e);
        }
    }
}

// ❌ INSECURE: Weak encryption
Cipher cipher = Cipher.getInstance("AES"); // ❌ Uses ECB mode by default!
cipher.init(Cipher.ENCRYPT_MODE, key); // ❌ No IV!

// ❌ INSECURE: Hardcoded key
private static final String KEY = "my-secret-key"; // ❌ NEVER!

// ❌ INSECURE: Weak random
Random random = new Random(); // ❌ Not cryptographically secure!
```

### A03:2021 - Injection
```java
// ✅ SECURE: Parameterized queries (SQL Injection prevention)
public class AccountRepository {
    
    public List<Account> findByCustomerId(String customerId) {
        String sql = "SELECT * FROM accounts WHERE customer_id = ?";
        
        return jdbcTemplate.query(
            sql,
            new Object[]{customerId}, // ✅ Parameterized
            accountRowMapper
        );
    }
    
    public void updateBalance(String accountId, BigDecimal newBalance) {
        String sql = "UPDATE accounts SET balance = ?, updated_at = ? WHERE id = ?";
        
        jdbcTemplate.update(
            sql,
            newBalance,
            Instant.now(),
            accountId
        );
    }
}

// ❌ INSECURE: String concatenation
public List<Account> findByCustomerId(String customerId) {
    String sql = "SELECT * FROM accounts WHERE customer_id = '" + customerId + "'"; // ❌ SQL INJECTION!
    return jdbcTemplate.query(sql, accountRowMapper);
}

// ✅ SECURE: Command Injection prevention
public class FileProcessor {
    
    public void processFile(String filename) {
        // Validate and sanitize input
        if (!isValidFilename(filename)) {
            throw new SecurityException("Invalid filename");
        }
        
        // Whitelist approach
        if (!filename.matches("^[a-zA-Z0-9_\\-\\.]+$")) {
            throw new SecurityException("Filename contains illegal characters");
        }
        
        Path filePath = Paths.get("/safe/directory", filename).normalize();
        
        // Prevent path traversal
        if (!filePath.startsWith("/safe/directory")) {
            throw new SecurityException("Path traversal detected");
        }
        
        // Process file safely
    }
}

// ❌ INSECURE: Command injection vulnerability
Runtime.getRuntime().exec("convert " + userInput + " output.pdf"); // ❌ COMMAND INJECTION!

// ✅ SECURE: LDAP Injection prevention
public User findUser(String username) {
    // Escape LDAP special characters
    String escapedUsername = escapeLDAPSearchFilter(username);
    String filter = "(&(uid=" + escapedUsername + ")(objectClass=person))";
    return ldapTemplate.search(filter);
}

private String escapeLDAPSearchFilter(String filter) {
    StringBuilder sb = new StringBuilder();
    for (char c : filter.toCharArray()) {
        switch (c) {
            case '\\' -> sb.append("\\5c");
            case '*' -> sb.append("\\2a");
            case '(' -> sb.append("\\28");
            case ')' -> sb.append("\\29");
            case '\0' -> sb.append("\\00");
            default -> sb.append(c);
        }
    }
    return sb.toString();
}
```

### A04:2021 - Insecure Design
```java
// ✅ SECURE: Rate limiting and brute force protection
@Component
public class LoginAttemptService {
    private final LoadingCache<String, Integer> attemptsCache;
    private static final int MAX_ATTEMPTS = 5;
    private static final int LOCKOUT_DURATION_MINUTES = 30;
    
    public LoginAttemptService() {
        attemptsCache = Caffeine.newBuilder()
            .expireAfterWrite(LOCKOUT_DURATION_MINUTES, TimeUnit.MINUTES)
            .build(key -> 0);
    }
    
    public void loginSucceeded(String username) {
        attemptsCache.invalidate(username);
    }
    
    public void loginFailed(String username) {
        int attempts = attemptsCache.get(username);
        attempts++;
        attemptsCache.put(username, attempts);
        
        if (attempts >= MAX_ATTEMPTS) {
            auditLogger.logAccountLockout(username, attempts);
        }
    }
    
    public boolean isBlocked(String username) {
        return attemptsCache.get(username) >= MAX_ATTEMPTS;
    }
}

// ✅ SECURE: Transaction limits
public class TransactionService {
    private static final BigDecimal DAILY_LIMIT = new BigDecimal("10000.00");
    
    public Transaction createTransaction(TransactionRequest request) {
        // Check daily limit
        BigDecimal todayTotal = repository.getTodayTotalForAccount(request.getAccountId());
        BigDecimal newTotal = todayTotal.add(request.getAmount());
        
        if (newTotal.compareTo(DAILY_LIMIT) > 0) {
            auditLogger.logLimitExceeded(request.getAccountId(), newTotal);
            throw new DailyLimitExceededException(DAILY_LIMIT, newTotal);
        }
        
        return processTransaction(request);
    }
}
```

### A05:2021 - Security Misconfiguration
```java
// ✅ SECURE: Proper configuration
public class SecurityConfiguration {
    
    @Bean
    public PasswordEncoder passwordEncoder() {
        // Use strong, modern algorithm
        return Argon2PasswordEncoder.defaultsForSpringSecurity_v5_8();
    }
    
    @Bean
    public SecurityConfig securityConfig() {
        return SecurityConfig.builder()
            .httpOnly(true)                    // Prevent XSS
            .secure(true)                      // HTTPS only
            .sameSite("Strict")                // CSRF protection
            .maxAge(Duration.ofHours(1))       // Session timeout
            .build();
    }
}

// ❌ INSECURE: Weak configuration
return new BCryptPasswordEncoder(4); // ❌ Too weak! Use at least 12
cookie.setHttpOnly(false); // ❌ Vulnerable to XSS
cookie.setSecure(false); // ❌ Can be sent over HTTP
```

### A06:2021 - Vulnerable and Outdated Components
```java
// ✅ SECURE: Always use latest stable versions
// In pom.xml or build.gradle
/*
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-security</artifactId>
    <version>3.2.1</version> <!-- Latest stable -->
</dependency>

<!-- MANDATORY: Dependency vulnerability scanning -->
<plugin>
    <groupId>org.owasp</groupId>
    <artifactId>dependency-check-maven</artifactId>
    <version>9.0.9</version>
</plugin>
*/

// ❌ INSECURE: Outdated dependencies
// <version>2.1.0</version> ❌ Old version with known CVEs!
```

### A07:2021 - Identification and Authentication Failures
```java
// ✅ SECURE: Proper session management
public class SessionService {
    
    public Session createSession(User user) {
        // Generate cryptographically secure session ID
        String sessionId = generateSecureSessionId();
        
        Session session = Session.builder()
            .id(sessionId)
            .userId(user.getId())
            .createdAt(Instant.now())
            .expiresAt(Instant.now().plus(30, ChronoUnit.MINUTES))
            .ipAddress(getClientIp())
            .userAgent(getUserAgent())
            .build();
        
        sessionRepository.save(session);
        
        auditLogger.logSessionCreated(user.getId(), sessionId);
        
        return session;
    }
    
    public void invalidateSession(String sessionId) {
        sessionRepository.deleteById(sessionId);
        auditLogger.logSessionInvalidated(sessionId);
    }
    
    private String generateSecureSessionId() {
        byte[] randomBytes = new byte[32];
        SecureRandom.getInstanceStrong().nextBytes(randomBytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(randomBytes);
    }
}

// ❌ INSECURE: Weak session management
String sessionId = UUID.randomUUID().toString(); // ❌ Predictable!
session.setExpiresAt(null); // ❌ Never expires!
```

### A08:2021 - Software and Data Integrity Failures
```java
// ✅ SECURE: Verify data integrity
public class IntegrityService {
    
    public String calculateHash(byte[] data) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(data);
            return Base64.getEncoder().encodeToString(hash);
        } catch (NoSuchAlgorithmException e) {
            throw new SecurityException("SHA-256 not available", e);
        }
    }
    
    public boolean verifyIntegrity(byte[] data, String expectedHash) {
        String actualHash = calculateHash(data);
        return MessageDigest.isEqual(
            actualHash.getBytes(StandardCharsets.UTF_8),
            expectedHash.getBytes(StandardCharsets.UTF_8)
        );
    }
}

// ✅ SECURE: Digital signatures
public class SignatureService {
    
    public byte[] sign(byte[] data, PrivateKey privateKey) {
        try {
            Signature signature = Signature.getInstance("SHA256withRSA");
            signature.initSign(privateKey);
            signature.update(data);
            return signature.sign();
        } catch (Exception e) {
            throw new SecurityException("Signature failed", e);
        }
    }
    
    public boolean verify(byte[] data, byte[] signatureBytes, PublicKey publicKey) {
        try {
            Signature signature = Signature.getInstance("SHA256withRSA");
            signature.initVerify(publicKey);
            signature.update(data);
            return signature.verify(signatureBytes);
        } catch (Exception e) {
            return false;
        }
    }
}
```

### A09:2021 - Security Logging and Monitoring Failures
```java
// ✅ SECURE: Comprehensive audit logging (with obfuscation)
public class AuditLogger {
    private static final Logger log = LoggerFactory.getLogger(AuditLogger.class);
    
    public void logAccountAccess(String userId, String accountId, String action) {
        log.info("AUDIT: user={}, account={}, action={}, timestamp={}, ip={}", 
            obfuscateUserId(userId),
            obfuscateAccountId(accountId),
            action,
            Instant.now(),
            obfuscateIp(getCurrentIp())
        );
    }
    
    public void logUnauthorizedAccess(String userId, String resource) {
        log.warn("SECURITY: Unauthorized access attempt - user={}, resource={}, ip={}", 
            obfuscateUserId(userId),
            resource,
            obfuscateIp(getCurrentIp())
        );
        
        // Send alert for security team
        securityAlertService.sendAlert(SecurityAlert.UNAUTHORIZED_ACCESS, userId);
    }
    
    public void logFailedLogin(String username, String reason) {
        log.warn("SECURITY: Failed login - username={}, reason={}, ip={}", 
            obfuscateUsername(username),
            reason,
            obfuscateIp(getCurrentIp())
        );
    }
    
    public void logSuspiciousActivity(String userId, String activity, String details) {
        log.error("SECURITY: Suspicious activity - user={}, activity={}, details={}", 
            obfuscateUserId(userId),
            activity,
            details
        );
        
        securityAlertService.sendAlert(SecurityAlert.SUSPICIOUS_ACTIVITY, userId);
    }
}

// ❌ INSECURE: No logging
public void processTransaction(Transaction t) {
    // Process without any audit trail ❌
}
```

### A10:2021 - Server-Side Request Forgery (SSRF)
```java
// ✅ SECURE: SSRF prevention
public class ExternalServiceClient {
    private static final Set<String> ALLOWED_HOSTS = Set.of(
        "api.trusted-partner.com",
        "payment-gateway.bank.com"
    );
    
    public Response callExternalService(String url) {
        URI uri;
        try {
            uri = new URI(url);
        } catch (URISyntaxException e) {
            throw new SecurityException("Invalid URL", e);
        }
        
        // Validate scheme
        if (!"https".equals(uri.getScheme())) {
            throw new SecurityException("Only HTTPS is allowed");
        }
        
        // Validate host (whitelist)
        if (!ALLOWED_HOSTS.contains(uri.getHost())) {
            throw new SecurityException("Host not in whitelist: " + uri.getHost());
        }
        
        // Prevent private IP ranges
        if (isPrivateIp(uri.getHost())) {
            throw new SecurityException("Private IP addresses are not allowed");
        }
        
        return httpClient.send(uri);
    }
    
    private boolean isPrivateIp(String host) {
        try {
            InetAddress addr = InetAddress.getByName(host);
            return addr.isSiteLocalAddress() || addr.isLoopbackAddress();
        } catch (UnknownHostException e) {
            return true; // Reject if can't resolve
        }
    }
}

// ❌ INSECURE: No validation
public Response callExternalService(String url) {
    return httpClient.get(url); // ❌ User can access internal services!
}
```

## Secure Logging with Obfuscation

### MANDATORY: All Sensitive Data MUST Be Obfuscated

```java
// ✅ SECURE: Obfuscation utility
public class LogObfuscator {
    
    /**
     * Obfuscate account number - show only last 4 digits
     */
    public static String obfuscateAccountNumber(String accountNumber) {
        if (accountNumber == null || accountNumber.length() < 4) {
            return "****";
        }
        return "*".repeat(accountNumber.length() - 4) + 
               accountNumber.substring(accountNumber.length() - 4);
    }
    
    /**
     * Obfuscate card number - show first 6 and last 4 digits
     */
    public static String obfuscateCardNumber(String cardNumber) {
        if (cardNumber == null || cardNumber.length() < 10) {
            return "****";
        }
        return cardNumber.substring(0, 6) + 
               "*".repeat(cardNumber.length() - 10) + 
               cardNumber.substring(cardNumber.length() - 4);
    }
    
    /**
     * Obfuscate email - show first char and domain
     */
    public static String obfuscateEmail(String email) {
        if (email == null || !email.contains("@")) {
            return "***@***.***";
        }
        String[] parts = email.split("@");
        return parts[0].charAt(0) + "***@" + parts[1];
    }
    
    /**
     * Obfuscate phone number - show last 4 digits
     */
    public static String obfuscatePhoneNumber(String phone) {
        if (phone == null || phone.length() < 4) {
            return "****";
        }
        return "***-***-" + phone.substring(phone.length() - 4);
    }
    
    /**
     * Obfuscate IP address - show first two octets
     */
    public static String obfuscateIp(String ip) {
        if (ip == null || !ip.contains(".")) {
            return "***.***.***.***";
        }
        String[] octets = ip.split("\\.");
        if (octets.length != 4) {
            return "***.***.***.***";
        }
        return octets[0] + "." + octets[1] + ".***.***";
    }
    
    /**
     * Obfuscate user ID - show first 4 chars
     */
    public static String obfuscateUserId(String userId) {
        if (userId == null || userId.length() < 4) {
            return "****";
        }
        return userId.substring(0, 4) + "*".repeat(userId.length() - 4);
    }
    
    /**
     * NEVER log these fields - return placeholder
     */
    public static String obfuscateSensitive(String sensitive) {
        return "[REDACTED]";
    }
}

// ✅ SECURE: Usage in logging
public class TransactionService {
    private static final Logger log = LoggerFactory.getLogger(TransactionService.class);
    
    public Transaction processTransaction(TransactionRequest request) {
        log.info("Processing transaction: id={}, account={}, amount={}, card={}", 
            request.getTransactionId(),
            LogObfuscator.obfuscateAccountNumber(request.getAccountNumber()),
            request.getAmount(), // Amount is OK to log
            LogObfuscator.obfuscateCardNumber(request.getCardNumber())
        );
        
        // Never log CVV, PIN, passwords!
        // log.info("CVV: {}", request.getCvv()); ❌ NEVER!
        
        Transaction transaction = executeTransaction(request);
        
        log.info("Transaction completed: id={}, status={}, account={}", 
            transaction.getId(),
            transaction.getStatus(),
            LogObfuscator.obfuscateAccountNumber(transaction.getAccountNumber())
        );
        
        return transaction;
    }
}

// ❌ INSECURE: Logging sensitive data
log.info("Account: {}, CVV: {}, PIN: {}", accountNumber, cvv, pin); // ❌ MAJOR VIOLATION!
log.debug("User: {}, Password: {}", username, password); // ❌ NEVER!
log.info("Full card: {}", cardNumber); // ❌ PCI-DSS violation!
```

### NEVER Log These Fields
```java
// ❌ ABSOLUTELY FORBIDDEN in logs:
- Passwords (plaintext or hashed)
- PINs
- CVV / CVC codes
- Full credit card numbers
- Social Security Numbers
- Full account numbers (only last 4 digits allowed)
- Security questions/answers
- API keys / tokens
- Encryption keys
- Session IDs
- OTP codes
- Private keys
- Biometric data
```

## SpotBugs / SonarQube / Fortify Compliance

### Null Safety
```java
// ✅ SECURE: Null-safe code
public class AccountService {
    
    public Account getAccount(@NotNull String accountId) {
        Objects.requireNonNull(accountId, "Account ID cannot be null");
        
        return repository.findById(accountId)
            .orElseThrow(() -> new AccountNotFoundException(accountId));
    }
    
    public Optional<Transaction> findTransaction(String transactionId) {
        if (transactionId == null || transactionId.isBlank()) {
            return Optional.empty();
        }
        
        return repository.findTransactionById(transactionId);
    }
}

// ❌ INSECURE: Null dereference risk
public Account getAccount(String accountId) {
    return repository.findById(accountId).get(); // ❌ Can throw NullPointerException!
}
```

### Resource Leaks
```java
// ✅ SECURE: Proper resource management
public List<Transaction> readTransactionsFromFile(String filePath) {
    try (BufferedReader reader = new BufferedReader(new FileReader(filePath))) {
        return reader.lines()
            .map(this::parseTransaction)
            .collect(Collectors.toList());
    } catch (IOException e) {
        throw new FileProcessingException("Failed to read file", e);
    }
}

// ❌ INSECURE: Resource leak
public List<Transaction> readTransactionsFromFile(String filePath) {
    BufferedReader reader = new BufferedReader(new FileReader(filePath)); // ❌ Never closed!
    return reader.lines().collect(Collectors.toList());
}
```

### Thread Safety
```java
// ✅ SECURE: Thread-safe singleton
public class ConfigurationService {
    private static volatile ConfigurationService instance;
    private final Map<String, String> config;
    
    private ConfigurationService() {
        this.config = new ConcurrentHashMap<>();
    }
    
    public static ConfigurationService getInstance() {
        if (instance == null) {
            synchronized (ConfigurationService.class) {
                if (instance == null) {
                    instance = new ConfigurationService();
                }
            }
        }
        return instance;
    }
}

// ❌ INSECURE: Not thread-safe
private static ConfigurationService instance; // ❌ Race condition!
public static ConfigurationService getInstance() {
    if (instance == null) {
        instance = new ConfigurationService(); // ❌ Multiple instances possible!
    }
    return instance;
}
```

## Security Checklist

Before committing code, verify:
- [ ] No hardcoded credentials or secrets
- [ ] All inputs are validated and sanitized
- [ ] All SQL queries use parameterized statements
- [ ] Sensitive data is encrypted at rest
- [ ] All sensitive fields are obfuscated in logs
- [ ] Proper authentication and authorization checks
- [ ] No information leakage in error messages
- [ ] Resources are properly closed (try-with-resources)
- [ ] Thread-safe code for shared mutable state
- [ ] No insecure random number generation
- [ ] HTTPS enforced for all communications
- [ ] Rate limiting implemented
- [ ] Audit logging for security events
- [ ] Dependencies are up-to-date (no known CVEs)
- [ ] SpotBugs / SonarQube / Fortify scans pass

---

**Security is not optional in banking!** 🔒
