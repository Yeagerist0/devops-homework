#!/usr/bin/env bash
# Session 8 homework - runs all 4 tasks end to end.
# Usage: ./reproduce.sh          run everything
#        ./reproduce.sh clean    tear it all down
set -u
cd "$(dirname "$0")"

hr() { echo; echo "=============== $* ==============="; }

clean() {
  docker rm -f frontend backend database apache-host bind-nginx 2>/dev/null
  docker network rm frontend-net backend-net db-net 2>/dev/null
  echo "cleaned up"
}

if [ "${1:-}" = "clean" ]; then clean; exit 0; fi

clean >/dev/null 2>&1

hr "TASK 1: three networks, three containers"
docker network create frontend-net
docker network create backend-net
docker network create db-net
docker network ls | grep -E 'NETWORK|frontend-net|backend-net|db-net'

docker run -d --name frontend --network frontend-net nginx:alpine
docker run -d --name backend  --network frontend-net alpine:3.20 sleep infinity
docker network connect backend-net backend          # backend's second network
docker run -d --name database --network backend-net -e MYSQL_ROOT_PASSWORD=root mysql:8.0
docker network connect db-net database
docker ps --filter name=frontend --filter name=backend --filter name=database \
  --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}'

hr "backend is on TWO networks"
docker inspect backend -f '{{range $k,$v := .NetworkSettings.Networks}}{{$k}} -> {{$v.IPAddress}}{{"\n"}}{{end}}'
docker exec backend ip addr show | grep -E '^[0-9]+:|inet '

hr "TEST: backend -> frontend (shared network, should PASS)"
docker exec backend ping -c 3 frontend

hr "TEST: backend -> database (shared network, should PASS)"
# </dev/null so the wait loop does not swallow (and echo) terminal keystrokes
docker exec backend sh -c 'for i in $(seq 20); do nc -z -w 2 database 3306 && break; sleep 3; done' </dev/null
docker exec backend ping -c 3 database
docker exec backend nc -zv -w 3 database 3306

hr "TEST: backend -> frontend over HTTP"
docker exec backend wget -qO- http://frontend | head -5

hr "TEST: frontend -> database (NO shared network, should FAIL)"
docker exec frontend ping -c 2 -W 2 database || echo "[expected] no shared network, name does not even resolve"

hr "TASK 2: apache on the host network, port 80"
echo "port 80 before:"; ss -tuln | grep -w ':80' || echo "  nothing listening"
docker run -d --name apache-host --network host httpd:alpine
docker ps --filter name=apache-host --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}'
docker inspect apache-host -f 'NetworkMode={{.HostConfig.NetworkMode}}  IPAddress="{{.NetworkSettings.IPAddress}}"'
echo "port 80 after:"; ss -tuln | grep -w ':80'
echo "curl http://localhost:80 ->"; curl -s http://localhost:80

hr "TASK 3: bind mount"
mkdir -p bind-mount/html
cat > bind-mount/html/index.html <<'HTML'
<!DOCTYPE html>
<html>
<head><title>Bind Mount Demo</title></head>
<body>
  <h1>Hello students</h1>
</body>
</html>
HTML
docker run -d --name bind-nginx -p 8081:80 -v "$PWD/bind-mount/html":/usr/share/nginx/html:ro nginx:alpine
docker inspect bind-nginx -f '{{range .Mounts}}Type={{.Type}} Source={{.Source}} Destination={{.Destination}} RW={{.RW}}{{end}}'
for i in 1 2 3 4 5; do [ -n "$(curl -s http://localhost:8081)" ] && break; docker exec bind-nginx sleep 1 </dev/null; done
echo "--- BEFORE edit ---"; curl -s http://localhost:8081

cat > bind-mount/html/index.html <<'HTML'
<!DOCTYPE html>
<html>
<head><title>Bind Mount Demo</title></head>
<body>
  <h1>Hello students</h1>
  <p>This line was added on the host AFTER the container was already running.</p>
  <p>No docker restart, no rebuild. Just saved the file.</p>
</body>
</html>
HTML
echo "--- AFTER edit, container NOT restarted ---"; curl -s http://localhost:8081
docker inspect bind-nginx -f 'StartedAt={{.State.StartedAt}}  RestartCount={{.RestartCount}}'
echo "--- :ro means the container cannot write back ---"
docker exec bind-nginx sh -c 'echo hacked > /usr/share/nginx/html/index.html' || echo "[expected] read-only"

hr "TASK 4: overlay - see README.md (needs 2+ docker hosts, no demo on a single machine)"

hr "DONE - run './reproduce.sh clean' to tear it down"
