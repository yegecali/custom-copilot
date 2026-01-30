# Skill: Quarkus Project Setup

## Propósito

Crear una estructura base de proyecto Quarkus lista para migración.

## Entradas

- `projectName`: Nombre del proyecto (ej: "petstore-api")
- `packageName`: Nombre del paquete base (ej: "com.example.petstore")
- `baseDir`: Directorio donde crear el proyecto

## Proceso

### Paso 1: Crear estructura básica

```bash
cd spring-quarkus-migration/

# Opción A: Usar Quarkus Maven plugin
mvn io.quarkus.platform:quarkus-maven-plugin:2.16.0.Final:create \
  -DprojectGroupId=com.example \
  -DprojectArtifactId=petstore-quarkus \
  -Dextensions="rest-client-reactive,mutiny,smallrye-openapi,jdbc-mysql,hibernate-orm-panache"

# Opción B: Usar archetype
mvn archetype:generate \
  -DarchetypeGroupId=io.quarkus \
  -DarchetypeArtifactId=quarkus-maven-archetype \
  -DarchetypeVersion=2.16.0.Final \
  -DgroupId=com.example \
  -DartifactId=petstore-quarkus
```

### Paso 2: Estructura esperada

```
quarkus-project/
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/example/
│   │   │       ├── client/          # REST Clients
│   │   │       ├── resource/        # REST Endpoints
│   │   │       ├── service/         # Business logic
│   │   │       ├── config/          # Configuration
│   │   │       ├── model/           # POJOs/DTOs
│   │   │       └── GreetingResource.java
│   │   └── resources/
│   │       ├── application.properties
│   │       ├── application-dev.properties
│   │       ├── application-prod.properties
│   │       └── openapi.yaml
│   └── test/
│       ├── java/
│       │   └── com/example/
│       │       └── *Test.java
│       └── resources/
│           └── application-test.properties
├── pom.xml
├── README.md
└── .gitignore
```

### Paso 3: pom.xml Base

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.example</groupId>
    <artifactId>petstore-quarkus</artifactId>
    <version>1.0.0-SNAPSHOT</version>

    <name>PetStore Quarkus API</name>
    <description>Pet Store API migrated from Spring Boot to Quarkus</description>

    <properties>
        <maven.compiler.source>17</maven.compiler.source>
        <maven.compiler.target>17</maven.compiler.target>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>

        <quarkus.platform.group-id>io.quarkus.platform</quarkus.platform.group-id>
        <quarkus.platform.artifact-id>quarkus-bom</quarkus.platform.artifact-id>
        <quarkus.platform.version>2.16.0.Final</quarkus.platform.version>
    </properties>

    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>${quarkus.platform.group-id}</groupId>
                <artifactId>${quarkus.platform.artifact-id}</artifactId>
                <version>${quarkus.platform.version}</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>

    <dependencies>
        <!-- REST Reactive -->
        <dependency>
            <groupId>io.quarkus</groupId>
            <artifactId>quarkus-resteasy-reactive</artifactId>
        </dependency>

        <!-- REST Client Reactive -->
        <dependency>
            <groupId>io.quarkus</groupId>
            <artifactId>quarkus-rest-client-reactive</artifactId>
        </dependency>

        <!-- Mutiny -->
        <dependency>
            <groupId>io.quarkus</groupId>
            <artifactId>quarkus-mutiny</artifactId>
        </dependency>

        <!-- JSON -->
        <dependency>
            <groupId>io.quarkus</groupId>
            <artifactId>quarkus-resteasy-reactive-jackson</artifactId>
        </dependency>

        <!-- OpenAPI -->
        <dependency>
            <groupId>io.quarkus</groupId>
            <artifactId>quarkus-smallrye-openapi</artifactId>
        </dependency>

        <!-- Database -->
        <dependency>
            <groupId>io.quarkus</groupId>
            <artifactId>quarkus-jdbc-mysql</artifactId>
        </dependency>
        <dependency>
            <groupId>io.quarkus</groupId>
            <artifactId>quarkus-hibernate-orm-panache</artifactId>
        </dependency>

        <!-- Health & Metrics -->
        <dependency>
            <groupId>io.quarkus</groupId>
            <artifactId>quarkus-smallrye-health</artifactId>
        </dependency>
        <dependency>
            <groupId>io.quarkus</groupId>
            <artifactId>quarkus-micrometer</artifactId>
        </dependency>

        <!-- Testing -->
        <dependency>
            <groupId>io.quarkus</groupId>
            <artifactId>quarkus-junit5</artifactId>
            <scope>test</scope>
        </dependency>
        <dependency>
            <groupId>io.rest-assured</groupId>
            <artifactId>rest-assured</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>io.quarkus.platform</groupId>
                <artifactId>quarkus-maven-plugin</artifactId>
                <version>${quarkus.platform.version}</version>
                <extensions>true</extensions>
                <executions>
                    <execution>
                        <goals>
                            <goal>build</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
            <plugin>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.10.1</version>
            </plugin>
            <plugin>
                <artifactId>maven-surefire-plugin</artifactId>
                <version>2.22.2</version>
            </plugin>
        </plugins>
    </build>
</project>
```

### Paso 4: application.properties inicial

```properties
# Application
quarkus.application.name=petstore-api
quarkus.application.version=1.0.0

# HTTP
quarkus.http.port=8080
quarkus.http.root-path=/api
quarkus.http.cors=true

# Logging
quarkus.log.level=INFO
quarkus.log.console.enable=true

# Database (opcional)
quarkus.datasource.db-kind=mysql
quarkus.datasource.jdbc.url=jdbc:mysql://localhost:3306/petstore
quarkus.datasource.username=root
quarkus.datasource.password=password

# OpenAPI
quarkus.smallrye-openapi.info.title=PetStore API
quarkus.smallrye-openapi.info.version=1.0.0
quarkus.swagger-ui.always-include=true
```

## Salidas

✅ **Estructura creada:**

- Directorio `quarkus-project/` con estructura Maven estándar
- `pom.xml` con todas las dependencias necesarias
- `application.properties` configurado
- Directorios de paquetes creados
- Tests básicos listos

✅ **Próximos pasos:**

1. Verificar compilación: `mvn clean compile`
2. Ejecutar tests: `mvn test`
3. Iniciar dev mode: `mvn quarkus:dev`
4. Proceder a migración de dependencias

## Checklist

- [ ] Proyecto creado sin errores
- [ ] `mvn clean compile` sin warnings
- [ ] `mvn test` pasa con tests de ejemplo
- [ ] `mvn quarkus:dev` inicia correctamente
- [ ] Swagger UI accesible en http://localhost:8080/q/swagger-ui
- [ ] Health check en http://localhost:8080/q/health
