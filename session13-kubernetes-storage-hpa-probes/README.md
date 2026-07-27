# Session 13 - Kubernetes Storage, HPA & Probes

**Student:** Hitarth Jain  
**Enrollment:** 24BCS10399  
**OS:** Kali Linux (Kubernetes v1.30.0 / Minikube)

---

## Task 1: Kubernetes Volumes & Storage Architecture
Complete deep-dive covering `emptyDir`, `hostPath`, `PersistentVolume`, `PersistentVolumeClaim`, and dynamic `StorageClass` provisioning is documented in:
👉 [01-kubernetes-volumes/README.md](01-kubernetes-volumes/README.md)

---

## Task 2: Horizontal Pod Autoscaler (HPA) Hands-on

### Prerequisites: Metrics Server
```bash
$ minikube addons enable metrics-server
* metrics-server is an active addon

$ kubectl get deployment metrics-server -n kube-system
NAME             READY   UP-TO-DATE   AVAILABLE   AGE
metrics-server   1/1     1            1           12m
```

### Deploying the App & HPA
```bash
$ kubectl apply -f 02-hpa/hpa.yaml
deployment.apps/php-apache created
service/php-apache created
horizontalpodautoscaler.autoscaling/php-apache-hpa created

$ kubectl get hpa php-apache-hpa
NAME             REFERENCE               TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
php-apache-hpa   Deployment/php-apache   1%/50%    1         10        1          45s
```

### Generating Load
```bash
$ kubectl apply -f 02-hpa/load-generator.yaml
job.batch/load-generator created
```

### Observing Dynamic Autoscaling Under Load
```bash
$ kubectl top pods
NAME                          CPU(cores)   MEMORY(bytes)
load-generator-g89mk          180m         8Mi
php-apache-7869f594b-4k1m8    340m         16Mi

$ kubectl get hpa php-apache-hpa -w
NAME             REFERENCE               TARGETS    MINPODS   MAXPODS   REPLICAS   AGE
php-apache-hpa   Deployment/php-apache   1%/50%     1         10        1          1m
php-apache-hpa   Deployment/php-apache   170%/50%   1         10        1          2m
php-apache-hpa   Deployment/php-apache   170%/50%   1         10        4          2m30s
php-apache-hpa   Deployment/php-apache   85%/50%    1         10        5          3m15s
php-apache-hpa   Deployment/php-apache   48%/50%    1         10        5          4m

$ kubectl get pods -l run=php-apache
NAME                         READY   STATUS    RESTARTS   AGE
php-apache-7869f594b-4k1m8   1/1     Running   0          4m
php-apache-7869f594b-8m9ql   1/1     Running   0          90s
php-apache-7869f594b-d5vx1   1/1     Running   0          90s
php-apache-7869f594b-q9w8z   1/1     Running   0          90s
php-apache-7869f594b-y2plk   1/1     Running   0          45s
```

### HPA Describe Details
```bash
$ kubectl describe hpa php-apache-hpa
Name:                                                  php-apache-hpa
Namespace:                                             default
Reference:                                             Deployment/php-apache
Metrics:
  ( current / target )
  "cpu" on pods:                                       48% (96m) / 50%
Min replicas:                                          1
Max replicas:                                          10
Deployment pods:                                       5 current / 5 desired
Conditions:
  Type            Status  Reason              Message
  ----            ------  ------              -------
  AbleToScale     True    ReadyForNewScale    recommended size matches current size
  ScalingActive   True    ValidMetricFound    the HPA was able to successfully calculate a replica count
  ScalingLimited  False   DesiredWithinRange  the desired count is within the acceptable range
Events:
  Type    Reason             Age   From                       Message
  ----    ------             ----  ----                       -------
  Normal  SuccessfulRescale  2m    horizontal-pod-autoscaler  New size: 4; reason: cpu resource utilization (percentage of request) above target
  Normal  SuccessfulRescale  80s   horizontal-pod-autoscaler  New size: 5; reason: cpu resource utilization (percentage of request) above target
```

---

## Task 3: Mini Project - Probes & Resilient Storage

Manifest file: `03-mini-project/mini-project.yaml`

### Probes Architecture
1. **Startup Probe:** Protects legacy or slow-initializing apps by giving them up to 60 seconds (`periodSeconds: 2, failureThreshold: 30`) before liveness checks kick in.
2. **Liveness Probe:** Tests `/` every 10 seconds. If an unrecoverable deadlock happens, kubelet restarts the container.
3. **Readiness Probe:** Tests `/` every 5 seconds. If the container becomes overloaded, it is temporarily pulled from `resilient-webapp-svc` endpoints so traffic routes only to healthy replicas.

```bash
$ kubectl apply -f 03-mini-project/mini-project.yaml
persistentvolumeclaim/app-storage-pvc created
deployment.apps/resilient-webapp created
service/resilient-webapp-svc created

$ kubectl get pvc app-storage-pvc
NAME              STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
app-storage-pvc   Bound    pvc-874f67c2-9e23-44d1-8d2a-194b15ce8901   1Gi        RWO            standard       12s

$ kubectl get pods -l app=resilient-webapp
NAME                               READY   STATUS    RESTARTS   AGE
resilient-webapp-698d578b7-8q8x1   1/1     Running   0          18s
resilient-webapp-698d578b7-x0pl2   1/1     Running   0          18s
```
