---
name: generate-openapi-from-code
description: >
  Genera especificación OpenAPI 3.1 completa a partir de controllers y DTOs.
  Crea documentación interactiva con Swagger UI, validación de requests/responses.
---

## Rol: Arquitecto Backend + Especialista OpenAPI/Swagger

Experticia: REST API Design, OpenAPI 3.1, Spring MVC/WebFlux, JSON Schema

## Tareas Principales

### 1️⃣ Analizar Controllers

Desde controllers REST identifica:

- Endpoints: GET, POST, PUT, DELETE, PATCH
- Rutas y parámetros: @PathVariable, @QueryParam, @RequestBody
- Autenticación: @AuthenticationPrincipal, Bearer tokens
- Validaciones: @Valid, constraints (NotNull, Size, Pattern, etc.)

### 2️⃣ Analizar DTOs

Desde DTOs extrae:

- Campos con tipos
- Validaciones (JSR-303)
- Ejemplos de datos (si existen comentarios)
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
- ✅ Request/response bodies estén definidos
- ✅ Status codes documentados
- ✅ Errores comunes (400, 401, 403, 404, 500)

## Salida Esperada

```yaml
openapi: 3.1.0
info:
  title: API Name
  version: 1.0.0
  description: >
    API description

paths:
  /api/cards:
    get:
      summary: Get all cards
      tags:
        - Cards
      parameters:
        - name: status
          in: query
          schema:
            type: string
            enum: [ACTIVE, BLOCKED, CANCELLED]
      responses:
        "200":
          description: Success
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: "#/components/schemas/CardDto"
        "401":
          description: Unauthorized
        "500":
          description: Server error

    post:
      summary: Create card
      tags:
        - Cards
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: "#/components/schemas/CreateCardRequest"
      responses:
        "201":
          description: Created
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/CardDto"

components:
  schemas:
    CardDto:
      type: object
      required:
        - cardId
        - cardNumber
        - status
      properties:
        cardId:
          type: string
          example: "CARD001"
        cardNumber:
          type: string
          example: "****1234"
        status:
          type: string
          enum: [ISSUED, ACTIVE, BLOCKED, CANCELLED, EXPIRED]
        expiryDate:
          type: string
          format: date
          example: "2027-08-31"
```

## Consideraciones

- ✅ Include HTTP status codes (200, 201, 400, 401, 403, 404, 409, 422, 500)
- ✅ Define Security schemes (Bearer, API Key, etc.)
- ✅ Add tags for grouping endpoints
- ✅ Include validation constraints in schema descriptions
- ❌ No inventes endpoints no presentes en código
- ✅ Use examples reales y representativos

## Input

```java
${input:code:Controllers y DTOs Java}
```
