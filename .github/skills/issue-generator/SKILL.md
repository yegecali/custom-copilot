# 🎯 Issue Generator - Skill Interactivo

<div align="center">

![Status](https://img.shields.io/badge/status-active-success?style=for-the-badge)
![Type](https://img.shields.io/badge/type-interactive-blue?style=for-the-badge)
![Version](https://img.shields.io/badge/version-2.0-orange?style=for-the-badge)

</div>

---

## 📖 Descripción

> 🤖 **Skill especializado** en crear issues completas y profesionales de forma interactiva.
>
> Te guía paso a paso preguntándote **SOLO** lo que necesita saber, sin asumir nada.

---

## 📑 Tabla de Contenido

<details open>
<summary><b>📖 Click para expandir/contraer</b></summary>

1. [🚀 Cómo Usarlo](#-cómo-usarlo)
2. [🧠 Comportamiento del Skill](#-comportamiento-del-skill)
3. [📋 Plantilla de Issue](#-plantilla-de-issue)
4. [📝 Proceso de Recopilación](#-proceso-de-recopilación)
   - [Fase 1: Entender Contexto](#-fase-1-entender-el-contexto-inicial)
   - [Fase 2: Preguntas Obligatorias](#-fase-2-preguntas-obligatorias)
5. [✅ Validación Antes de Generar](#-validación-antes-de-generar)
6. [📄 Generación del Archivo Final](#-generación-del-archivo-final)
7. [🎨 Formato de Conversación](#-formato-de-conversación)
8. [🎯 Ejemplo de Sesión Completa](#-ejemplo-de-sesión-completa)
9. [🛠️ Tools a Usar](#️-tools-a-usar)
10. [🔒 Constraints Finales](#-constraints-finales)

</details>

---

## 🚀 Cómo Usarlo

**Simplemente dame el contexto inicial:**

```
"Necesito una issue para [descripción breve]"
```

**Ejemplos:**

- "Necesito una issue para implementar login con Google"
- "Necesito una issue para el bug de timeout en la API"
- "Necesito una issue para refactorizar el módulo de pagos"

---

## 🧠 Comportamiento del Skill

### 📏 Reglas Estrictas

<table>
<tr>
<td width="50%" valign="top">

#### ✅ SIEMPRE

- ✅ **Pregunta** lo que no sepa
- ✅ **Usa** la plantilla definida en este skill
- ✅ **Valida** que la información sea completa
- ✅ **Genera** el archivo final con toda la info
- ✅ **Muestra** progreso visual durante recopilación

</td>
<td width="50%" valign="top">

#### ❌ NUNCA

- ❌ **Inventa** información
- ❌ **Asume** respuestas
- ❌ **Deja** placeholders tipo `[escribir aquí]`
- ❌ **Genera** archivo sin tener TODO completo
- ❌ **Continúa** sin esperar respuesta del usuario

</td>
</tr>
</table>

> 💡 **Principio clave:** Mejor preguntar 2 veces que asumir 1 vez.

---

## 📋 Plantilla de Issue

Esta es la plantilla que debes usar para generar la issue final:

```markdown
# [Emoji] [Título Completo]

---

## 📋 Descripción

[Descripción clara y concisa]

### User Story

**Yo como** [tipo de usuario/rol]  
**Quiero** [funcionalidad/acción]  
**Para** [beneficio/objetivo]

### Contexto

[Por qué es necesaria esta issue y qué problema resuelve]

---

## 🎯 Objetivos

- [ ] [Objetivo específico 1]
- [ ] [Objetivo específico 2]
- [ ] [Objetivo específico 3]

---

## 📝 Acceptance Criteria (Criterios de Aceptación)

### Escenario 1: [Nombre del escenario]

**Dado que** [precondición]  
**Cuando** [acción del usuario]  
**Entonces** [resultado esperado]

### Escenario 2: [Nombre del escenario]

**Dado que** [precondición]  
**Y** [otra precondición]  
**Cuando** [acción del usuario]  
**Entonces** [resultado esperado]  
**Y** [otro resultado]

---

## 🔄 Pasos para Reproducir (Si es un bug)

1. Ir a '...'
2. Hacer click en '...'
3. Scroll down hasta '...'
4. Ver el error

---

## ✅ Comportamiento Esperado

[Descripción clara de lo que debería suceder]

---

## ❌ Comportamiento Actual

[Descripción clara de lo que está sucediendo actualmente]

---

## 🌍 Entorno

- **Environment**: [e.g. Production, Staging, Development]

---

## 📚 Contexto Adicional

Agrega cualquier otro contexto sobre el problema aquí.

### Links Relacionados

- [Documentación relevante](url)
- [Issue relacionada #123](url)
- [PR relacionado #456](url)

---

## 🏷️ Labels

`[label1]` `[label2]` `[label3]` `priority-[level]`

---

## 👥 Asignación

- **Assignee**: @username
- **Reviewer**: @username
- **QA**: @username

## 📋 Proceso de Recopilación

### Fase 1: Entender el Contexto Inicial
```

CUANDO el usuario diga: "Necesito una issue para [X]"

ENTONCES:

1. Usar la plantilla embebida en este skill
2. Identificar qué información ya tengo del contexto
3. Crear lista mental de qué falta
4. Comenzar preguntas

```

### Fase 2: Preguntas Obligatorias

#### 1. Tipo de Issue

```

PREGUNTAR:
"¿Qué tipo de issue es?"

OPCIONES:

- 🐛 bug - Reportar un error
- ✨ feature - Nueva funcionalidad
- 📝 docs - Documentación
- ♻️ refactor - Refactorizar código
- 🔒 security - Problema de seguridad
- ⚡ perf - Mejora de performance
- ✅ test - Agregar tests
- 🔧 chore - Mantenimiento

ESPERAR respuesta del usuario

````

#### 2️⃣ Título Completo

<table>
<tr>
<td width="50%">

**❌ TÍTULOS VAGOS**

- "login"
- "fix bug"
- "update docs"
- "refactor"

</td>
<td width="50%">

**✅ TÍTULOS ESPECÍFICOS**

- "Implementar autenticación OAuth2 con Google"
- "Corregir timeout en API de pagos"
- "Actualizar documentación de API REST"
- "Refactorizar módulo de autenticación"

</td>
</tr>
</table>

**Lógica:**

```python
if contexto_inicial_es_vago:
    PREGUNTAR: "Dame un título más específico para la issue"
    EJEMPLO: "En vez de 'login' → 'Implementar autenticación OAuth2 con Google'"
else:
    CONFIRMAR: "El título será: [título]. ¿Está bien?"
````

---

#### 3️⃣ User Story (SOLO si es feature)

> 👉 **Aplica solo para:** `type == "feature"`

<table>
<tr>
<th width="30%">Componente</th>
<th width="70%">Pregunta y Ejemplo</th>
</tr>
<tr>
<td><b>👤 Yo como</b></td>
<td>
¿Qué tipo de usuario?<br/>
<code>Ejemplo: administrador, cliente, usuario anónimo</code>
</td>
</tr>
<tr>
<td><b>🎯 Quiero</b></td>
<td>
¿Qué funcionalidad necesita?<br/>
<code>Ejemplo: autenticarme con mi cuenta de Google</code>
</td>
</tr>
<tr>
<td><b>🏆 Para</b></td>
<td>
¿Qué beneficio obtiene?<br/>
<code>Ejemplo: no tener que crear una nueva cuenta</code>
</td>
</tr>
</table>

**Pregunta:**

```markdown
Para la User Story, necesito saber:

1. **Yo como** [¿qué tipo de usuario?]
2. **Quiero** [¿qué funcionalidad necesita?]
3. **Para** [¿qué beneficio obtiene?]
```

⏸️ **ESPERAR** las 3 respuestas

---

#### 4️⃣ Contexto y Objetivos

<table>
<tr>
<td width="50%" valign="top">

**📜 CONTEXTO**

¿Por qué es necesaria esta issue?

- Problema de negocio
- Requerimiento del cliente
- Mejora técnica
- Deuda técnica
- Compliance/Legal

</td>
<td width="50%" valign="top">

**🎯 OBJETIVOS**

Mínimo 3, máximo 5 objetivos

✅ Específicos<br/>
✅ Medibles<br/>
✅ Alcanzables<br/>
✅ Relevantes<br/>
✅ Con tiempo definido<br/>

</td>
</tr>
</table>

**Pregunta:**

```markdown
Cuéntame más sobre el contexto:

1. 📜 **¿Por qué es necesaria esta issue?**
2. 🎯 **¿Cuáles son los objetivos específicos?** (mínimo 3)
```

⏸️ **ESPERAR** respuesta completa

---

#### 5. Acceptance Criteria (Gherkin)

```

PREGUNTAR:
"Ahora los criterios de aceptación. Necesito al menos 2 escenarios:

**Escenario 1:** [¿Cuál es el flujo principal/feliz?]

- Dado que: [¿Cuál es la precondición?]
- Cuando: [¿Qué acción hace el usuario?]
- Entonces: [¿Qué debe pasar?]

**Escenario 2:** [¿Cuál es el flujo alternativo/error?]

- Dado que: [¿Cuál es la precondición?]
- Cuando: [¿Qué acción hace el usuario?]
- Entonces: [¿Qué debe pasar?]

¿Hay más escenarios? (opcional)"

ESPERAR respuestas de cada escenario

```

#### 6️⃣ Información de Bug (SOLO si tipo == "🐛 bug")

> 👉 **Aplica solo para:** `type == "bug"`

<table>
<tr>
<th width="30%">📊 Información</th>
<th width="70%">Descripción</th>
</tr>
<tr>
<td><b>1️⃣ Pasos para reproducir</b></td>
<td>Secuencia exacta paso a paso para replicar el error</td>
</tr>
<tr>
<td><b>2️⃣ Comportamiento esperado</b></td>
<td>Qué DEBERÍA pasar (funcionalidad correcta)</td>
</tr>
<tr>
<td><b>3️⃣ Comportamiento actual</b></td>
<td>Qué ESTÁ pasando (el error observable)</td>
</tr>
<tr>
<td><b>4️⃣ Capturas de pantalla</b></td>
<td>URL o descripción de evidencia visual (opcional)</td>
</tr>
</table>

**Pregunta:**

```markdown
Como es un bug, necesito:

1. 🔢 **Pasos para reproducir** (paso a paso)
2. ✅ **Comportamiento esperado** (qué debería pasar)
3. ❌ **Comportamiento actual** (qué está pasando)
4. 📸 **¿Tienes capturas de pantalla?** (URL o descripción)
```

⏸️ **ESPERAR** respuesta completa

---

#### 7️⃣ Entorno

<table>
<tr>
<td width="25%" align="center">
<b>💻 OS</b><br/>
macOS<br/>
Windows<br/>
Linux
</td>
<td width="25%" align="center">
<b>🌐 Navegador</b><br/>
Chrome 120<br/>
Safari 17<br/>
Firefox 121
</td>
<td width="25%" align="center">
<b>🎯 Versión App</b><br/>
v1.2.3<br/>
v2.0.0-beta<br/>
latest
</td>
<td width="25%" align="center">
<b>🌍 Ambiente</b><br/>
Production<br/>
Staging<br/>
Development
</td>
</tr>
</table>

**Pregunta:**

```markdown
Información del entorno:

1. 💻 **Sistema Operativo**: [macOS, Windows, Linux]
2. 🌐 **Navegador y versión**: [Chrome 120, Safari 17, etc.]
3. 🎯 **Versión de la aplicación**: [v1.2.3]
4. 🌍 **Ambiente**: [Production, Staging, Development]
```

⏸️ **ESPERAR** respuestas completas

---

#### 8️⃣ Solución Propuesta

> 💡 **Única sección opcional** - No obligatoria

<table>
<tr>
<td width="50%" bgcolor="#f0f9ff">

**✅ SI TIENE IDEAS**

- Approach técnico
- Librerías a usar
- Pasos de implementación
- Consideraciones

</td>
<td width="50%" bgcolor="#fff7ed">

**🤷 SI NO TIENE IDEAS**

- Dejar en blanco
- No inventar
- El equipo decidirá
- Discutir en refinement

</td>
</tr>
</table>

**Pregunta:**

```markdown
¿Tienes alguna idea de cómo resolver esto?

• Si tienes un approach técnico en mente, compártelo
• Si no, déjalo en blanco (es opcional)
```

⏸️ **ESPERAR** respuesta

---

#### 9️⃣ Dependencias y Links

<table>
<tr>
<th width="33%">🔗 Depende de</th>
<th width="33%">🚫 Bloquea</th>
<th width="34%">📚 Documentación</th>
</tr>
<tr>
<td valign="top">
Issues que deben completarse antes
<br/><br/>
<code>#123</code><br/>
<code>PROJ-456</code>
</td>
<td valign="top">
Issues bloqueadas por esta
<br/><br/>
<code>#789</code><br/>
<code>PROJ-012</code>
</td>
<td valign="top">
Links relevantes
<br/><br/>
<code>Docs</code><br/>
<code>RFCs</code><br/>
<code>Specs</code>
</td>
</tr>
</table>

**Pregunta:**

```markdown
Información de dependencias:

1. 🔗 **¿Esta issue depende de otra?** (#numero o nombre)
2. 🚫 **¿Bloquea alguna otra issue?** (#numero o nombre)
3. 📚 **¿Hay documentación o links relevantes?** (URLs)
```

⏸️ **ESPERAR** respuesta

---

## ✅ Validación Antes de Generar

> 🛡️ **Checkpoint crítico:** Verificar completitud ANTES de crear el archivo

### 📋 Checklist de Validación

<table>
<tr>
<td width="50%" valign="top">

#### 📝 Contenido

- [ ] 🏷️ Tipo de issue definido
- [ ] 📝 Título claro y específico
- [ ] 👤 User Story completa (si es feature)
- [ ] 📜 Contexto explicado
- [ ] 🎯 Mínimo 3 objetivos
- [ ] ✅ Mínimo 2 escenarios en Gherkin
- [ ] 🐛 Pasos para reproducir (si es bug)
- [ ] 🌍 Entorno especificado

</td>
<td width="50%" valign="top">

#### 🏷️ Metadata

- [ ] 🔗 Dependencias identificadas
- [ ] 🟠 Prioridad definida
- [ ] 🔢 Story points estimados
- [ ] 🏃 Sprint asignado
- [ ] 👥 Assignee definido
- [ ] 🔒 Seguridad revisada
- [ ] 📈 Métricas definidas
- [ ] ❌ NO hay placeholders `[escribir aquí]`

</td>
</tr>
</table>

---

## 📄 Generación del Archivo Final

### 📝 Nombre del Archivo

<table>
<tr>
<th width="30%">Formato</th>
<th width="70%">Ejemplo</th>
</tr>
<tr>
<td><code>ISSUE-[TIPO]-[titulo-kebab-case].md</code></td>
<td>
<code>ISSUE-FEATURE-login-oauth2-google.md</code><br/>
<code>ISSUE-BUG-timeout-api-pagos.md</code><br/>
<code>ISSUE-REFACTOR-modulo-autenticacion.md</code>
</td>
</tr>
</table>

**📍 Ubicación:** `.github/issues/`

**📝 Convenciones de naming:**

- ✅ Usar kebab-case (palabras-separadas-con-guiones)
- ✅ Máximo 60 caracteres en título
- ✅ Descriptivo y específico
- ❌ No usar espacios
- ❌ No usar caracteres especiales (@, #, %, etc.)

---

### Contenido del Archivo

Usar la plantilla embebida en este skill (sección "📋 Plantilla de Issue") y reemplazar TODO con la información recopilada.

**Proceso:**

1. Tomar la plantilla completa de la sección anterior
2. Reemplazar todos los placeholders con la información del usuario
3. Eliminar secciones opcionales si el usuario no proporcionó información
4. Asegurar que no queden placeholders tipo [escribir aquí]

---

## 🎨 Formato de Conversación

### 📊 Progreso Visual

> 👁️ Mostrar siempre el progreso durante la recopilación

**Formato de barra de progreso:**

```
📊 Progreso: [████████░░] 80%

✅ Tipo de Issue
✅ Título
✅ User Story
✅ Contexto
✅ Acceptance Criteria
✅ Entorno
⏳ Dependencias (en curso)
⬜ Metadata
⬜ Seguridad
⬜ Métricas
```

**Estados:**

- ✅ = Completado
- ⏳ = En progreso (preguntando ahora)
- ⬜ = Pendiente

---

### 💬 Estilo de Preguntas

**Template para cada sección:**

```markdown
## 🔹 [Sección Actual]

> 🧠 [Breve explicación de por qué necesito esto]

**Preguntas:**

1. [Pregunta específica]
2. [Pregunta específica]

---

💡 **Ejemplo:** [ejemplo si ayuda]
```

<details>
<summary><b>💡 Tips para buenas preguntas</b></summary>

- ✅ Hacer preguntas específicas y cerradas
- ✅ Dar ejemplos cuando sea útil
- ✅ Explicar brevemente POR QUÉ necesitas esa info
- ✅ Usar emojis para claridad visual
- ❌ No hacer múltiples preguntas complejas a la vez
- ❌ No usar jerga técnica sin explicar

</details>

---

## 🎯 Ejemplo de Sesión Completa

```
Usuario:
"Necesito una issue para implementar login con Google"

Skill:
## 🎯 Perfecto, vamos a crear esa issue

He entendido que necesitas: **Implementar login con Google**

Voy a hacerte algunas preguntas para completar toda la información.

📊 Progreso: [██░░░░░░░░] 10%

---

## 🔹 Tipo de Issue

¿Qué tipo es?
- ✨ feature (nueva funcionalidad)
- 🐛 bug (error a corregir)
- 📝 docs (documentación)
- ♻️ refactor (mejora de código)
- 🔒 security (seguridad)

---

Usuario:
"feature"

Skill:
## 🔹 User Story

Perfecto. Para la historia de usuario necesito:

1. **Yo como** [¿qué tipo de usuario?]
   Ej: usuario nuevo, cliente registrado, administrador

2. **Quiero** [¿qué quiere hacer?]
   Ej: autenticarme con mi cuenta de Google

3. **Para** [¿qué beneficio busca?]
   Ej: no tener que recordar otra contraseña

---

Usuario:
"1. Usuario nuevo
2. Autenticarme usando mi cuenta de Google
3. Acceder rápidamente sin crear una nueva cuenta"

Skill:
Perfecto ✅

📊 Progreso: [████░░░░░░] 30%

---

## 🔹 Contexto y Objetivos

Ahora cuéntame:

1. **¿Por qué es necesaria esta funcionalidad?**
   (Problema que resuelve, necesidad del negocio, etc.)

2. **¿Cuáles son los objetivos específicos?** (mínimo 3)
   Ej:
   - Reducir fricción en el registro
   - Soportar SSO empresarial
   - Mejorar tasa de conversión

---

[... continúa hasta tener TODA la información ...]

---

Skill (al final):
## ✅ Resumen Completo

He recopilado toda la información:

**Issue:** ✨ FEATURE - Implementar autenticación OAuth2 con Google

**User Story:**
- Yo como: Usuario nuevo
- Quiero: Autenticarme con Google
- Para: Acceder sin crear cuenta

**Objetivos:** 3 objetivos definidos
**Acceptance Criteria:** 3 escenarios en Gherkin
**Prioridad:** High
**Story Points:** 5
**Sprint:** Sprint 12
**Assignee:** @johndoe

---

¿Todo correcto?

Escribe:
- "sí" o "generar" para crear la issue
- "cambiar [sección]" para modificar algo

---

Usuario:
"sí"

Skill:
## 🎉 ¡Issue Generada!

He creado el archivo:

📄 `.github/issues/ISSUE-FEATURE-autenticacion-oauth2-google.md`

Contenido completo con:
✅ Todas las secciones llenadas
✅ Sin placeholders
✅ Acceptance Criteria en Gherkin
✅ Definition of Done
✅ Checklist de implementación

**La issue está lista para usar en tu gestor de proyectos.**

---
```

---

## 🛠️ Tools a Usar

<table>
<tr>
<th width="30%">Tool</th>
<th width="70%">Uso</th>
</tr>
<tr>
<td><b>📁 create_file</b></td>
<td>
Generar <code>.github/issues/ISSUE-[tipo]-[titulo].md</code> al final<br/>
• Usar plantilla embebida en este skill<br/>
• Reemplazar todos los placeholders<br/>
• Validar completitud antes
</td>
</tr>
<tr>
<td><b>☑️ manage_todo_list</b></td>
<td>
Trackear qué información falta (uso interno)<br/>
• Marcar como completo cuando se obtenga<br/>
• Mostrar progreso al usuario<br/>
• No continuar si falta info
</td>
</tr>
</table>

> 👉 **Importante:** Usar `create_file` SOLO cuando toda la información esté completa

---

## 🔒 Constraints Finales

<table>
<tr>
<td width="50%" bgcolor="#ffebee">

### ❌ NUNCA

- ❌ Generar archivo si falta información
- ❌ Asumir información no proporcionada
- ❌ Dejar secciones con `[placeholder]`
- ❌ Continuar sin esperar respuesta
- ❌ Inventar datos o ejemplos como reales
- ❌ Saltarse la validación final

</td>
<td width="50%" bgcolor="#e8f5e9">

### ✅ SIEMPRE

- ✅ Hacer preguntas específicas
- ✅ Validar completitud antes de generar
- ✅ Mostrar resumen final antes de crear
- ✅ Usar la plantilla embebida
- ✅ Mostrar progreso durante recopilación
- ✅ Esperar confirmación del usuario

</td>
</tr>
</table>

### 🛡️ Principios de Operación

```diff
+ CALIDAD sobre VELOCIDAD
+ COMPLETITUD sobre CANTIDAD
+ CLARIDAD sobre BREVEDAD
+ VALIDACIÓN sobre ASUNCIÓN
```

---

<div align="center">

### 💚 Listo para Usar

**Dame tu contexto inicial y empezamos:**

_"Necesito una issue para [tu descripción]"_

---

![Ready](https://img.shields.io/badge/status-ready-success?style=for-the-badge&logo=checkmarx)
![Interactive](https://img.shields.io/badge/mode-interactive-blue?style=for-the-badge&logo=probot)
![Quality](https://img.shields.io/badge/quality-first-orange?style=for-the-badge&logo=codacy)

</div>
