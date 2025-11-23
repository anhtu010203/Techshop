# ========= STAGE 1: Build JAR=========
FROM eclipse-temurin:21-jdk-alpine AS builder
WORKDIR /app
COPY pom.xml .
COPY src ./src

RUN apk add --no-cache maven && mvn clean package -DskipTests

# ========= STAGE 2: Runtime =========
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY --from=builder /app/target/techshop-backend-*.jar app.jar

ENV PORT=8080
EXPOSE $PORT

ENTRYPOINT ["java", "--enable-preview", "-jar", "app.jar"]
