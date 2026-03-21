# Java

## Base Image
mcr.microsoft.com/devcontainers/base:ubuntu-24.04

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

When added as a secondary stack in a multi-stack project:

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

## Credential Files

### ~/.m2/settings.xml

- **Description**: Maven settings with server credentials for private Maven repositories (Nexus, Artifactory, GitHub Packages)
- **Host path**: `~/.m2/settings.xml`
- **Mount target**: `/tmp/.m2-settings-host.xml`
- **Pre-select**: Pre-selected if Maven detected (`pom.xml` or `.mvn/` present)
- **Extraction type**: XML — copy entire file (XML splicing is unsafe)
- **initializeCommand**: `mkdir -p "$HOME/.m2" && (test -f "$HOME/.m2/settings.xml" || touch "$HOME/.m2/settings.xml")`
- **Mount**: `source=${localEnv:HOME}/.m2/settings.xml,target=/tmp/.m2-settings-host.xml,type=bind,readonly`
- **Fallback env var**: `MAVEN_SERVER_PASSWORD`

#### Post-Create Extraction

```bash
if [ -s /tmp/.m2-settings-host.xml ]; then
  log "Copying Maven settings from host ~/.m2/settings.xml..."
  mkdir -p ~/.m2
  cp /tmp/.m2-settings-host.xml ~/.m2/settings.xml
elif [ -n "${MAVEN_SERVER_PASSWORD:-}" ]; then
  log "Using MAVEN_SERVER_PASSWORD environment variable..."
  mkdir -p ~/.m2
  cat > ~/.m2/settings.xml << 'MVNEOF'
<settings>
  <servers>
    <server>
      <id>private-repo</id>
      <username>${env.MAVEN_SERVER_USERNAME:-deploy}</username>
      <password>${env.MAVEN_SERVER_PASSWORD}</password>
    </server>
  </servers>
</settings>
MVNEOF
else
  log "⚠ No Maven credentials found. Set MAVEN_SERVER_PASSWORD or populate ~/.m2/settings.xml on the host."
fi
```

#### DEVCONTAINER.md Block

| Host File | Container Path | Purpose | Fallback Env Var |
|-----------|---------------|---------|-----------------|
| `~/.m2/settings.xml` | `/tmp/.m2-settings-host.xml` | Maven server credentials | `MAVEN_SERVER_PASSWORD` |

### ~/.gradle/gradle.properties

- **Description**: Gradle properties with credentials for private repositories and plugin portals
- **Host path**: `~/.gradle/gradle.properties`
- **Mount target**: `/tmp/.gradle-props-host`
- **Pre-select**: Pre-selected if Gradle detected (`build.gradle`, `build.gradle.kts`, or `gradlew` present)
- **Extraction type**: Properties — grep credential-related keys
- **initializeCommand**: `mkdir -p "$HOME/.gradle" && (test -f "$HOME/.gradle/gradle.properties" || touch "$HOME/.gradle/gradle.properties")`
- **Mount**: `source=${localEnv:HOME}/.gradle/gradle.properties,target=/tmp/.gradle-props-host,type=bind,readonly`
- **Fallback env var**: `GRADLE_PUBLISH_KEY`

#### Post-Create Extraction

```bash
if [ -s /tmp/.gradle-props-host ]; then
  log "Extracting Gradle credentials from host ~/.gradle/gradle.properties..."
  mkdir -p ~/.gradle
  grep -iE '(token|password|key|user|auth|credential|publish|maven|nexus|artifactory)' /tmp/.gradle-props-host >> ~/.gradle/gradle.properties 2>/dev/null || true
elif [ -n "${GRADLE_PUBLISH_KEY:-}" ]; then
  log "Using GRADLE_PUBLISH_KEY environment variable..."
  mkdir -p ~/.gradle
  echo "mavenPublishKey=${GRADLE_PUBLISH_KEY}" >> ~/.gradle/gradle.properties
else
  log "⚠ No Gradle credentials found. Set GRADLE_PUBLISH_KEY or populate ~/.gradle/gradle.properties on the host."
fi
```

#### DEVCONTAINER.md Block

| Host File | Container Path | Purpose | Fallback Env Var |
|-----------|---------------|---------|-----------------|
| `~/.gradle/gradle.properties` | `/tmp/.gradle-props-host` | Gradle repository credentials | `GRADLE_PUBLISH_KEY` |

