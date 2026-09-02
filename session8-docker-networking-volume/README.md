# Session 8 - Docker Networking & Volumes Homework

All four tasks below were actually run on my machine, the blocks are real terminal output pasted as is.
`reproduce.sh` in this folder runs the whole thing end to end if you want to see it live.

Resources:
- https://docs.docker.com/engine/network/drivers/

---

## Task 1: Docker Container Networking

Three containers, three user defined bridge networks, and the backend sits on two of them.

### Layout i went with

| container | image | networks |
|---|---|---|
| frontend | nginx:alpine | frontend-net |
| backend  | alpine:3.20  | frontend-net **+** backend-net |
| database | mysql:8.0    | backend-net + db-net |

The point of this layout is that backend is the only container that can talk to both sides. frontend has no route to database at all, which is exactly how you'd want a real app segmented.

### Creating the networks

```
$ docker network create frontend-net
f77967347dc020382dc20e78bd71fd40831f074b96464b53177ecf5e03decd56
$ docker network create backend-net
812d85af6a228bb7a16b029bc6a4a1dc396894ffba12aadc230142e9f7921a82
$ docker network create db-net
5339ea349a8ecbabd24a9024f3d31c18e14536f8cc9b26c651f0240531ace885

$ docker network ls
NETWORK ID     NAME           DRIVER    SCOPE
812d85af6a22   backend-net    bridge    local
5339ea349a8e   db-net         bridge    local
f77967347dc0   frontend-net   bridge    local
```

Each one got its own subnet automatically:

```
frontend-net: 172.23.0.0/16 gw=172.23.0.1
backend-net:  172.24.0.0/16 gw=172.24.0.1
db-net:       172.25.0.0/16 gw=172.25.0.1
```

### Starting the containers

```
$ docker run -d --name frontend --network frontend-net nginx:alpine
$ docker run -d --name backend  --network frontend-net alpine:3.20 sleep infinity
$ docker network connect backend-net backend          # <- backend's 2nd network
$ docker run -d --name database --network backend-net -e MYSQL_ROOT_PASSWORD=root mysql:8.0
$ docker network connect db-net database
```

`--network` on `docker run` only takes one network, so the second one is attached afterwards with `docker network connect`. That command works on a running container, no restart needed.

```
$ docker ps
NAMES        IMAGE          STATUS         PORTS
database     mysql:8.0      Up 1 minute    3306/tcp, 33060/tcp
backend      alpine:3.20    Up 1 minute
frontend     nginx:alpine   Up 1 minute    80/tcp
```

### Who is on which network

```
$ docker inspect backend -f '{{range $k,$v := .NetworkSettings.Networks}}{{$k}} -> {{$v.IPAddress}}{{"\n"}}{{end}}'
backend-net  -> 172.24.0.2
frontend-net -> 172.23.0.3

$ docker inspect frontend -f '...'
frontend-net -> 172.23.0.2

$ docker inspect database -f '...'
backend-net -> 172.24.0.3
db-net      -> 172.25.0.2
```

Being on two networks literally means two network cards inside the container:

```
$ docker exec backend ip addr show
1: lo:   inet 127.0.0.1/8
2: eth0@if18: inet 172.23.0.3/16      <- frontend-net
3: eth1@if19: inet 172.24.0.2/16      <- backend-net
```

### Connectivity tests

**backend -> frontend** (both on frontend-net) - works:

```
$ docker exec backend ping -c 3 frontend
PING frontend (172.23.0.2): 56 data bytes
64 bytes from 172.23.0.2: seq=0 ttl=64 time=0.122 ms
64 bytes from 172.23.0.2: seq=1 ttl=64 time=0.168 ms
64 bytes from 172.23.0.2: seq=2 ttl=64 time=0.172 ms
3 packets transmitted, 3 packets received, 0% packet loss
```

**backend -> database** (both on backend-net) - works, and the mysql port is actually open:

```
$ docker exec backend ping -c 3 database
PING database (172.24.0.3): 56 data bytes
64 bytes from 172.24.0.3: seq=0 ttl=64 time=0.040 ms
3 packets transmitted, 3 packets received, 0% packet loss

$ docker exec backend nc -zv -w 3 database 3306
database (172.24.0.3:3306) open
```

**backend -> frontend over HTTP** - works:

```
$ docker exec backend wget -qO- http://frontend
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
```

**frontend -> database** (no shared network) - fails, which is the whole point:

```
$ docker exec frontend ping -c 2 database
ping: bad address 'database'
```

Notice it fails at DNS, not at routing. Docker's embedded DNS only resolves names for containers that share a network with you, so `database` doesn't even exist as a name from frontend's point of view.

### What i understood

- The default `bridge` network does **not** give you DNS. You only get container-name resolution on **user defined** networks, which is why you basically always create your own.
- That DNS lives at `127.0.0.11` inside every container:
  ```
  $ docker exec backend cat /etc/resolv.conf
  nameserver 127.0.0.11
  options ndots:0
  ```
  It resolves container names locally and forwards everything else to the host's real resolvers.
- A network is a security boundary, not just plumbing. frontend can't reach the database because it was never attached to a network the database is on, no firewall rule needed.
- `docker network connect` / `disconnect` work live, so you can add a container to a network without downtime.

---

## Task 2: Host Network

```
$ ss -tuln | grep -w ':80'
(nothing listening on :80)

$ docker run -d --name apache-host --network host httpd:alpine
5213c1332a0c410b6d50e5063f30229d60de5397ec76ed8cf7206ca3657ece39
```

The `docker ps` output is the interesting part - the PORTS column is **empty**:

```
$ docker ps
NAMES         IMAGE          STATUS         PORTS
apache-host   httpd:alpine   Up 1 minute
```

No `-p` was used and there is no port mapping, because with `--network host` there is nothing to map. The container is using the host's network stack directly:

```
$ docker inspect apache-host -f 'NetworkMode={{.HostConfig.NetworkMode}}  IPAddress="{{.NetworkSettings.IPAddress}}"'
NetworkMode=host  IPAddress=""
```

The container has no IP of its own. And apache is now listening on the host's port 80:

```
$ ss -tuln | grep -w ':80'
tcp   LISTEN 0      511                *:80               *:*
```

### Accessing it on port 80

```
$ curl http://localhost:80
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
<title>It works! Apache httpd</title>
</head>
<body>
<p>It works!</p>
</body>
</html>

$ curl -I http://localhost:80
HTTP/1.1 200 OK
Date: Wed, 02 Sep 2026 04:47:25 GMT
Server: Apache/2.4.68 (Unix)

$ curl http://100.129.173.211:80        # host's own LAN IP, works too
<p>It works!</p>
```

**Browser at http://localhost:80 - Apache reached with no port mapping at all:**

![apache on the host network, port 80](outputs/host-network-apache-port80.jpg)


### bridge vs host

|  | bridge (default) | host |
|---|---|---|
| container IP | own IP, e.g. 172.23.0.2 | none, uses the host's |
| reaching it | needs `-p 8080:80` | already on the host's port |
| port conflicts | no, each container isolated | yes, only one thing can own :80 |
| DNS by container name | yes on user defined networks | no |
| speed | small NAT overhead | no NAT at all |

Host networking is faster and simpler but you lose isolation completely, and two containers both wanting port 80 will collide. It's Linux only, on Mac/Windows docker runs inside a VM so "host" means the VM, not your laptop.

---

## Task 3: Bind Mount

### The folder on my machine

```
$ mkdir -p bind-mount/html
$ cat bind-mount/html/index.html
<!DOCTYPE html>
<html>
<head><title>Bind Mount Demo</title></head>
<body>
  <h1>Hello students</h1>
</body>
</html>
```

### Mounting it into nginx

```
$ docker run -d --name bind-nginx -p 8081:80 \
    -v "$PWD/bind-mount/html":/usr/share/nginx/html:ro \
    nginx:alpine
f781faffb048bdc07fdb8e8437aff75a5e7cc31add00c3a63de59de685959930

$ docker inspect bind-nginx -f '{{range .Mounts}}Type={{.Type}} Source={{.Source}} Destination={{.Destination}} RW={{.RW}}{{end}}'
Type=bind Source=/home/.../session8-docker-networking-volume/bind-mount/html Destination=/usr/share/nginx/html RW=false
```

`Type=bind` confirms it's a bind mount and not a named volume. The `:ro` makes it read only from the container's side.

### Before the edit

```
$ curl http://localhost:8081
<!DOCTYPE html>
<html>
<head><title>Bind Mount Demo</title></head>
<body>
  <h1>Hello students</h1>
</body>
</html>
```

### Editing the file on the host while the container keeps running

I only changed `bind-mount/html/index.html` with an editor. No `docker restart`, no rebuild, no `docker cp`.

```
$ curl http://localhost:8081
<!DOCTYPE html>
<html>
<head><title>Bind Mount Demo</title></head>
<body>
  <h1>Hello students</h1>
  <p>This line was added on the host AFTER the container was already running.</p>
  <p>No docker restart, no rebuild. Just saved the file.</p>
</body>
</html>
```

**Browser at http://localhost:8081 after editing the file on the host:**

![bind mount reflecting the live edit](outputs/bind-mount-after-live-edit.jpg)


Proof the container was never restarted - `StartedAt` is the same timestamp as when it was created and the restart counter is still 0:

```
$ docker inspect bind-nginx -f 'StartedAt={{.State.StartedAt}}  RestartCount={{.RestartCount}}'
StartedAt=2026-09-02T04:47:36.002944621Z  RestartCount=0

$ docker ps
NAMES        STATUS          PORTS
bind-nginx   Up 18 seconds   0.0.0.0:8081->80/tcp
```

The `:ro` flag doing its job:

```
$ docker exec bind-nginx sh -c 'echo hacked > /usr/share/nginx/html/index.html'
sh: can't create /usr/share/nginx/html/index.html: Read-only file system
```

### What i understood

The change shows up instantly because a bind mount isn't a copy. The kernel is mounting that host directory straight into the container's filesystem tree, so the container and my editor are reading the exact same inode. Anything that copies files in (`COPY` in a Dockerfile, `docker cp`) would need a rebuild or restart.

**Bind mount vs named volume:**

| | bind mount (`-v /host/path:/in/container`) | named volume (`-v mydata:/in/container`) |
|---|---|---|
| where the data lives | a path i choose on the host | docker managed, under `/var/lib/docker/volumes` |
| main use | live source code / config during development | databases and real persistent data |
| portable | no, depends on that path existing | yes, docker creates it anywhere |
| host can edit it easily | yes, its just a normal folder | not really |

So: bind mount for dev so you can edit live, named volume for the mysql data directory.

---

## Task 4: Overlay Network

No demo for this one since an overlay only makes sense across more than one docker host and i have a single machine, so this part is written up from the docs and the driver comparison.

### What it is

A bridge network is `local` scope, it exists on one docker host and containers on a different machine can't join it. An overlay network is `swarm` scope, it spans **multiple docker hosts** and makes containers on different physical machines behave like they're on one flat LAN, same subnet, same container name DNS.

### How it works

1. The hosts join a swarm (`docker swarm init` on the first, `docker swarm join` on the rest). The managers keep the network state in a shared store and gossip it around.
2. When a container on host A sends a packet to a container on host B, docker wraps the whole layer 2 frame inside a **VXLAN** UDP packet (port 4789) and sends it over the normal physical network to host B.
3. Host B unwraps it and hands the original frame to the target container.

That wrapping is the "overlay" part - a virtual layer 2 network drawn on top of whatever real layer 3 network the machines already share. The containers have no idea, they just see a normal ethernet neighbour.

Docker keeps a distributed record of container name -> IP -> which host, so `ping backend` still works even when backend is running on a different machine. VXLAN traffic can be encrypted with `--opt encrypted`.

```
docker network create -d overlay --attachable my-overlay
```

### Where you'd use it

- Multi host swarm deployments where a service's replicas are spread across nodes.
- Rolling out a service that scales beyond one machine but should stay one logical network.
- Keeping tenants/apps separated across a cluster - one overlay per app.

### Driver comparison

| driver | scope | what it's for |
|---|---|---|
| bridge | single host | the normal case, containers on one machine |
| host | single host | share the host's stack, no isolation, no NAT |
| overlay | multi host | swarm, containers across several machines |
| macvlan | single host | container gets a real MAC/IP on the physical LAN |
| none | - | no networking at all |

Kubernetes solves the same problem but with CNI plugins (Calico, Flannel) instead of docker's overlay driver. The idea is identical - every pod/container gets an address on one virtual network no matter which node it landed on.

---

## Cleanup

```
docker rm -f frontend backend database apache-host bind-nginx
docker network rm frontend-net backend-net db-net
```
