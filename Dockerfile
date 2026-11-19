# Etapa 1: Compilar y probar el proyecto
FROM maven:3.9-eclipse-temurin-26 AS build
WORKDIR /app

COPY pom.xml .
COPY src ./src

RUN mvn -B -ntp package

# Etapa 2: Ejecutar la aplicación
FROM eclipse-temurin:26-jre-noble
WORKDIR /app

COPY --from=build /app/target/deisw-retail-store-0.0.1-SNAPSHOT.jar app.jar

EXPOSE 8096

ENTRYPOINT ["java", "-jar", "app.jar"]
