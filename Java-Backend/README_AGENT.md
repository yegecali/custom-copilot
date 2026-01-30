# 📚 Guía Completa: Cómo Usar tu Custom Agent Java Backend

Este documento es una guía paso a paso para usar tu agente personalizado `java-backend` en VS Code, activar herramientas, ejecutar prompts y aprovechar tus skills especializados.

---

## 🚀 Inicio Rápido: 5 Pasos

### 1️⃣ Abre el Chat en VS Code

**Opción A - Atajo de Teclado:**

- **Mac:** `Cmd + Shift + L` o `Cmd + I`
- **Windows/Linux:** `Ctrl + Shift + L` o `Ctrl + I`

**Opción B - Menú Visual:**

1. Click en el icono de **Chat** en la barra lateral izquierda
2. O busca en Command Palette: `Cmd + Shift + P` → escribe "GitHub Copilot: Open Chat"

---

### 2️⃣ Activa tu Agent Custom

Una vez que el chat esté abierto, necesitas **activar tu agente** escribiendo:

```
@java-backend
```

Luego escribe tu pregunta. Por ejemplo:

```
@java-backend revisa mi código de CardService
```

**¿Por qué?** Esto activa el agente especializado en Java backend en lugar del Copilot genérico.

---

### 3️⃣ Activa las Tools (Herramientas)

El agente tiene tools disponibles automáticamente, pero puedes **controlar cuáles se usan** escribiendo:

```
@github.copilot #web #file #codebase
```

**Tools disponibles en tu agent:**

- `#vscode` - Acceder a archivos VS Code
- `#execute` - Ejecutar comandos
- `#read` - Leer archivos
- `#edit` - Editar archivos
- `#search` - Buscar en el código
- `#web` - Buscar en internet
- `#agent` - Ejecutar sub-agentes
- `#todo` - Gestionar tareas

**Ejemplo completo:**

```
@java-backend #read #search revisa mi código de CardService
```

---

### 4️⃣ Ejecuta un Prompt (Tarea Específica)

Tu agente tiene **12 prompts especializados**. Aquí cómo usarlos:

#### **Opción A: Comando Directo**

```
@java-backend revisa mi código de CardService
```

_El agente automáticamente selecciona el prompt correcto_

#### **Opción B: Usar Nombre Exacto del Prompt**

Si quieres ser explícito, usa el comando exact:

```
@java-backend code-review-performance-security
```

**Prompts disponibles:**

| #   | Prompt                           | Comando de Ejemplo                   |
| --- | -------------------------------- | ------------------------------------ |
| 1   | analyze-design-patterns          | `@java-backend analiza patrones`     |
| 2   | code-review-performance-security | `@java-backend code review`          |
| 3   | conventional-commit-assistant    | `@java-backend genera commit`        |
| 4   | detect-antipatterns              | `@java-backend detecta antipatterns` |
| 5   | generate-openapi                 | `@java-backend genera openapi`       |
| 6   | generate-sequence-diagram        | `@java-backend genera diagrama`      |
| 7   | jira-readme                      | `@java-backend documenta jira`       |
| 8   | project-refactor                 | `@java-backend analiza deuda`        |
| 9   | fortify-checker-obs              | `@java-backend fortify check`        |
| 10  | iriuskrisk-review                | `@java-backend iriuskrisk check`     |
| 11  | refactoring-loggers              | `@java-backend refactor logs`        |
| 12  | maven-dependencies-checker       | `@java-backend analiza deps`         |

---

### 5️⃣ Usa un Skill (Capacidad Especializada)

Los **skills** son capacidades avanzadas para tareas específicas.

#### **Activar un Skill:**

```
@java-backend #skill java-code-review
```

O dentro del contexto de tu petición:

```
@java-backend #skill pr-change-analyzer revisa mis cambios
```

**Skills disponibles:**

| Skill                  | Descripción                         | Cuándo usar                              |
| ---------------------- | ----------------------------------- | ---------------------------------------- |
| **java-code-review**   | Revisión senior de código Java      | Cuando necesitas code review profesional |
| **pr-change-analyzer** | Analizar cambios en PR/commits      | Cuando tienes cambios para revisar       |
| **checkstyle-review**  | Validación CheckStyle + conventions | Cuando necesitas validar code style      |

---

## 📖 Guía Detallada por Caso de Uso

### 📋 Caso 1: Revisar mi Código (Code Review)

**Paso 1 - Abre el chat:**

```
Cmd + Shift + L
```

**Paso 2 - Escribe el comando:**

```
@java-backend #read #search revisa mi código de CardService
```

**Paso 3 - El agente hará:**

- ✅ Leer los archivos de CardService
- ✅ Buscar patrones de código
- ✅ Revisar performance y seguridad OWASP
- ✅ Proporcionar recomendaciones

**Resultado esperado:**

```
## Code Review: CardService

### Performance Analysis
- ❌ N+1 Query detected in getCardsByUser()
- ✅ Proper caching strategy in place

### Security Issues
- ⚠️ Missing SQL injection validation
- ✅ Proper credential handling

### Recommendations
1. Use @Query with JOIN FETCH
2. Add input validation
...
```

---

### 🔀 Caso 2: Generar un Commit

**Paso 1 - Abre el chat:**

```
Cmd + Shift + L
```

**Paso 2 - Escribe:**

```
@java-backend genera commit
```

**Paso 3 - El agente hará:**

- ✅ Detectar archivos modificados con `get_changed_files`
- ✅ Analizarlos con el prompt `conventional-commit-assistant`
- ✅ Generar mensaje con Jira ticket

**Resultado esperado:**

```
feat(JIRA-123): Add user authentication service

- Implement JWT token generation
- Add password hashing with BCrypt
- Create AuthService interface
- Add unit tests for auth flow

JIRA: JIRA-123
Type: feature
```

---

### 📝 Caso 3: Documentar un Ticket Jira

**Paso 1 - Abre el chat:**

```
Cmd + Shift + L
```

**Paso 2 - Escribe:**

```
@java-backend documenta el ticket TEST-456
```

**Paso 3 - El agente hará:**

- ✅ Leer archivos relacionados
- ✅ Aplicar el prompt `jira-readme`
- ✅ Generar documentación completa

**Resultado esperado:**

```
# TEST-456: Implement Payment Processing

## Overview
User story para implementar procesamiento de pagos...

## Acceptance Criteria
- [ ] GET /api/payments/{id} returns payment details
- [ ] POST /api/payments validates amount
- [ ] Error handling for insufficient funds

## Technical Design
...

## Implementation Steps
1. Create Payment entity
2. Implement PaymentRepository
...
```

---

### 🐛 Caso 4: Revisar mis Cambios de PR (Pull Request)

**Paso 1 - Abre el chat:**

```
Cmd + Shift + L
```

**Paso 2 - Escribe:**

```
@java-backend #skill pr-change-analyzer
```

**Paso 3 - El agente hará:**

- ✅ Obtener cambios con `get_changed_files`
- ✅ Analizar diferencias
- ✅ Revisar calidad con `pr-change-analyzer` skill
- ✅ Proporcionar feedback

**Resultado esperado:**

```
## PR Analysis: 5 files changed

### CardService.java
✅ Good: Proper dependency injection
⚠️ Warning: Complex method with 20+ lines
❌ Issue: Missing @Transactional annotation

### CardServiceTest.java
✅ Good: 85% code coverage
✅ Good: Using @Mock correctly
...

### Overall Assessment
- Quality Score: 82/100
- Risk Level: Low
- Ready to merge: YES
```

---

### 🔍 Caso 5: Analizar Patrones de Diseño

**Paso 1 - Abre el chat:**

```
Cmd + Shift + L
```

**Paso 2 - Escribe:**

```
@java-backend analiza los patrones de diseño en mi controller
```

**Paso 3 - Resultado:**

```
## Design Patterns Analysis

### Detected Patterns
1. **Dependency Injection Pattern** ✅
   - Location: CardController
   - Correct usage: YES

2. **Strategy Pattern** ✅
   - In: PaymentProcessor interface
   - Status: Well implemented

3. **Singleton Pattern** ⚠️
   - Location: DatabaseConnection
   - Issue: Not thread-safe
   - Recommendation: Use synchronized or Spring @Singleton
```

---

### 🔒 Caso 6: Detectar Problemas de Seguridad

**Paso 1 - Abre el chat:**

```
Cmd + Shift + L
```

**Paso 2 - Escribe:**

```
@java-backend detecta problemas de seguridad
```

**Paso 3 - Resultado:**

```
## Security Analysis

### Critical Issues 🔴
- Hardcoded credentials found in application.properties
- SQL injection vulnerability in UserRepository

### High Issues 🟠
- Missing CORS configuration
- No rate limiting on login endpoint

### Medium Issues 🟡
- Missing input validation on file upload
- Weak password policy

### Recommendations
1. Move credentials to environment variables
2. Use parameterized queries
...
```

---

### 📊 Caso 7: Chequear Vulnerabilidades Fortify

**Paso 1 - Abre el chat:**

```
Cmd + Shift + L
```

**Paso 2 - Escribe:**

```
@java-backend fortify check
```

**Paso 3 - Resultado:**

```
## Fortify Security Analysis

### Critical Vulnerabilities
- [CVSS 9.8] SQL Injection in UserRepository.findByEmail()
  - Remediation: Use @Query with parameterized queries

### High Vulnerabilities
- [CVSS 8.2] Hardcoded Password in DatabaseConfig
  - Remediation: Use Spring Cloud Config Server

...

### CVSS Score Summary
- Critical: 1 (CVSS 9.8)
- High: 3 (CVSS avg 8.1)
- Medium: 5
- Overall Risk: HIGH
```

---

### 📈 Caso 8: Analizar Dependencias Maven

**Paso 1 - Abre el chat:**

```
Cmd + Shift + L
```

**Paso 2 - Escribe:**

```
@java-backend analiza mis dependencias
```

**Paso 3 - Resultado:**

```
## Maven Dependency Analysis

### Outdated Dependencies
- spring-boot: 2.7.0 → 3.2.1 (LATEST)
- junit: 4.13.2 → 5.10.1 (LATEST)
- log4j: 2.19.0 → 2.22.1 (SECURITY UPDATE)

### Vulnerable Dependencies
⚠️ log4j-core:2.19.0
   - CVE-2023-44271 (CRITICAL)
   - Action: Upgrade to 2.22.1

### Unused Dependencies
- org.apache.commons:commons-lang3:3.12.0
  - Recommendation: Remove if not needed

### Size Analysis
- Total JAR size: 52MB
- Largest: spring-boot-starter-web (8MB)
```

---

## 🎯 Tablas de Referencia Rápida

### Comandos Principales

```
@java-backend [PALABRA_CLAVE]
```

| Palabra clave                     | Prompt que se activa             |
| --------------------------------- | -------------------------------- |
| `revisa`, `review`, `code`        | code-review-performance-security |
| `commit`, `git`                   | conventional-commit-assistant    |
| `jira`, `ticket`, `documenta`     | jira-readme                      |
| `patrones`, `design`              | analyze-design-patterns          |
| `antipatterns`, `malas prácticas` | detect-antipatterns              |
| `openapi`, `swagger`              | generate-openapi                 |
| `diagrama`, `sequence`            | generate-sequence-diagram        |
| `deuda técnica`, `refactor`       | project-refactor                 |
| `fortify`, `vulnerabilities`      | fortify-checker-obs              |
| `iriuskrisk`, `riesgos`           | iriuskrisk-review                |
| `loggers`, `logs`                 | refactoring-loggers              |
| `dependencias`, `maven`           | maven-dependencies-checker       |

---

### Activar Tools Específicas

```
@java-backend #[TOOL_NAME]
```

| Tool       | Uso                        |
| ---------- | -------------------------- |
| `#read`    | Leer archivos del proyecto |
| `#search`  | Buscar en el código        |
| `#edit`    | Editar archivos            |
| `#execute` | Ejecutar comandos          |
| `#web`     | Buscar en internet         |
| `#vscode`  | Usar API de VS Code        |

---

### Activar Skills

```
@java-backend #skill [SKILL_NAME]
```

| Skill                | Descripción                 |
| -------------------- | --------------------------- |
| `java-code-review`   | Análisis profundo de código |
| `pr-change-analyzer` | Análisis de cambios en PR   |
| `checkstyle-review`  | Validación de estilo        |

---

## ⚙️ Configuración Avanzada

### Cambiar las Instrucciones Aplicadas

El agente aplica estándares por defecto:

```
✅ Clean Code + SOLID
✅ Conventional Commits + Jira
✅ Gherkin para acceptance criteria
✅ OWASP para seguridad
✅ Inmutabilidad por defecto
✅ Tests obligatorios
```

**Para usar instrucciones específicas:**

```
@java-backend #instructions copilot-instructions-security
```

O combina múltiples:

```
@java-backend #instructions copilot-instructions-java copilot-instructions-spring
```

**Instrucciones disponibles:**

| Instruction                       | Aplica a                             |
| --------------------------------- | ------------------------------------ |
| `copilot-instructions-java`       | Java 17+ features, SOLID, Clean Code |
| `copilot-instructions-spring`     | Spring Boot 3.x, WebFlux, JPA        |
| `copilot-instructions-quarkus`    | Quarkus 3.x, Mutiny, Panache         |
| `copilot-instructions-testing`    | JUnit 5, AAA pattern, mocks          |
| `copilot-instructions-security`   | OWASP, SpotBugs, Fortify             |
| `copilot-instructions-logging`    | Structured logging, MDC              |
| `copilot-instructions-serverless` | AWS Lambda, Azure Functions          |

---

## 🔧 Ejemplos Combinados Reales

### Ejemplo 1: Code Review + Security Check

```
@java-backend #read #search #instructions copilot-instructions-security revisa mi CardService y chequea vulnerabilidades
```

**Resultado:**

- Code review completo
- Análisis OWASP
- Recomendaciones de seguridad

---

### Ejemplo 2: Refactor + Testing

```
@java-backend #read #instructions copilot-instructions-testing analiza deuda técnica y necesito mejorar los tests
```

**Resultado:**

- Identificación de código legacy
- Propuestas de refactoring
- Mejoras en cobertura de tests

---

### Ejemplo 3: Documentación Completa de Ticket

```
@java-backend #read #edit #instructions copilot-instructions-spring documenta JIRA-123 como user story con acceptance criteria y diagrama de secuencia
```

**Resultado:**

- Documentación Jira completa
- Criterios de aceptación en Gherkin
- Diagrama de secuencia Mermaid
- Archivos generados en el proyecto

---

## 🚨 Troubleshooting

### Problema: El agente no responde

**Solución:**

1. Asegúrate de escribir `@java-backend` primero
2. Verifica que tengas permisos en el proyecto
3. Intenta cerrar y abrir el chat nuevamente

```
Cmd + Shift + L → Cerrar chat → Cmd + Shift + L → Abrir de nuevo
```

---

### Problema: El prompt no se ejecuta correctamente

**Solución:**

1. Verifica que el archivo existe: `Cmd + P` y busca el archivo
2. Prueba con el nombre exacto del prompt:
   ```
   @java-backend code-review-performance-security
   ```
3. Añade tools explícitamente:
   ```
   @java-backend #read #search code-review-performance-security
   ```

---

### Problema: Los skills no funcionan

**Solución:**

1. Verifica que el skill existe en `.github/skills/`
2. Usa la sintaxis correcta:
   ```
   @java-backend #skill java-code-review
   ```
3. No mezcles skill con prompt, usa uno a la vez:
   ```
   ❌ @java-backend #skill java-code-review code review
   ✅ @java-backend #skill java-code-review
   ```

---

## 📁 Estructura de Archivos

```
.github/
├── agents/
│   └── java-backend.agent.md          ← Tu agente custom
├── prompts/
│   ├── analyze-design-patterns-v2.prompt.md
│   ├── code-review-performance-security-v2.prompt.md
│   ├── conventional-commit-assistant-v2.prompt.md
│   ├── detect-antipatterns-v2.prompt.md
│   ├── fortify-checker-obs.prompt.md
│   ├── generate-openapi-v2.prompt.md
│   ├── generate-sequence-diagram-v2.prompt.md
│   ├── iriuskrisk-review.prompt.md
│   ├── jira-readme-v2.prompt.md
│   ├── maven-dependencies-checker.prompt.md
│   ├── project-refactor-v2.prompt.md
│   └── refactoring-loggers.prompt.md
├── skills/
│   ├── java-code-review/
│   ├── pr-change-analyzer/
│   └── checkstyle-review/
└── instructions/
    ├── copilot-instructions.md
    ├── copilot-instructions-spring.md
    ├── copilot-instructions-quarkus.md
    ├── copilot-instructions-testing.md
    ├── copilot-instructions-security.md
    ├── copilot-instructions-logging.md
    └── copilot-instructions-serverless.md
```

---

## 🎓 Mejores Prácticas

✅ **DO:**

- Sé específico: `revisa CardService` mejor que `revisa código`
- Usa tools explícitamente: `@java-backend #read #search`
- Combina con instrucciones: `#instructions copilot-instructions-security`
- Agrupa tareas: Commit + Test + Review en una sesión

❌ **DON'T:**

- No escribas solo `revisa código` sin contexto
- No mezcles múltiples skills en un mismo mensaje
- No hagas peticiones sin activar `@java-backend`
- No combines skill + prompt en el mismo comando

---

## 📞 Soporte

- **¿Preguntas?** Abre una issue en tu repositorio
- **¿Mejoras?** Edita los prompts en `.github/prompts/`
- **¿Nuevos skills?** Crea carpetas en `.github/skills/`

---

**Última actualización:** 30 de enero, 2026  
**Versión:** 1.0  
**Autor:** Tu equipo de Java Backend
