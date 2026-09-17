# Docker Hello World Applications

Each folder is independently buildable and serves a Hello World page:

```bash
docker build -t devops-node ./nodejs-app
docker run --rm -p 3000:3000 devops-node
```

Repeat with the other folders and their documented ports. Verify each with
`curl http://localhost:<port>` or a browser.

| Folder | Image | Port |
| --- | --- | --- |
| `nodejs-app` | Node.js HTTP server | 3000 |
| `python-app` | Python standard-library server | 8000 |
| `java-app` | Java `HttpServer` | 8080 |
| `apache-app` | Apache httpd | 80 |
| `react-app` | React static build served by Nginx | 80 |
| `nginx-app` | Nginx static site | 80 |

Stop a foreground container with `Ctrl+C`, or use `docker rm -f <name>`.
