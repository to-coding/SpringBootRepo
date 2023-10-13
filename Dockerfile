FROM openjdk:17
COPY target/SpringBootRepo-0.0.1-SNAPSHOT.jar SpringBootRepo-0.0.1-SNAPSHOT.jar
CMD ["java", "-jar", "SpringBootRepo-0.0.1-SNAPSHOT.jar"]
#docker build -t demo .
#docker images
#docker run -d --name test-demo -p 8080:8080 demo:latest
#aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 160071257600.dkr.ecr.us-east-1.amazonaws.com
#docker tag test-demo:latest 160071257600.dkr.ecr.us-east-1.amazonaws.com/beach_ecr:latest
#docker push 160071257600.dkr.ecr.us-east-1.amazonaws.com/beach_ecr:latest
