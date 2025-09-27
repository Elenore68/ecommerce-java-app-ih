# Multi-stage build for Spring Boot application


# Stage 1: Build stage
FROM maven:3.9.9-eclipse-temurin-21 AS builder


LABEL maintainer="saurabh@uptut.com"


# Set the working directory inside the container
WORKDIR /app


# Copy the pom.xml to the container first (for better layer caching)
COPY pom.xml .


# Download dependencies (this layer will be cached if pom.xml doesn't change)
RUN mvn dependency:go-offline -B


# Copy the source code to the container
COPY src ./src


# Build the application using Maven
RUN mvn package -DskipTests


# Stage 2: Runtime stage
FROM eclipse-temurin:21-jre-alpine AS runtime


LABEL maintainer="Saurabh"


# Create a non-root user for security
RUN addgroup -g 1001 -S appgroup && \
   adduser -u 1001 -S appuser -G appgroup


# Set the working directory inside the container
WORKDIR /app


# Copy the JAR file from the builder stage
COPY --from=builder /app/target/*.jar app.jar



# Change ownership of the app directory to the non-root user
RUN chown -R appuser:appgroup /app


# Switch to the non-root user
USER appuser


# Expose the port the app runs on
EXPOSE 8080


# Command to run the application
CMD ["java", "-jar", "app.jar"]
# End of Dockerfile