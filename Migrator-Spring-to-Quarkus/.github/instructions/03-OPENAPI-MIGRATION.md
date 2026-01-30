# Migración: OpenAPI API-First a Quarkus

## 🎯 Objetivo

Mantener contrato OpenAPI y generar DTOs/Modelos compatible con Quarkus.

## 📋 Prerequisitos

- [ ] Contrato OpenAPI disponible (openapi.yaml o openapi.json)
- [ ] OpenAPI Generator instalado
- [ ] Quarkus base creado
- [ ] Maven configurado

## 🔄 Estrategia

1. **Mantener** contrato OpenAPI original
2. **Generar** DTOs con OpenAPI Generator
3. **Usar** DTOs generados en REST Client y Resources
4. **Validar** que la API sigue el contrato

## 📝 Paso 1: Verificar Contrato OpenAPI

### Ubicación esperada

```
original-spring/
├── src/main/resources/
│   ├── openapi.yaml          ← AQUÍ
│   └── openapi/
│       └── schemas/
└── docs/
    └── api.yaml              ← O AQUÍ
```

### Validar formato

```bash
# Validar con swagger-ui (opcional)
# La mayoría de IDEs valida automáticamente

# Copiar a quarkus-project
cp original-spring/src/main/resources/openapi.yaml \
   quarkus-project/src/main/resources/
```

## 📝 Paso 2: Configurar OpenAPI Generator en Maven

### pom.xml - Agregar plugin

```xml
<build>
    <plugins>
        <plugin>
            <groupId>org.openapitools</groupId>
            <artifactId>openapi-generator-maven-plugin</artifactId>
            <version>6.2.1</version>
            <executions>
                <execution>
                    <goals>
                        <goal>generate</goal>
                    </goals>
                    <configuration>
                        <!-- Ubicación del contrato -->
                        <inputSpec>${project.basedir}/src/main/resources/openapi.yaml</inputSpec>

                        <!-- Lenguaje/Framework generador -->
                        <generatorName>java</generatorName>

                        <!-- Dónde generar -->
                        <output>${project.build.directory}/generated-sources</output>

                        <!-- Configuración específica -->
                        <configOptions>
                            <packageName>com.example.api.generated</packageName>
                            <modelPackage>com.example.api.generated.model</modelPackage>
                            <apiPackage>com.example.api.generated.api</apiPackage>
                            <library>microprofile</library>  <!-- ← IMPORTANTE para Quarkus -->
                            <sourceFolder>java</sourceFolder>
                            <generateApiTests>false</generateApiTests>
                            <generateModelTests>false</generateModelTests>
                            <importMappings>
                                <mapping>Date=java.time.LocalDate</mapping>
                                <mapping>DateTime=java.time.OffsetDateTime</mapping>
                            </importMappings>
                        </configOptions>
                    </configuration>
                </execution>
            </executions>
        </plugin>
    </plugins>
</build>
```

### Alternativa: Con generador específico Quarkus

```xml
<plugin>
    <groupId>org.openapitools</groupId>
    <artifactId>openapi-generator-maven-plugin</artifactId>
    <version>6.2.1</version>
    <executions>
        <execution>
            <goals>
                <goal>generate</goal>
            </goals>
            <configuration>
                <inputSpec>${project.basedir}/src/main/resources/openapi.yaml</inputSpec>

                <!-- Usar generador jaxrs-cdi que es compatible -->
                <generatorName>jaxrs-cdi</generatorName>

                <output>${project.build.directory}/generated-sources</output>

                <configOptions>
                    <packageName>com.example.api</packageName>
                    <modelPackage>com.example.api.model</modelPackage>
                    <apiPackage>com.example.api</apiPackage>
                    <useJakartaEe>true</useJakartaEe>
                    <generateApis>true</generateApis>
                    <generateModels>true</generateModels>
                    <generateSupportingFiles>true</generateSupportingFiles>
                    <generateApiDocumentation>false</generateApiDocumentation>
                </configOptions>
            </configuration>
        </execution>
    </executions>
</plugin>
```

## 📝 Paso 3: Generar Modelos

```bash
cd quarkus-project/

# Generar desde OpenAPI
mvn clean compile openapi-generator:generate

# Verificar generación
tree target/generated-sources/openapi/
# Debe mostrar:
# target/generated-sources/openapi/
# └── java/
#     └── com/example/api/generated/
#         ├── model/
#         │   ├── Pet.java
#         │   ├── Error.java
#         │   └── ...
#         └── api/
#             └── DefaultApi.java  (opcional)
```

## 📝 Paso 4: Usar DTOs Generados en REST Client

### Rest Client (original)

```java
// quarkus-project/src/main/java/com/example/client/PetStoreApi.java
package com.example.client;

import org.eclipse.microprofile.rest.client.inject.RegisterRestClient;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import io.smallrye.mutiny.Uni;
import java.util.List;

// IMPORTANTE: Usar clases generadas
import com.example.api.generated.model.Pet;
import com.example.api.generated.model.Error;

@RegisterRestClient(configKey = "petstore-api")
@Path("/api")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public interface PetStoreApi {

    @GET
    @Path("/pets")
    Uni<List<Pet>> listPets(@QueryParam("limit") int limit);

    @GET
    @Path("/pets/{petId}")
    Uni<Pet> getPetById(@PathParam("petId") String petId);

    @POST
    @Path("/pets")
    Uni<Pet> createPet(Pet pet);
}
```

## 📝 Paso 5: Usar DTOs en REST Resources

### Resource que sirve la API

```java
// quarkus-project/src/main/java/com/example/resource/PetResource.java
package com.example.resource;

import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import jakarta.inject.Inject;
import io.smallrye.mutiny.Uni;
import com.example.service.PetService;

// Usar clases generadas
import com.example.api.generated.model.Pet;
import com.example.api.generated.model.Error;

@Path("/api/pets")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class PetResource {

    @Inject
    PetService petService;

    @GET
    public Uni<List<Pet>> listPets(
        @QueryParam("limit") @DefaultValue("10") int limit
    ) {
        return petService.getAllPets(limit);
    }

    @GET
    @Path("/{id}")
    public Uni<Pet> getPet(@PathParam("id") String id) {
        return petService.getPet(id)
            .onFailure()
            .recoverWithItem(() -> {
                Error error = new Error();
                error.setCode(404);
                error.setMessage("Pet not found");
                return null;
            });
    }

    @POST
    public Uni<Pet> createPet(Pet pet) {
        return petService.createPet(pet);
    }
}
```

## 📝 Paso 6: Documentación OpenAPI Automática

### Agregar dependencia para documentación

```xml
<dependency>
    <groupId>io.quarkus</groupId>
    <artifactId>quarkus-smallrye-openapi</artifactId>
</dependency>
```

### Anotar Resources

```java
import org.eclipse.microprofile.openapi.annotations.Operation;
import org.eclipse.microprofile.openapi.annotations.media.Content;
import org.eclipse.microprofile.openapi.annotations.media.Schema;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponse;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponses;

@Path("/api/pets")
public class PetResource {

    @GET
    @Operation(summary = "List all pets", description = "Returns a list of pets")
    @APIResponses(
        value = {
            @APIResponse(
                responseCode = "200",
                description = "List of pets",
                content = @Content(
                    mediaType = MediaType.APPLICATION_JSON,
                    schema = @Schema(ref = "#/components/schemas/Pet")
                )
            ),
            @APIResponse(
                responseCode = "400",
                description = "Invalid parameters"
            )
        }
    )
    public Uni<List<Pet>> listPets(
        @QueryParam("limit") @DefaultValue("10") int limit
    ) {
        // ...
    }
}
```

### Acceder a la documentación

```bash
# Cuando está en dev
# http://localhost:8080/q/openapi
# http://localhost:8080/q/swagger-ui
```

### Configurar en application.properties

```properties
# OpenAPI
quarkus.smallrye-openapi.info.title=Pet Store API
quarkus.smallrye-openapi.info.version=1.0.0
quarkus.smallrye-openapi.info.description=API para gestión de mascotas
quarkus.smallrye-openapi.servers=https://api.example.com

# Mostrar en desarrollo
quarkus.swagger-ui.always-include=true
quarkus.smallrye-openapi.auto-add-server=false
```

## 📝 Paso 7: Validación de Contrato

### Crear test para verificar conformidad

```java
// quarkus-project/src/test/java/com/example/OpenAPIValidationTest.java
package com.example;

import io.restassured.RestAssured;
import io.quarkus.test.junit.QuarkusTest;
import org.junit.jupiter.api.Test;

import static io.restassured.RestAssured.*;
import static org.hamcrest.Matchers.*;

@QuarkusTest
public class OpenAPIValidationTest {

    @Test
    void testOpenAPISchemaIsValid() {
        get("/q/openapi.yaml")
            .then()
            .statusCode(200)
            .body("openapi", notNullValue());
    }

    @Test
    void testPetEndpointConformsToOpenAPI() {
        get("/api/pets")
            .then()
            .statusCode(200)
            .body("$", instanceOf(List.class));
    }
}
```

## 🔄 Flujo Recomendado

```
1. Copiar openapi.yaml a recursos
   ↓
2. Configurar openapi-generator-maven-plugin
   ↓
3. Ejecutar: mvn openapi-generator:generate
   ↓
4. Usar clases generadas en REST Client
   ↓
5. Usar clases generadas en REST Resources
   ↓
6. Agregar anotaciones de documentación
   ↓
7. Validar: mvn compile
   ↓
8. Ejecutar: mvn test
   ↓
9. Verificar: http://localhost:8080/q/swagger-ui
```

## ✅ Checklist

- [ ] Contrato OpenAPI identificado
- [ ] openapi.yaml copiado a recursos
- [ ] openapi-generator-maven-plugin configurado
- [ ] Modelos generados correctamente
- [ ] REST Client usa DTOs generados
- [ ] REST Resources usan DTOs generados
- [ ] Documentación OpenAPI configurada
- [ ] Tests de contrato creados
- [ ] Compilación sin errores
- [ ] Swagger UI accesible

## 🔗 Siguiente Paso

→ Ir a `04-REACTIVE-STACK.md`
