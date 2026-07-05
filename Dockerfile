# Stage 1: Build
FROM maven:3.9-eclipse-temurin-21 AS builder
WORKDIR /app
COPY pom.xml mvnw mvnw.cmd ./
COPY .mvn .mvn
ENV MAVEN_OPTS="-Xmx384m -Xms128m"
RUN mvn dependency:resolve -q
COPY src src
RUN mvn package -DskipTests -q

# Stage 2: Run
FROM tomcat:10.1-jdk21-temurin
ENV CATALINA_OPTS="-Xmx200m -Xms64m -XX:+UseSerialGC -XX:MaxMetaspaceSize=80m -XX:ReservedCodeCacheSize=32m -XX:CompressedClassSpaceSize=24m -Xss256k" \
    JAVA_OPTS="-Djava.awt.headless=true -Dfile.encoding=UTF-8"
RUN rm -rf /usr/local/tomcat/webapps/*
COPY --from=builder /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080
