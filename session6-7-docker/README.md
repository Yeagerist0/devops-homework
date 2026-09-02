# Session 6-7 - Docker Homework

Six Hello World web apps, each in its own folder with its own Dockerfile, all built and run with Docker on my machine. Plus the multi-stage build task.

## Folder structure

```
session6-7-docker/
├── nodejs-app/              Express, port 3000
├── python-app/              FastAPI + uvicorn, port 8000
├── java-app/                built-in HttpServer, port 8080
├── Apache-app/              httpd serving a static page, port 80
├── React-app/               Vite build -> served by nginx, port 80
├── nginx-app/               nginx serving a static page, port 80
└── multi-stage-dockerfile/  the multi-stage task, port 3000
```

## All of them running at once

```
$ docker ps
NAMES          IMAGE               STATUS          PORTS
multi-stage    multi-stage-build   Up 15 seconds   0.0.0.0:8080->3000/tcp
hello-nginx    nginx-app           Up 16 seconds   0.0.0.0:8082->80/tcp
hello-react    react-app           Up 18 seconds   0.0.0.0:8085->80/tcp
hello-apache   apache-app          Up 18 seconds   0.0.0.0:8084->80/tcp
hello-java     java-app            Up 19 seconds   0.0.0.0:8083->8080/tcp
hello-python   python-app          Up 21 seconds   0.0.0.0:8001->8000/tcp
hello-node     nodejs-app          Up 22 seconds   0.0.0.0:3001->3000/tcp
```

```
$ docker images
nodejs-app:latest         176MB
python-app:latest         165MB
java-app:latest           364MB
apache-app:latest         117MB
react-app:latest          162MB
nginx-app:latest          162MB
multi-stage-build:latest  172MB
```

---

## 1. Node.js app (`nodejs-app`)

Express with one route.

```
$ docker build -t nodejs-app ./nodejs-app
#5 [1/5] FROM docker.io/library/node:24-alpine
#6 [2/5] WORKDIR /app
#7 [3/5] COPY package*.json ./
#8 [4/5] RUN npm install
#9 [5/5] COPY . .
#10 naming to docker.io/library/nodejs-app done

$ docker run -d --name hello-node -p 3001:3000 nodejs-app
e9a762f9fa6e0f7df4fdaaa88ff68d237115b30a489900f84bc5d380cee3c0d2

$ curl http://localhost:3001
<h1>Hello World from Docker!</h1>
```

`COPY package*.json` before `COPY . .` is deliberate - Docker caches each layer, so if only `server.js` changes the `npm install` layer is reused instead of reinstalling everything.

## 2. Python app (`python-app`)

FastAPI served by uvicorn.

```
$ docker build -t python-app ./python-app
#5 [1/5] FROM docker.io/library/python:3.11-slim
#6 [2/5] WORKDIR /app
#7 [3/5] COPY requirements.txt .
#8 [4/5] RUN pip install -r requirements.txt
#9 [5/5] COPY app.py .
#10 naming to docker.io/library/python-app done

$ docker run -d --name hello-python -p 8001:8000 python-app
141ba1f386925879f57f49752d3dae8a006ac0eec06f97249b417aae2fa5bb42

$ curl http://localhost:8001
<h1>Hello World from Docker!</h1>
```

`--host 0.0.0.0` in the CMD matters. uvicorn defaults to 127.0.0.1, which inside a container means "only reachable from inside this container" - the port mapping would look fine and the page still wouldn't load.

## 3. Java app (`java-app`)

Java's built-in `com.sun.net.httpserver.HttpServer`, no Maven or Gradle needed for a hello world.

```
$ docker build -t java-app ./java-app
#5 [1/4] FROM docker.io/library/eclipse-temurin:21-jdk-alpine
#6 [2/4] WORKDIR /app
#7 [3/4] COPY App.java .
#8 [4/4] RUN javac App.java
#9 naming to docker.io/library/java-app done

$ docker run -d --name hello-java -p 8083:8080 java-app
c39c250b2cd242f05936f4c01f8612a552aadba9e8402f9772935d0ec16a541b

$ curl http://localhost:8083
<h1>Hello World from Docker!</h1>
```

364MB, the biggest of the lot, because the image ships a full JDK. A real app would compile in a JDK stage and run on a JRE stage - which is exactly the multi-stage idea below.

## 4. Apache app (`Apache-app`)

Static page dropped into the official httpd image.

```
$ docker build -t apache-app ./Apache-app
#5 [1/2] FROM docker.io/library/httpd:latest
#6 [2/2] COPY index.html /usr/local/apache2/htdocs/index.html
#7 naming to docker.io/library/apache-app done

$ docker run -d --name hello-apache -p 8084:80 apache-app
9873dc0ed0af41b851619d28425bdf640d6d5b689aa6da813bce9eed49a2c0e8

$ curl http://localhost:8084
<!DOCTYPE html>
<html>
<head>
    <title>Hello Docker</title>
</head>
<body>
    <h1>Hello World from Apache + Docker!</h1>
</body>
</html>
```

Apache's docroot is `/usr/local/apache2/htdocs`, nginx's is `/usr/share/nginx/html`. Mixing those two up is the usual reason you get the default page instead of yours.

## 5. React app (`React-app`)

Vite + React, built inside the image and served as static files by nginx. This one is a multi-stage Dockerfile too.

```
$ docker build -t react-app ./React-app
#12 [build 6/6] RUN npm run build
#12 vite v5.4.21 building for production...
#12 transforming...
#12 ✓ 30 modules transformed.
#12 dist/index.html                  0.20 kB │ gzip:  0.17 kB
#12 dist/assets/index-u2Cd2JyX.js  142.52 kB │ gzip: 45.74 kB
#12 ✓ built in 500ms
#13 [stage-1 2/2] COPY --from=build /app/dist /usr/share/nginx/html
#14 naming to docker.io/library/react-app done

$ docker run -d --name hello-react -p 8085:80 react-app
fa8ef3c9a1e9d39a76e2d1aa3a9e7e4a0cb9817b6e3ac2856d2cde31299129ec

$ curl http://localhost:8085
<!DOCTYPE html>
<html>
<head>
    <title>Hello Docker</title>
  <script type="module" crossorigin src="/assets/index-u2Cd2JyX.js"></script>
</head>
<body>
    <div id="root"></div>
</body>
</html>
```

`curl` only returns the empty shell because React renders into `<div id="root">` in the browser. The text is inside the JS bundle, which I checked:

```
$ curl -s http://localhost:8085/assets/index-u2Cd2JyX.js | grep -o 'Hello World[^"]*'
Hello World from Docker!
```

In a browser at http://localhost:8085 the page shows **Hello World from Docker!**

## 6. Nginx app (`nginx-app`)

```
$ docker build -t nginx-app ./nginx-app
#4 [1/2] FROM docker.io/library/nginx:latest
#6 [2/2] COPY index.html /usr/share/nginx/html/index.html
#7 naming to docker.io/library/nginx-app done

$ docker run -d --name hello-nginx -p 8082:80 nginx-app
819189398b3fa8c01becf60526aaf43726564d6e81818035e3e2aef072d49acd

$ curl http://localhost:8082
<!DOCTYPE html>
<html>
<head>
    <title>Hello Docker</title>
</head>
<body>
    <h1>Hello World from Nginx + Docker!</h1>
</body>
</html>
```

---

## Multi-stage build task

See [submission.md](submission.md) for the tasks 1-3 write up with the `docker ps` on port 8080.

The Dockerfile in `multi-stage-dockerfile/`:

```dockerfile
FROM node:24-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .

FROM node:24-alpine AS production
WORKDIR /app
COPY --from=builder /app/package*.json ./
RUN npm install --omit=dev
COPY --from=builder /app/server.js ./
EXPOSE 3000
CMD ["npm", "start"]
```

```
$ docker build -t multi-stage-build ./multi-stage-dockerfile
#12 [production 5/5] COPY --from=builder /app/server.js ./
#13 naming to docker.io/library/multi-stage-build done

$ docker run -d --name multi-stage -p 8080:3000 multi-stage-build
5ee5d2aea948e07249ae125d185010e8b92eebd0dc6426ec6165514a4b74dfb9

$ curl http://localhost:8080
<h1>Hello World from Docker Multi-Stage Build!</h1>
```

### Does multi-stage actually make the image smaller

I built a single-stage version of the same app to compare instead of just assuming:

```
$ docker images
multi-stage-build   172MB
single-stage-build  176MB
```

Only 4MB. Which is honest - this app is plain JS with nothing to compile, so the only thing the second stage drops is the dev dependencies.

The React app is where it actually shows. I built its build stage on its own to see:

```
$ docker build --target build -t react-buildstage ./React-app
$ docker images
react-buildstage  336MB     <- node + node_modules + source
react-app         162MB     <- nginx + the built dist/
```

**336MB down to 162MB.** Looking inside explains it:

```
$ docker run --rm react-buildstage sh -c 'du -sh /app/node_modules; ls /app'
40.5M   /app/node_modules
Dockerfile  dist  index.html  node_modules  package-lock.json  package.json  src  vite.config.js

$ docker run --rm react-app sh -c 'ls /usr/share/nginx/html; du -sh /usr/share/nginx/html'
50x.html  assets  index.html
156K    /usr/share/nginx/html
```

The final image contains **156KB** of static files and no Node.js at all. The compiler, the 40MB of node_modules and the source code all stayed behind in the build stage and never reach production.

So the rule I took from this: multi-stage pays off in proportion to how much of your build is *tooling*. A compiled or bundled app (React, Go, Java, TypeScript) gets a huge win, an interpreted app that ships its source gets a small one.

### Other things I picked up

- Each `FROM` starts a fresh stage. `AS <name>` labels it so `COPY --from=<name>` can reach back into it.
- Only the **last** stage becomes the image you get. Earlier stages are thrown away, which is why secrets used at build time still leak if you put them in the final stage but not if they only exist in an earlier one.
- `--target <stage>` builds and stops at a named stage, useful for debugging or for a dev image.
- Layer order matters for caching: copy dependency manifests and install first, copy source last.

---

## Cleanup

```
docker rm -f hello-node hello-python hello-java hello-apache hello-react hello-nginx multi-stage
```
