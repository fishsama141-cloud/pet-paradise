FROM eclipse-temurin:22-jdk

# Install MySQL client + tools
RUN apt-get update -qq && apt-get install -y -qq curl default-mysql-client && rm -rf /var/lib/apt/lists/*

# Install Tomcat 10.1
ENV CATALINA_HOME=/opt/tomcat
ENV PATH=$CATALINA_HOME/bin:$PATH
RUN mkdir -p $CATALINA_HOME
RUN curl -fsSL https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.54/bin/apache-tomcat-10.1.54.tar.gz \
    | tar xz -C $CATALINA_HOME --strip-components=1

# Copy Maven wrapper and source
WORKDIR /app
COPY .mvn .mvn
COPY mvnw mvnw.cmd pom.xml ./
RUN chmod +x mvnw && ./mvnw dependency:resolve -q || true

# Copy source and build
COPY src src
RUN ./mvnw package -DskipTests -q

# Deploy WAR to Tomcat
RUN rm -rf $CATALINA_HOME/webapps/* && cp target/*.war $CATALINA_HOME/webapps/ROOT.war

# Copy init script
COPY init.sql /app/init.sql
COPY docker-entrypoint.sh /app/docker-entrypoint.sh
RUN chmod +x /app/docker-entrypoint.sh

EXPOSE 8080
CMD ["/app/docker-entrypoint.sh"]
