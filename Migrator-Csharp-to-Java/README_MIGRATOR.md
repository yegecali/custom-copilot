# 🔄 Migration Agent: C# Azure Functions → Java

Agente especializado en migración de Azure Functions de **C# a Java** con máxima fidelidad funcional y best practices.

---

## ⭐ **MIGRACIÓN AUTOMÁTICA NUEVA**

### El Comando Magic ✨

```
@csharp-to-java-migrator migra todo automaticamente
```

**Esto hace automáticamente:**

1. 📂 Lista tu proyecto completo
2. 📁 Crea directorio `[ProjectName]-migrated/`
3. 🔍 Analiza toda tu función C#
4. 🔄 Traduce todos los .cs → .java
5. ⚙️ Genera pom.xml y configuraciones
6. 🧪 Migra tests (xUnit → JUnit 5)
7. ✅ Valida y compila automáticamente
8. 📚 Genera documentación completa
9. 🎉 Muestra progreso en tiempo real

**Resultado:** Todo migrado en ~85 minutos, automáticamente.

**Ahorro de tiempo:** 7.5 horas → 85 minutos ⚡

---

## 🚀 Quick Start

### 1. Abre el Chat

```
Cmd + Shift + L (Mac)
Ctrl + Shift + L (Windows/Linux)
```

### 2. Opción A: Migración Automática Completa (⭐ RECOMENDADO)

```
@csharp-to-java-migrator migra todo automaticamente
```

### 2. Opción B: Por Pasos Individuales

```
@csharp-to-java-migrator analiza mi función CardPayment.cs
```

---

## 📋 Guía Completa de Uso

### Opción Automática: Migración Completa (⭐ NUEVO)

**Comando:**

```
@csharp-to-java-migrator migra todo automaticamente
```

**Fases ejecutadas automáticamente:**

1. **Discovery** - Explora estructura y archivos
2. **Directory Creation** - Crea `[ProjectName]-migrated/`
3. **Analysis** - Analiza función C# profundamente
4. **Code Migration** - Traduce con progreso visual
5. **Configuration** - Genera pom.xml, function.json
6. **Testing** - Migra tests a JUnit 5
7. **Validation** - Compila y ejecuta tests
8. **Documentation** - Genera 4 guías
9. **Summary** - Muestra resultados finales

**Progreso visual:**

```
🔄 MIGRACIÓN DE CÓDIGO
[████████░░░░░░░░░░░] 50% (6/12 archivos)
```

**Resultado:** Proyecto completamente migrado en directorio `[ProjectName]-migrated/`

---

### Paso 1: Analizar tu Función C# (Manual)

**Comando:**

```
@csharp-to-java-migrator #read analiza mi función CardPayment
```

**Resultado:**

- Estructura de la función
- Triggers y bindings
- Dependencias NuGet
- Patrones async/await
- Puntos de configuración

### Paso 2: Traducir el Código

**Comando:**

```
@csharp-to-java-migrator #read #skill java-translator traduce mi código
```

**Resultado:**

- Código Java idiomático
- Conversión async/await → CompletableFuture
- LINQ → Streams API
- Mantiene 100% funcionalidad

### Paso 3: Migrar HTTP Trigger (si aplica)

**Comando:**

```
@csharp-to-java-migrator migra mi http trigger
```

**Resultado:**

- @HttpTrigger configuration
- Route mapping
- Status codes handling
- Request/Response bodies

### Paso 4: Convertir Dependencias

**Comando:**

```
@csharp-to-java-migrator #read migra mis dependencias
```

**Resultado:**

- NuGet → Maven mapping
- pom.xml generado
- Versiones compatibles
- Resolución de conflictos

### Paso 5: Migrar Tests

**Comando:**

```
@csharp-to-java-migrator #read migra mis tests a junit
```

**Resultado:**

- xUnit → JUnit 5 conversion
- Mockito en lugar de Moq
- Assertions actualizadas
- Cobertura preservada

### Paso 6: Generar Reporte

**Comando:**

```
@csharp-to-java-migrator genera reporte de migración
```

**Resultado:**

- Resumen ejecutivo
- Cambios realizados
- Métricas de calidad
- Pasos siguientes

---

## 🎯 Prompts Disponibles (13 totales)

| #    | Prompt                         | Comando                      | Descripción                 |
| ---- | ------------------------------ | ---------------------------- | --------------------------- |
| 🚀   | **orchestrate-full-migration** | `migra todo automaticamente` | ⭐ **MIGRACIÓN AUTOMÁTICA** |
| 1️⃣   | analyze-csharp-function        | `analiza función`            | Analiza estructura C#       |
| 2️⃣   | translate-csharp-to-java       | `traduce código`             | Convierte a Java            |
| 3️⃣   | migrate-http-trigger           | `migra http trigger`         | HTTP bindings               |
| 4️⃣   | migrate-timer-trigger          | `migra timer trigger`        | Timer triggers              |
| 5️⃣   | migrate-queue-trigger          | `migra queue trigger`        | Queue triggers              |
| 6️⃣   | migrate-cosmos-trigger         | `migra cosmos trigger`       | Cosmos DB triggers          |
| 7️⃣   | migrate-dependencies           | `migra dependencias`         | NuGet → Maven               |
| 8️⃣   | generate-pom-xml               | `genera pom`                 | Crea pom.xml                |
| 9️⃣   | migrate-configuration          | `migra configuración`        | appsettings → properties    |
| 🔟   | migrate-testing                | `migra tests`                | xUnit → JUnit 5             |
| 1️⃣1️⃣ | migrate-exception-handling     | `migra excepciones`          | Manejo de errores           |
| 1️⃣2️⃣ | migration-report               | `genera reporte`             | Reporte completo            |

---

## 🎓 Skills Disponibles (2 totales)

### 1. C# Analyzer Skill

```
@csharp-to-java-migrator #skill csharp-analyzer [file]
```

Proporciona:

- Análisis de complejidad
- Mapeo de dependencias
- Detección de patrones
- Métricas de calidad
- Análisis async/await
- Detección de seguridad

### 2. Java Translator Skill

```
@csharp-to-java-migrator #skill java-translator [código]
```

Proporciona:

- Traducción idiomática
- Conversión de patrones
- Best practices
- Validación de sintaxis
- Async/await → CompletableFuture/Mono
- LINQ → Streams API
- Null coalescing → Optional

---

## 📚 Ejemplos Reales

### Ejemplo 1: Migrar HTTP Trigger

**Mi función C#:**

```csharp
[FunctionName("GetUser")]
public static async Task<IActionResult> Run(
    [HttpTrigger(AuthorizationLevel.Function, "get", Route = "users/{id}")]
    HttpRequest req,
    string id,
    ILogger log)
{
    log.LogInformation($"Getting user {id}");
    var user = await database.GetUserAsync(id);
    return new OkObjectResult(user);
}
```

**Comando:**

```
@csharp-to-java-migrator #read migra mi http trigger
```

**Resultado:**

```java
@FunctionName("GetUser")
public HttpResponseMessage run(
    @HttpTrigger(
        name = "req",
        methods = {HttpMethod.GET},
        authLevel = AuthorizationLevel.FUNCTION,
        route = "users/{id}")
    HttpRequestMessage<Optional<String>> request,
    @BindingName("id") String id,
    final ExecutionContext context) {

    final Logger logger = context.getLogger();
    logger.info("Getting user {}", id);

    User user = database.getUser(id).get();

    return request.createResponseBuilder(HttpStatus.OK)
        .body(user)
        .build();
}
```

---

### Ejemplo 2: Convertir Dependencias

**Mi .csproj:**

```xml
<ItemGroup>
    <PackageReference Include="Microsoft.Azure.Functions" Version="4.0.1" />
    <PackageReference Include="Newtonsoft.Json" Version="13.0.1" />
    <PackageReference Include="Azure.Storage.Blobs" Version="12.14.0" />
</ItemGroup>
```

**Comando:**

```
@csharp-to-java-migrator #read migra dependencias
```

**Resultado - pom.xml:**

```xml
<dependency>
    <groupId>com.microsoft.azure.functions</groupId>
    <artifactId>azure-functions-java-library</artifactId>
    <version>3.0.0</version>
</dependency>

<dependency>
    <groupId>com.fasterxml.jackson.core</groupId>
    <artifactId>jackson-databind</artifactId>
    <version>2.15.2</version>
</dependency>

<dependency>
    <groupId>com.azure</groupId>
    <artifactId>azure-storage-blob</artifactId>
    <version>12.14.0</version>
</dependency>
```

---

### Ejemplo 3: Migrar Tests

**Mi test C# (xUnit):**

```csharp
public class PaymentServiceTests
{
    private readonly PaymentService _service;

    public PaymentServiceTests()
        => _service = new PaymentService();

    [Fact]
    public async Task ProcessPayment_WithValidRequest_ReturnsSuccess()
    {
        var request = new PaymentRequest { Amount = 100 };
        var result = await _service.ProcessAsync(request);

        Assert.NotNull(result);
        Assert.True(result.Success);
        Assert.Equal(100, result.Amount);
    }
}
```

**Comando:**

```
@csharp-to-java-migrator #read migra mis tests
```

**Resultado - JUnit 5:**

```java
public class PaymentServiceTests {
    private PaymentService service;

    @BeforeEach
    void setUp() {
        service = new PaymentService();
    }

    @Test
    void testProcessPaymentWithValidRequestReturnsSuccess()
        throws Exception {

        PaymentRequest request = new PaymentRequest()
            .setAmount(BigDecimal.valueOf(100));

        PaymentResult result = service.process(request).get();

        assertNotNull(result);
        assertTrue(result.isSuccess());
        assertEquals(BigDecimal.valueOf(100), result.getAmount());
    }
}
```

---

## 🔑 Conceptos Clave Mapeados

### Triggers Azure Functions

| C#                  | Java               | Clase              |
| ------------------- | ------------------ | ------------------ |
| `[HttpTrigger]`     | `@HttpTrigger`     | HttpRequestMessage |
| `[TimerTrigger]`    | `@TimerTrigger`    | ExecutionContext   |
| `[QueueTrigger]`    | `@QueueTrigger`    | String/Message     |
| `[CosmosDBTrigger]` | `@CosmosDBTrigger` | List<T>            |
| `[BlobTrigger]`     | `@BlobTrigger`     | Stream             |

### Patrones Comunes

| C#                  | Java                               |
| ------------------- | ---------------------------------- |
| `async Task<T>`     | `CompletableFuture<T>` / `Mono<T>` |
| `.Where().Select()` | `.stream().filter().map()`         |
| `?? null`           | `Optional.orElse()`                |
| `using`             | `try-with-resources`               |
| `event`             | `Consumer<T>` / `Supplier<T>`      |

---

## 🚨 Troubleshooting

### Problema: El agente no entiende mi función

**Solución:**

```
@csharp-to-java-migrator #read analiza el archivo CardPayment.cs
```

Asegúrate de:

- ✅ Abrir el archivo en VS Code
- ✅ Usar #read para que el agente lo lea
- ✅ Ser específico: menciona el nombre del archivo

---

### Problema: Dependencias no se encuentran

**Solución:**

```
@csharp-to-java-migrator #read #search migra dependencias y encuentra equivalentes
```

El agente buscará:

- ✅ En Maven Central Repository
- ✅ Versiones compatibles
- ✅ Alternativas si no hay equivalente directo

---

### Problema: Async/await no se convierte bien

**Solución:**

```
@csharp-to-java-migrator #skill java-translator traduce mi async code a CompletableFuture
```

Especifica:

- ✅ El tipo de async (simple, chained, etc.)
- ✅ Si prefieres CompletableFuture o Reactor
- ✅ Si hay operaciones bloqueantes

---

## 📁 Estructura del Proyecto Migrado

```
java-function-migrated/
├── src/
│   ├── main/java/com/example/
│   │   ├── CardPayment.java
│   │   ├── models/
│   │   │   ├── PaymentRequest.java
│   │   │   └── PaymentResult.java
│   │   └── services/
│   │       └── PaymentService.java
│   └── test/java/com/example/
│       └── CardPaymentTests.java
├── pom.xml
├── function.json
├── host.json
├── local.settings.json
└── README.md
```

---

## ✅ Checklist de Migración

- [ ] Función C# analizada y entendida
- [ ] Código traducido a Java
- [ ] Triggers y bindings mapeados
- [ ] Dependencias convertidas a Maven
- [ ] Configuración migrada (appsettings → properties)
- [ ] Tests convertidos a JUnit 5
- [ ] Exception handling actualizado
- [ ] Performance validado
- [ ] Security review completado
- [ ] Documentación generada
- [ ] Tests pasando al 100%
- [ ] Reporte de migración generado

---

## � MIGRACIÓN AUTOMÁTICA PASO A PASO

### Flujo Completo con Progreso

```
$ @csharp-to-java-migrator migra todo automaticamente

✨ INICIANDO MIGRACIÓN AUTOMÁTICA...

═══════════════════════════════════════════════════════

📂 FASE 1: DISCOVERY & SETUP
──────────────────────────────
[████████████████████] 100% Complete

📁 PROJECT STRUCTURE ANALYSIS
Project Root: /Users/yegecali/Projects/CardPaymentFunction
Total .cs files: 8
Total .csproj files: 1
Total Test files: 2

Sample Files Found:
├── CardPaymentFunction.cs
├── Models/PaymentRequest.cs
├── Models/PaymentResult.cs
├── Services/PaymentService.cs
├── Tests/CardPaymentFunctionTests.cs
├── Tests/PaymentServiceTests.cs
├── CardPaymentFunction.csproj
└── appsettings.json

═══════════════════════════════════════════════════════

📁 FASE 2: DIRECTORY CREATION
──────────────────────────────
[████████████████████] 100% Complete

✅ Created: CardPaymentFunction-migrated/
✅ Created: CardPaymentFunction-migrated/src/main/java/com/example/payment/
✅ Created: CardPaymentFunction-migrated/src/test/java/com/example/payment/
✅ Created: CardPaymentFunction-migrated/config/
✅ Created: CardPaymentFunction-migrated/docs/

Directory Structure Ready:
CardPaymentFunction-migrated/
├── src/main/java/com/example/payment/
├── src/test/java/com/example/payment/
├── config/
├── docs/
└── resources/

═══════════════════════════════════════════════════════

🔍 FASE 3: ANALYSIS & PLANNING
──────────────────────────────
[████████████████████] 100% Complete

📊 CODE ANALYSIS RESULTS
Total Classes: 4
Total Methods: 18
Async Methods: 6
Dependencies Found: 12

Complexity Metrics:
├── High Complexity: 2 (will need attention)
├── Medium Complexity: 5
└── Low Complexity: 11

Async Patterns Detected:
├── async/await: 6 instances
├── Task<T>: 4 instances
└── ConfigureAwait: 3 instances

═══════════════════════════════════════════════════════

🔄 FASE 4: CODE MIGRATION
──────────────────────────
[████████████░░░░░░░░] 65% (5/8 files)

✅ CardPaymentFunction.cs → CardPaymentFunction.java
✅ Models/PaymentRequest.cs → PaymentRequest.java
✅ Models/PaymentResult.cs → PaymentResult.java
✅ Services/PaymentService.cs → PaymentService.java
✅ Utilities/CardValidator.cs → CardValidator.java

⏳ Translating: Models/PaymentProcessor.cs (2/3 steps)
⬜ Pending: Exceptions/PaymentException.cs
⬜ Pending: Config/PaymentConfig.cs

Estimated time: 8 minutes remaining

═══════════════════════════════════════════════════════

⚙️ FASE 5: CONFIGURATION
────────────────────────
[████████████████████] 100% Complete

✅ Generated: pom.xml
   - 15 dependencies mapped
   - Java 17 target version
   - Maven 3.9.1 compatible

✅ Generated: function.json
   - HttpTrigger configuration
   - Route mapping: /payment/process
   - Authorization: Function

✅ Generated: host.json
   - Function runtime: 4.x
   - Extension bundle: 4.x
   - Logging configured

✅ Generated: local.settings.json
   - Local development settings
   - Azure Storage connection
   - App insights key

═══════════════════════════════════════════════════════

🧪 FASE 6: TESTING MIGRATION
─────────────────────────────
[████████████████░░░░] 80% (2/3 test suites)

✅ CardPaymentFunctionTests.cs → CardPaymentFunctionTests.java
   ├── 12 test methods converted
   ├── Assertions: Assert → assertEquals
   ├── Mocking: Moq → Mockito
   └── ✅ All assertions validated

✅ PaymentServiceTests.cs → PaymentServiceTests.java
   ├── 8 test methods converted
   ├── Fixtures: Constructor → @BeforeEach
   ├── Async tests: Task → CompletableFuture
   └── ✅ All patterns converted

⏳ Converting: IntegrationTests.cs (50% complete)
   └── Database mock setup

═══════════════════════════════════════════════════════

✅ FASE 7: VALIDATION
─────────────────────
[████████████████████] 100% Complete

Maven Compilation:
✅ mvn clean compile - SUCCESS
   └── 0 errors, 0 warnings

Unit Tests:
✅ mvn test - ALL PASSED
   ├── CardPaymentFunctionTests: 12/12 ✅
   ├── PaymentServiceTests: 8/8 ✅
   └── IntegrationTests: 5/5 ✅
   └── Total Coverage: 94%

Security Scan:
✅ No critical vulnerabilities
✅ No high-risk dependencies
⚠️ 2 medium-risk deps (informational)

Performance:
✅ Compilation time: 45s
✅ Test execution: 12s
✅ No performance regressions

═══════════════════════════════════════════════════════

📚 FASE 8: DOCUMENTATION
────────────────────────
[████████████████████] 100% Complete

✅ MIGRATION_REPORT.md (8 KB)
   - Executive summary
   - Migration statistics
   - Mapping details
   - Recommendations

✅ IMPLEMENTATION_GUIDE.md (12 KB)
   - Setup instructions
   - Build & deploy steps
   - Troubleshooting
   - FAQ

✅ API_DOCUMENTATION.md (15 KB)
   - Endpoint documentation
   - Request/response examples
   - Error codes
   - Authentication

✅ README.md (5 KB)
   - Project overview
   - Quick start
   - File structure explanation

═══════════════════════════════════════════════════════

🎉 FASE 9: SUMMARY
───────────────────
[████████████████████] 100% Complete

📊 MIGRATION SUMMARY
═══════════════════════════════════════════════════════

✅ COMPLETE MIGRATION SUCCESSFUL

📈 Statistics:
├── Files Migrated: 8/8 (100%)
├── Tests Migrated: 3/3 (100%)
├── Lines of Code: 2,450 → 2,380 (-2.8%, more concise)
├── Compilation: ✅ SUCCESS
├── Tests Passing: 25/25 (100%)
└── Documentation: ✅ COMPLETE

🎯 Migration Metrics:
├── Code Quality Score: 9.4/10
├── Test Coverage: 94%
├── Performance Match: 99.8%
└── Security Status: ✅ SECURE

📂 Project Structure:
CardPaymentFunction-migrated/
├── src/main/java/com/example/payment/
│   ├── CardPaymentFunction.java ✅
│   ├── models/ (2 files) ✅
│   ├── services/ (1 file) ✅
│   └── utilities/ (1 file) ✅
├── src/test/java/com/example/payment/
│   └── *Tests.java (3 files) ✅
├── config/
│   ├── pom.xml ✅
│   ├── function.json ✅
│   ├── host.json ✅
│   └── local.settings.json ✅
├── docs/
│   ├── MIGRATION_REPORT.md ✅
│   ├── IMPLEMENTATION_GUIDE.md ✅
│   ├── API_DOCUMENTATION.md ✅
│   └── README.md ✅
└── .gitignore ✅

🚀 Next Steps:
1. cd CardPaymentFunction-migrated/
2. mvn clean package
3. func start (or deploy to Azure)
4. Test in your environment
5. Review documentation

⏱️ Total Execution Time: 85 minutes
📊 Files Created: 28
✨ Automation Level: 100%

═══════════════════════════════════════════════════════
✅ MIGRATION COMPLETE - Ready for production!
═══════════════════════════════════════════════════════
```

---

## 📝 Archivos Generados Automáticamente

### Estructura Completa Creada

```
CardPaymentFunction-migrated/
├── src/
│   ├── main/
│   │   └── java/com/example/payment/
│   │       ├── CardPaymentFunction.java (398 líneas)
│   │       ├── models/
│   │       │   ├── PaymentRequest.java
│   │       │   └── PaymentResult.java
│   │       ├── services/
│   │       │   └── PaymentService.java
│   │       └── utilities/
│   │           └── CardValidator.java
│   └── test/
│       └── java/com/example/payment/
│           ├── CardPaymentFunctionTests.java
│           ├── PaymentServiceTests.java
│           └── IntegrationTests.java
├── config/
│   ├── pom.xml (con 15 dependencias)
│   ├── function.json (HttpTrigger config)
│   ├── host.json (runtime config)
│   └── local.settings.json
├── src/main/resources/
│   └── application.properties
├── docs/
│   ├── MIGRATION_REPORT.md
│   ├── IMPLEMENTATION_GUIDE.md
│   ├── API_DOCUMENTATION.md
│   └── README.md
└── .gitignore
```

---

## 📞 Soporte y Ayuda

### Migración Automática Tiene Problema

```
@csharp-to-java-migrator #read debug migración automática
```

### Necesitas Ayuda Específica

```
@csharp-to-java-migrator ayudame con [problema específico]
```

Ejemplos:

- `@csharp-to-java-migrator ayudame con async/await conversion`
- `@csharp-to-java-migrator ayudame con dependency injection setup`
- `@csharp-to-java-migrator ayudame con cosmos trigger`
- `@csharp-to-java-migrator ayudame con tests que fallan`

### Revisar Documentación Generada

Después de la migración automática:

```bash
cd CardPaymentFunction-migrated/
cat docs/MIGRATION_REPORT.md
cat docs/IMPLEMENTATION_GUIDE.md
```

---

## 📊 Comparativa: Manual vs Automático

| Tarea             | Manual        | Automático     | Ahorro              |
| ----------------- | ------------- | -------------- | ------------------- |
| Análisis función  | 1 hora        | Automático     | 1 hora              |
| Traducción código | 2 horas       | Automático     | 2 horas             |
| Configurar Maven  | 30 min        | Automático     | 30 min              |
| Migrar tests      | 2 horas       | Automático     | 2 horas             |
| Documentación     | 1 hora        | Automático     | 1 hora              |
| Validación        | 1 hora        | Automático     | 1 hora              |
| **TOTAL**         | **7.5 horas** | **85 minutos** | **360% más rápido** |

---

## 🎯 Flujo de Decisión

```
¿Necesitas migrar función C#?
│
├─ ¿Quieres TODO automático?
│  └─ Sí → @csharp-to-java-migrator migra todo automaticamente
│
└─ ¿Prefieres aprender paso a paso?
   ├─ Analizar → @csharp-to-java-migrator analiza función
   ├─ Traducir → @csharp-to-java-migrator traduce código
   ├─ HTTP? → @csharp-to-java-migrator migra http trigger
   ├─ Tests? → @csharp-to-java-migrator migra tests
   └─ Deps? → @csharp-to-java-migrator migra dependencias
```

---

## ✨ Características Clave

✅ **Migración Automática Orquestada**

- Una sola línea de comando migra TODO
- 9 fases automáticas
- Progreso visual en tiempo real

✅ **Creación Automática de Directorios**

- Detecta nombre del proyecto
- Crea estructura profesional
- Directorio listo para usar

✅ **13 Prompts Especializados**

- Cada uno enfocado en una tarea
- Se pueden usar individualmente
- Se integran en migración automática

✅ **2 Skills Expertos**

- Análisis profundo de C#
- Traducción idiomática a Java

✅ **Generación de Documentación**

- MIGRATION_REPORT.md
- IMPLEMENTATION_GUIDE.md
- API_DOCUMENTATION.md
- README.md

✅ **Validación Completa**

- Compilación Maven
- Ejecución de tests
- Escaneo de seguridad
- Verificación de cobertura

---

## ✅ Checklist de Migración (Automático)

Cuando ejecutas `@csharp-to-java-migrator migra todo automaticamente`:

- [x] Función C# analizada y entendida
- [x] Código traducido a Java
- [x] Triggers y bindings mapeados
- [x] Dependencias convertidas a Maven
- [x] Configuración migrada (appsettings → properties)
- [x] Tests convertidos a JUnit 5
- [x] Exception handling actualizado
- [x] Performance validado
- [x] Security review completado
- [x] Documentación generada
- [x] Tests pasando al 100%
- [x] Reporte de migración generado
- [x] Directorio [ProjectName]-migrated/ creado
- [x] Todo listo para producción

---

## 📚 Documentación Adicional

- **MIGRACION_AUTOMATICA.md** - Guía detallada del flujo automático
- **MIGRACION_AUTOMATICA_COMPLETADA.md** - Resumen final con ejemplos
- **EJEMPLO_COMPLETO.md** - Migración paso a paso de ejemplo real
- **QUICKSTART.md** - Inicio rápido de 5 minutos

---

**Versión**: 2.0 (Con migración automática)  
**Última actualización**: 30 de enero, 2026  
**Status**: Producción ✅  
**Total de Líneas**: 2,800+  
**Prompts**: 13  
**Skills**: 2  
**Tiempo de Migración**: ~85 minutos (automático)
