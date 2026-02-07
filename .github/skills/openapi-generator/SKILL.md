# 🎯 OpenAPI Generator - Skill Interactivo

<div align="center">

![Status](https://img.shields.io/badge/status-active-success?style=for-the-badge)
![Type](https://img.shields.io/badge/type-interactive-blue?style=for-the-badge)
![Version](https://img.shields.io/badge/version-1.0-orange?style=for-the-badge)

</div>

---

## 📖 Descripción

> 🤖 **Skill especializado** en generar especificaciones OpenAPI automáticamente desde controladores REST.
>
> Analiza controladores, extrae endpoints, modelos, y genera un **OpenAPI 3.1 válido** listo para usar con Swagger UI.

---

## 🚀 Cómo Usarlo

**Palabras clave para activar:**

```
"Genera OpenAPI"
"Crea especificación OpenAPI"
"Genera Swagger de los controllers"
"Documenta la API en OpenAPI"
"OpenAPI de mis endpoints"
```

**El skill:**

1. 🔍 Busca todos los controladores REST
2. 📊 Extrae endpoints, métodos HTTP, paths
3. 📝 Mapea request bodies, params, responses
4. 🏗️ Genera especificación OpenAPI 3.1 válida
5. 💾 Crea archivo YAML/JSON

---

## 🧠 Comportamiento del Skill

### 📏 Reglas Estrictas

<table>
<tr>
<td width="50%" valign="top">

#### ✅ SIEMPRE

- ✅ **Analiza** todos los controllers del proyecto
- ✅ **Extrae** endpoints completos con paths
- ✅ **Mapea** request bodies y DTOs
- ✅ **Mapea** responses con status codes
- ✅ **Identifica** parámetros (path, query, header)
- ✅ **Genera** OpenAPI 3.1 válido
- ✅ **Valida** sintaxis YAML/JSON

</td>
<td width="50%" valign="top">

#### ❌ NUNCA

- ❌ **Asume** estructura sin analizar
- ❌ **Omite** endpoints
- ❌ **Deja** esquemas vacíos
- ❌ **Genera** YAML inválido
- ❌ **Ignora** validaciones
- ❌ **Omite** responses de error

</td>
</tr>
</table>

> 💡 **Principio clave:** Generación precisa desde código real.

---

## 📋 Proceso de Generación

### 🔵 Fase 1: Configuración Inicial

**Preguntas al usuario:**

```markdown
## ⚙️ Configuración de OpenAPI

### 1️⃣ Información de la API

**Título de la API:**
[Ejemplo: "User Management API"]

**Versión:**
[Ejemplo: "1.0.0"]

**Descripción:**
[Ejemplo: "API para gestión de usuarios y autenticación"]

---

### 2️⃣ Configuración del Servidor

**Base URL:**
[Ejemplo: "https://api.example.com/v1"]

**Ambiente:**

- 🟢 "production" → https://api.example.com
- 🟡 "staging" → https://staging-api.example.com
- 🔵 "development" → http://localhost:8080
- 📝 "custom: [URL]" → URL personalizada

---

### 3️⃣ Configuración de Seguridad

**¿Requiere autenticación?**

- ✅ "sí" → Configurar esquema de seguridad
- ❌ "no" → API pública

**Si sí, ¿qué tipo?**

- 🔐 "bearer" → Bearer Token (JWT)
- 🗝️ "apikey" → API Key
- 👤 "oauth2" → OAuth2
- 🔑 "basic" → Basic Auth

---

### 4️⃣ Formato de Salida

**¿Formato del archivo?**

- 📄 "yaml" → openapi.yaml (recomendado)
- 📋 "json" → openapi.json
- 🎯 "ambos" → Generar ambos formatos
```

**Valores por defecto:**

- Título: Nombre del proyecto
- Versión: "1.0.0"
- Base URL: "http://localhost:8080"
- Seguridad: Bearer Token
- Formato: YAML

---

### 🔶 Fase 2: Buscar Controllers

**Secuencia de búsqueda:**

1️⃣ **Buscar archivos de controllers**

```javascript
file_search("**/*Controller.java");
file_search("**/*controller.py");
file_search("**/*controller.ts");
file_search("**/*Controller.cs");
```

2️⃣ **Identificar controllers REST**

```javascript
grep_search("@RestController|@Controller", isRegexp: true)
grep_search("@RequestMapping", isRegexp: true)
```

3️⃣ **Listar controllers encontrados**

```markdown
## 📂 Controllers Encontrados

✅ 5 controllers REST identificados:

1. UserController (8 endpoints)
2. AuthController (4 endpoints)
3. ProductController (6 endpoints)
4. OrderController (7 endpoints)
5. PaymentController (3 endpoints)

**Total:** 28 endpoints

¿Incluir todos?

- ✅ "todos" → Incluir todos los controllers
- 📝 "seleccionar" → Elegir cuáles incluir
- 🎯 "solo: UserController, AuthController" → Específicos
```

---

### 🔷 Fase 3: Analizar Endpoints

**Para cada controller seleccionado:**

**Información a extraer:**

<table>
<tr>
<th width="25%">Elemento</th>
<th width="75%">Qué buscar</th>
</tr>
<tr>
<td><b>📍 Base Path</b></td>
<td>
<code>@RequestMapping("/api/v1/users")</code><br/>
Path base del controller
</td>
</tr>
<tr>
<td><b>🔵 Endpoints</b></td>
<td>
<code>@GetMapping</code> → GET<br/>
<code>@PostMapping</code> → POST<br/>
<code>@PutMapping</code> → PUT<br/>
<code>@DeleteMapping</code> → DELETE<br/>
<code>@PatchMapping</code> → PATCH
</td>
</tr>
<tr>
<td><b>🛣️ Path Completo</b></td>
<td>
Base path + método path<br/>
<code>/api/v1/users</code> + <code>/{id}</code> = <code>/api/v1/users/{id}</code>
</td>
</tr>
<tr>
<td><b>📥 Request Body</b></td>
<td>
<code>@RequestBody UserDTO user</code><br/>
Tipo del DTO → Mapear esquema
</td>
</tr>
<tr>
<td><b>🔗 Path Parameters</b></td>
<td>
<code>@PathVariable Long id</code><br/>
<code>@PathVariable("userId") Long userId</code>
</td>
</tr>
<tr>
<td><b>🔍 Query Parameters</b></td>
<td>
<code>@RequestParam String name</code><br/>
<code>@RequestParam(required=false) Integer page</code><br/>
<code>@RequestParam(defaultValue="10") Integer size</code>
</td>
</tr>
<tr>
<td><b>📤 Response</b></td>
<td>
Return type: <code>ResponseEntity&lt;UserDTO&gt;</code><br/>
<code>@ResponseStatus(HttpStatus.CREATED)</code><br/>
Status codes implícitos y explícitos
</td>
</tr>
<tr>
<td><b>📋 Headers</b></td>
<td>
<code>@RequestHeader("Authorization")</code><br/>
Headers requeridos
</td>
</tr>
<tr>
<td><b>📝 Descripción</b></td>
<td>
Javadoc/comentarios del método<br/>
<code>/** Creates a new user */</code>
</td>
</tr>
<tr>
<td><b>🏷️ Tags</b></td>
<td>
Nombre del controller como tag<br/>
<code>UserController</code> → tag "Users"
</td>
</tr>
</table>

**Ejemplo de análisis:**

**Código:**

```java
@RestController
@RequestMapping("/api/v1/users")
public class UserController {

    /**
     * Obtiene un usuario por ID
     * @param id ID del usuario
     * @return Usuario encontrado
     */
    @GetMapping("/{id}")
    public ResponseEntity<UserDTO> getUserById(
        @PathVariable Long id
    ) {
        // ...
    }

    /**
     * Crea un nuevo usuario
     * @param request Datos del usuario
     * @return Usuario creado
     */
    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public ResponseEntity<UserDTO> createUser(
        @Valid @RequestBody CreateUserRequest request,
        @RequestHeader("Authorization") String token
    ) {
        // ...
    }

    /**
     * Lista usuarios paginados
     */
    @GetMapping
    public ResponseEntity<PagedResponse<UserDTO>> listUsers(
        @RequestParam(required = false) String name,
        @RequestParam(defaultValue = "0") Integer page,
        @RequestParam(defaultValue = "10") Integer size
    ) {
        // ...
    }
}
```

**Análisis extraído:**

```yaml
Endpoint 1:
  - Method: GET
  - Path: /api/v1/users/{id}
  - Description: "Obtiene un usuario por ID"
  - Parameters:
      - id (path, required, Long)
  - Response: UserDTO (200)
  - Errors: 404 Not Found

Endpoint 2:
  - Method: POST
  - Path: /api/v1/users
  - Description: "Crea un nuevo usuario"
  - Request Body: CreateUserRequest (required)
  - Headers:
      - Authorization (required)
  - Response: UserDTO (201)
  - Errors: 400 Bad Request, 401 Unauthorized

Endpoint 3:
  - Method: GET
  - Path: /api/v1/users
  - Description: "Lista usuarios paginados"
  - Query Params:
      - name (optional, string)
      - page (optional, integer, default: 0)
      - size (optional, integer, default: 10)
  - Response: PagedResponse<UserDTO> (200)
```

---

### 🔹 Fase 4: Mapear DTOs y Modelos

**Para cada DTO/Model usado:**

1️⃣ **Encontrar la clase**

```javascript
file_search("**/UserDTO.java")
grep_search("class UserDTO", isRegexp: false)
```

2️⃣ **Leer la clase completa**

```javascript
read_file(dtoPath, startLine: 1, endLine: -1)
```

3️⃣ **Extraer propiedades**

**Información a extraer:**

```java
public class UserDTO {
    @NotNull
    private Long id;

    @NotEmpty
    @Size(min = 3, max = 50)
    private String name;

    @Email
    private String email;

    @Min(18)
    @Max(120)
    private Integer age;

    private LocalDateTime createdAt;

    private List<String> roles;
}
```

**Mapeo a OpenAPI:**

```yaml
UserDTO:
  type: object
  required:
    - id
    - name
    - email
  properties:
    id:
      type: integer
      format: int64
      description: "User ID"
    name:
      type: string
      minLength: 3
      maxLength: 50
      description: "User full name"
    email:
      type: string
      format: email
      description: "User email address"
    age:
      type: integer
      minimum: 18
      maximum: 120
      description: "User age"
    createdAt:
      type: string
      format: date-time
      description: "Creation timestamp"
    roles:
      type: array
      items:
        type: string
      description: "User roles"
```

**Mapeo de tipos:**

<table>
<tr>
<th>Java/Python/C#</th>
<th>OpenAPI Type</th>
<th>Format</th>
</tr>
<tr>
<td>String</td>
<td>string</td>
<td>-</td>
</tr>
<tr>
<td>Integer, int</td>
<td>integer</td>
<td>int32</td>
</tr>
<tr>
<td>Long, long</td>
<td>integer</td>
<td>int64</td>
</tr>
<tr>
<td>Float, float</td>
<td>number</td>
<td>float</td>
</tr>
<tr>
<td>Double, double</td>
<td>number</td>
<td>double</td>
</tr>
<tr>
<td>Boolean, bool</td>
<td>boolean</td>
<td>-</td>
</tr>
<tr>
<td>LocalDate, Date</td>
<td>string</td>
<td>date</td>
</tr>
<tr>
<td>LocalDateTime, DateTime</td>
<td>string</td>
<td>date-time</td>
</tr>
<tr>
<td>UUID</td>
<td>string</td>
<td>uuid</td>
</tr>
<tr>
<td>List&lt;T&gt;, Array</td>
<td>array</td>
<td>items: {type}</td>
</tr>
<tr>
<td>Map, Object</td>
<td>object</td>
<td>-</td>
</tr>
</table>

**Mapeo de validaciones:**

<table>
<tr>
<th>Anotación</th>
<th>OpenAPI</th>
</tr>
<tr>
<td>@NotNull, @NotEmpty</td>
<td>required: true</td>
</tr>
<tr>
<td>@Size(min=3, max=50)</td>
<td>minLength: 3, maxLength: 50</td>
</tr>
<tr>
<td>@Min(0), @Max(100)</td>
<td>minimum: 0, maximum: 100</td>
</tr>
<tr>
<td>@Email</td>
<td>format: email</td>
</tr>
<tr>
<td>@Pattern(regex)</td>
<td>pattern: "regex"</td>
</tr>
<tr>
<td>@Positive</td>
<td>minimum: 1</td>
</tr>
<tr>
<td>@Negative</td>
<td>maximum: -1</td>
</tr>
</table>

---

### 🔸 Fase 5: Generar OpenAPI YAML

**Estructura completa del archivo:**

```yaml
openapi: 3.1.0

info:
  title: User Management API
  version: 1.0.0
  description: |
    API completa para gestión de usuarios, autenticación y autorización.

    ## Características
    - Gestión de usuarios (CRUD)
    - Autenticación JWT
    - Paginación y filtros

  contact:
    name: API Support
    email: support@example.com
    url: https://support.example.com
  license:
    name: Apache 2.0
    url: https://www.apache.org/licenses/LICENSE-2.0.html

servers:
  - url: https://api.example.com/v1
    description: Production
  - url: https://staging-api.example.com/v1
    description: Staging
  - url: http://localhost:8080/v1
    description: Development

security:
  - bearerAuth: []

tags:
  - name: Users
    description: Operations about users
  - name: Authentication
    description: Authentication endpoints
  - name: Products
    description: Product management

paths:
  /users/{id}:
    get:
      tags:
        - Users
      summary: Get user by ID
      description: Obtiene un usuario específico por su ID
      operationId: getUserById
      parameters:
        - name: id
          in: path
          required: true
          description: User ID
          schema:
            type: integer
            format: int64
            minimum: 1
      responses:
        "200":
          description: Successful response
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/UserDTO"
              examples:
                example1:
                  value:
                    id: 123
                    name: "John Doe"
                    email: "john@example.com"
                    age: 30
                    createdAt: "2026-01-15T10:30:00Z"
                    roles:
                      - "USER"
                      - "ADMIN"
        "404":
          description: User not found
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/ErrorResponse"
        "401":
          description: Unauthorized
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/ErrorResponse"
      security:
        - bearerAuth: []

  /users:
    get:
      tags:
        - Users
      summary: List users
      description: Lista usuarios con paginación y filtros opcionales
      operationId: listUsers
      parameters:
        - name: name
          in: query
          required: false
          description: Filter by name
          schema:
            type: string
        - name: page
          in: query
          required: false
          description: Page number (0-indexed)
          schema:
            type: integer
            default: 0
            minimum: 0
        - name: size
          in: query
          required: false
          description: Page size
          schema:
            type: integer
            default: 10
            minimum: 1
            maximum: 100
      responses:
        "200":
          description: Successful response
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/PagedResponseUserDTO"
        "400":
          description: Bad request
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/ErrorResponse"

    post:
      tags:
        - Users
      summary: Create user
      description: Crea un nuevo usuario en el sistema
      operationId: createUser
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: "#/components/schemas/CreateUserRequest"
            examples:
              example1:
                value:
                  name: "Jane Smith"
                  email: "jane@example.com"
                  password: "SecurePass123!"
                  age: 25
      responses:
        "201":
          description: User created successfully
          headers:
            Location:
              description: URL of the created user
              schema:
                type: string
                format: uri
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/UserDTO"
        "400":
          description: Validation error
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/ValidationErrorResponse"
        "401":
          description: Unauthorized
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/ErrorResponse"
      security:
        - bearerAuth: []

components:
  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
      description: |
        JWT token obtenido del endpoint de autenticación.

        Ejemplo: `Authorization: Bearer <token>`

  schemas:
    UserDTO:
      type: object
      required:
        - id
        - name
        - email
      properties:
        id:
          type: integer
          format: int64
          description: User unique identifier
          example: 123
        name:
          type: string
          minLength: 3
          maxLength: 50
          description: User full name
          example: "John Doe"
        email:
          type: string
          format: email
          description: User email address
          example: "john@example.com"
        age:
          type: integer
          minimum: 18
          maximum: 120
          description: User age
          example: 30
        createdAt:
          type: string
          format: date-time
          description: Account creation timestamp
          example: "2026-01-15T10:30:00Z"
        roles:
          type: array
          items:
            type: string
            enum:
              - USER
              - ADMIN
              - MODERATOR
          description: User roles
          example: ["USER", "ADMIN"]

    CreateUserRequest:
      type: object
      required:
        - name
        - email
        - password
      properties:
        name:
          type: string
          minLength: 3
          maxLength: 50
          description: User full name
          example: "Jane Smith"
        email:
          type: string
          format: email
          description: User email address
          example: "jane@example.com"
        password:
          type: string
          minLength: 8
          maxLength: 100
          format: password
          description: User password (must be strong)
          example: "SecurePass123!"
        age:
          type: integer
          minimum: 18
          maximum: 120
          description: User age
          example: 25

    PagedResponseUserDTO:
      type: object
      properties:
        content:
          type: array
          items:
            $ref: "#/components/schemas/UserDTO"
        page:
          type: integer
          example: 0
        size:
          type: integer
          example: 10
        totalElements:
          type: integer
          format: int64
          example: 100
        totalPages:
          type: integer
          example: 10
        first:
          type: boolean
          example: true
        last:
          type: boolean
          example: false

    ErrorResponse:
      type: object
      required:
        - error
        - message
        - timestamp
      properties:
        error:
          type: string
          description: Error type
          example: "Not Found"
        message:
          type: string
          description: Error message
          example: "User with id 123 not found"
        timestamp:
          type: string
          format: date-time
          description: Error timestamp
          example: "2026-02-07T10:30:00Z"
        path:
          type: string
          description: Request path
          example: "/api/v1/users/123"

    ValidationErrorResponse:
      allOf:
        - $ref: "#/components/schemas/ErrorResponse"
        - type: object
          properties:
            errors:
              type: array
              items:
                type: object
                properties:
                  field:
                    type: string
                    example: "email"
                  message:
                    type: string
                    example: "must be a valid email"
```

---

### 🔹 Fase 6: Validación y Generación

**Pasos finales:**

1️⃣ **Validar sintaxis YAML**

```javascript
// Verificar que el YAML generado sea válido
yaml.parse(generatedYaml);
```

2️⃣ **Validar contra OpenAPI schema**

```javascript
// Verificar que cumpla OpenAPI 3.1 spec
validateOpenAPISpec(generatedYaml);
```

3️⃣ **Generar archivo(s)**

**Nombre del archivo:**

```
openapi.yaml
openapi.json (si se solicita)
```

**Ubicación:**

```
docs/api/
```

4️⃣ **Generar archivo README de la API**

````markdown
# API Documentation

## OpenAPI Specification

La especificación OpenAPI completa se encuentra en: `docs/api/openapi.yaml`

## Visualizar con Swagger UI

### Online

Sube el archivo a: https://editor.swagger.io/

### Local

```bash
docker run -p 8080:8080 -e SWAGGER_JSON=/openapi.yaml \
  -v $(pwd)/openapi.yaml:/openapi.yaml \
  swaggerapi/swagger-ui
```
````

Accede a: http://localhost:8080

## Endpoints

Total de endpoints: 28

### Users (8 endpoints)

- GET /api/v1/users - List users
- POST /api/v1/users - Create user
- GET /api/v1/users/{id} - Get user by ID
- PUT /api/v1/users/{id} - Update user
- DELETE /api/v1/users/{id} - Delete user
- ...

### Authentication (4 endpoints)

- POST /api/v1/auth/login - Login
- POST /api/v1/auth/logout - Logout
- POST /api/v1/auth/refresh - Refresh token
- POST /api/v1/auth/register - Register

## Modelos

Total de modelos: 15

- UserDTO
- CreateUserRequest
- UpdateUserRequest
- PagedResponseUserDTO
- ErrorResponse
- ValidationErrorResponse
- ...

## Autenticación

La API utiliza **Bearer Token (JWT)** para autenticación.

### Obtener token:

```bash
curl -X POST https://api.example.com/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "user@example.com", "password": "password"}'
```

### Usar token:

```bash
curl -X GET https://api.example.com/v1/users \
  -H "Authorization: Bearer <your-token>"
```

## Actualización

**Última actualización:** 2026-02-07  
**Versión API:** 1.0.0  
**Generado automáticamente** desde los controladores del proyecto.

```

---

## 🛠️ Tools a Usar

<table>
<tr>
<th width="30%">Tool</th>
<th width="70%">Uso</th>
</tr>
<tr>
<td><b>📂 file_search</b></td>
<td>
Buscar todos los controllers<br/>
Buscar DTOs y modelos<br/>
Encontrar request/response classes
</td>
</tr>
<tr>
<td><b>🔍 grep_search</b></td>
<td>
Buscar anotaciones REST<br/>
Buscar @RequestMapping, @GetMapping, etc.<br/>
Buscar validaciones
</td>
</tr>
<tr>
<td><b>📖 read_file</b></td>
<td>
Leer controllers completos<br/>
Leer DTOs completos<br/>
Extraer javadocs/comentarios
</td>
</tr>
<tr>
<td><b>📁 create_file</b></td>
<td>
Crear openapi.yaml<br/>
Crear openapi.json (opcional)<br/>
Crear API README
</td>
</tr>
<tr>
<td><b>📋 manage_todo_list</b></td>
<td>
Trackear progreso<br/>
• Controllers encontrados<br/>
• Endpoints mapeados<br/>
• DTOs analizados<br/>
• OpenAPI generado
</td>
</tr>
</table>

---

## 🎯 Ejemplo de Sesión Completa

```

Usuario:
"Genera OpenAPI de mis controllers"

Skill:

## 🎯 OpenAPI Generator

Voy a generar una especificación OpenAPI automáticamente.

---

## ⚙️ Configuración

### 1️⃣ Información básica

**Título de la API:**
[Detectado del proyecto: "User Management API"]

**Versión:**
[Por defecto: "1.0.0"]

**Descripción:**
"API para gestión de usuarios y autenticación"

¿Está bien o quieres modificar algo?

---

Usuario:
"está bien"

Skill:
✅ Configuración confirmada

---

### 🔍 Buscando controllers...

✅ Encontrados 5 controllers REST:

1. **UserController** (8 endpoints)
   - GET /api/v1/users
   - POST /api/v1/users
   - GET /api/v1/users/{id}
   - PUT /api/v1/users/{id}
   - DELETE /api/v1/users/{id}
   - PATCH /api/v1/users/{id}
   - GET /api/v1/users/search
   - GET /api/v1/users/export

2. **AuthController** (4 endpoints)
   - POST /api/v1/auth/login
   - POST /api/v1/auth/logout
   - POST /api/v1/auth/refresh
   - POST /api/v1/auth/register

3. **ProductController** (6 endpoints)
4. **OrderController** (7 endpoints)
5. **PaymentController** (3 endpoints)

**Total:** 28 endpoints

¿Incluir todos? (todos/seleccionar)

---

Usuario:
"todos"

Skill:
✅ Analizando 28 endpoints...

📊 Progreso: [████████░░] 80%

---

### 📝 Análisis completado:

**Endpoints mapeados:** 28  
**DTOs identificados:** 15

- UserDTO
- CreateUserRequest
- UpdateUserRequest
- ProductDTO
- OrderDTO
- ...

**Responses mapeados:** 42

- Success: 28
- Errors: 14 (400, 401, 404, 500)

---

### 🏗️ Generando OpenAPI...

✅ Estructura básica
✅ Paths (28 endpoints)
✅ Components/Schemas (15 modelos)
✅ Security schemes (Bearer JWT)
✅ Servers (3 ambientes)
✅ Validación YAML

---

## 🎉 ¡OpenAPI Generado!

### 📄 Archivos creados:

📁 `docs/api/openapi.yaml` (850 líneas)
📁 `docs/api/API-README.md`

### 📊 Resumen:

**OpenAPI Version:** 3.1.0  
**API Version:** 1.0.0  
**Endpoints:** 28  
**Modelos:** 15  
**Seguridad:** Bearer JWT

---

### 🚀 Próximos pasos:

1️⃣ **Visualizar en Swagger UI:**

```bash
docker run -p 8080:8080 -e SWAGGER_JSON=/openapi.yaml \
  -v $(pwd)/docs/api/openapi.yaml:/openapi.yaml \
  swaggerapi/swagger-ui
```

Accede a: http://localhost:8080

2️⃣ **O usar editor online:**
https://editor.swagger.io/

3️⃣ **Validar especificación:**

```bash
npx @apidevtools/swagger-cli validate docs/api/openapi.yaml
```

---

✅ ¡OpenAPI listo para usar!

````

---

## 🔒 Constraints Finales

<table>
<tr>
<td width="50%" bgcolor="#ffebee">

### ❌ NUNCA

- ❌ Generar YAML inválido
- ❌ Omitir endpoints
- ❌ Dejar esquemas vacíos
- ❌ Ignorar validaciones
- ❌ Asumir tipos sin verificar
- ❌ Omitir códigos de error

</td>
<td width="50%" bgcolor="#e8f5e9">

### ✅ SIEMPRE

- ✅ Validar sintaxis YAML
- ✅ Incluir todos los endpoints
- ✅ Mapear esquemas completos
- ✅ Incluir validaciones
- ✅ Verificar tipos en código
- ✅ Documentar errores

</td>
</tr>
</table>

### 🛡️ Principios de Operación

```diff
+ OpenAPI 3.1 VÁLIDO sobre YAML genérico
+ CÓDIGO REAL sobre EJEMPLOS
+ COMPLETITUD sobre VELOCIDAD
+ VALIDACIONES sobre TIPOS SIMPLES
+ EJEMPLOS sobre SOLO ESQUEMAS
````

---

<div align="center">

### 💚 Listo para Usar

**Palabras clave de activación:**

_"Genera OpenAPI"_

---

![Ready](https://img.shields.io/badge/status-ready-success?style=for-the-badge&logo=swagger)
![OpenAPI](https://img.shields.io/badge/OpenAPI-3.1-green?style=for-the-badge&logo=openapiinitiative)
![Automated](https://img.shields.io/badge/automated-generation-blue?style=for-the-badge&logo=yaml)

</div>
