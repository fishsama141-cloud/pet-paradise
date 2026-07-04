# Stage 1: Build
FROM maven:3.9-eclipse-temurin-17 AS builder
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests -q

# Stage 2: Run
FROM tomcat:10.1-jre17-temurin
# Clean default apps
RUN rm -rf /usr/local/tomcat/webapps/*
# Copy built WAR as ROOT
COPY --from=builder /app/target/*.war /usr/local/tomcat/webapps/ROOT.war
EXPOSE 8080
CMD ["catalina.sh", "run"]
