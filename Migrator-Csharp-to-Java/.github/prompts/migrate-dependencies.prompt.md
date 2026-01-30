# 📦 Migrate Dependencies (NuGet to Maven)

## Objective

Convert .csproj NuGet dependencies to Maven pom.xml, finding equivalent Java libraries and maintaining functionality.

## Context

- Source: .csproj with NuGet packages
- Target: pom.xml with Maven dependencies
- Must find functional equivalents
- Must ensure version compatibility
- Must avoid transitive dependency conflicts

## Instructions

You are a Maven and NuGet expert. When migrating dependencies:

### 1. Common NuGet to Maven Mappings

#### Azure Services

```
NuGet                               → Maven
Azure.Storage.Blobs                 → com.azure:azure-storage-blob
Azure.Messaging.ServiceBus          → com.azure:azure-messaging-servicebus
Azure.Cosmos                        → com.azure:azure-cosmos
Microsoft.Azure.Functions           → com.microsoft.azure.functions:azure-functions-java-library
Microsoft.Azure.Cosmos              → com.azure:azure-cosmos
Azure.Data.Tables                   → com.azure:azure-data-tables
Azure.Identity                      → com.azure:azure-identity
```

#### Logging & Monitoring

```
NuGet                               → Maven
NLog                                → org.slf4j:slf4j-api + org.apache.logging.log4j:log4j-core
Serilog                             → org.apache.logging.log4j:log4j-core
Application Insights                → com.microsoft.applicationinsights:applicationinsights-core
```

#### JSON Processing

```
NuGet                               → Maven
Newtonsoft.Json (JSON.NET)          → com.fasterxml.jackson.core:jackson-databind
System.Text.Json                    → com.google.code.gson:gson
Utf8Json                            → com.fasterxml.jackson.core:jackson-databind
```

#### ORM & Database

```
NuGet                               → Maven
Entity Framework Core                → org.springframework.boot:spring-boot-starter-data-jpa
Dapper                              → org.jooq:jooq
Linq2Db                             → org.jooq:jooq
SqlClient                           → com.microsoft.sqlserver:mssql-jdbc
Npgsql                              → org.postgresql:postgresql
MySqlConnector                      → mysql:mysql-connector-java
```

#### HTTP & REST

```
NuGet                               → Maven
HttpClient                          → (built-in java.net.http)
RestSharp                           → com.squareup.okhttp3:okhttp
Refit                               → com.squareup.retrofit2:retrofit
```

#### Utilities

```
NuGet                               → Maven
Newtonsoft.Json                     → com.fasterxml.jackson.core:jackson-databind
AutoMapper                          → org.modelmapper:modelmapper
Hangfire                            → com.github.kagkarlsson:db-scheduler
Quartz.NET                          → org.quartz-scheduler:quartz
StackExchange.Redis                 → redis.clients:jedis
```

#### Testing

```
NuGet                               → Maven
xUnit.net                           → org.junit.jupiter:junit-jupiter
Moq                                 → org.mockito:mockito-core
NSubstitute                         → org.mockito:mockito-core
FluentAssertions                    → org.assertj:assertj-core
```

### 2. Analyze .csproj File

```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net6.0</TargetFramework>
    <AzureFunctionsVersion>4</AzureFunctionsVersion>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="Microsoft.Azure.WebJobs.Extensions.Storage" Version="5.0.0" />
    <PackageReference Include="Microsoft.NET.Sdk.Functions" Version="4.0.1" />
    <PackageReference Include="Newtonsoft.Json" Version="13.0.1" />
  </ItemGroup>
</Project>
```

Extract:

- ✅ All `<PackageReference>` entries
- ✅ Package name and version
- ✅ Target framework (.NET 6.0 → Java 17+)

### 3. Generate pom.xml Structure

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
                             http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.example.migration</groupId>
    <artifactId>azure-function-migrated</artifactId>
    <version>1.0.0</version>

    <properties>
        <maven.compiler.source>17</maven.compiler.source>
        <maven.compiler.target>17</maven.compiler.target>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <azure-functions-java-library.version>3.0.0</azure-functions-java-library.version>
    </properties>

    <dependencies>
        <!-- Azure Functions Core -->
        <dependency>
            <groupId>com.microsoft.azure.functions</groupId>
            <artifactId>azure-functions-java-library</artifactId>
            <version>${azure-functions-java-library.version}</version>
        </dependency>

        <!-- Other dependencies mapped from .csproj -->
    </dependencies>

    <build>
        <plugins>
            <!-- Build plugins -->
        </plugins>
    </build>
</project>
```

### 4. Dependency Resolution

For each NuGet package:

1. **Identify Purpose**: What does the package do?
2. **Find Java Equivalent**: Search Maven Central
3. **Check Compatibility**: Version compatibility with Java 17+
4. **Verify Functionality**: Same or similar capabilities
5. **Check Dependencies**: Transitive dependencies

#### Example Resolution

```
NuGet: Microsoft.Azure.Functions v4.0.1
↓
Purpose: Azure Functions runtime library
↓
Maven Equivalent: com.microsoft.azure.functions:azure-functions-java-library
↓
Recommended Version: 3.0.0 (compatible with Functions runtime 4.x)
↓
Added to pom.xml:
<dependency>
    <groupId>com.microsoft.azure.functions</groupId>
    <artifactId>azure-functions-java-library</artifactId>
    <version>3.0.0</version>
</dependency>
```

### 5. Common Issues & Solutions

#### Transitive Dependencies

```xml
<!-- Exclude conflicting transitive dependency -->
<dependency>
    <groupId>org.example</groupId>
    <artifactId>some-library</artifactId>
    <version>1.0.0</version>
    <exclusions>
        <exclusion>
            <groupId>org.conflicting</groupId>
            <artifactId>conflicting-lib</artifactId>
        </exclusion>
    </exclusions>
</dependency>
```

#### Version Conflicts

```xml
<!-- Use dependencyManagement to enforce versions -->
<dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>com.fasterxml.jackson.core</groupId>
            <artifactId>jackson-databind</artifactId>
            <version>2.15.2</version>
        </dependency>
    </dependencies>
</dependencyManagement>
```

#### Missing Equivalent

If no direct equivalent exists:

1. Document the gap
2. Find alternative approach
3. Implement custom solution if needed

## Template pom.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
                             http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.example.migration</groupId>
    <artifactId>azure-function-migrated</artifactId>
    <version>1.0.0</version>

    <properties>
        <maven.compiler.source>17</maven.compiler.source>
        <maven.compiler.target>17</maven.compiler.target>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <azure-functions.version>3.0.0</azure-functions.version>
        <jackson.version>2.15.2</jackson.version>
    </properties>

    <dependencies>
        <!-- Azure Functions -->
        <dependency>
            <groupId>com.microsoft.azure.functions</groupId>
            <artifactId>azure-functions-java-library</artifactId>
            <version>${azure-functions.version}</version>
        </dependency>

        <!-- JSON Processing -->
        <dependency>
            <groupId>com.fasterxml.jackson.core</groupId>
            <artifactId>jackson-databind</artifactId>
            <version>${jackson.version}</version>
        </dependency>

        <!-- Logging -->
        <dependency>
            <groupId>org.slf4j</groupId>
            <artifactId>slf4j-api</artifactId>
            <version>2.0.7</version>
        </dependency>
        <dependency>
            <groupId>org.apache.logging.log4j</groupId>
            <artifactId>log4j-slf4j2-impl</artifactId>
            <version>2.20.0</version>
        </dependency>

        <!-- Testing -->
        <dependency>
            <groupId>org.junit.jupiter</groupId>
            <artifactId>junit-jupiter</artifactId>
            <version>5.9.2</version>
            <scope>test</scope>
        </dependency>
        <dependency>
            <groupId>org.mockito</groupId>
            <artifactId>mockito-core</artifactId>
            <version>5.2.0</version>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <!-- Compiler Plugin -->
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.11.0</version>
                <configuration>
                    <source>17</source>
                    <target>17</target>
                </configuration>
            </plugin>

            <!-- Azure Functions Plugin -->
            <plugin>
                <groupId>com.microsoft.azure</groupId>
                <artifactId>azure-functions-maven-plugin</artifactId>
                <version>1.20.0</version>
            </plugin>
        </plugins>
    </build>
</project>
```

## Checklist

- ✅ All NuGet packages identified
- ✅ Maven equivalents found
- ✅ Versions checked for compatibility
- ✅ Transitive dependencies resolved
- ✅ Conflicts addressed
- ✅ Test dependencies added
- ✅ Build plugins configured
- ✅ Properties defined for easy updates

## Tags

#maven #dependencies #nuget #migration #package-management
