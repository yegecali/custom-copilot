# 🎯 API Controller Documentation Generator - Skill Interactivo

<div align="center">

![Status](https://img.shields.io/badge/status-active-success?style=for-the-badge)
![Type](https://img.shields.io/badge/type-interactive-blue?style=for-the-badge)
![Version](https://img.shields.io/badge/version-1.0-orange?style=for-the-badge)

</div>

---

## 📖 Descripción

> 🤖 **Skill especializado** en documentar el flujo completo de controladores REST/API.
>
> Analiza desde la **Request** hasta la **Response**, documenta cada capa del flujo y genera un **diagrama de secuencia Mermaid** visual.

---

## 🚀 Cómo Usarlo

**Palabras clave para activar:**

```
"Documentame el controlador"
"Documenta este controller"
"Genera documentación del endpoint"
"Analiza el flujo del controlador"
```

**El skill:**

1. 📂 Identifica el controlador a documentar
2. 🔍 Analiza el código completo del flujo
3. 📝 Documenta request, validaciones, servicios, repositorios
4. 📊 Genera diagrama de secuencia Mermaid
5. 💾 Crea archivo markdown con documentación completa

---

## 🧠 Comportamiento del Skill

### 📏 Reglas Estrictas

<table>
<tr>
<td width="50%" valign="top">

#### ✅ SIEMPRE

- ✅ **Analiza** el código completo del controlador
- ✅ **Identifica** todas las capas (Controller → Service → Repository)
- ✅ **Documenta** request body, path params, query params
- ✅ **Documenta** validaciones y reglas de negocio
- ✅ **Documenta** responses (success y error)
- ✅ **Genera** diagrama Mermaid de secuencia
- ✅ **Crea** archivo markdown estructurado

</td>
<td width="50%" valign="top">

#### ❌ NUNCA

- ❌ **Asume** comportamiento sin analizar código
- ❌ **Omite** capas del flujo
- ❌ **Ignora** manejo de errores
- ❌ **Genera** diagramas incompletos
- ❌ **Deja** placeholders sin información
- ❌ **Documenta** sin verificar el código

</td>
</tr>
</table>

> 💡 **Principio clave:** Documentar con precisión analizando el código real.

---

## 📋 Proceso de Documentación

### 🔵 Fase 1: Identificar Controlador

**Opciones de entrada:**

1. **Usuario tiene archivo abierto** → Usar ese controlador
2. **Usuario especifica nombre** → Buscar por nombre/path
3. **Usuario pide listar** → Mostrar controladores disponibles

**Pregunta:**

```markdown
## 🎯 Identificación del Controlador

Detecté que tienes abierto: `[ControllerName.java]`

¿Quieres documentar este controlador?

- ✅ "sí" → Analizar este controlador
- 📝 "otro: [nombre]" → Buscar otro controlador
- 📂 "listar" → Mostrar todos los controladores
```

⏸️ **ESPERAR** confirmación del usuario

---

### 🔶 Fase 2: Análisis del Código

**Comandos a ejecutar:**

1. **Leer controlador completo**

   ```javascript
   read_file(controllerPath, startLine: 1, endLine: -1)
   ```

2. **Buscar servicios relacionados**

   ```javascript
   grep_search("@Service.*UserService", isRegexp: true)
   list_code_usages("UserService")
   ```

3. **Buscar repositorios relacionados**

   ```javascript
   grep_search("@Repository", isRegexp: true)
   ```

4. **Buscar DTOs y modelos**
   ```javascript
   grep_search("class.*DTO|class.*Request|class.*Response", isRegexp: true)
   ```

**Información a extraer del controlador:**

<table>
<tr>
<th width="30%">Elemento</th>
<th width="70%">Qué buscar</th>
</tr>
<tr>
<td><b>📍 Endpoint</b></td>
<td>
• <code>@GetMapping</code>, <code>@PostMapping</code>, etc.<br/>
• Path completo: <code>/api/v1/users/{id}</code><br/>
• HTTP Method: GET, POST, PUT, DELETE<br/>
• Produces/Consumes: JSON, XML
</td>
</tr>
<tr>
<td><b>📥 Request</b></td>
<td>
• <code>@RequestBody</code> → Body completo<br/>
• <code>@PathVariable</code> → Parámetros de ruta<br/>
• <code>@RequestParam</code> → Query parameters<br/>
• <code>@RequestHeader</code> → Headers requeridos
</td>
</tr>
<tr>
<td><b>✅ Validaciones</b></td>
<td>
• <code>@Valid</code>, <code>@Validated</code><br/>
• <code>@NotNull</code>, <code>@NotEmpty</code>, <code>@Size</code><br/>
• Validaciones custom en código
</td>
</tr>
<tr>
<td><b>🔧 Servicios</b></td>
<td>
• <code>@Autowired</code> services<br/>
• Métodos llamados<br/>
• Parámetros pasados
</td>
</tr>
<tr>
<td><b>💾 Repositorios</b></td>
<td>
• JPA repositories<br/>
• Queries ejecutadas<br/>
• Entidades manipuladas
</td>
</tr>
<tr>
<td><b>📤 Response</b></td>
<td>
• Return type<br/>
• Status codes: 200, 201, 400, 404, 500<br/>
• Response body structure<br/>
• Headers de respuesta
</td>
</tr>
<tr>
<td><b>⚠️ Excepciones</b></td>
<td>
• <code>try-catch</code> blocks<br/>
• <code>@ExceptionHandler</code><br/>
• Custom exceptions<br/>
• Error responses
</td>
</tr>
<tr>
<td><b>🔒 Seguridad</b></td>
<td>
• <code>@PreAuthorize</code><br/>
• <code>@Secured</code><br/>
• Roles requeridos<br/>
• Autenticación necesaria
</td>
</tr>
</table>

---

### 🔷 Fase 3: Documentar Flujo Completo

**Estructura del documento a generar:**

```markdown
# 📋 Documentación: [EndpointName]

---

## 📍 Información General

**Endpoint:** `[HTTP_METHOD] /api/v1/resource/{id}`  
**Controller:** `[ControllerClassName]`  
**Método:** `[methodName]`  
**Descripción:** [Propósito del endpoint]

---

## 📥 Request

### HTTP Method

`[GET/POST/PUT/DELETE/PATCH]`

### URL
```

[BASE_URL]/api/v1/resource/{id}

````

### Path Parameters

| Parámetro | Tipo | Requerido | Descripción |
|-----------|------|-----------|-------------|
| `id` | Long | Sí | ID del recurso |

### Query Parameters

| Parámetro | Tipo | Requerido | Default | Descripción |
|-----------|------|-----------|---------|-------------|
| `page` | Integer | No | 0 | Número de página |
| `size` | Integer | No | 10 | Tamaño de página |

### Headers

| Header | Tipo | Requerido | Descripción |
|--------|------|-----------|-------------|
| `Authorization` | String | Sí | Bearer token |
| `Content-Type` | String | Sí | `application/json` |

### Request Body

```json
{
  "field1": "string",
  "field2": 123,
  "field3": true
}
````

**Validaciones:**

- ✅ `field1`: NotNull, Size(min=3, max=50)
- ✅ `field2`: Min(0), Max(1000)
- ✅ `field3`: NotNull

---

## 🔄 Flujo de Ejecución

### 1️⃣ Controller Layer

**Clase:** `[ControllerClass]`  
**Método:** `[methodName]`

**Responsabilidades:**

- Recibir y validar request
- Llamar al servicio correspondiente
- Mapear response

**Código relevante:**

```java
[código del método del controller]
```

---

### 2️⃣ Service Layer

**Clase:** `[ServiceClass]`  
**Método:** `[methodName]`

**Responsabilidades:**

- Lógica de negocio
- Validaciones adicionales
- Coordinación de repositorios

**Código relevante:**

```java
[código del método del servicio]
```

---

### 3️⃣ Repository Layer

**Clase:** `[RepositoryClass]`  
**Operación:** `[findById/save/delete]`

**Responsabilidades:**

- Acceso a base de datos
- Queries JPA/SQL

**Query ejecutada:**

```sql
[query SQL si es custom]
```

---

## 📤 Response

### Success Response

**Status Code:** `200 OK`

```json
{
  "id": 123,
  "field1": "value",
  "field2": 456,
  "timestamp": "2026-02-07T10:30:00Z"
}
```

### Error Responses

#### 400 Bad Request

```json
{
  "error": "Validation failed",
  "message": "field1 must not be null",
  "timestamp": "2026-02-07T10:30:00Z"
}
```

#### 404 Not Found

```json
{
  "error": "Resource not found",
  "message": "Resource with id 123 not found",
  "timestamp": "2026-02-07T10:30:00Z"
}
```

#### 500 Internal Server Error

```json
{
  "error": "Internal server error",
  "message": "An unexpected error occurred",
  "timestamp": "2026-02-07T10:30:00Z"
}
```

---

## 🔒 Seguridad

**Autenticación:** Requerida ✅  
**Autorización:** `ROLE_USER`, `ROLE_ADMIN`  
**Anotaciones:** `@PreAuthorize("hasRole('USER')")`

---

## ⚡ Performance

**Complejidad:** O(n)  
**Cache:** Habilitado/No habilitado  
**Timeouts:** 30s  
**Rate Limiting:** 100 req/min

---

## 📊 Diagrama de Secuencia

```mermaid
[diagrama generado]
```

---

## 🧪 Ejemplo de Uso

### cURL

\`\`\`bash
curl -X POST https://api.example.com/api/v1/users \
 -H "Authorization: Bearer YOUR_TOKEN" \
 -H "Content-Type: application/json" \
 -d '{
"name": "John Doe",
"email": "john@example.com"
}'
\`\`\`

### Response

\`\`\`json
{
"id": 123,
"name": "John Doe",
"email": "john@example.com",
"createdAt": "2026-02-07T10:30:00Z"
}
\`\`\`

---

## 📝 Notas Adicionales

[Notas específicas del endpoint]

---

**Generado el:** 2026-02-07  
**Versión API:** v1.0  
**Última actualización:** 2026-02-07

````

---

### 🔹 Fase 4: Generar Diagrama Mermaid

**Estructura del diagrama:**

```mermaid
sequenceDiagram
    participant Client
    participant Controller
    participant Service
    participant Repository
    participant Database

    Client->>+Controller: [HTTP_METHOD] /api/v1/resource
    Note over Client,Controller: Headers: Authorization, Content-Type

    Controller->>Controller: Validar Request
    alt Validación falla
        Controller-->>Client: 400 Bad Request
    end

    Controller->>+Service: methodName(params)
    Note over Service: Lógica de negocio

    Service->>Service: Validaciones adicionales
    alt Validación de negocio falla
        Service-->>Controller: BusinessException
        Controller-->>Client: 422 Unprocessable Entity
    end

    Service->>+Repository: findById(id)
    Repository->>+Database: SELECT * FROM table WHERE id = ?
    Database-->>-Repository: ResultSet

    alt Recurso no encontrado
        Repository-->>Service: Optional.empty()
        Service-->>Controller: NotFoundException
        Controller-->>Client: 404 Not Found
    end

    Repository-->>-Service: Entity
    Service->>Service: Procesar datos
    Service-->>-Controller: DTO Response
    Controller-->>-Client: 200 OK + Response Body
````

**Lógica de generación:**

1. **Identificar participantes:**
   - Client (siempre)
   - Controller
   - Services llamados
   - Repositories llamados
   - External APIs (si hay)
   - Cache (si se usa)
   - Database (si hay persistence)

2. **Identificar interacciones:**
   - Request inicial
   - Validaciones
   - Llamadas entre capas
   - Queries a DB
   - Responses

3. **Identificar flujos alternativos:**
   - Validaciones fallidas
   - Excepciones
   - Cache hit/miss
   - Timeouts

---

### 🔸 Fase 5: Generación del Archivo

**Nombre del archivo:**

```
DOCS-[ControllerName]-[MethodName]-[HTTPMethod].md
```

**Ejemplos:**

- `DOCS-UserController-createUser-POST.md`
- `DOCS-OrderController-getOrderById-GET.md`
- `DOCS-PaymentController-processPayment-POST.md`

**Ubicación:**

```
docs/api/controllers/[ControllerName]/
```

---

## 🛠️ Tools a Usar

<table>
<tr>
<th width="30%">Tool</th>
<th width="70%">Uso</th>
</tr>
<tr>
<td><b>📖 read_file</b></td>
<td>
Leer controlador completo<br/>
Leer servicios relacionados<br/>
Leer repositorios<br/>
Leer DTOs/Models
</td>
</tr>
<tr>
<td><b>🔍 grep_search</b></td>
<td>
Buscar anotaciones Spring<br/>
Buscar validaciones<br/>
Buscar excepciones<br/>
Buscar dependencias
</td>
</tr>
<tr>
<td><b>🔗 list_code_usages</b></td>
<td>
Ver cómo se usa el servicio<br/>
Ver flujo completo<br/>
Identificar dependencias
</td>
</tr>
<tr>
<td><b>📂 file_search</b></td>
<td>
Buscar controladores<br/>
Buscar servicios por nombre<br/>
Buscar DTOs
</td>
</tr>
<tr>
<td><b>📁 create_file</b></td>
<td>
Crear archivo de documentación<br/>
Con contenido completo<br/>
En ubicación correcta
</td>
</tr>
<tr>
<td><b>📋 manage_todo_list</b></td>
<td>
Trackear progreso análisis<br/>
• Controller analizado<br/>
• Services identificados<br/>
• Repositories identificados<br/>
• Diagrama generado<br/>
• Archivo creado
</td>
</tr>
</table>

---

## 🎯 Ejemplo de Sesión Completa

````
Usuario:
"Documentame el controlador"

Skill:
## 🎯 API Controller Documentation Generator

Detecté que tienes abierto: `UserController.java`

¿Quieres documentar este controlador?
- ✅ "sí" → Analizar UserController
- 📝 "otro: [nombre]" → Buscar otro controlador
- 📂 "listar" → Mostrar todos los controladores

---

Usuario:
"sí"

Skill:
✅ **Analizando:** `UserController.java`

📊 Progreso: [████░░░░░░] 40%

---

### 🔍 Análisis en progreso...

✅ Controlador leído (250 líneas)
✅ 3 endpoints identificados
✅ 2 servicios encontrados (UserService, EmailService)
✅ 1 repository encontrado (UserRepository)
✅ 5 DTOs identificados
⏳ Analizando flujo de ejecución...

---

Skill:
## 📋 Endpoints Detectados

Encontré 3 endpoints en `UserController`:

1️⃣ **POST** `/api/v1/users` - createUser
   - Service: UserService.createUser()
   - Repository: UserRepository.save()

2️⃣ **GET** `/api/v1/users/{id}` - getUserById
   - Service: UserService.findById()
   - Repository: UserRepository.findById()

3️⃣ **PUT** `/api/v1/users/{id}` - updateUser
   - Service: UserService.updateUser()
   - Repository: UserRepository.save()

¿Documentar todos o elegir uno?
- 📦 "todos" → Documentar los 3 endpoints
- 1️⃣ "1" → Solo createUser
- 2️⃣ "2" → Solo getUserById
- 3️⃣ "3" → Solo updateUser

---

Usuario:
"2"

Skill:
✅ **Documentando:** GET `/api/v1/users/{id}` - getUserById

📊 Progreso: [████████░░] 80%

---

### 📝 Análisis Completado

**Controller:** UserController
**Método:** getUserById(Long id)
**HTTP Method:** GET
**Path:** /api/v1/users/{id}

**Flujo identificado:**
1. Controller recibe request con @PathVariable id
2. Valida que id > 0
3. Llama a UserService.findById(id)
4. Service llama a UserRepository.findById(id)
5. Repository ejecuta query JPA
6. Si no existe → NotFoundException (404)
7. Si existe → mapea a UserDTO y retorna 200

**Seguridad:**
- @PreAuthorize("hasRole('USER')")
- Requiere Bearer token

**Generando diagrama Mermaid...**

---

Skill:
## 🎉 ¡Documentación Generada!

### 📄 Archivo creado:

📁 `docs/api/controllers/UserController/DOCS-UserController-getUserById-GET.md`

### 📊 Contenido incluye:

✅ Información general del endpoint
✅ Detalles completos del request
✅ Documentación del flujo (3 capas)
✅ Responses (success + errores)
✅ Configuración de seguridad
✅ Diagrama de secuencia Mermaid
✅ Ejemplos de uso (cURL)

### 🔍 Preview del diagrama:

```mermaid
sequenceDiagram
    participant Client
    participant UserController
    participant UserService
    participant UserRepository
    participant Database

    Client->>+UserController: GET /api/v1/users/{id}
    UserController->>UserController: Validar id > 0
    UserController->>+UserService: findById(id)
    UserService->>+UserRepository: findById(id)
    UserRepository->>+Database: SELECT * FROM users WHERE id = ?
    Database-->>-UserRepository: ResultSet

    alt User not found
        UserRepository-->>UserService: Optional.empty()
        UserService-->>UserController: NotFoundException
        UserController-->>Client: 404 Not Found
    end

    UserRepository-->>-UserService: User entity
    UserService->>UserService: Map to UserDTO
    UserService-->>-UserController: UserDTO
    UserController-->>-Client: 200 OK + UserDTO
````

---

¿Documentar otro endpoint? 🚀

````

---

## 🔍 Análisis Inteligente de Flujos

### Detección Automática

<details>
<summary><b>🔍 Click para ver patrones de detección</b></summary>

**Patrón REST estándar:**
```java
@RestController
@RequestMapping("/api/v1/users")
public class UserController {

    @Autowired
    private UserService userService;

    @GetMapping("/{id}")
    public ResponseEntity<UserDTO> getUserById(@PathVariable Long id) {
        // Flujo detectado automáticamente
    }
}
````

**Patrón con validaciones:**

```java
@PostMapping
public ResponseEntity<UserDTO> createUser(
    @Valid @RequestBody CreateUserRequest request
) {
    // Detectar: @Valid, @RequestBody, validaciones
}
```

**Patrón con seguridad:**

```java
@PreAuthorize("hasRole('ADMIN')")
@DeleteMapping("/{id}")
public ResponseEntity<Void> deleteUser(@PathVariable Long id) {
    // Detectar: roles, autorización
}
```

**Patrón async:**

```java
@GetMapping("/async/{id}")
public CompletableFuture<UserDTO> getUserAsync(@PathVariable Long id) {
    // Detectar: operación asíncrona
}
```

**Patrón reactive:**

```java
@GetMapping("/reactive/{id}")
public Mono<UserDTO> getUserReactive(@PathVariable Long id) {
    // Detectar: WebFlux, Mono/Flux
}
```

</details>

---

## 🔒 Constraints Finales

<table>
<tr>
<td width="50%" bgcolor="#ffebee">

### ❌ NUNCA

- ❌ Documentar sin analizar código
- ❌ Generar diagramas genéricos
- ❌ Omitir capas del flujo
- ❌ Ignorar manejo de errores
- ❌ Asumir estructura sin verificar
- ❌ Dejar información incompleta

</td>
<td width="50%" bgcolor="#e8f5e9">

### ✅ SIEMPRE

- ✅ Analizar código completo
- ✅ Verificar todas las capas
- ✅ Documentar validaciones
- ✅ Incluir error handling
- ✅ Generar diagrama preciso
- ✅ Crear archivo estructurado

</td>
</tr>
</table>

### 🛡️ Principios de Operación

```diff
+ PRECISIÓN sobre VELOCIDAD
+ ANÁLISIS sobre SUPOSICIÓN
+ COMPLETITUD sobre BREVEDAD
+ DIAGRAMAS VISUALES sobre TEXTO PLANO
+ CÓDIGO REAL sobre EJEMPLOS GENÉRICOS
```

---

<div align="center">

### 💚 Listo para Usar

**Palabras clave de activación:**

_"Documentame el controlador"_

---

![Ready](https://img.shields.io/badge/status-ready-success?style=for-the-badge&logo=markdown)
![Automated](https://img.shields.io/badge/automated-docs-blue?style=for-the-badge&logo=readme)
![Mermaid](https://img.shields.io/badge/diagrams-mermaid-orange?style=for-the-badge&logo=mermaid)

</div>
