FROM openjdk:17-jdk-slim-buster
COPY staging/*.jar app.jar
ENTRYPOINT ["java", "-jar", "/app.jar"]
EXPOSE 8080