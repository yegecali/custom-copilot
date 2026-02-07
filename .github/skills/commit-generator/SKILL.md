# 🎯 Commit Message Generator - Skill Interactivo

<div align="center">

![Status](https://img.shields.io/badge/status-active-success?style=for-the-badge)
![Type](https://img.shields.io/badge/type-interactive-blue?style=for-the-badge)
![Version](https://img.shields.io/badge/version-2.0-orange?style=for-the-badge)

</div>

---

## 📖 Descripción

> 🤖 **Skill especializado** en generar mensajes de commit siguiendo estándares profesionales.
>
> Analiza tus cambios en git, evalúa el contexto y genera commits en formato **Conventional Commits** con tu ticket de Jira.
>
> ✨ **Nuevas capacidades v2.0:**
>
> - 🔀 Detecta y separa commits lógicamente cuando hay cambios de diferentes tipos
> - ⚡ Ejecuta `git add` y `git commit` automáticamente
> - 📊 Commits atómicos para historial limpio y organizado

---

## 🚀 Cómo Usarlo

**Simplemente ejecuta:**

```
"Genera un commit para mis cambios"
"Necesito un commit message"
"Commitear cambios"
"Separa mis cambios en commits"
```

**El skill:**

1. 📊 Analiza tus cambios
2. 🔍 Detecta si hay múltiples tipos lógicos
3. 💬 Te pregunta el ticket de Jira
4. ✨ Genera mensaje(s) profesional(es)
5. ⚡ Ejecuta git add + commit automáticamente

---

## 🧠 Comportamiento del Skill

### 📏 Reglas Estrictas

<table>
<tr>
<td width="50%" valign="top">

#### ✅ SIEMPRE

- ✅ **Pregunta** el ticket de Jira
- ✅ **Ejecuta** comandos git en terminal con `run_in_terminal`
- ✅ **Analiza** cambios con git diff/log/status
- ✅ **Evalúa** el tipo de cambio realizado
- ✅ **Detecta** si hay múltiples commits lógicos
- ✅ **Genera** mensaje en inglés
- ✅ **Valida** máximo 100 caracteres
- ✅ **Sigue** formato Conventional Commits
- ✅ **Ejecuta** git add y commit automáticamente

</td>
<td width="50%" valign="top">

#### ❌ NUNCA

- ❌ **Inventa** el tipo de commit
- ❌ **Asume** el ticket de Jira
- ❌ **Genera** mensajes en español
- ❌ **Supera** 100 caracteres
- ❌ **Ignora** el análisis de cambios
- ❌ **Omite** el ticket en el mensaje

</td>
</tr>
</table>

> 💡 **Principio clave:** Analizar primero, generar después.

---

## 📋 Formato de Commit

### 🎯 Estructura Obligatoria

```
<type>: <TICKET-ID> <description>
```

**Ejemplo:**

```
feat: TICKET-12345 add user authentication endpoint
```

### 📊 Tipos de Commit (Conventional Commits)

<table>
<tr>
<th width="20%">Type</th>
<th width="80%">Cuándo usar</th>
</tr>
<tr>
<td><code>feat</code></td>
<td>Nueva funcionalidad o característica</td>
</tr>
<tr>
<td><code>fix</code></td>
<td>Corrección de bugs</td>
</tr>
<tr>
<td><code>docs</code></td>
<td>Cambios en documentación</td>
</tr>
<tr>
<td><code>style</code></td>
<td>Cambios de formato (espacios, punto y coma, etc.)</td>
</tr>
<tr>
<td><code>refactor</code></td>
<td>Refactorización sin cambiar funcionalidad</td>
</tr>
<tr>
<td><code>perf</code></td>
<td>Mejoras de rendimiento</td>
</tr>
<tr>
<td><code>test</code></td>
<td>Agregar o modificar tests</td>
</tr>
<tr>
<td><code>build</code></td>
<td>Cambios en build system o dependencias</td>
</tr>
<tr>
<td><code>ci</code></td>
<td>Cambios en CI/CD</td>
</tr>
<tr>
<td><code>chore</code></td>
<td>Tareas de mantenimiento</td>
</tr>
<tr>
<td><code>revert</code></td>
<td>Revertir un commit anterior</td>
</tr>
<tr>
<td><code>security</code></td>
<td>Correcciones de seguridad</td>
</tr>
</table>

---

## 📝 Proceso de Generación

### 🔵 Fase 1: Identificar Ticket

**Pregunta:**

```markdown
🎫 ¿Cuál es el ticket de Jira para estos cambios?

Formato esperado: TICKET-12345, PROJ-456, etc.
```

⏸️ **ESPERAR** respuesta del usuario

---

### 🔶 Fase 2: Analizar Cambios

> ⚠️ **IMPORTANTE:** Usar `run_in_terminal` para ejecutar TODOS los comandos git

**Secuencia de comandos a ejecutar:**

1. 📊 **`run_in_terminal`** → `git status --short`

   ```javascript
   run_in_terminal({
     command: "git status --short",
     explanation: "Ver archivos modificados",
     goal: "Identificar cambios staged y unstaged",
     isBackground: false,
     timeout: 5000,
   });
   ```

2. 📝 **`run_in_terminal`** → `git diff --stat`

   ```javascript
   run_in_terminal({
     command: "git diff --stat",
     explanation: "Obtener estadísticas de cambios",
     goal: "Ver resumen de líneas modificadas",
     isBackground: false,
     timeout: 5000,
   });
   ```

3. 🔍 **`run_in_terminal`** → `git diff --cached`

   ```javascript
   run_in_terminal({
     command: "git diff --cached",
     explanation: "Ver cambios en staging area",
     goal: "Analizar contenido de los cambios",
     isBackground: false,
     timeout: 10000,
   });
   ```

4. 📜 **`run_in_terminal`** → `git log -5 --oneline`

   ```javascript
   run_in_terminal({
     command: "git log -5 --oneline",
     explanation: "Ver últimos commits",
     goal: "Obtener contexto de commits recientes",
     isBackground: false,
     timeout: 5000,
   });
   ```

5. 🧠 **Analizar** los resultados de todos los comandos

**El análisis debe incluir:**

- ✅ ¿Qué archivos fueron modificados? (de `git status`)
- ✅ ¿Cuántas líneas agregadas/eliminadas? (de `git diff --stat`)
- ✅ ¿Qué tipo de cambios? (código, tests, docs, config)
- ✅ ¿Es nuevo código o modificación? (de `git diff --cached`)
- ✅ ¿Hay cambios de seguridad?
- ✅ ¿Hay patrones reconocibles? (nuevos archivos, refactor, etc.)
- ✅ **¿Se pueden separar en múltiples commits lógicos?**

**🔀 Detección de Múltiples Commits:**

Si los cambios incluyen tipos diferentes (feat + docs + test), **PREGUNTAR:**

```
🔀 Detecté cambios de diferentes tipos:

1️⃣ feat: 3 archivos (nuevos endpoints)
2️⃣ docs: 2 archivos (README actualizado)
3️⃣ test: 4 archivos (nuevos tests)

¿Prefieres?
- 📦 "un solo commit" → Commitear todo junto
- 🔀 "separar" → Crear 3 commits independientes
```

⏸️ **ESPERAR** respuesta del usuario

---

### 🔷 Fase 3: Determinar Tipo de Commit

**Lógica de decisión:**

<table>
<tr>
<th width="30%">Si detecta...</th>
<th width="40%">Entonces tipo es...</th>
<th width="30%">Ejemplo</th>
</tr>
<tr>
<td>Nuevos endpoints/features</td>
<td><code>feat</code></td>
<td>Controllers, Services nuevos</td>
</tr>
<tr>
<td>Fix de bugs / correcciones</td>
<td><code>fix</code></td>
<td>Correcciones en lógica</td>
</tr>
<tr>
<td>Solo tests</td>
<td><code>test</code></td>
<td>Archivos *Test.java</td>
</tr>
<tr>
<td>README, docs/</td>
<td><code>docs</code></td>
<td>Archivos .md, javadoc</td>
</tr>
<tr>
<td>Refactoring sin cambio funcional</td>
<td><code>refactor</code></td>
<td>Rename, extract method</td>
</tr>
<tr>
<td>pom.xml, build.gradle</td>
<td><code>build</code></td>
<td>Dependencias</td>
</tr>
<tr>
<td>Cambios de seguridad</td>
<td><code>security</code></td>
<td>Validaciones, filtros</td>
</tr>
<tr>
<td>CI/CD configs</td>
<td><code>ci</code></td>
<td>.github/, Jenkinsfile</td>
</tr>
<tr>
<td>Performance optimizations</td>
<td><code>perf</code></td>
<td>Caching, queries</td>
</tr>
</table>

**Si hay múltiples tipos:** Usar el tipo más relevante/impactante

---

### 🔹 Fase 4: Generar Descripción

**Reglas para la descripción:**

✅ **Debe:**

- Estar en **inglés**
- Ser clara y concisa
- Describir **QUÉ** cambió (no cómo)
- Usar verbo en presente imperativo (add, fix, update, remove)
- Ser específica pero breve

❌ **No debe:**

- Superar 100 caracteres TOTAL (incluyendo tipo + ticket)
- Incluir puntos finales
- Usar "." al final
- Ser vaga ("update code", "fix bug")
- Incluir detalles técnicos excesivos

**Fórmula de longitud:**

```
<type>: <TICKET-ID> <description>
  ↓        ↓            ↓
 4-10    10-15       50-75 chars máx
```

**Ejemplos válidos:**

```bash
✅ feat: PROJ-123 add user authentication endpoint
✅ fix: TICKET-456 resolve NPE in payment service
✅ docs: PROJ-789 update API documentation for v2
✅ refactor: TICKET-012 extract validation logic to utility class
✅ security: PROJ-999 validate Content-Type in login endpoints
✅ test: TICKET-555 add integration tests for order flow
```

**Ejemplos inválidos:**

```bash
❌ feat: PROJ-123 add user authentication endpoint with JWT tokens and refresh mechanism (>100 chars)
❌ arreglado: PROJ-123 se arreglo el bug (español)
❌ fix: arreglar el error en el servicio (sin ticket)
❌ update code (sin tipo ni ticket)
❌ feat: PROJ-123 Updated the authentication system. (punto final, pasado)
```

---

### 🔸 Fase 5: Validación y Confirmación

**Validar:**

1. ✅ Longitud total ≤ 100 caracteres
2. ✅ Formato: `<type>: <TICKET-ID> <description>`
3. ✅ Ticket válido (formato XXXX-NNNN)
4. ✅ Descripción en inglés
5. ✅ Sin punto final
6. ✅ Verbo en imperativo

**Mostrar al usuario:**

```markdown
## ✅ Commit Message Generado

📦 **Archivos modificados:** X files
📊 **Líneas cambiadas:** +Y, -Z
🎯 **Tipo detectado:** <type>

### 📝 Mensaje propuesto:

\`\`\`
<type>: <TICKET-ID> <description>
\`\`\`

**Longitud:** XX/100 caracteres

---

¿Usar este mensaje?

- ✅ "sí" o "usar" → Ejecutar git add + commit automáticamente
- ✏️ "modificar: [nuevo mensaje]" → Ajustar manualmente
- 🔄 "regenerar" → Generar alternativa
- 📋 "solo mensaje" → Mostrar comando sin ejecutar
```

---

### 🔹 Fase 6: Ejecución Automática

**Cuando el usuario confirma con "sí" o "usar":**

**Secuencia de comandos a ejecutar:**

1. 📦 **`run_in_terminal`** → `git add .` (o archivos específicos)

   ```javascript
   run_in_terminal({
     command: "git add .",
     explanation: "Agregar archivos al staging area",
     goal: "Preparar cambios para commit",
     isBackground: false,
     timeout: 5000,
   });
   ```

2. ✅ **`run_in_terminal`** → `git commit -m "<mensaje>"`

   ```javascript
   run_in_terminal({
     command: 'git commit -m "feat: PROJ-123 add user authentication"',
     explanation: "Ejecutar commit con mensaje generado",
     goal: "Crear commit en el repositorio",
     isBackground: false,
     timeout: 5000,
   });
   ```

3. 🎉 **Confirmar éxito** y mostrar resultado

**Si el usuario dice "solo mensaje":**

- Mostrar el comando sin ejecutar
- Usuario copia y ejecuta manualmente

**Si hay múltiples commits:**

- Ejecutar git add y commit para cada grupo de archivos
- Mostrar progreso: "Commit 1/3 completado ✅"

---

## 🎨 Formato de Conversación

### Ejemplo de Sesión Completa

```
Usuario:
"Genera un commit para mis cambios"

Skill:
## 🎯 Generador de Commit Message

Voy a analizar tus cambios y generar un mensaje de commit profesional.

---

## 🎫 Ticket de Jira

¿Cuál es el ticket de Jira para estos cambios?

Formato: TICKET-12345, PROJ-456, etc.

---

Usuario:
"PROJ-789"

Skill:
✅ **Ticket:** PROJ-789

Analizando cambios...

📊 **Análisis de Cambios:**

- 📁 Archivos modificados: 3
  - src/main/java/com/example/LoginController.java (+45, -10)
  - src/main/java/com/example/ContentTypeFilter.java (+80, -0)
  - src/test/java/com/example/LoginControllerTest.java (+30, -5)

- 🔍 **Tipo detectado:** `security`
  - Razón: Nuevos filtros de validación y configuración de seguridad

- 📝 **Cambios principales:**
  - Nuevo filtro de Content-Type
  - Validación de headers
  - Tests de seguridad

---

## ✅ Commit Message Generado

📦 **Archivos:** 3 files
📊 **Cambios:** +155, -15
🎯 **Tipo:** security

### 📝 Mensaje propuesto:

\`\`\`
security: PROJ-789 validate Content-Type in login endpoints
\`\`\`

**Longitud:** 58/100 caracteres ✅

---

¿Usar este mensaje?

- ✅ "sí" o "usar"
- ✏️ "modificar: [nuevo mensaje]"
- 🔄 "regenerar"

---

Usuario:
"sí"

Skill:
## 🎉 Ejecutando Commit...

### 📦 Paso 1: Agregando archivos

\`\`\`bash
$ git add .
\`\`\`

✅ Archivos agregados al staging area

---

### ✅ Paso 2: Creando commit

\`\`\`bash
$ git commit -m "security: PROJ-789 validate Content-Type in login endpoints"
[main 3e451e4] security: PROJ-789 validate Content-Type in login endpoints
 3 files changed, 155 insertions(+), 15 deletions(-)
\`\`\`

---

## 🎉 ¡Commit Creado Exitosamente!

✅ **Commit ID:** `3e451e4`
✅ **Archivos:** 3 files
✅ **Cambios:** +155, -15
✅ **Mensaje:** security: PROJ-789 validate Content-Type in login endpoints

---

**Próximos pasos:**
- 🚀 `git push` para subir cambios
- 🔄 ¿Necesitas otro commit?
```

---

## 🛠️ Tools a Usar

> 🔑 **HERRAMIENTA PRINCIPAL:** `run_in_terminal` - Úsala para TODOS los comandos git

<table>
<tr>
<th width="30%">Tool</th>
<th width="70%">Uso y Comandos</th>
</tr>
<tr>
<td><b>💻 run_in_terminal</b><br/><br/><i>⭐ Obligatorio</i></td>
<td>
<b>Ejecutar comandos git en la terminal:</b><br/><br/>

<b>1. Ver estado:</b><br/>
<code>git status --short</code><br/>
<code>git status</code><br/><br/>

<b>2. Ver estadísticas:</b><br/>
<code>git diff --stat</code><br/>
<code>git diff --stat --cached</code><br/><br/>

<b>3. Ver cambios detallados:</b><br/>
<code>git diff</code> (unstaged)<br/>
<code>git diff --cached</code> (staged)<br/>
<code>git diff HEAD</code> (todos)<br/><br/>

<b>4. Ver historial:</b><br/>
<code>git log -5 --oneline</code><br/>
<code>git log --oneline --graph -10</code><br/><br/>

<b>5. Ver archivos específicos:</b><br/>
<code>git diff --name-only</code><br/>
<code>git ls-files -m</code><br/><br/>

<b>6. Ejecutar commits:</b><br/>
<code>git add .</code> (todos los archivos)<br/>
<code>git add archivo.txt</code> (específico)<br/>
<code>git commit -m "mensaje"</code><br/><br/>

<b>7. Commits selectivos:</b><br/>
<code>git add src/main/_.java</code><br/>
<code>git add README.md docs/</code><br/>
<code>git add test/\*\*/_.java</code><br/><br/>

⚠️ <b>Siempre usar:</b><br/>
• <code>isBackground: false</code><br/>
• <code>timeout: 5000-10000</code><br/>
• <code>explanation</code> clara<br/>
• <code>goal</code> específico

</td>
</tr>
<tr>
<td><b>📋 manage_todo_list</b></td>
<td>
Trackear proceso (uso interno)<br/>
• Ticket recopilado<br/>
• Cambios analizados<br/>
• Tipo determinado<br/>
• Mensaje generado
</td>
</tr>
</table>

---

## 🔍 Análisis Inteligente de Cambios

### Patrones de Detección

<details>
<summary><b>🔍 Click para ver lógica de detección</b></summary>

**feat (Feature):**

```python
if (new_files_created OR
    new_endpoints OR
    new_classes OR
    new_public_methods):
    type = "feat"
```

**fix (Bug Fix):**

```python
if (bug_keywords in commit_context OR
    fix_keywords in files OR
    error_handling_changes):
    type = "fix"
```

**security:**

```python
if (security_keywords OR
    validation_added OR
    authentication_changes OR
    authorization_changes):
    type = "security"
```

**refactor:**

```python
if (code_restructure AND
    no_new_features AND
    no_bug_fixes):
    type = "refactor"
```

**test:**

```python
if (only_test_files_changed):
    type = "test"
```

**docs:**

```python
if (only_md_or_doc_files):
    type = "docs"
```

</details>

---

### 🔀 Detección de Múltiples Commits

**Lógica para separar commits:**

```python
# Detectar si hay cambios de diferentes tipos
changes_by_type = {
    'feat': [archivos de features],
    'docs': [archivos de docs],
    'test': [archivos de tests],
    'fix': [archivos de fixes]
}

if len(changes_by_type) > 1:
    PREGUNTAR: "¿Separar en múltiples commits?"

    if usuario_dice_separar:
        for tipo, archivos in changes_by_type:
            1. git add [archivos_del_tipo]
            2. generar_mensaje(tipo, archivos)
            3. git commit -m mensaje
            4. mostrar_progreso()
    else:
        # Commit único con tipo dominante
        tipo_dominante = max(changes_by_type, key=lambda x: len(x.archivos))
        commit_all_with_type(tipo_dominante)
```

**Ejemplo de output:**

```
🔀 Detecté 3 tipos de cambios diferentes:

1️⃣ feat (5 archivos):
   - src/services/AuthService.java
   - src/controllers/LoginController.java
   - src/models/User.java

2️⃣ docs (2 archivos):
   - README.md
   - docs/API.md

3️⃣ test (3 archivos):
   - test/AuthServiceTest.java
   - test/LoginControllerTest.java
   - test/UserTest.java

¿Prefieres?
- 📦 "un solo commit" → Commitear todo como 'feat' (tipo dominante)
- 🔀 "separar" → Crear 3 commits independientes
```

---

## 🔒 Constraints Finales

<table>
<tr>
<td width="50%" bgcolor="#ffebee">

### ❌ NUNCA

- ❌ Generar sin analizar cambios
- ❌ Superar 100 caracteres
- ❌ Usar español en mensaje
- ❌ Omitir el ticket de Jira
- ❌ Inventar el tipo de commit
- ❌ Usar verbos en pasado
- ❌ Ejecutar commit sin confirmación
- ❌ Ignorar opción de múltiples commits

</td>
<td width="50%" bgcolor="#e8f5e9">

### ✅ SIEMPRE

- ✅ Analizar cambios primero
- ✅ Validar longitud ≤100 chars
- ✅ Generar en inglés
- ✅ Incluir ticket formato correcto
- ✅ Determinar tipo basado en análisis
- ✅ Usar verbo imperativo presente
- ✅ Detectar si hay múltiples tipos lógicos
- ✅ Ejecutar git add + commit automáticamente
- ✅ Confirmar éxito del commit

</td>
</tr>
</table>

### 🛡️ Principios de Operación

```diff
+ ANÁLISIS sobre SUPOSICIÓN
+ PRECISIÓN sobre VELOCIDAD
+ ESTÁNDARES sobre CONVENIENCIA
+ CLARIDAD sobre BREVEDAD
+ AUTOMATIZACIÓN sobre TRABAJO MANUAL
+ COMMITS ATÓMICOS sobre COMMITS GRANDES
```

---

## 💡 Tips y Mejores Prácticas

<details>
<summary><b>📚 Click para ver tips</b></summary>

### ✍️ Escribiendo Buenas Descripciones

**✅ Buenos ejemplos:**

```
add user registration endpoint
fix null pointer in payment service
update authentication documentation
remove deprecated API endpoints
refactor database connection pool
validate Content-Type headers
```

**❌ Malos ejemplos:**

```
changes
updated stuff
fix bug
new feature
algunos cambios
arreglé el error
```

### 📏 Optimizando Longitud

**Si el mensaje es muy largo:**

1. Remover palabras innecesarias
2. Usar abreviaturas estándar (API, DB, etc.)
3. Ser más específico pero conciso
4. Enfocarse en QUÉ cambió, no CÓMO

**Ejemplo de optimización:**

```diff
- feat: PROJ-123 add new endpoint for user registration with email validation
+ feat: PROJ-123 add user registration endpoint with email validation
+ feat: PROJ-123 add user registration with validation
✅ feat: PROJ-123 add user registration endpoint
```

</details>

---

## 🔀 Ejemplo: Múltiples Commits

<details>
<summary><b>📖 Click para ver ejemplo completo de separación de commits</b></summary>

### Escenario: Cambios mixtos detectados

```
Usuario:
"Genera commits para mis cambios"

Skill:
## 🎯 Generador de Commit Message

Analizando cambios...

📊 **Análisis de Cambios:**

- 📁 **10 archivos modificados:**

  **Features (5 archivos):**
  - src/services/AuthService.java (+120, -0)
  - src/controllers/LoginController.java (+85, -10)
  - src/models/User.java (+45, -0)
  - src/config/SecurityConfig.java (+30, -5)
  - src/utils/TokenGenerator.java (+60, -0)

  **Documentation (2 archivos):**
  - README.md (+25, -10)
  - docs/API.md (+150, -0)

  **Tests (3 archivos):**
  - test/AuthServiceTest.java (+200, -0)
  - test/LoginControllerTest.java (+180, -0)
  - test/UserTest.java (+90, -0)

---

🔀 **Detecté 3 tipos de cambios diferentes**

¿Prefieres crear?
- 📦 **"un solo commit"** → Todo junto como 'feat'
- 🔀 **"separar"** → 3 commits independientes (recomendado)

---

Usuario:
"separar"

Skill:
✅ Perfecto. Voy a crear 3 commits atómicos.

🎫 ¿Cuál es el ticket de Jira?

Usuario:
"PROJ-456"

Skill:
✅ **Ticket:** PROJ-456

---

## 📋 Generando Commits (1/3)

### 🔵 Commit 1: Feature

**Archivos:**
- src/services/AuthService.java
- src/controllers/LoginController.java
- src/models/User.java
- src/config/SecurityConfig.java
- src/utils/TokenGenerator.java

**Mensaje propuesto:**
```

feat: PROJ-456 add OAuth2 authentication with Google

````

¿Confirmar? (sí/modificar)

Usuario:
"sí"

Skill:
### 🔵 Ejecutando Commit 1/3...

```bash
$ git add src/services/AuthService.java src/controllers/LoginController.java src/models/User.java src/config/SecurityConfig.java src/utils/TokenGenerator.java
$ git commit -m "feat: PROJ-456 add OAuth2 authentication with Google"
[main a1b2c3d] feat: PROJ-456 add OAuth2 authentication with Google
 5 files changed, 340 insertions(+), 15 deletions(-)
````

✅ **Commit 1/3 completado**

---

## 📋 Generando Commits (2/3)

### 📘 Commit 2: Documentation

**Archivos:**

- README.md
- docs/API.md

**Mensaje propuesto:**

```
docs: PROJ-456 update authentication documentation
```

¿Confirmar? (sí/modificar)

Usuario:
"sí"

Skill:

### 📘 Ejecutando Commit 2/3...

```bash
$ git add README.md docs/API.md
$ git commit -m "docs: PROJ-456 update authentication documentation"
[main b2c3d4e] docs: PROJ-456 update authentication documentation
 2 files changed, 175 insertions(+), 10 deletions(-)
```

✅ **Commit 2/3 completado**

---

## 📋 Generando Commits (3/3)

### ✅ Commit 3: Tests

**Archivos:**

- test/AuthServiceTest.java
- test/LoginControllerTest.java
- test/UserTest.java

**Mensaje propuesto:**

```
test: PROJ-456 add integration tests for OAuth2 flow
```

¿Confirmar? (sí/modificar)

Usuario:
"sí"

Skill:

### ✅ Ejecutando Commit 3/3...

```bash
$ git add test/AuthServiceTest.java test/LoginControllerTest.java test/UserTest.java
$ git commit -m "test: PROJ-456 add integration tests for OAuth2 flow"
[main c3d4e5f] test: PROJ-456 add integration tests for OAuth2 flow
 3 files changed, 470 insertions(+)
```

✅ **Commit 3/3 completado**

---

## 🎉 ¡Todos los Commits Creados!

### 📊 Resumen:

✅ **3 commits atómicos creados**

1️⃣ `a1b2c3d` - feat: PROJ-456 add OAuth2 authentication with Google (5 archivos)
2️⃣ `b2c3d4e` - docs: PROJ-456 update authentication documentation (2 archivos)
3️⃣ `c3d4e5f` - test: PROJ-456 add integration tests for OAuth2 flow (3 archivos)

---

**Próximos pasos:**

- 🚀 `git push` para subir cambios
- 📝 `git log --oneline -3` para verificar commits

**Beneficios:**
✅ Commits atómicos y enfocados
✅ Historial limpio y organizado
✅ Fácil de revertir cambios específicos
✅ Code review más claro

```

</details>

---

<div align="center">

### 💚 Listo para Usar

**Dame el comando y empezamos:**

_"Genera un commit para mis cambios"_

---

![Ready](https://img.shields.io/badge/status-ready-success?style=for-the-badge&logo=git)
![Conventional](https://img.shields.io/badge/format-conventional%20commits-blue?style=for-the-badge&logo=conventionalcommits)
![Quality](https://img.shields.io/badge/quality-first-orange?style=for-the-badge&logo=codacy)
![Automated](https://img.shields.io/badge/automated-commits-green?style=for-the-badge&logo=githubactions)

</div>
```
