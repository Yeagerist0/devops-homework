# Multi-stage Docker build

Build and run the existing multi-stage application:

```bash
docker build -t devops-multistage .
docker run -d --name devops-multistage -p 8080:3000 devops-multistage
curl http://localhost:8080
docker ps --filter name=devops-multistage
docker rm -f devops-multistage
```

The application listens on container port `3000` and is published as host port
`8080`. Expected response contains `Hello World from Docker Multi-Stage Build!`.
