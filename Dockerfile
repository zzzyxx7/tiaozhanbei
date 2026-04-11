# 使用官方 Maven 镜像构建，避免在 Alpine 里 apk 安装 maven 时因 TLS/依赖失败
FROM maven:3.9-eclipse-temurin-21-alpine AS builder

WORKDIR /app

COPY pom.xml .
COPY src ./src

RUN mvn -q -DskipTests package && \
    cp target/rule-backend-0.0.1-SNAPSHOT.jar app.jar

FROM eclipse-temurin:21-jre-alpine

RUN apk add --no-cache curl

WORKDIR /app

ENV JAVA_OPTS=""

COPY --from=builder /app/app.jar /app/app.jar

EXPOSE 8080

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar /app/app.jar"]
