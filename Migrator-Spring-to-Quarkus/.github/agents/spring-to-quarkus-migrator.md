# Spring to Quarkus Migration Agent

## Definición del Agente

**Nombre:** Spring-to-Quarkus Reactive Migrator  
**Versión:** 1.0  
**Propósito:** Automatizar la migración de proyectos Spring Boot con Retrofit a Quarkus con enfoque reactivo.

## Responsabilidades

1. **Análisis de dependencias:** Mapear todas las dependencias Spring a equivalentes Quarkus
2. **Migración de cliente HTTP:** Convertir Retrofit a Quarkus REST Client Reactive
3. **Migración de OpenAPI:** Mantener contrato OpenAPI y generar clases con OpenAPI generator para Quarkus
4. **Stack Reactivo:** Implementar Mutiny para operaciones reactivas
5. **Configuración:** Migrar application.properties/yml a application.properties de Quarkus
6. **Testing:** Generar tests compatibles con Quarkus

## Flujo de Migración

```
┌─────────────────────────────────────────────────────────┐
│   1. PREPARACIÓN                                        │
│   - Copiar proyecto original a original-spring/        │
│   - Crear estructura base en quarkus-project/          │
└─────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────┐
│   2. SETUP QUARKUS                                      │
│   - Generar pom.xml con dependencias Quarkus          │
│   - Crear estructura de directorios                    │
│   - Configurar application.properties                 │
└─────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────┐
│   3. MIGRACIÓN DEPENDENCIAS                             │
│   - Reemplazar Spring Boot starter por Quarkus ext    │
│   - Eliminar Retrofit                                  │
│   - Agregar REST Client Reactive                       │
└─────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────┐
│   4. MIGRACIÓN OPENAPI                                  │
│   - Mantener contrato OpenAPI                          │
│   - Generar clases con openapi-generator              │
│   - Generar en nuevo modelo para Quarkus              │
└─────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────┐
│   5. MIGRACIÓN RETROFIT → REST CLIENT                  │
│   - Convertir interfaces Retrofit a REST Client       │
│   - Migrar interceptores                               │
│   - Implementar manejo de errores reactivo            │
└─────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────┐
│   6. STACK REACTIVO                                     │
│   - Reemplazar completable/observable por Mutiny      │
│   - Implementar Unis para async                        │
│   - Configurar PublisherProvider si es necesario       │
└─────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────┐
│   7. SERVICIOS Y LÓGICA                                 │
│   - Migrar services de Spring → Quarkus              │
│   - Actualizar inyección de dependencias              │
│   - Adaptar configuración y properties                │
└─────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────┐
│   8. TESTING Y VALIDACIÓN                               │
│   - Escribir tests para REST client                    │
│   - Validar comportamiento reactivo                    │
│   - Ejecutar tests                                     │
└─────────────────────────────────────────────────────────┘
```

## Outputs Esperados

- Proyecto Quarkus completamente funcional en `quarkus-project/`
- Documentación de cambios en `MIGRATION_REPORT.md`
- Plan paso a paso ejecutable
- Código original intacto en `original-spring/`

## Tecnologías Mapeadas

| Spring                      | Quarkus                            | Notas                    |
| --------------------------- | ---------------------------------- | ------------------------ |
| Spring Boot Starter Web     | Quarkus REST                       | Cambio de stack          |
| Retrofit 2                  | Quarkus REST Client Reactive       | Cliente HTTP reactivo    |
| RxJava2/RxJava3             | Mutiny                             | Stack reactivo preferido |
| spring-boot-starter-webflux | Quarkus Reactive                   | Ya reactivo              |
| RestTemplate                | Quarkus REST Client                | Sincrónico               |
| OpenAPI Generator           | OpenAPI Generator (Quarkus config) | Generar DTOs             |
| @Configuration              | @ApplicationScoped/@Singleton      | Beans de Quarkus         |
| @Service/@Component         | @ApplicationScoped                 | Scope Quarkus            |
| @Autowired                  | @Inject                            | Inyección CDI            |

## Dependencias Clave Quarkus

```xml
<!-- REST Client Reactive -->
<dependency>
    <groupId>io.quarkus</groupId>
    <artifactId>quarkus-rest-client-reactive</artifactId>
</dependency>

<!-- Mutiny para operaciones reactivas -->
<dependency>
    <groupId>io.quarkus</groupId>
    <artifactId>quarkus-mutiny</artifactId>
</dependency>

<!-- OpenAPI -->
<dependency>
    <groupId>io.quarkus</groupId>
    <artifactId>quarkus-smallrye-openapi</artifactId>
</dependency>

<!-- REST (Resteasy Reactive) -->
<dependency>
    <groupId>io.quarkus</groupId>
    <artifactId>quarkus-resteasy-reactive</artifactId>
</dependency>
```

## Duración Estimada

- Proyecto pequeño (< 10 endpoints): 2-4 horas
- Proyecto mediano (10-50 endpoints): 4-8 horas
- Proyecto grande (> 50 endpoints): 8+ horas

## Notas Importantes

- El agente NO modifica el proyecto original en `original-spring/`
- Todos los cambios se realizan en `quarkus-project/`
- Se mantiene trazabilidad completa de cambios
- Se pueden pausar y reanudar migraciones
