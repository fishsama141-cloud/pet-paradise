# Stage 1: Build
FROM maven:3.9-eclipse-temurin-21 AS builder
WORKDIR /app
COPY pom.xml mvnw mvnw.cmd ./
COPY .mvn .mvn
RUN mvn dependency:resolve -q
COPY src src
RUN mvn package -DskipTests -q

# Stage 2: Run
FROM tomcat:10.1
RUN rm -rf /usr/local/tomcat/webapps/*
COPY --from=builder /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

# Install MySQL client
RUN apt-get update -qq && apt-get install -y -qq default-mysql-client && rm -rf /var/lib/apt/lists/*

COPY init.sql /app/init.sql
COPY docker-entrypoint.sh /app/docker-entrypoint.sh
RUN chmod +x /app/docker-entrypoint.sh

EXPOSE 8080
ENTRYPOINT ["/app/docker-entrypoint.sh"]
CMD ["catalina.sh", "run"]
