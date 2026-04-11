FROM eclipse-temurin:21-jdk-alpine AS builder

WORKDIR /app

COPY pom.xml .
COPY src ./src

# 必须复制 Spring Boot 打好的可执行 fat jar，不能是 *-plain.jar（无 Main-Class）
RUN apk add --no-cache maven && \
    mvn -q -DskipTests package && \
    cp target/rule-backend-0.0.1-SNAPSHOT.jar app.jar

FROM eclipse-temurin:21-jre-alpine

RUN apk add --no-cache curl

WORKDIR /app

ENV JAVA_OPTS=""

COPY --from=builder /app/app.jar /app/app.jar

EXPOSE 8080

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar /app/app.jar"]

