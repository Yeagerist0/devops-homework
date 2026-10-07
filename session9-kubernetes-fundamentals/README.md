# Session 9 - Kubernetes Fundamentals

**Student:** Hitarth Jain  
**Enrollment:** 24BCS10399  
**OS:** Kali Linux (Docker runtime / Minikube v1.33.0 / Kubernetes v1.30.0)

---

## 1. Minikube Installation & Cluster Setup

### Starting Minikube with Docker driver
```bash
$ minikube start --driver=docker --cpus=2 --memory=2048
* minikube v1.33.0 on Debian kali-rolling
* Using the docker driver based on user configuration
* Starting control plane node minikube in cluster minikube
* Pulling base image ...
* Downloading Kubernetes v1.30.0 preload ...
* Creating docker container (CPUs=2, Memory=2048MB, Disk=20000MB) ...
* Preparing Kubernetes v1.30.0 on Docker 26.1.1 ...
  - Generating certificates and keys ...
  - Booting up control plane ...
  - Configuring RBAC rules ...
* Configuring cluster permissions ...
* Verifying Kubernetes components...
  - Using image gcr.io/k8s-minikube/storage-provisioner:v5
* Enabled addons: storage-provisioner, default-storageclass
* Done! kubectl is now configured to use "minikube" cluster and "default" namespace.
```

### Verifying Cluster Status
```bash
$ kubectl cluster-info
Kubernetes control plane is running at https://192.168.49.2:8443
CoreDNS is running at https://192.168.49.2:8443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

$ kubectl get nodes -o wide
NAME       STATUS   ROLES           AGE   VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION   CONTAINER-RUNTIME
minikube   Ready    control-plane   3m    v1.30.0   192.168.49.2   <none>        Ubuntu 22.04.4 LTS   6.8.11-amd64     docker://26.1.1

$ kubectl get componentstatuses
Warning: v1 ComponentStatus is deprecated in v1.19+
NAME                 STATUS    MESSAGE   ERROR
controller-manager   Healthy   ok        
scheduler            Healthy   ok        
etcd-0               Healthy   ok        
```

---

## 2. Kubernetes Architecture Deep Dive

A Kubernetes cluster consists of two main planes:

```
+---------------------------------------------------------------+
|                      CONTROL PLANE                            |
|                                                               |
|  [ API Server (kube-apiserver) ] <==== REST API Gateway       |
|          |                |                                   |
|  [ kube-scheduler ]  [ Controller Manager ]                    |
|          |                |                                   |
|          +--------+-------+                                   |
|                   |                                           |
|             [ etcd Store ] (Key-Value, Raft Consensus)       |
+-------------------+-------------------------------------------+
                    | (TLS communication)
+-------------------+-------------------------------------------+
|                   v                                           |
|                 WORKER NODE(S)                                |
|                                                               |
|  [ kubelet ] <--- Node agent, communicates with API server   |
|  [ kube-proxy ] <--- Network proxy & iptables/IPVS rules      |
|  [ Container Runtime (containerd / CRI-O / Docker) ]          |
|                                                               |
|       +-------------------+    +-------------------+          |
|       | Pod A (App + Env) |    | Pod B (Sidecar)   |          |
|       +-------------------+    +-------------------+          |
+---------------------------------------------------------------+
```

### Control Plane Components
1. **kube-apiserver:** The front door of Kubernetes. Exposes the Kubernetes API, handles authentication, authorization (RBAC), admission control, and writes cluster state to `etcd`.
2. **etcd:** Distributed, consistent key-value store acting as the single source of truth for all cluster configuration and state.
3. **kube-scheduler:** Watches for newly created Pods without assigned nodes, selects the most suitable worker node based on resource requests, taints/tolerations, affinity, and topology.
4. **kube-controller-manager:** Runs core reconciliation control loops (Node Controller, Replication Controller, Endpoints Controller, ServiceAccount Controller).
5. **cloud-controller-manager:** Integrates cloud provider-specific APIs (Load Balancers, Storage volumes, Routes).

### Worker Node Components
1. **kubelet:** The node agent. Ensures containers described in PodSpecs are running and healthy. Reports node status to the API server.
2. **kube-proxy:** Maintains network rules on nodes (iptables/IPVS) enabling communication to Pods from internal or external networks.
3. **Container Runtime:** Software responsible for running containers (CRI compliant, e.g., containerd, CRI-O).

---

## 3. Kubernetes Basics Hands-on

### Creating First Pod (Imperative & Declarative)

```bash
$ kubectl run test-pod --image=nginx:alpine --port=80
pod/test-pod created

$ kubectl get pods
NAME       READY   STATUS    RESTARTS   AGE
test-pod   1/1     Running   0          14s

$ kubectl describe pod test-pod
Name:             test-pod
Namespace:        default
Priority:         0
Service Account:  default
Node:             minikube/192.168.49.2
Start Time:       Wed, 07 Oct 2026 20:41:00 +0530
Labels:           run=test-pod
Status:           Running
IP:               10.244.0.5
Containers:
  test-pod:
    Container ID:   docker://7f8e3b4a2d1
    Image:          nginx:alpine
    Image ID:       docker-pullable://nginx@sha256:a6eb2...
    Port:           80/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Wed, 07 Oct 2026 20:41:02 +0530
    Ready:          True
    Restart Count:  0
Conditions:
  Type                        Status
  PodReadyToStartContainers   True 
  Initialized                 True 
  Ready                       True 
  ContainersReady             True 
  PodScheduled                True 

$ kubectl delete pod test-pod
pod "test-pod" deleted
```

### Applying Manifests from `manifests/`

```bash
$ kubectl apply -f manifests/01-first-pod.yaml
pod/devops-first-pod created

$ kubectl apply -f manifests/02-nginx-deployment.yaml
deployment.apps/basic-nginx-deploy created

$ kubectl get pods -l session=09
NAME                                  READY   STATUS    RESTARTS   AGE
basic-nginx-deploy-697ffc64dc-d8m2x   1/1     Running   0          22s
basic-nginx-deploy-697ffc64dc-q8w7l   1/1     Running   0          22s
devops-first-pod                      1/1     Running   0          35s

$ kubectl logs devops-first-pod
/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
/docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
...
2026/10/07 15:11:05 [notice] 1#1: start worker processes
```
