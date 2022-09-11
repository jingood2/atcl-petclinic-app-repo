FROM openjdk:8-jdk-slim as runtime
MAINTAINER jingood2 <jingood2@sk.com>

ENV TERM=dumb
RUN cd spring-petclinic
CMD ["./mvnw", "clean","package]
ARG JAR_FILE=target/*.jar
ADD ${JAR_FILE} app.jar
ENTRYPOINT ["java","-jar","/app.jar"]
