# ========= STAGE 1: Build JAR với Java 21 =========
FROM eclipse-temurin:21-jdk-alpine AS builder
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN chmod +x mvnw && ./mvnw clean package -DskipTests


FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY --from=builder /app/target/techshop-backend-*.jar app.jar

ENV PORT=8080
EXPOSE $PORT

# Virtual Thread bật sẵn (Java 21)
ENTRYPOINT ["java", "--enable-preview", "-jar", "app.jar"]