
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app

# Copy pom.xml first to cache dependencies separately from source code
COPY pom.xml .
RUN mvn -B dependency:go-offline

# Copy source and build the WAR
COPY src ./src
RUN mvn -B clean package -DskipTests

# ---------- Stage 2: Runtime ----------
FROM tomcat:10.1-jdk21-temurin

# Remove Tomcat's default landing page app
RUN rm -rf /usr/local/tomcat/webapps/ROOT

# Copy the built WAR from the build stage, deploy at root path
COPY --from=build /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080

CMD ["catalina.sh", "run"]
