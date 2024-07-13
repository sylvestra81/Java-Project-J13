FROM openjdk:17
EXPOSE 8080
ADD target/project-j13.jar /project-j13.jar
ENTRYPOINT ["java", "-jar", "/project-j13.jar"]