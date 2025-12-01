# Stage 1: Build
FROM eclipse-temurin:17-jdk-focal AS build

WORKDIR /app

# Install Maven
RUN apt-get update && apt-get install -y maven

# Copy pom.xml and download dependencies
COPY pom.xml .
RUN mvn dependency:go-offline

# Copy source code
COPY src ./src

# Build the application
RUN mvn clean package -DskipTests

# Stage 2: Runtime
FROM eclipse-temurin:17-jre-jammy

WORKDIR /app

# Copy the built jar from the build stage
COPY --from=build /app/target/*.jar app.jar

# Set environment variables
ENV SPRING_PROFILES_ACTIVE=docker

# Expose port
EXPOSE 8083

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
