# Guía General de Migración Spring → Quarkus

## 📋 Visión General

Migración de un proyecto Spring Boot con Retrofit a Quarkus manteniendo arquitectura reactiva.

### Estructura de Directorios Creada

```
Migrator-Spring-to-Quarkus/
├── .github/
│   ├── agents/                    # Definiciones de agentes
│   ├── instructions/              # Guías paso a paso
│   ├── prompts/                   # Prompts del sistema
│   └── skills/                    # Skills específicas
├── spring-quarkus-migration/
│   ├── original-spring/           # ⚠️ ORIGINAL - NO MODIFICAR
│   │   └── (copiar proyecto aquí)
│   ├── quarkus-project/           # 📁 NUEVO PROYECTO - MIGRACIÓN AQUÍ
│   │   ├── src/
│   │   ├── pom.xml
│   │   └── README.md
│   ├── MIGRATION_CHECKLIST.md     # Checklist de progreso
│   └── MIGRATION_REPORT.md        # Reporte final
└── README.md                      # Este archivo
```

## 🚀 Inicio Rápido

### Paso 1: Preparación

```bash
# 1.1 Copia el proyecto original
cp -r /ruta/tu/proyecto-spring original-spring/

# 1.2 Verifica estructura
tree original-spring/ -L 2
```

### Paso 2: Generar Base Quarkus

```bash
# 2.1 Crear proyecto base Quarkus
cd quarkus-project/
mvn io.quarkus.platform:quarkus-maven-plugin:2.16.0.Final:create \
  -DprojectGroupId=com.example \
  -DprojectArtifactId=my-quarkus-app \
  -DclassName=com.example.GreetingResource \
  -Dextensions="rest-client-reactive,mutiny,smallrye-openapi"

# 2.2 O usar maven directamente
mvn archetype:generate \
  -DarchetypeGroupId=io.quarkus \
  -DarchetypeArtifactId=quarkus-maven-archetype \
  -DarchetypeVersion=2.16.0.Final \
  -DgroupId=com.example \
  -DartifactId=my-quarkus-app
```

## 📊 Fases de Migración

### Fase 1: Estructura Base ✓

- [ ] Copiar proyecto original
- [ ] Crear estructura Quarkus
- [ ] Configurar pom.xml
- [ ] Validar compilación

### Fase 2: Dependencias

- [ ] Mapear todas las dependencias Spring
- [ ] Agregar dependencias Quarkus
- [ ] Eliminar dependencias conflictivas
- [ ] Validar transitividad

### Fase 3: OpenAPI

- [ ] Mantener contrato OpenAPI
- [ ] Generar modelos/DTOs con openapi-generator
- [ ] Configurar rutas de generación
- [ ] Validar generación

### Fase 4: Cliente HTTP (Retrofit → REST Client)

- [ ] Analizar interfaces Retrofit actuales
- [ ] Crear interfaces REST Client Reactive
- [ ] Migrar interceptores
- [ ] Implementar error handling reactivo

### Fase 5: Stack Reactivo (RxJava → Mutiny)

- [ ] Reemplazar Observable → Uni/Multi
- [ ] Actualizar operadores reactivos
- [ ] Implementar subscripciones
- [ ] Validar flujos async

### Fase 6: Servicios y Lógica

- [ ] Convertir @Service a @ApplicationScoped
- [ ] Actualizar @Autowired a @Inject
- [ ] Migrar configuración
- [ ] Actualizar properties

### Fase 7: Endpoints REST

- [ ] Actualizar @RestController a @Path/@ApplicationPath
- [ ] Convertir a Resteasy Reactive
- [ ] Implementar manejo de errores
- [ ] Agregar validación

### Fase 8: Testing

- [ ] Crear tests para REST client
- [ ] Tests de endpoints
- [ ] Tests de integración
- [ ] Validar cobertura

## 📚 Archivos de Referencia

| Archivo                         | Descripción                   |
| ------------------------------- | ----------------------------- |
| `spring-to-quarkus-migrator.md` | Definición del agente         |
| `01-MIGRATION-OVERVIEW.md`      | Este archivo                  |
| `02-RETROFIT-MIGRATION.md`      | Migrar Retrofit → REST Client |
| `03-OPENAPI-MIGRATION.md`       | Mantener/generar OpenAPI      |
| `04-REACTIVE-STACK.md`          | Migrar a Mutiny               |
| `05-CONFIGURATION.md`           | Configuración Quarkus         |
| `06-TESTING.md`                 | Testing en Quarkus            |

## 🛠️ Herramientas Recomendadas

- **Maven 3.8.1+** - Build tool
- **Java 17+** - Runtime
- **OpenAPI Generator 6.0+** - Generación de código
- **Quarkus CLI 2.16+** - Herramientas Quarkus
- **IntelliJ IDEA 2022.3+** o **VS Code** - IDE

## ⚠️ Puntos de Atención

1. **Retrofit es un cliente HTTP synchrono** → REST Client Reactive es async
   - Requiere cambio en cómo se usan los métodos
   - Retornan `Uni<T>` en lugar de `T`

2. **RxJava/Reactor → Mutiny**
   - No es simple mapeo 1:1
   - Mutiny tiene API más limpia

3. **Spring beans → CDI beans**
   - @Configuration se convierte en @ApplicationScoped
   - @Autowired se convierte en @Inject

4. **application.properties**
   - Cambio en prefijo de propiedades
   - `quarkus.` es el nuevo prefijo

5. **Testing**
   - Usa @QuarkusTest en lugar de @SpringBootTest
   - Rest Assured para testing de endpoints

## 📝 Ejemplo Rápido: Retrofit → REST Client

### Antes (Spring + Retrofit)

```java
public interface ApiService {
    @GET("/users/{id}")
    Observable<User> getUser(@Path("id") String id);
}

Observable<User> user = apiService.getUser("123")
    .subscribeOn(Schedulers.io())
    .observeOn(Schedulers.mainThread());
```

### Después (Quarkus + REST Client)

```java
@RegisterRestClient
public interface ApiService {
    @GET
    @Path("/users/{id}")
    Uni<User> getUser(@PathParam("id") String id);
}

// En servicio
Uni<User> user = apiService.getUser("123");
user.subscribe().with(
    user -> System.out.println(user),
    error -> error.printStackTrace()
);
```

## 🎯 Objetivos

- ✅ Proyecto 100% funcional en Quarkus
- ✅ Mantener comportamiento original
- ✅ Mejorar performance con stack reactivo nativo
- ✅ Reducir consumo de memoria
- ✅ Mantener tiempo de startup < 5 segundos

## 📞 Soporte

Para dudas específicas:

- Consultar archivo de instrucción correspondiente
- Revisar ejemplos en `skills/`
- Validar con `prompts/system-prompt.md`

---

**Inicio recomendado:** Ejecutar `02-RETROFIT-MIGRATION.md` primero
