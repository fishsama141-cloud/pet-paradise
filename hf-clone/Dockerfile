FROM maven:3.9-eclipse-temurin-21 AS builder
RUN apt-get update -qq && apt-get install -y -qq git && \
    git clone https://github.com/fishsama141-cloud/pet-paradise.git /app
WORKDIR /app
ENV MAVEN_OPTS="-Xmx512m -Xms256m"
RUN mvn package -DskipTests -q

FROM tomcat:10.1-jdk21-temurin
RUN sed -i 's/port="8080"/port="7860"/' /usr/local/tomcat/conf/server.xml \
    && rm -rf /usr/local/tomcat/webapps/*
COPY --from=builder /app/target/*.war /usr/local/tomcat/webapps/ROOT.war
ENV CATALINA_OPTS="-Xmx256m -Xms128m -XX:+UseG1GC -XX:MaxMetaspaceSize=128m" \
    JAVA_OPTS="-Djava.awt.headless=true -Dfile.encoding=UTF-8" \
    DB_HOST=sql5.freesqldatabase.com \
    DB_PORT=3306 \
    DB_NAME=sql5832284 \
    DB_USER=sql5832284 \
    DB_PASSWORD=rdzhK5AlZe
EXPOSE 7860
