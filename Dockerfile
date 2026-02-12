# Stage 1: Build the application
FROM maven:3.9.9-eclipse-temurin-21 AS builder

WORKDIR /app

# Copy only the pom first to leverage Docker cache for dependencies
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy source and build
COPY src ./src
RUN mvn clean package -DskipTests

# Stage 2: Runtime environment
# FIX: Use eclipse-temurin instead of the deprecated openjdk image
FROM eclipse-temurin:21-jre AS runner

WORKDIR /app

# FIX: Corrected the source path (absolute path from builder stage)
# Note: Double-check your JAR name matches 'api-gateway
COPY --from=builder /app/target/api-gateway-0.0.1-SNAPSHOT.jar ./app.jar

EXPOSE 4004

# Use 'exec' form for better signal handling
ENTRYPOINT ["java", "-jar", "app.jar"]