FROM eclipse-temurin:21-jdk-alpine AS build
WORKDIR /src
COPY HelloWorldServer.java .
RUN javac --add-modules jdk.httpserver HelloWorldServer.java

FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY --from=build /src/HelloWorldServer.class .
EXPOSE 8080
CMD ["java", "--add-modules", "jdk.httpserver", "HelloWorldServer"]
