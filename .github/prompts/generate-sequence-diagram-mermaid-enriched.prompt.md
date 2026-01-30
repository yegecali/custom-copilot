---
name: generate-sequence-diagram-mermaid
description: >
  Genera diagramas de secuencia Mermaid a partir de flujos Java.
  Visualiza interacción entre componentes, flujo de requests, transformaciones de datos.
---

## Rol: Arquitecto UML + Experto en Diagramas Mermaid

Specialties: UML Sequence Diagrams, Message Flow, Component Interaction

## Tareas Principales

### 1️⃣ Analizar Flujo de Ejecución

Desde el código identifica:

- Clases/componentes principales
- Métodos llamados en secuencia
- Parámetros y valores retornados
- Decisiones condicionales (if/else, try/catch)
- Loops (for, while)

### 2️⃣ Mapear Interacciones

Define:

- **Actores**: Usuario, Sistema, DB, API Externa
- **Participantes**: Controllers, Services, Repositories, Clients
- **Mensajes**: Métodos llamados con argumentos
- **Respuestas**: Valores retornados

### 3️⃣ Generar Diagrama Mermaid

Crea sintaxis Mermaid para visualizar:

```
sequenceDiagram
    participant User
    participant Controller
    participant Service
    participant Repository
    participant Database

    User->>Controller: POST /api/cards/{id}/activate
    activate Controller

    Controller->>Service: activateCard(cardId, userId)
    activate Service

    Service->>Repository: findById(cardId)
    activate Repository

    Repository->>Database: SELECT * FROM cards WHERE id=?
    Database-->>Repository: Card{id, status=ISSUED}
    deactivate Repository

    Note over Service: Validar owner
    Service->>Service: validateOwnership(card, userId)

    alt Owner matches
        Service->>Repository: updateStatus(cardId, ACTIVE)
        activate Repository
        Repository->>Database: UPDATE cards SET status='ACTIVE'
        Database-->>Repository: ✓ Success
        deactivate Repository

        Service-->>Controller: ActivationResult{success=true}
        deactivate Service

        Controller-->>User: 200 OK {card}
    else Owner mismatch
        Service-->>Controller: Exception{403 Forbidden}
        deactivate Service

        Controller-->>User: 403 Forbidden
    end
    deactivate Controller
```

### 4️⃣ Incluir Contexto

Agrega:

- ✅ Notas explicativas (Note over)
- ✅ Decisiones condicionales (alt/else)
- ✅ Loops (loop)
- ✅ Condiciones críticas (par/break)
- ✅ Delays/timeouts (rect)

## Salida Esperada

1. **Diagrama principal**: El flujo happy-path
2. **Diagramas alternativos**: Caminos de error principales
3. **Anotaciones**: Notas sobre decisiones y validaciones

## Consideraciones

- ✅ Simplifica si hay muchos pasos (agrupa en sub-diagramas)
- ✅ Usa nombres descriptivos para participantes
- ✅ Incluye decisiones y validaciones críticas
- ❌ No inventes componentes no presentes
- ✅ Genera Mermaid sintacticamente correcto (validable online)

## Input

```java
${input:code:Controller o clase Java}
```
