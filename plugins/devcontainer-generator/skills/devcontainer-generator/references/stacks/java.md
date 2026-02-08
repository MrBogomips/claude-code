# Java

## Base Image
mcr.microsoft.com/devcontainers/java:21

## Detection
- `pom.xml` — Maven project
- `build.gradle` — Gradle project (Groovy DSL)
- `build.gradle.kts` — Gradle project (Kotlin DSL)
- `.mvn/` — Maven wrapper directory
- `gradlew` — Gradle wrapper script
- `settings.gradle` or `settings.gradle.kts` — multi-module Gradle project

## Frameworks

### Spring Boot
- Detection: `spring-boot-starter` in `pom.xml` or `build.gradle`
- CLI: `./mvnw spring-boot:run` or `./gradlew bootRun`
- Dev port: 8080
- Config: `application.properties` or `application.yml`

### Quarkus
- Detection: `quarkus` in `pom.xml` or `build.gradle`
- CLI: `./mvnw quarkus:dev` or `./gradlew quarkusDev`
- Dev port: 8080
- Config: `application.properties` in `src/main/resources`

### Micronaut
- Detection: `micronaut` in `pom.xml` or `build.gradle`
- CLI: `./mvnw mn:run` or `./gradlew run`
- Dev port: 8080

## Package Managers

| Lock File | Manager | Install Command | Cache Volume |
|-----------|---------|-----------------|--------------|
| — | Maven | `./mvnw dependency:resolve` | `devcontainer-{{PROJECT_NAME}}-maven` mounted at `/home/vscode/.m2` |
| `gradle.lockfile` | Gradle | `./gradlew dependencies` | `devcontainer-{{PROJECT_NAME}}-gradle` mounted at `/home/vscode/.gradle` |

## Dockerfile Layers

When layered on a non-native base image:

```dockerfile
RUN apt-get update && apt-get install -y openjdk-21-jdk \
    && update-alternatives --set java /usr/lib/jvm/java-21-openjdk-amd64/bin/java
ENV JAVA_HOME="/usr/lib/jvm/java-21-openjdk-amd64"
ENV PATH="${JAVA_HOME}/bin:${PATH}"
```

## Devcontainer Features

```json
{
  "ghcr.io/devcontainers/features/java:1": {
    "version": "21",
    "installMaven": "true",
    "installGradle": "true"
  }
}
```

## VS Code Extensions

- `vscjava.vscode-java-pack` — Java extension pack (language support, debugger, test runner, Maven, project manager)
- `vmware.vscode-spring-boot` — Spring Boot tools (Spring Boot projects)
- `redhat.vscode-quarkus` — Quarkus tools (Quarkus projects)

## Port Forwarding

| Port | Label | Condition |
|------|-------|-----------|
| 8080 | Spring Boot / Quarkus / Micronaut | framework detected in build file |
| 8443 | HTTPS (Spring Boot) | HTTPS configured in `application.properties` |
| 5005 | Java Debug | remote debugging enabled |

## Host Binding

Java frameworks bind via configuration properties:

- **Spring Boot**: add `server.address=0.0.0.0` in `application.properties` or `application.yml`
- **Quarkus**: add `quarkus.http.host=0.0.0.0` in `application.properties`
- **Micronaut**: add `micronaut.server.host=0.0.0.0` in `application.yml`

## Environment Variables

```json
{
  "JAVA_HOME": "/usr/lib/jvm/java-21-openjdk-amd64",
  "MAVEN_OPTS": "-Xmx512m",
  "GRADLE_OPTS": "-Xmx512m"
}
```

## Post-Create Steps

```bash
# Maven projects
if [ -f pom.xml ]; then
  ./mvnw dependency:resolve -q
fi

# Gradle projects
if [ -f build.gradle ] || [ -f build.gradle.kts ]; then
  ./gradlew dependencies --quiet
fi
```

## Aliases

```bash
alias mvn="./mvnw"
alias gradle="./gradlew"
```

## Firewall Domains

```
ALLOW repo1.maven.org
ALLOW repo.maven.apache.org
ALLOW plugins.gradle.org
ALLOW services.gradle.org
ALLOW jcenter.bintray.com
```

## Combo Templates

- `java-postgres` — Java + PostgreSQL
