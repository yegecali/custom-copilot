# 🎯 Commit Reorganizer - Skill Interactivo

<div align="center">

![Status](https://img.shields.io/badge/status-active-success?style=for-the-badge)
![Type](https://img.shields.io/badge/type-interactive-blue?style=for-the-badge)
![Version](https://img.shields.io/badge/version-2.1-orange?style=for-the-badge)

</div>

---

## 📖 Descripción

> 🤖 **Skill especializado** en reorganizar commits existentes con mejor estructura y mensajes.
>
> Analiza el historial de commits, permite reorganizarlos lógicamente, y regenera commits con **mensajes convencionales y tickets Jira**.

---

## 🚀 Cómo Usarlo

**Palabras clave para activar:**

```
"Reorganiza mis commits"
"Rebase interactivo de commits"
"Limpia el historial de commits"
"Reorganizar commits desde [hash]"
"Refactoriza mis commits"
```

**Ejemplo de uso:**

```
"Reorganiza mis commits desde abc1234"
"Limpia los últimos 5 commits"
"Rebase interactivo desde HEAD~3"
```

**El skill:**
**El skill:**

1. 🔢 Pregunta cuántos commits ver
2. 📊 Muestra git log con historial
3. 🎯 Pregunta desde dónde reorganizar
4. 🔍 Analiza cambios de cada commit
5. ⚠️ **Detecta commits pusheados y pregunta qué hacer**
6. 🛡️ **Crea rama backup si hay riesgo**
7. 🎫 Pregunta si mantener o cambiar tickets Jira
8. 🤔 Sugiere agrupaciones lógicas
9. 🔐 Crea backup de seguridad adicional
10. ✨ Genera nuevos commits limpios
11. 🚀 **Guía force push si reorganizó pusheados**
8. ✨ Genera nuevos commits limpios

---

## 🧠 Comportamiento del Skill

### 📏 Reglas Estrictas

<table>
<tr>
<td width="50%" valign="top">

#### ✅ SIEMPRE

- ✅ **Muestra** historial completo antes de reorganizar
- ✅ **Detecta** commits pusheados vs locales
- ✅ **Pregunta** confirmación antes de rebase
- ✅ **Crea rama backup** si hay commits pusheados
- ✅ **Agrupa** cambios relacionados
- ✅ **Pide** ticket Jira por grupo
- ✅ **Valida** mensajes convencionales
- ✅ **Crea backup** antes de reorganizar
- ✅ **Guía force push** si reorganizó pusheados

</td>
<td width="50%" valign="top">

#### ❌ NUNCA

- ❌ **Reorganiza** sin confirmación
- ❌ **Pierde** cambios del usuario
- ❌ **Asume** agrupación sin validar
- ❌ **Omite** backup de seguridad
- ❌ **Modifica** commits pusheados sin advertir
- ❌ **Ignora** conflictos
- ❌ **Hace force push** sin permiso explícito

</td>
</tr>
</table>

> 💡 **Principio clave:** Seguridad primero, reorganización inteligente.

---

## ⚠️ Advertencia Importante

```diff
! ESTE SKILL MODIFICA EL HISTORIAL DE GIT
! DETECTA AUTOMÁTICAMENTE COMMITS PUSHEADOS
! TE PREGUNTARÁ SI QUIERES REORGANIZARLOS (ALTO RIESGO)
! O SOLO REORGANIZAR COMMITS LOCALES (SEGURO)
! SE CREARÁ UN BACKUP AUTOMÁTICAMENTE
! SI REORGANIZAS PUSHEADOS, NECESITARÁS FORCE PUSH
```

---

## 📋 Proceso de Reorganización

### 🔵 Fase 1: Preguntar Cantidad de Commits

**Siempre preguntar primero:**

```markdown
## 🔢 Visualizar Historial de Commits

¿Cuántos commits quieres ver?

**Opciones rápidas:**

1️⃣ Últimos **5 commits**
2️⃣ Últimos **10 commits**
3️⃣ Últimos **20 commits**
4️⃣ Cantidad personalizada (escribe el número)
5️⃣ Desde último push (`origin/develop..HEAD`)

Escribe un número (1-5) o el número exacto de commits:
```

⏸️ **ESPERAR** respuesta del usuario

**Ejemplo:**

```
Usuario: "20"
         → Mostrar últimos 20 commits

Usuario: "2"
         → Mostrar últimos 10 commits
```

---

### 🔶 Fase 2: Mostrar Git Log

**Ejecutar comando según respuesta:**

```bash
# Si usuario dijo "20 commits"
git log --oneline --graph --decorate HEAD~20..HEAD

# Si usuario dijo "desde último push"
git log --oneline --graph --decorate origin/develop..HEAD
```

**Mostrar resultado:**

```markdown
## 📊 Historial de Commits (Últimos 20)
```

- 9a8ca60 (HEAD -> develop) style: TECH-123 improve markdown formatting
- 72ecc83 docs: PROJ-456 add API documentation generation skills
- 005266b chore: PROJ-456 consolidate project structure
- f92d5a9 chore: PROJ-456 add agent stubs
- 8d65ef5 docs: PROJ-456 add interactive skills
- c9c605d chore: PROJ-456 reorganize agent structure
- 3e451e4 (origin/develop) Enhance Java Streams Documentation
- b043344 chore: remove obsolete v2 prompt files
- adef9be feat: add code analysis and utility prompts
- d5850f7 feat: add advanced functional programming prompts
  ... (más commits)

```

**Total:** 20 commits mostrados
```

---

### 🔷 Fase 3: Preguntar Desde Dónde Reorganizar

```markdown
## 🎯 ¿Desde dónde quieres reorganizar?

Ahora que viste el historial, selecciona el punto inicial:

**Opciones:**

1️⃣ **Desde commit específico**

- Escribe el hash del commit
- Ejemplo: `3e451e4`, `c9c605d`

2️⃣ **Últimos N commits**

- Ejemplo: `HEAD~5`, `HEAD~10`

3️⃣ **Solo commits NO pusheados** ✅ **RECOMENDADO**

- `origin/develop..HEAD`
- Más seguro para reorganizar

4️⃣ **Todos los mostrados**

- Reorganizar los 20 commits mostrados

---

⚠️ **Importante:** Solo reorganiza commits que **NO** han sido pusheados al remoto.

¿Desde dónde? (escribe número u opción):
```

⏸️ **ESPERAR** respuesta del usuario

**Ejemplo:**

```
Usuario: "3"  → origin/develop..HEAD
Usuario: "c9c605d"  → Desde commit c9c605d
Usuario: "HEAD~6"  → Últimos 6 commits
```

---

### 🔹 Fase 4: Analizar Cambios por Commit

**Ejecutar análisis detallado:**

```bash
# Ver commits en el rango seleccionado
git log origin/develop..HEAD --reverse --format="=== %h - %s ===" --stat
```

\*\*Ejemplo de salida:

## 📊 Historial de Commits

```

\* 9a8ca60 (HEAD -> develop) style: TECH-123 improve markdown formatting

- 72ecc83 docs: PROJ-456 add API documentation generation skills
- 005266b chore: PROJ-456 consolidate project structure
- f92d5a9 chore: PROJ-456 add agent stubs
- 8d65ef5 docs: PROJ-456 add interactive skills

```

**Total:** 5 commits para analizar

---

### 🔎 Análisis Detallado

Analizando cambios de cada commit...

````

---

### 🔷 Fase 3: Analizar Cambios por Commit

**Para cada commit, ejecutar:**

```bash
git show --stat <commit-hash>
git show --name-status <commit-hash>
````

**Extraer información:**

```markdown
## 📝 Análisis de Commit: 9a8ca60

**Mensaje original:** `style: TECH-123 improve markdown formatting`  
**Autor:** Usuario  
**Fecha:** 2026-02-07 10:30:00

### Archivos modificados:

- ✏️ `.github/skills/method-flow-diagram/SKILL.md` (+82, -56)
- ✏️ `.github/skills/openapi-generator/SKILL.md` (+83, -43)

### Tipo de cambios:

- 🎨 Style/Format changes
- 📝 Documentation

### Categoría detectada:

- **Tipo:** `style`
- **Scope:** documentation skills
- **Ticket Jira:** `TECH-123`
```

**Repetir para cada commit.**

**Resumen del análisis:**

```markdown
## 📊 Resumen de Análisis

**Total commits:** 6

**Tickets Jira detectados:**

- `PROJ-456` → 5 commits (chore, docs)
- `TECH-123` → 1 commit (style)

**Tipos de commit:**

- 🔧 `chore` → 3 commits
- 📝 `docs` → 2 commits
- 🎨 `style` → 1 commit
```

---

### 🔸 Fase 5: Validar Commits Pusheados

**Verificar si hay commits pusheados en el rango:**

```bash
# Detectar commits pusheados
git branch -r --contains <commit-hash>

# O verificar con:
git log origin/develop..HEAD --oneline
```

**Si HAY commits pusheados:**

```markdown
## ⚠️ Commits Pusheados Detectados

### 🚨 ADVERTENCIA DE ALTO RIESGO

Detecté que algunos commits en el rango seleccionado **YA FUERON PUSHEADOS** al remoto:

**Commits pusheados:** 5 commits (hasta 3e451e4)
**Commits locales:** 6 commits (desde c9c605d)

---

### ⚠️ Riesgos de Reorganizar Commits Pusheados:

❌ **Reescribir el historial** público  
❌ Requiere **force push** (`git push -f`)  
❌ Puede causar **conflictos** para otros desarrolladores  
❌ Puede **romper** otros branches basados en estos commits  
❌ No es reversible fácilmente en el remoto

---

### 🤔 ¿Qué quieres hacer?

**Opciones:**

1️⃣ **Solo reorganizar commits locales** ✅ **RECOMENDADO**

- Reorganizar solo los 6 commits NO pusheados
- Rango: `origin/develop..HEAD`
- Seguro y sin riesgos

2️⃣ **Reorganizar TODO (incluyendo pusheados)** ⚠️ **ALTO RIESGO**

- Reorganizar los 11 commits seleccionados
- Requiere crear rama de backup
- Requiere force push al finalizar
- Solo si trabajas solo o tienes autorización

3️⃣ **Cancelar** 🛑

- No hacer ninguna reorganización
- Volver al inicio

---

💡 **Recomendación:** Opción 1 - Solo reorganizar commits locales (más seguro)

¿Qué opción prefieres? (1/2/3):
```

⏸️ **ESPERAR** respuesta del usuario

---

**Si usuario elige Opción 1 (Solo locales):**

```markdown
✅ Excelente decisión. Reorganizando solo commits locales.

**Rango ajustado:** `origin/develop..HEAD` (6 commits)

Continuando con configuración de tickets Jira...
```

---

**Si usuario elige Opción 2 (Incluir pusheados):**

````markdown
⚠️ HAS ELEGIDO REORGANIZAR COMMITS PUSHEADOS

### 🛡️ Creando Rama de Backup

Antes de continuar, voy a crear una rama de respaldo:

```bash
# Crear rama de backup con timestamp
git branch backup-reorganize-$(date +%Y%m%d-%H%M%S)
```
````

✅ Rama de backup creada: `backup-reorganize-20260207-103000`

**Para restaurar si algo sale mal:**

```bash
git checkout backup-reorganize-20260207-103000
git branch -D develop
git checkout -b develop
git branch -D backup-reorganize-20260207-103000
```

---

### ⚠️ Confirmación Final de Alto Riesgo

**Estás a punto de:**

- Reorganizar 11 commits (5 pusheados + 6 locales)
- Reescribir el historial público
- Necesitar force push al finalizar

**¿Estás 100% seguro?** (escribe "SI ACEPTO EL RIESGO"):

```

⏸️ **ESPERAR** confirmación explícita

**Si usuario NO confirma exactamente:**

```

🛑 Reorganización cancelada por seguridad.

Rama de backup mantenida: `backup-reorganize-20260207-103000`

```

**Si usuario confirma "SI ACEPTO EL RIESGO":**

```

✅ Confirmación recibida. Procediendo con reorganización completa.

⚠️ Recuerda: Al finalizar deberás hacer `git push --force-with-lease`

Continuando con configuración de tickets Jira...

```

---

**Si usuario elige Opción 3 (Cancelar):**

```

🛑 Reorganización cancelada por el usuario.

Tu repositorio permanece sin cambios.

````

⏹️ **FIN DEL SKILL**

---

**Si NO hay commits pusheados:**

```markdown
✅ Todos los commits en el rango son locales (no pusheados)

**Commits a reorganizar:** 6 commits
**Seguro para reorganizar** ✅

Continuando con configuración de tickets Jira...
````

---

### 🔸 Fase 6: Consultar Tickets Jira

```markdown
## 🎫 Configuración de Tickets Jira

Detecté los siguientes tickets en tus commits:

**Tickets actuales:**

- `PROJ-456` (5 commits)
- `TECH-123` (1 commit)

---

### ¿Qué quieres hacer con los tickets?

1️⃣ **Mantener tickets actuales** ✅ **RECOMENDADO**

- Los commits mantendrán sus tickets Jira originales
- Agrupaciones respetarán los tickets

2️⃣ **Cambiar TODOS a un ticket nuevo**

- Unificar bajo un solo ticket Jira
- Ejemplo: `PROJ-789`

3️⃣ **Cambiar por grupo**

- Cada grupo de commits tendrá su propio ticket
- Te preguntaré el ticket por cada grupo más adelante

4️⃣ **Reorganizar tickets custom**

- Tú decides qué tickets usar

---

¿Qué opción prefieres? (1/2/3/4):
```

⏸️ **ESPERAR** respuesta del usuario

**Si usuario elige opción 1:**

```
✅ Manteniendo tickets originales: PROJ-456, TECH-123
```

**Si usuario elige opción 2:**

```markdown
### Ticket único para todos los commits

Escribe el ticket Jira que quieres usar:

Ejemplo: `PROJ-789`, `TECH-456`, `FEAT-123`
```

⏸️ **ESPERAR** ticket del usuario

```
✅ Todos los commits usarán: PROJ-789
```

**Si usuario elige opción 3:**

```
✅ Consultaré el ticket Jira para cada grupo durante la reorganización
```

**Si usuario elige opción 4:**

```markdown
### Configuración Custom de Tickets

Por cada commit, indica el ticket Jira a usar:

**Commit 1:** `c9c605d` - chore: reorganize

- Ticket actual: `PROJ-456`
- Nuevo ticket (o Enter para mantener): \_\_\_
```

⏸️ **ESPERAR** respuesta por cada commit

---

### 🔹 Fase 7: Sugerencias de Reorganización

```markdown
## 🤔 ¿Deseas Reorganizar los Commits?

### Análisis completado:

**Commits analizados:** 6

**Tickets Jira:** `PROJ-456` (5 commits), `TECH-123` (1 commit)

**Tipos detectados:**

- 📝 `docs` - 2 commits (33%)
- 🔧 `chore` - 3 commits (50%)
- 🎨 `style` - 1 commit (17%)

---

### 💡 Sugerencias de Reorganización:

**Opción 1: Mantener como está**

- No hacer cambios
- Los commits están bien organizados
- 6 commits separados

**Opción 2: Agrupar por tipo** ✅ **RECOMENDADO**

- Grupo 1: `chore` - Reorganización completa (3 commits → 1)
  - Ticket: `PROJ-456`
- Grupo 2: `docs` - Skills de documentación (2 commits → 1)
  - Ticket: `PROJ-456`
- Grupo 3: `style` - Formato markdown (mantener)
  - Ticket: `TECH-123`

**Resultado:** 6 → 3 commits bien organizados

**Opción 3: Agrupar por ticket**

- Grupo 1: PROJ-456 (5 commits → 1-2 commits)
- Grupo 2: TECH-123 (mantener)

**Opción 4: Reorganización custom**

- Tú decides cómo agrupar

---

¿Qué opción prefieres? (1/2/3/4)
```

⏸️ **ESPERAR** respuesta del usuario

---

### 🔷 Fase 8: Crear Backup

**Antes de cualquier cambio:**

```bash
# Crear tag de backup
git tag -a backup-before-reorganize-$(date +%Y%m%d-%H%M%S) -m "Backup antes de reorganizar commits"
```

````markdown
## 🛡️ Backup Creado

✅ Tag de backup: `backup-before-reorganize-20260207-103000`

**Para restaurar si algo sale mal:**

```bash
git reset --hard backup-before-reorganize-20260207-103000
git tag -d backup-before-reorganize-20260207-103000
```
````

---

Continuando con reorganización...

````

---

### 🔸 Fase 9: Agrupar Cambios y Confirmar Tickets

**Si usuario eligió Opción 2 (Agrupar por tipo):**

```markdown
## 🎯 Agrupación de Cambios

### Grupo 1: Reorganización de estructura

**Commits a combinar:**

- `005266b` - chore: PROJ-456 consolidate project structure
- `f92d5a9` - chore: PROJ-456 add agent stubs

**Archivos involucrados:** 81 archivos
**Cambios:** Reorganización completa + agent stubs

**Ticket Jira para este grupo:**
[Ejemplo: PROJ-456]
````

⏸️ **ESPERAR** ticket Jira del usuario

```markdown
**Mensaje propuesto:**
```

chore: PROJ-456 reorganize project structure and add agent stubs

- Consolidate all configurations to root .github/ folder
- Move 35+ instruction and prompt files
- Add agent stubs for future implementation
- Clean up old subdirectories

```

¿Está bien este mensaje? (si/cambia/cancela)
```

⏸️ **ESPERAR** confirmación

**Repetir para cada grupo.**

---

### 🔷 Fase 10: Ejecutar Reorganización

**Método 1: Rebase Interactivo (si commits consecutivos)**

```bash
git rebase -i HEAD~5
```

**Archivo de rebase interactivo (generado automáticamente):**

```
pick 8d65ef5 docs: PROJ-456 add interactive skills
squash f92d5a9 chore: PROJ-456 add agent stubs
squash 005266b chore: PROJ-456 consolidate project structure
pick 72ecc83 docs: PROJ-456 add API documentation generation skills
pick 9a8ca60 style: TECH-123 improve markdown formatting
```

**Ejecutar:**

```bash
git rebase --continue
# Editar mensajes según lo acordado
```

---

**Método 2: Reset y Recomit (si reorganización compleja)**

```bash
# Soft reset al commit base
git reset --soft HEAD~5

# Ahora todos los cambios están staged
git status
```

**Luego, separar y commitear por grupos:**

````markdown
## 📦 Creando Nuevo Commit 1/3

**Grupo:** Reorganización de estructura  
**Ticket:** PROJ-456

### Archivos a incluir:

- `.github/agents/java-backend.agent.md`
- `.github/instructions/` (35 archivos)
- `.github/prompts/` (46 archivos)
- Archivos de configuración

**Comando:**

```bash
git add .github/agents/ .github/instructions/ .github/prompts/ .vscode/settings.json
git commit -m "chore: PROJ-456 reorganize project structure and add agent stubs"
```
````

Ejecutando...

````

✅ **Commit 1/3 creado:** `abc1234`

---

**Repetir para cada grupo.**

---

### 🔸 Fase 11: Validación Final

**Después de reorganizar:**

```bash
# Mostrar nuevo historial
git log --oneline --graph HEAD~3..HEAD

# Comparar con backup
git diff backup-before-reorganize-20260207-103000 HEAD
````

```markdown
## ✅ Reorganización Completada

### 📊 Antes vs Después:

**Antes:**

- 5 commits
- Mensajes mixtos
- Algunos sin ticket Jira

**Después:**

- 3 commits
- Todos con conventional commits
- Todos con tickets Jira
- Agrupación lógica

---

### 🆕 Nuevo Historial:
```

\* def5678 (HEAD -> develop) style: TECH-123 improve markdown formatting

- abc1234 docs: PROJ-789 add complete API documentation skills
- 123abcd chore: PROJ-456 reorganize project structure

```

---

### 📈 Estadísticas:

**Commits reducidos:** 5 → 3 (-40%)
**Todos con Jira:** ✅
**Conventional commits:** ✅
**Agrupación lógica:** ✅

---

### 🗑️ Limpiar Backup

¿Quieres eliminar el backup? (si/no)

**Si NO:** El tag `backup-before-reorganize-20260207-103000` se mantendrá
```

⏸️ **ESPERAR** respuesta

**Si "si":**

```bash
git tag -d backup-before-reorganize-20260207-103000
```

---

### ⚠️ Fase 12: Force Push (Solo si reorganizaste commits pusheados)

**Si reorganizaste commits que YA ESTABAN PUSHEADOS:**

````markdown
## 🚨 FALTA PUSH AL REMOTO

Has reorganizado commits que ya estaban en el remoto.

**Debes hacer FORCE PUSH para actualizar el remoto:**

⚠️ **Importante:** Usa `--force-with-lease` (más seguro que `-f`)

```bash
# Verificar estado
git status

# Ver diferencia con remoto
git log origin/develop..HEAD --oneline

# Force push con seguridad
git push --force-with-lease origin develop
```
````

---

### ⚠️ ADVERTENCIAS FINALES:

❌ **Informa a tu equipo** antes de hacer push  
❌ **Otros desarrolladores** deberán sincronizar:

```bash
# Para otros devs después de tu force push:
git fetch origin
git reset --hard origin/develop
```

❌ **Branches basados** en los commits viejos tendrán conflictos  
❌ **Pull requests abiertos** pueden romperse

---

¿Quieres hacer el force push ahora? (si/no/después)

````

⏸️ **ESPERAR** respuesta

**Si "si":**

```bash
git push --force-with-lease origin develop
````

```
✅ Force push completado

**Tu rama remota ahora tiene el historial reorganizado.**

⚠️ Notifica a tu equipo para que sincronicen.
```

**Si "no" o "después":**

````
⚠️ Recuerda hacer force push más tarde:

```bash
git push --force-with-lease origin develop
````

Tu rama local está reorganizada pero el remoto mantiene el historial antiguo.

````

---

**Si SOLO reorganizaste commits locales:**

```markdown
## 🎉 Push normal disponible

Como solo reorganizaste commits locales (no pusheados), puedes hacer push normal:

```bash
git push origin develop
````

✅ No requiere force push  
✅ Seguro para el equipo  
✅ Sin riesgos

```

---

## 🎨 Formato de Conversación

### Ejemplo de Sesión Completa

```

Usuario:
"Reorganiza mis commits"

Skill:

## 🎯 Commit Reorganizer

---

### 🔢 ¿Cuántos commits quieres ver?

1️⃣ Últimos 5 commits
2️⃣ Últimos 10 commits
3️⃣ Últimos 20 commits
4️⃣ Cantidad personalizada
5️⃣ Desde último push

¿Qué opción prefieres?

---

Usuario:
"3"

Skill:
✅ Mostrando últimos 20 commits...

```

git log --oneline --graph --decorate HEAD~20..HEAD

```

## 📊 Historial de Commits (Últimos 20)

```

- 9a8ca60 (HEAD -> develop) style: TECH-123 improve markdown formatting
- 72ecc83 docs: PROJ-456 add API documentation generation skills
- 005266b chore: PROJ-456 consolidate project structure
- f92d5a9 chore: PROJ-456 add agent stubs
- 8d65ef5 docs: PROJ-456 add interactive skills
- c9c605d chore: PROJ-456 reorganize agent structure
- 3e451e4 (origin/develop) Enhance Java Streams Documentation
- b043344 chore: remove obsolete v2 prompt files
  ... (más commits)

```

---

### 🎯 ¿Desde dónde reorganizar?

1️⃣ Desde commit específico (escribe hash)
2️⃣ Últimos N commits (escribe HEAD~N)
3️⃣ Solo commits NO pusheados ✅ Recomendado
4️⃣ Todos los mostrados

---

Usuario:
"3"

Skill:
✅ Analizando commits NO pusheados: `origin/develop..HEAD`

Encontrados: 6 commits

---

### 📊 Analizando cambios...

```

git log origin/develop..HEAD --reverse --stat

```

✅ Análisis completado:

**Commit 1:** `c9c605d` - chore: PROJ-456 (2 archivos, agent config)
**Commit 2:** `8d65ef5` - docs: PROJ-456 (2 skills, 2,006 líneas)
**Commit 3:** `f92d5a9` - chore: PROJ-456 (2 agent stubs)
**Commit 4:** `005266b` - chore: PROJ-456 (81 archivos, reorganización)
**Commit 5:** `72ecc83` - docs: PROJ-456 (3 skills, 2,996 líneas)
**Commit 6:** `9a8ca60` - style: TECH-123 (2 archivos, formato)

---

### 🎫 Configuración de Tickets Jira

Detecté: `PROJ-456` (5 commits), `TECH-123` (1 commit)

**¿Qué hacer con los tickets?**

1️⃣ Mantener tickets actuales ✅
2️⃣ Cambiar TODOS a un ticket nuevo
3️⃣ Cambiar por grupo
4️⃣ Custom

---

Usuario:
"1"

Skill:
✅ Manteniendo tickets originales: PROJ-456, TECH-123

---

### 🤔 ¿Reorganizar?

**Sugerencia: Opción 2 - Agrupar por tipo**

Grupo 1: chore + PROJ-456 (3 commits → 1)
Grupo 2: docs + PROJ-456 (2 commits → 1)
Grupo 3: style + TECH-123 (mantener)

**De 6 commits → 3 commits organizados**

¿Te parece bien la opción 2? (si/no/otra)

---

Usuario:
"si"

Skill:
✅ Perfecto, agrupando por tipo.

---

### 🛡️ Creando backup...

```

git tag -a backup-before-reorganize-20260207-103000

```

✅ Backup creado

---

### 🎯 Grupo 1: Reorganización de estructura

**Combinando:**

- c9c605d - chore: PROJ-456 reorganize agent structure
- f92d5a9 - chore: PROJ-456 add agent stubs
- 005266b - chore: PROJ-456 consolidate project structure

**Ticket Jira para este grupo:**

💡 Configuración: Mantener tickets originales
✅ Usando: `PROJ-456` (detectado en todos los commits del grupo)

**Mensaje propuesto:**

```

chore: PROJ-456 reorganize project structure and add agent stubs

- Consolidate configurations to root .github/
- Move 35+ instruction and prompt files
- Add agent stubs for future implementation
- Clean up old subdirectories

```

¿OK? (si/cambia)

---

Usuario:
"si"

Skill:
✅ Mensaje confirmado para Grupo 1

---

### 🎯 Grupo 2: Skills de documentación

**Combinando:**

- 8d65ef5 - docs: PROJ-456 add interactive skills
- 72ecc83 - docs: PROJ-456 add API documentation generation skills

**Ticket:** `PROJ-456` (mantenido)

**Mensaje propuesto:**

```

docs: PROJ-456 add complete interactive skills suite

- Add commit-generator and issue-generator skills
- Add documentation-api skill for REST controllers
- Add method-flow-diagram skill for call flows
- Add openapi-generator skill for API specs

```

¿OK? (si/cambia)

---

Usuario:
"si"

Skill:
✅ Mensaje confirmado para Grupo 2

Grupo 3: style + TECH-123 → mantener sin cambios

Skill:
✅ Ticket: PROJ-789

**Mensaje propuesto:**

```

docs: PROJ-789 add complete interactive skills suite

- Add commit-generator and issue-generator skills
- Add documentation-api skill for REST controllers
- Add method-flow-diagram skill for call flows
- Add openapi-generator skill for API specs

```

¿OK? (si/cambia)

---

Usuario:
"si"

Skill:
✅ Todos los mensajes confirmados

---

### 🚀 Ejecutando reorganización...

**Método:** Reset + Recomit (reorganización compleja)

```

git reset --soft HEAD~5

```

✅ Reset completado. Todos los cambios en staging.

---

**Creando Commit 1/3...**

```

git add .github/agents/ .github/instructions/ .github/prompts/ .vscode/
git commit -m "chore: PROJ-456 reorganize project structure and add agent stubs"

```

✅ Commit 1/3: `123abcd`

---

**Creando Commit 2/3...**

```

git add .github/skills/commit-generator/ .github/skills/issue-generator/ ...
git commit -m "docs: PROJ-789 add complete interactive skills suite"

```

✅ Commit 2/3: `456efgh`

---

**Creando Commit 3/3...**

```

git add .github/skills/method-flow-diagram/ .github/skills/openapi-generator/
git commit -m "style: TECH-123 improve markdown formatting in documentation skills"

```

✅ Commit 3/3: `789ijkl`

---

## ✅ Reorganización Completada!

### 🆕 Nuevo Historial:

```

\* 789ijkl (HEAD -> develop) style: TECH-123 improve markdown formatting

- 456efgh docs: PROJ-789 add complete interactive skills suite
- 123abcd chore: PROJ-456 reorganize project structure

```

---

### 📊 Comparación:

| Métrica      | Antes | Después |
| ------------ | ----- | ------- |
| Commits      | 5     | 3       |
| Con Jira     | 5/5   | 3/3 ✅  |
| Conventional | 5/5   | 3/3 ✅  |
| Agrupación   | ❌    | ✅      |

---

### 🗑️ ¿Eliminar backup?

Tag: `backup-before-reorganize-20260207-103000`

Responde: si/no

---

Usuario:
"no, dejalo por si acaso"

Skill:
✅ Backup conservado.

**Para eliminarlo más tarde:**

```

git tag -d backup-before-reorganize-20260207-103000

```

---

## 🎉 ¡Todo listo!

Tu historial ahora está limpio y bien organizado.

**Próximos pasos:**

```

git log --oneline -3 # Verificar
git push # Subir cambios (si todo está bien)

```

⚠️ **Recuerda:** Solo haz push si estás 100% seguro de los cambios.

````

---

## 🛠️ Tools a Usar

<table>
<tr>
<th width="30%">Tool</th>
<th width="70%">Uso</th>
</tr>
<tr>
<td><b>🔍 run_in_terminal</b></td>
<td>
Ejecutar git log<br/>
Ejecutar git show<br/>
Crear backup tag<br/>
Ejecutar git reset<br/>
Ejecutar git rebase<br/>
Crear nuevos commits
</td>
</tr>
<tr>
<td><b>📊 get_changed_files</b></td>
<td>
Ver cambios en cada commit<br/>
Analizar diffs<br/>
Identificar archivos por commit
</td>
</tr>
<tr>
<td><b>📋 manage_todo_list</b></td>
<td>
Trackear progreso<br/>
• Historial consultado<br/>
• Análisis completado<br/>
• Backup creado<br/>
• Grupos confirmados<br/>
• Commits recreados
</td>
</tr>
<tr>
<td><b>❓ ask_questions</b></td>
<td>
Preguntar commit inicial<br/>
Opción de reorganización<br/>
Tickets Jira por grupo<br/>
Confirmación de mensajes<br/>
Eliminar backup
</td>
</tr>
</table>

---

## 🔒 Constraints Finales

<table>
<tr>
<td width="50%" bgcolor="#ffebee">

### ❌ NUNCA

- ❌ Reorganizar sin backup
- ❌ Modificar commits pusheados
- ❌ Perder cambios del usuario
- ❌ Asumir agrupación sin preguntar
- ❌ Continuar si hay conflictos
- ❌ Omitir validación final

</td>
<td width="50%" bgcolor="#e8f5e9">

### ✅ SIEMPRE

- ✅ Crear backup antes de cambios
- ✅ Verificar estado del repo
- ✅ Pedir confirmación explícita
- ✅ Mostrar antes/después
- ✅ Validar conventional commits
- ✅ Ofrecer rollback fácil

</td>
</tr>
</table>

### 🛡️ Principios de Operación

```diff
+ SEGURIDAD sobre VELOCIDAD
+ CONFIRMACIÓN sobre AUTOMATIZACIÓN
+ DETECTAR PUSHEADOS sobre ASUMIR LOCALES
+ RAMA BACKUP sobre REORGANIZAR DIRECTO
+ BACKUP sobre CONFIANZA
+ CLARIDAD sobre BREVEDAD
+ ROLLBACK FÁCIL sobre COMMITS PERFECTOS
+ FORCE PUSH GUIADO sobre FORCE PUSH AUTOMÁTICO
````

---

## ⚠️ Casos de Uso

<details>
<summary><b>📚 Cuándo usar este skill</b></summary>

### ✅ Casos ideales:

1. **Limpieza pre-PR**
   - "Tengo 10 commits desordenados"
   - "Necesito agrupar antes de PR"

2. **Commits sin Jira**
   - "Olvidé poner tickets"
   - "Necesito agregar PROJ-XXX a todo"

3. **Mensajes mal escritos**
   - "fix stuff" → "fix: PROJ-123..."
   - Mejorar descripción

4. **Agrupación lógica**
   - "2 commits de docs + 3 de tests"
   - Mejor en 2 commits separados

5. **Trabajo en progreso**
   - "WIP: feature X" × 5
   - Consolidar en 1-2 commits finales

### ❌ NO usar si:

- Los commits ya fueron pusheados
- Trabajas en un branch compartido
- No entiendes qué hace cada commit
- Hay merges en el historial

</details>

---

<div align="center">

### 💚 Listo para Usar

**Palabras clave de activación:**

_"Reorganiza mis commits"_

---

![Ready](https://img.shields.io/badge/status-ready-success?style=for-the-badge&logo=git)
![Safety](https://img.shields.io/badge/safety-backup%20included-green?style=for-the-badge&logo=git)
![Interactive](https://img.shields.io/badge/flow-interactive-blue?style=for-the-badge&logo=github)

</div>
