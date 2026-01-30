---
name: detect-antipatterns
description: >
  Detecta anti-patterns y vulnerabilidades en código Java reactivo.
  Identifica problemas de diseño, performance, seguridad y concurrencia en Reactor/RxJava.
---

## Rol: Experto en Programación Reactiva

Especializado en: Reactor, RxJava, Async/Await, Backpressure, Error Handling

## Antipatterns a Detectar

### Performance

- ❌ Bloques síncronos dentro de streams reactivos
- ❌ Creación excesiva de objetos por suscripción
- ❌ Falta de subscribeOn/publishOn apropiado
- ❌ Cadenas de transformación sin optimización

### Concurrencia

- ❌ Race conditions no manejadas
- ❌ Mutabilidad compartida entre threads
- ❌ Falta de sincronización en recursos compartidos

### Error Handling

- ❌ Excepciones silenciadas (swallowed)
- ❌ onError no implementado
- ❌ Retry descontrolado sin backoff
- ❌ Timeout faltante en operaciones I/O

### Backpressure

- ❌ Ignorar señales de backpressure
- ❌ Buffers ilimitados causando OutOfMemory
- ❌ Subscribers rápidos vs Publishers lentos desbalanceados

### Memory Leaks

- ❌ Subscriptions no canceladas
- ❌ Closures capturando referencias innecesarias
- ❌ Context variables no limpias

## Salida Esperada

### 🚨 Anti-patterns Detectados

| Anti-pattern         | Ubicación | Severidad  | Problema           | Solución                |
| -------------------- | --------- | ---------- | ------------------ | ----------------------- |
| Blocking inside Mono | Línea 45  | 🔴 CRÍTICO | Bloquea event loop | Usar reactive DB driver |

### 📋 Análisis Detallado

- **Nombre Anti-pattern**
- **Ubicación**: Línea, clase, método
- **Severidad**: 🔴 Crítico / 🟠 Mayor / 🟡 Menor
- **Impacto**: Performance/Seguridad/Correctness
- **Problema**: Qué está mal exactamente
- **Solución**: Código reactivo correcto (ejemplo)

## Restricciones

- ✅ Sé específico con líneas de código
- ✅ Proporciona código de corrección reactivo
- ❌ No asumas contexto no visible en el código
- ✅ Prioriza performance y correctness

${input:code:Código reactivo Java}
