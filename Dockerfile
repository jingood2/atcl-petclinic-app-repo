FROM openjdk:8-jdk-slim as build 

WORKDIR /app

COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .
COPY src src

RUN ./mvnw  install -DskipTests

RUN cp /app/target/*.jar app.jar
RUN java -Djarmode=layertools -jar app.jar extract

FROM openjdk:8-jdk-slim
WORKDIR /app

ADD https://github.com/aws-observability/aws-otel-java-instrumentation/releases/download/v1.17.0/aws-opentelemetry-agent.jar /app/aws-opentelemetry-agent.jar
ENV JAVA_TOOL_OPTIONS "-javaagent:/app/aws-opentelemetry-agent.jar"

# OpenTelemetry agent configuration
ENV OTEL_TRACES_SAMPLER "always_on"
ENV OTEL_PROPAGATORS "tracecontext,baggage,xray"
ENV OTEL_RESOURCE_ATTRIBUTES `service.name=${SERVICE_NAME}`
ENV OTEL_IMR_EXPORT_INTERVAL "10000"
ENV OTEL_EXPORTER_OTLP_ENDPOINT "http://localhost:4317"

COPY --from=build app/dependencies/ ./
COPY --from=build app/spring-boot-loader/ ./
COPY --from=build app/snapshot-dependencies/ ./
COPY --from=build app/application/ ./
ENTRYPOINT ["java", "org.springframework.boot.loader.JarLauncher"]