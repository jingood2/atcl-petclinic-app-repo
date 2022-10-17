FROM openjdk:8-jdk-slim as runtime

WORKDIR /app

COPY ./mvnw ./mvnw
COPY ./src ./src
COPY ./pom.xml ./pom.xml
CMD ["./mvnw", "clean","package]
RUN ls -al ./target

FROM amazoncorretto:17-alpine
#FROM adoptopenjdk/openjdk11:jdk11u-nightly-slim
WORKDIR /app

ADD https://github.com/aws-observability/aws-otel-java-instrumentation/releases/download/v1.17.0/aws-opentelemetry-agent.jar /app/aws-opentelemetry-agent.jar
ENV JAVA_TOOL_OPTIONS "-javaagent:/app/aws-opentelemetry-agent.jar"

ARG JAR_FILE=target/*.jar
COPY --from=runtime /app/${JAR_FILE} ./app.jar

# OpenTelemetry agent configuration
ENV OTEL_TRACES_SAMPLER "always_on"
ENV OTEL_PROPAGATORS "tracecontext,baggage,xray"
ENV OTEL_RESOURCE_ATTRIBUTES "service.name=PetSearch"
ENV OTEL_IMR_EXPORT_INTERVAL "10000"
ENV OTEL_EXPORTER_OTLP_ENDPOINT "http://localhost:4317"

ENTRYPOINT ["java","-jar","/app/app.jar"]
