# Task 4: CoreDNS in Kubernetes

**Student:** Hitarth Jain  
**Enrollment:** 24BCS10399  

---

## 1. What is CoreDNS?
**CoreDNS** is a fast, flexible, plugin-driven DNS server that acts as the default internal cluster DNS provider in Kubernetes (replacing kube-dns since K8s 1.13).

It runs as a Deployment in the `kube-system` namespace, usually backed by 2 replicas:
```bash
$ kubectl get pods -n kube-system -l k8s-app=kube-dns
NAME                       READY   STATUS    RESTARTS   AGE
coredns-7db6d8ff4d-2qk8m   1/1     Running   0          42m
coredns-7db6d8ff4d-x7f4w   1/1     Running   0          42m
```

---

## 2. Why Kubernetes Uses CoreDNS
1. **Dynamic Service Discovery:** Watches the Kubernetes API server for Service and Endpoint lifecycle events and updates DNS records immediately without service restarts.
2. **Plugin Architecture:** CoreDNS behavior is customized using chained plugins (`kubernetes`, `errors`, `health`, `cache`, `forward`, `prometheus`).
3. **High Performance & Low Footprint:** Written in Go with minimal resource overhead.

---

## 3. CoreDNS Configuration (`Corefile`)

CoreDNS configuration is managed through a ConfigMap named `coredns` in `kube-system`:

```bash
$ kubectl get cm -n kube-system coredns -o yaml
```

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns
  namespace: kube-system
data:
  Corefile: |
    .:53 {
        errors
        health {
           lameduck 5s
        }
        ready
        kubernetes cluster.local in-addr.arpa ip6.arpa {
           pods insecure
           fallthrough in-addr.arpa ip6.arpa
           ttl 30
        }
        prometheus :9153
        forward . /etc/resolv.conf {
           max_concurrent 1000
        }
        cache 30
        loop
        reload
        loadbalance
    }
```

### Key Plugins Explained:
* `kubernetes`: Resolves cluster queries (`*.cluster.local`). Queries the API server for Pods and Services.
* `forward`: Forwards external internet DNS queries (e.g., `google.com`) to the upstream DNS resolvers specified in `/etc/resolv.conf`.
* `cache`: Caches responses for 30 seconds to reduce query latency.
* `loadbalance`: Acts as a round-robin DNS load balancer across multiple records.

---

## 4. Troubleshooting DNS in Kubernetes

### Step 1: Deploy a DNS test container
```bash
$ kubectl run dnsutils --image=tutum/dnsutils --command -- sleep 3600
pod/dnsutils created
```

### Step 2: Test internal lookup
```bash
$ kubectl exec -i -t dnsutils -- nslookup backend-clusterip-svc.default.svc.cluster.local
Server:         10.96.0.10
Address:        10.96.0.10#53

Name:   backend-clusterip-svc.default.svc.cluster.local
Address: 10.105.120.44
```

### Step 3: Check CoreDNS logs
```bash
$ kubectl logs -n kube-system -l k8s-app=kube-dns --tail=50
```

### Step 4: Verify kube-dns Service ClusterIP
```bash
$ kubectl get svc -n kube-system kube-dns
NAME       TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)                  AGE
kube-dns   ClusterIP   10.96.0.10   <none>        53/UDP,53/TCP,9153/TCP   45m
```
If `kube-dns` is missing endpoints or its ClusterIP differs from `/etc/resolv.conf`, Pods will fail to resolve DNS names.
