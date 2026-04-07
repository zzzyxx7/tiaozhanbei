FROM eclipse-temurin:17-jdk-alpine AS builder

WORKDIR /app

COPY pom.xml .
COPY src ./src

RUN apk add --no-cache maven && \
    mvn -q -DskipTests package && \
    cp target/*.jar app.jar

FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

ENV JAVA_OPTS="" \
    DB_URL="jdbc:mysql://db:3306/rule_engine_db?useUnicode=true&characterEncoding=utf8&serverTimezone=Asia/Shanghai" \
    DB_USER="root" \
    DB_PASSWORD="1234"

COPY --from=builder /app/app.jar /app/app.jar

EXPOSE 8080

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar /app/app.jar"]

