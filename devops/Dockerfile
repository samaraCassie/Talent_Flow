# Etapa de build
FROM maven:3.9.6-eclipse-temurin-17-alpine AS build

WORKDIR /app

# Copia o pom.xml e baixa dependências
COPY ../pom.xml ./
RUN mvn dependency:go-offline

# Copia o restante do projeto
COPY ../ .

# Compila o projeto
RUN mvn clean package -DskipTests

# Etapa de execução
FROM eclipse-temurin:17-jdk-alpine
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]