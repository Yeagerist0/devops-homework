# Docker Networking and Volumes Homework

## Three containers and three networks

The existing [`demo/docker-compose.yml`](demo/docker-compose.yml) provides a
frontend, backend, and database. The backend is attached to both application
networks. To run it:

```bash
cd demo
docker compose up -d --build
docker compose ps
docker network ls
docker compose exec frontend wget -qO- http://backend:5000/health
docker compose down -v
```

Container names resolve through Docker's embedded DNS on a shared network.

## Host network

```bash
docker pull httpd:2.4-alpine
docker run --rm --name apache-host --network host httpd:2.4-alpine
curl http://localhost/
```

## Bind mount

```bash
mkdir -p bind-mount
printf "Hello students\n" > bind-mount/index.html
docker run -d --name nginx-bind -p 8080:80 \
  -v "$PWD/bind-mount:/usr/share/nginx/html:ro" nginx:alpine
curl http://localhost:8080
printf "Hello students - updated\n" > bind-mount/index.html
curl http://localhost:8080
docker rm -f nginx-bind
```

The host file changes are visible without restarting because the container reads
the mounted directory directly.

## Overlay networks

Overlay networks span Docker Swarm nodes. They require Swarm mode and are useful
when services on different Docker hosts need service discovery and encrypted
or isolated traffic:

```bash
docker swarm init
docker network create --driver overlay --attachable devops-overlay
docker network inspect devops-overlay
docker swarm leave --force
```
