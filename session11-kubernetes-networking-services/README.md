# Session 11 - Kubernetes Networking & Services

**Student:** Hitarth Jain  
**Enrollment:** 24BCS10399  
**OS:** Kali Linux (Kubernetes v1.30.0 / Minikube)

---

## Task 1: The 5 Kubernetes Service Types

A Service provides a persistent IP and DNS entry for a dynamic, ephemeral group of Pods.

### 1. ClusterIP (Default)
Exposes the Service on an internal IP in the cluster. Only reachable from within the cluster.

```bash
$ kubectl apply -f services/01-clusterip.yaml
deployment.apps/backend-clusterip-demo created
service/backend-clusterip-svc created

$ kubectl get svc backend-clusterip-svc
NAME                    TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
backend-clusterip-svc   ClusterIP   10.105.120.44    <none>        80/TCP    24s

$ kubectl run curl-test --image=curlimages/curl --rm -it --restart=Never -- curl -s http://backend-clusterip-svc
<!DOCTYPE html>
<html>
<head><title>Welcome to nginx!</title></head>
...
```

---

### 2. NodePort
Exposes the Service on each Node's IP at a static port (between 30000–32767). Enables external access without an external cloud load balancer.

```bash
$ kubectl apply -f services/02-nodeport.yaml
deployment.apps/web-nodeport-demo created
service/web-nodeport-svc created

$ kubectl get svc web-nodeport-svc
NAME               TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
web-nodeport-svc   NodePort   10.108.90.150   <none>        80:31080/TCP   15s

$ curl -s http://$(minikube ip):31080 | grep "Welcome to nginx"
<title>Welcome to nginx!</title>
```

---

### 3. LoadBalancer
Provisions an external load balancer in supported cloud providers (AWS ALB/NLB, GCP, Azure). On Minikube, simulated via `minikube tunnel`.

```bash
$ kubectl apply -f services/03-loadbalancer.yaml
deployment.apps/api-lb-demo created
service/api-lb-svc created

$ kubectl get svc api-lb-svc
NAME         TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)        AGE
api-lb-svc   LoadBalancer   10.100.45.210   192.168.49.10   80:32456/TCP   30s

$ curl -s http://192.168.49.10 | grep "Welcome to nginx"
<title>Welcome to nginx!</title>
```

---

### 4. ExternalName
Maps the Service to an external DNS name via a `CNAME` record without any proxying or Pod selectors.

```bash
$ kubectl apply -f services/04-externalname.yaml
service/external-database-svc created

$ kubectl get svc external-database-svc
NAME                    TYPE           CLUSTER-IP   EXTERNAL-IP                           PORT(S)   AGE
external-database-svc   ExternalName   <none>       my-db.us-east-1.rds.amazonaws.com     <none>    18s
```

---

### 5. Headless Service (`clusterIP: None`)
Allocates no ClusterIP. DNS queries for the service name return individual A records for all matching Pods directly. Indispensable for StatefulSets (databases, Kafka, Redis) requiring direct peer-to-peer addressing.

```bash
$ kubectl apply -f services/05-headless.yaml
statefulset.apps/stateful-redis created
service/redis-headless-svc created

$ kubectl get svc redis-headless-svc
NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)    AGE
redis-headless-svc   ClusterIP   None         <none>        6379/TCP   20s

# DNS resolution test:
$ kubectl exec -it stateful-redis-0 -- nslookup redis-headless-svc
Server:         10.96.0.10
Address:        10.96.0.10#53

Name:   redis-headless-svc.default.svc.cluster.local
Address: 10.244.0.22
Name:   redis-headless-svc.default.svc.cluster.local
Address: 10.244.0.23
```

---

## Task 2: Kubernetes Object Comparisons

### A. Deployment vs ReplicaSet
* **ReplicaSet:** Low-level controller ensuring exact number of Pod replicas are running at any moment using label selectors. Does not provide declarative rollout strategies.
* **Deployment:** Higher-level declarative controller managing ReplicaSets underneath. Adds rolling updates, rollbacks (`kubectl rollout undo`), pause/resume, and revision history.

$$\text{Deployment} \longrightarrow \text{ReplicaSet} \longrightarrow \text{Pods}$$

---

### B. Deployment vs DaemonSet vs StatefulSet

| Dimension | Deployment | DaemonSet | StatefulSet |
|---|---|---|---|
| **Pod Creation** | Random, non-sequential names (`app-6b8f-x9l2`) | Exactly one per matching Node | Stable, ordered ordinal names (`db-0, db-1`) |
| **Scaling** | Dynamic up/down across cluster | Automatically scales with node count | Predictable, ordered scaling (0 -> 1 -> 2) |
| **Storage** | Shared or ephemeral storage | HostPath / local node storage | Dedicated PersistentVolume per replica via `volumeClaimTemplates` |
| **Network** | Ephemeral Pod IPs behind ClusterIP | Host network or node port | Predictable DNS (`$(pod-name).$(service-name)`) |
| **Primary Use Cases**| Stateless APIs, Web Frontends | Monitoring (Fluentd, Prometheus Node Exporter), CNI plugins | Databases (PostgreSQL, MongoDB), ZooKeeper, Kafka |

---

### C. ReplicaSet vs Service
* **ReplicaSet:** Controls **quantity and lifecycle** (creates/deletes Pods to maintain desired replica count).
* **Service:** Controls **reachability and traffic routing** (provides a static IP/DNS and load-balances L4 traffic across live endpoints).

---

## Sub-Tasks
* Detailed FQDN Documentation: [fqdn/README.md](fqdn/README.md)
* CoreDNS & Troubleshooting Documentation: [coredns/README.md](coredns/README.md)
