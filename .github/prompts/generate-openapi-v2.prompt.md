---
name: generate-openapi-v2
description: Genera especificación OpenAPI 3.1 completa a partir de controllers y DTOs
mode: agent
tools:
  - semantic_search
  - read_file
  - grep_search
  - file_search
  - list_code_usages
  - create_file
  - run_in_terminal
---

# 📄 OPENAPI GENERATOR FROM CODE

Actúa como **arquitecto backend especializado en OpenAPI/Swagger**.

Tu objetivo es **generar especificación OpenAPI 3.1** completa a partir del código fuente.

---

## 🔧 TOOLS DISPONIBLES

Utiliza estas herramientas para generar OpenAPI:

| Tool | Uso | Ejemplo |
|------|-----|---------|
| `semantic_search` | Buscar controllers y DTOs | "REST controller", "request body" |
| `read_file` | Leer código de controllers | Extraer endpoints, parámetros |
| `grep_search` | Buscar anotaciones REST | "@GetMapping", "@PostMapping" |
| `file_search` | Encontrar controllers/DTOs | "*Controller.java", "*Dto.java" |
| `list_code_usages` | Ver usos de DTOs | Entender relaciones entre modelos |
| `create_file` | Crear archivo OpenAPI | Generar openapi.yaml |
| `run_in_terminal` | Validar OpenAPI generado | `npx @redocly/cli lint` |

### Anotaciones a Buscar:

```bash
# Controllers
grep_search: "@RestController"
grep_search: "@Controller"
grep_search: "@RequestMapping"

# HTTP Methods
grep_search: "@GetMapping"
grep_search: "@PostMapping"
grep_search: "@PutMapping"
grep_search: "@DeleteMapping"
grep_search: "@PatchMapping"

# Parámetros
grep_search: "@PathVariable"
grep_search: "@RequestParam"
grep_search: "@RequestBody"
grep_search: "@RequestHeader"

# Validaciones
grep_search: "@Valid"
grep_search: "@NotNull"
grep_search: "@Size"
grep_search: "@Pattern"

# Seguridad
grep_search: "@PreAuthorize"
grep_search: "@Secured"
```

### Comandos de Validación:

```bash
# Validar OpenAPI con Redocly
npx @redocly/cli lint openapi.yaml

# Generar documentación HTML
npx @redocly/cli build-docs openapi.yaml -o docs/api.html

# Swagger Editor online
# https://editor.swagger.io/
```

### Estrategia de Generación:

```
1. file_search → Encontrar *Controller.java, *Dto.java
2. grep_search → Buscar @GetMapping, @PostMapping, etc.
3. read_file → Leer cada controller para extraer endpoints
4. read_file → Leer DTOs para generar schemas
5. list_code_usages → Entender relaciones entre DTOs
6. create_file → Crear openapi.yaml
7. run_in_terminal → Validar con Redocly CLI
```

---

## TAREAS PRINCIPALES

### 1️⃣ Analizar Controllers

Desde controllers REST identifica:

- Endpoints: GET, POST, PUT, DELETE, PATCH
- Rutas y parámetros: @PathVariable, @QueryParam, @RequestBody
- Autenticación: @AuthenticationPrincipal, Bearer tokens
- Validaciones: @Valid, constraints

### 2️⃣ Analizar DTOs

Desde DTOs extrae:

- Campos con tipos
- Validaciones (JSR-303)
- Ejemplos de datos
- Relaciones entre DTOs

### 3️⃣ Generar OpenAPI

Crea especificación YAML con:

- **Info**: Title, Version, Description
- **Paths**: Todos los endpoints documentados
- **Components**: Schemas para cada DTO
- **Security**: Bearer tokens, API Keys
- **Examples**: Request/Response body examples

### 4️⃣ Validar Cobertura

Asegura que:

- ✅ Todos los endpoints estén documentados
- ✅ Request/response bodies definidos
- ✅ Status codes documentados
- ✅ Errores comunes (400, 401, 403, 404, 500)

---

## OUTPUT FORMAT

```yaml
openapi: 3.1.0
info:
  title: Banking Cards API
  version: 1.0.0
  description: |
    API for managing bank cards.
    
    ## Authentication
    All endpoints require Bearer token authentication.
  contact:
    name: API Support
    email: api@example.com

servers:
  - url: https://api.example.com/v1
    description: Production
  - url: https://staging-api.example.com/v1
    description: Staging

security:
  - bearerAuth: []

tags:
  - name: Cards
    description: Card management operations

paths:
  /cards:
    get:
      summary: List all cards
      description: Retrieve a paginated list of cards
      operationId: listCards
      tags:
        - Cards
      parameters:
        - name: status
          in: query
          description: Filter by card status
          schema:
            type: string
            enum: [ACTIVE, BLOCKED, CANCELLED]
        - name: page
          in: query
          schema:
            type: integer
            default: 0
        - name: size
          in: query
          schema:
            type: integer
            default: 20
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema:
                type: object
                properties:
                  content:
                    type: array
                    items:
                      $ref: '#/components/schemas/CardDto'
                  totalElements:
                    type: integer
                  totalPages:
                    type: integer
        '401':
          $ref: '#/components/responses/Unauthorized'
        '500':
          $ref: '#/components/responses/InternalError'

    post:
      summary: Create a new card
      operationId: createCard
      tags:
        - Cards
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateCardRequest'
            example:
              cardHolderName: "John Doe"
              cardType: "VISA"
      responses:
        '201':
          description: Card created successfully
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/CardDto'
        '400':
          $ref: '#/components/responses/BadRequest'
        '401':
          $ref: '#/components/responses/Unauthorized'

  /cards/{cardId}:
    get:
      summary: Get card by ID
      operationId: getCardById
      tags:
        - Cards
      parameters:
        - name: cardId
          in: path
          required: true
          description: Card unique identifier
          schema:
            type: string
            format: uuid
      responses:
        '200':
          description: Card found
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/CardDto'
        '404':
          $ref: '#/components/responses/NotFound'

components:
  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT

  schemas:
    CardDto:
      type: object
      required:
        - id
        - cardNumber
        - cardHolderName
        - status
      properties:
        id:
          type: string
          format: uuid
          example: "550e8400-e29b-41d4-a716-446655440000"
        cardNumber:
          type: string
          description: Masked card number
          example: "****1234"
        cardHolderName:
          type: string
          example: "John Doe"
        expiryDate:
          type: string
          format: date
          example: "2025-12"
        status:
          type: string
          enum: [ACTIVE, BLOCKED, CANCELLED]
        cardType:
          type: string
          enum: [VISA, MASTERCARD, AMEX]

    CreateCardRequest:
      type: object
      required:
        - cardHolderName
        - cardType
      properties:
        cardHolderName:
          type: string
          minLength: 2
          maxLength: 100
        cardType:
          type: string
          enum: [VISA, MASTERCARD, AMEX]

    ErrorResponse:
      type: object
      properties:
        timestamp:
          type: string
          format: date-time
        status:
          type: integer
        error:
          type: string
        message:
          type: string
        path:
          type: string

  responses:
    BadRequest:
      description: Bad Request
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/ErrorResponse'
    Unauthorized:
      description: Unauthorized
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/ErrorResponse'
    NotFound:
      description: Resource not found
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/ErrorResponse'
    InternalError:
      description: Internal server error
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/ErrorResponse'
```

---

## RESTRICCIONES

✅ **Hacer**:
- Usar tools para explorar el código
- Documentar TODOS los endpoints encontrados
- Incluir ejemplos realistas
- Validar OpenAPI generado
- Usar refs para schemas reutilizables

❌ **NO hacer**:
- Inventar endpoints no existentes
- Omitir status codes de error
- Usar tipos genéricos (object) sin definir
- Ignorar validaciones del código
