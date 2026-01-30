# Skill: OpenAPI Generation & Management

## Propósito

Mantener contrato OpenAPI y generar DTOs compatible con Quarkus.

## Prerequisitos

- Contrato OpenAPI (openapi.yaml o openapi.json) disponible
- OpenAPI Generator Maven plugin configurado
- Estructura Quarkus creada

## Proceso

### Paso 1: Localizar Contrato OpenAPI

**Buscar en proyecto original:**

```bash
cd original-spring/

# Búsquedas comunes
find . -name "openapi.*" -o -name "swagger.*" -o -name "*api*.yaml"

# Posibles ubicaciones:
# src/main/resources/openapi.yaml
# docs/openapi.yaml
# docs/api/swagger.json
# .github/openapi.yaml
```

**Copiar a proyecto Quarkus:**

```bash
cp original-spring/src/main/resources/openapi.yaml \
   quarkus-project/src/main/resources/
```

### Paso 2: Configurar Maven para Generación

**Agregar a pom.xml:**

```xml
<build>
    <plugins>
        <plugin>
            <groupId>org.openapitools</groupId>
            <artifactId>openapi-generator-maven-plugin</artifactId>
            <version>6.2.1</version>
            <executions>
                <execution>
                    <id>generate-java-models</id>
                    <phase>generate-sources</phase>
                    <goals>
                        <goal>generate</goal>
                    </goals>
                    <configuration>
                        <!-- Ubicación del contrato -->
                        <inputSpec>
                            ${project.basedir}/src/main/resources/openapi.yaml
                        </inputSpec>

                        <!-- Generador para Quarkus/JAX-RS -->
                        <generatorName>java</generatorName>

                        <!-- Dónde generar código -->
                        <output>
                            ${project.build.directory}/generated-sources
                        </output>

                        <!-- Configuración específica -->
                        <configOptions>
                            <!-- Paquete base -->
                            <packageName>com.example.api.generated</packageName>

                            <!-- Paquetes específicos -->
                            <modelPackage>com.example.api.generated.model</modelPackage>
                            <apiPackage>com.example.api.generated.api</apiPackage>

                            <!-- Configuración de generación -->
                            <library>microprofile</library>
                            <sourceFolder>java</sourceFolder>
                            <generateApiTests>false</generateApiTests>
                            <generateModelTests>false</generateModelTests>

                            <!-- Mapeo de tipos Java -->
                            <importMappings>
                                <mapping>Date=java.time.LocalDate</mapping>
                                <mapping>DateTime=java.time.OffsetDateTime</mapping>
                                <mapping>UUID=java.util.UUID</mapping>
                            </importMappings>

                            <!-- Usar Jakarta EE -->
                            <jakarta>true</jakarta>

                            <!-- Generar modelos y APIs -->
                            <generateApis>true</generateApis>
                            <generateModels>true</generateModels>
                        </configOptions>
                    </configuration>
                </execution>
            </executions>
        </plugin>
    </plugins>
</build>
```

### Paso 3: Ejecutar Generación

```bash
cd quarkus-project/

# Generar modelos
mvn clean compile openapi-generator:generate

# Verificar generación
tree target/generated-sources/openapi/
# Debe mostrar:
# target/generated-sources/openapi/
# └── java/
#     └── com/example/api/generated/
#         ├── model/
#         │   ├── Pet.java
#         │   ├── User.java
#         │   ├── Error.java
#         │   └── ...
#         └── api/
#             └── DefaultApi.java (opcional)
```

### Paso 4: Usar DTOs Generados

**En REST Client:**

```java
package com.example.client;

import org.eclipse.microprofile.rest.client.inject.RegisterRestClient;
import jakarta.ws.rs.*;
import io.smallrye.mutiny.Uni;

// ← USAR CLASES GENERADAS
import com.example.api.generated.model.Pet;
import com.example.api.generated.model.User;

@RegisterRestClient(configKey = "petstore-api")
@Path("/api")
public interface PetStoreApi {

    @GET
    @Path("/pets/{petId}")
    Uni<Pet> getPetById(@PathParam("petId") String petId);

    @POST
    @Path("/pets")
    Uni<Pet> createPet(Pet pet);
}
```

**En REST Resource:**

```java
package com.example.resource;

import jakarta.ws.rs.*;
import jakarta.inject.Inject;
import io.smallrye.mutiny.Uni;
import com.example.service.PetService;

// ← USAR CLASES GENERADAS
import com.example.api.generated.model.Pet;

@Path("/api/pets")
public class PetResource {

    @Inject
    PetService service;

    @GET
    @Path("/{id}")
    public Uni<Pet> getPet(@PathParam("id") String id) {
        return service.getPet(id);
    }

    @POST
    public Uni<Pet> createPet(Pet pet) {
        return service.createPet(pet);
    }
}
```

### Paso 5: Documentación OpenAPI Automática

**Agregar dependencia:**

```xml
<dependency>
    <groupId>io.quarkus</groupId>
    <artifactId>quarkus-smallrye-openapi</artifactId>
</dependency>
```

**Anotar Resources:**

```java
import org.eclipse.microprofile.openapi.annotations.Operation;
import org.eclipse.microprofile.openapi.annotations.media.Content;
import org.eclipse.microprofile.openapi.annotations.media.Schema;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponse;

@Path("/api/pets")
public class PetResource {

    @GET
    @Path("/{id}")
    @Operation(
        summary = "Get pet by ID",
        description = "Retrieve a specific pet by its ID"
    )
    @APIResponse(
        responseCode = "200",
        description = "Pet found",
        content = @Content(
            mediaType = "application/json",
            schema = @Schema(ref = "#/components/schemas/Pet")
        )
    )
    @APIResponse(
        responseCode = "404",
        description = "Pet not found"
    )
    public Uni<Pet> getPet(@PathParam("id") String id) {
        return service.getPet(id);
    }
}
```

**Configuración en application.properties:**

```properties
# OpenAPI Documentation
quarkus.smallrye-openapi.info.title=Pet Store API
quarkus.smallrye-openapi.info.version=1.0.0
quarkus.smallrye-openapi.info.description=API for managing pets
quarkus.smallrye-openapi.servers=https://api.example.com

# Mostrar en desarrollo
quarkus.swagger-ui.always-include=true
quarkus.swagger-ui.path=/swagger-ui
```

**Acceder:**

- OpenAPI JSON: http://localhost:8080/q/openapi
- Swagger UI: http://localhost:8080/q/swagger-ui
- ReDoc: http://localhost:8080/q/redoc

### Paso 6: Validación de Contrato

```java
@QuarkusTest
public class OpenAPIContractTest {

    @Test
    void testOpenAPIDocumentIsValid() {
        given()
        .when()
            .get("/q/openapi.yaml")
        .then()
            .statusCode(200)
            .body("openapi", notNullValue())
            .body("info.title", equalTo("Pet Store API"));
    }

    @Test
    void testPetSchemaExists() {
        given()
        .when()
            .get("/q/openapi.yaml")
        .then()
            .statusCode(200)
            .body(
                "components.schemas.Pet",
                notNullValue()
            );
    }

    @Test
    void testEndpointConformsToContract() {
        given()
        .when()
            .get("/api/pets/1")
        .then()
            .statusCode(200)
            .body("id", notNullValue())
            .body("name", notNullValue());
    }
}
```

### Paso 7: Mantener Sincronización

**Cuando cambies el contrato OpenAPI:**

```bash
# 1. Actualizar openapi.yaml
# 2. Regenerar modelos
mvn clean compile openapi-generator:generate

# 3. Recompilar
mvn clean compile

# 4. Actualizar código que usa modelos si estructura cambió
# 5. Ejecutar tests
mvn test
```

## Salidas

✅ **DTOs/Modelos generados:**

- Clases Java desde OpenAPI
- Anotaciones correctas de serialización
- Validaciones incorporadas

✅ **Documentación automática:**

- Swagger UI funcional
- OpenAPI JSON/YAML disponible
- Esquemas validados

✅ **Conformidad de contrato:**

- API sigue el contrato OpenAPI
- Tests validan conformidad
- Cambios en contrato fácil de reflejar

## Checklist

- [ ] Contrato OpenAPI localizado y copiado
- [ ] openapi-generator-maven-plugin configurado
- [ ] Generación ejecutada sin errores
- [ ] DTOs generados en target/
- [ ] REST Client usa clases generadas
- [ ] REST Resource usa clases generadas
- [ ] SmallRye OpenAPI configurado
- [ ] Swagger UI accesible
- [ ] Tests de conformidad pasan
- [ ] Documentación correcta en /q/swagger-ui
