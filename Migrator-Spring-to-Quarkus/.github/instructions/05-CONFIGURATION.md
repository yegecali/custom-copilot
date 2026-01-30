# Migración: Configuración Spring → Quarkus

## 🎯 Objetivo

Migrar propiedades de configuración y beans de Spring a Quarkus.

## 📋 Cambios Principales

| Spring                   | Quarkus                  | Notas                  |
| ------------------------ | ------------------------ | ---------------------- |
| `spring.*`               | `quarkus.*`              | Prefijo de propiedades |
| `application.properties` | `application.properties` | Igual nombre           |
| `@Configuration`         | `@ApplicationScoped`     | Beans singleton        |
| `@Service`               | `@ApplicationScoped`     | Servicios              |
| `@Component`             | `@ApplicationScoped`     | Componentes            |
| `@Autowired`             | `@Inject`                | Inyección CDI          |
| `@Value`                 | `@ConfigProperty`        | Propiedades inyectadas |
| `@Bean`                  | `@Produces`              | Producción de beans    |
| `@Profile`               | `%profile.property`      | Perfiles               |

## 📝 Paso 1: Convertir application.properties

### Antes (Spring)

```properties
# Server
server.port=8080
server.servlet.context-path=/api

# Logging
logging.level.root=INFO
logging.level.com.example=DEBUG
logging.file.name=logs/application.log

# Datasource
spring.datasource.url=jdbc:mysql://localhost:3306/petstore
spring.datasource.username=root
spring.datasource.password=password
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver

# JPA
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.MySQL8Dialect

# Actuator
management.endpoints.web.exposure.include=health,metrics
```

### Después (Quarkus)

```properties
# Server
quarkus.http.port=8080
quarkus.http.root-path=/api

# Logging
quarkus.log.level=INFO
quarkus.log.category."com.example".level=DEBUG
quarkus.log.file.path=logs/application.log

# Datasource
quarkus.datasource.db-kind=mysql
quarkus.datasource.jdbc.url=jdbc:mysql://localhost:3306/petstore
quarkus.datasource.username=root
quarkus.datasource.password=password

# JPA/Hibernate
quarkus.jpa.show-sql=true
quarkus.hibernate-orm.database.generation=update
quarkus.hibernate-orm.dialect=org.hibernate.dialect.MySQL8Dialect

# Health
quarkus.health.enabled=true
```

### application.properties completo para Quarkus

```properties
# ==========================================
# SERVIDOR
# ==========================================
quarkus.application.name=petstore-api
quarkus.application.version=1.0.0
quarkus.http.port=8080
quarkus.http.root-path=/api
quarkus.http.cors=true
quarkus.http.cors.origins=*
quarkus.http.cors.methods=GET,POST,PUT,DELETE

# ==========================================
# LOGGING
# ==========================================
quarkus.log.level=INFO
quarkus.log.category."com.example".level=DEBUG
quarkus.log.file.enable=false
# quarkus.log.file.path=logs/app.log

# ==========================================
# DATASOURCE
# ==========================================
quarkus.datasource.db-kind=mysql
quarkus.datasource.jdbc.url=jdbc:mysql://localhost:3306/petstore
quarkus.datasource.username=root
quarkus.datasource.password=password

# Connection Pool
quarkus.datasource.jdbc.initial-size=5
quarkus.datasource.jdbc.max-size=20
quarkus.datasource.jdbc.min-idle=2

# ==========================================
# JPA/HIBERNATE
# ==========================================
quarkus.jpa.show-sql=false
quarkus.jpa.sql-load-script=import.sql
quarkus.hibernate-orm.database.generation=update
quarkus.hibernate-orm.dialect=org.hibernate.dialect.MySQL8Dialect

# ==========================================
# REST CLIENT
# ==========================================
quarkus.rest-client.petstore-api.url=https://petstore.api.example.com
quarkus.rest-client.petstore-api.connect-timeout=5000
quarkus.rest-client.petstore-api.read-timeout=10000

# ==========================================
# HEALTH & METRICS
# ==========================================
quarkus.health.enabled=true
quarkus.smallrye-health.root-path=/health
quarkus.micrometer.enabled=true

# ==========================================
# SWAGGER/OPENAPI
# ==========================================
quarkus.smallrye-openapi.info.title=Pet Store API
quarkus.smallrye-openapi.info.version=1.0.0
quarkus.swagger-ui.always-include=true
```

## 📝 Paso 2: Configuración con Perfiles

### Antes (Spring)

```properties
# application.properties
spring.profiles.active=dev

# application-dev.properties
logging.level.root=DEBUG
spring.datasource.url=jdbc:mysql://localhost:3306/petstore_dev

# application-prod.properties
logging.level.root=WARN
spring.datasource.url=jdbc:mysql://prod-db:3306/petstore
```

### Después (Quarkus)

**application.properties**

```properties
quarkus.log.level=INFO
quarkus.datasource.jdbc.url=jdbc:mysql://localhost:3306/petstore
```

**application-dev.properties**

```properties
%dev.quarkus.log.level=DEBUG
%dev.quarkus.datasource.jdbc.url=jdbc:mysql://localhost:3306/petstore_dev
```

**application-prod.properties**

```properties
%prod.quarkus.log.level=WARN
%prod.quarkus.datasource.jdbc.url=jdbc:mysql://prod-db:3306/petstore
%prod.quarkus.http.cors.origins=https://example.com
```

**Ejecutar con perfil**

```bash
mvn quarkus:dev -Dquarkus.profile=dev
# O en JAR
java -Dquarkus.profile=prod -jar target/app-runner.jar
```

## 📝 Paso 3: Convertir Beans de Configuración

### Configuración Bean (Spring)

```java
// original-spring/src/main/java/com/example/config/RestClientConfig.java
package com.example.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import retrofit2.Retrofit;
import retrofit2.converter.jackson.JacksonConverterFactory;
import retrofit2.adapter.rxjava2.RxJava2CallAdapterFactory;

@Configuration
public class RestClientConfig {

    @Bean
    public Retrofit retrofit() {
        return new Retrofit.Builder()
            .baseUrl("https://api.example.com")
            .addConverterFactory(JacksonConverterFactory.create())
            .addCallAdapterFactory(RxJava2CallAdapterFactory.create())
            .build();
    }

    @Bean
    public PetStoreApi petStoreApi(Retrofit retrofit) {
        return retrofit.create(PetStoreApi.class);
    }
}
```

### Bean Quarkus

```java
// quarkus-project/src/main/java/com/example/config/RestClientConfig.java
package com.example.config;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.enterprise.inject.Produces;
import org.eclipse.microprofile.config.inject.ConfigProperty;
import com.example.client.PetStoreApi;

@ApplicationScoped
public class RestClientConfig {

    @ConfigProperty(name = "petstore.api.url")
    String petStoreUrl;

    @ConfigProperty(name = "petstore.api.timeout", defaultValue = "10000")
    int timeout;

    @Produces
    @ApplicationScoped
    public PetStoreApi petStoreApi() {
        // Ya no es necesario - se maneja con @RegisterRestClient
        // y configuración en properties
        return null; // La inyección se hace con @RestClient
    }
}
```

O más simple, sin bean:

```java
// quarkus-project/src/main/java/com/example/service/PetService.java
package com.example.service;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import org.eclipse.microprofile.rest.client.inject.RestClient;
import org.eclipse.microprofile.config.inject.ConfigProperty;
import com.example.client.PetStoreApi;

@ApplicationScoped
public class PetService {

    @Inject
    @RestClient
    PetStoreApi api;

    @ConfigProperty(name = "petstore.api.timeout", defaultValue = "10000")
    int timeout;

    // ...
}
```

## 📝 Paso 4: Inyección de Propiedades

### Antes (Spring @Value)

```java
@Service
public class PetService {

    @Value("${app.max-pets:100}")
    private int maxPets;

    @Value("${app.cache-timeout:3600}")
    private int cacheTimeout;

    public void process() {
        System.out.println("Max pets: " + maxPets);
    }
}
```

### Después (Quarkus @ConfigProperty)

```java
@ApplicationScoped
public class PetService {

    @ConfigProperty(name = "app.max-pets", defaultValue = "100")
    int maxPets;

    @ConfigProperty(name = "app.cache-timeout", defaultValue = "3600")
    int cacheTimeout;

    public void process() {
        System.out.println("Max pets: " + maxPets);
    }
}
```

**O en application.properties:**

```properties
app.max-pets=100
app.cache-timeout=3600
```

## 📝 Paso 5: Configuración Avanzada con ConfigMapping

```java
// quarkus-project/src/main/java/com/example/config/AppConfig.java
package com.example.config;

import io.smallrye.config.ConfigMapping;
import io.smallrye.config.WithName;

@ConfigMapping(prefix = "app")
public interface AppConfig {

    String name();

    String version();

    @WithName("max-pets")
    int maxPets();

    Database database();

    interface Database {
        String url();
        String username();
        String password();
    }
}

// Uso
@ApplicationScoped
public class PetService {

    @Inject
    AppConfig config;

    public void start() {
        System.out.println("App: " + config.name());
        System.out.println("DB: " + config.database().url());
    }
}
```

**application.properties:**

```properties
app.name=PetStore API
app.version=1.0.0
app.max-pets=100
app.database.url=jdbc:mysql://localhost/petstore
app.database.username=root
app.database.password=pass
```

## 📝 Paso 6: Variables de Entorno

```properties
# En application.properties, usar ${ENV_VAR}
quarkus.datasource.jdbc.url=${DB_URL:jdbc:mysql://localhost/petstore}
quarkus.datasource.username=${DB_USER:root}
quarkus.datasource.password=${DB_PASSWORD:}
quarkus.http.port=${HTTP_PORT:8080}
```

**Ejecutar:**

```bash
export DB_URL=jdbc:mysql://prod-server/db
export DB_USER=prod_user
export HTTP_PORT=9090
mvn quarkus:dev
```

## ✅ Checklist

- [ ] application.properties convertido
- [ ] Perfiles configurados (dev, prod, test)
- [ ] Beans de configuración creados
- [ ] @ConfigProperty inyectadas
- [ ] REST Client configurado con properties
- [ ] Variables de entorno documentadas
- [ ] Tests con diferentes profiles
- [ ] Compilación sin errores

## 🔗 Siguiente Paso

→ Ir a `06-TESTING.md`
