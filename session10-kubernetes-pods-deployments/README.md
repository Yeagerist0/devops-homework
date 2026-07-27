# Session 10 - Kubernetes Pods, ReplicaSets & Deployments

**Student:** Hitarth Jain  
**Enrollment:** 24BCS10399  
**OS:** Kali Linux (Kubernetes v1.30.0 / Minikube)

---

## Task 1: Deployment Strategies

Kubernetes supports multiple deployment patterns to balance zero-downtime, risk management, and resource consumption.

### 01. Rolling Update
The default Kubernetes strategy. Pods are updated incrementally with fine-tuned `maxSurge` (how many extra pods can exist) and `maxUnavailable` (how many pods can be offline during rollout).

```bash
$ kubectl apply -f 01-deployment-strategies/01-rolling-update/deployment.yaml
deployment.apps/rolling-update-app created
service/rolling-update-svc created

$ kubectl get pods -l app=rolling-app
NAME                                  READY   STATUS    RESTARTS   AGE
rolling-update-app-79d868979b-2h4j1   1/1     Running   0          18s
rolling-update-app-79d868979b-5v9p2   1/1     Running   0          18s
rolling-update-app-79d868979b-9x2mk   1/1     Running   0          18s
rolling-update-app-79d868979b-lq4nm   1/1     Running   0          18s

# Trigger rolling update
$ kubectl set image deployment/rolling-update-app web=nginx:1.25-alpine --record
deployment.apps/rolling-update-app image updated

# Watch rollout status in real time
$ kubectl rollout status deployment/rolling-update-app
Waiting for deployment "rolling-update-app" rollout to finish: 1 out of 4 new replicas have been updated...
Waiting for deployment "rolling-update-app" rollout to finish: 2 out of 4 new replicas have been updated...
Waiting for deployment "rolling-update-app" rollout to finish: 3 out of 4 new replicas have been updated...
Waiting for deployment "rolling-update-app" rollout to finish: 1 old replicas are pending termination...
deployment "rolling-update-app" successfully rolled out

$ kubectl rollout history deployment/rolling-update-app
REVISION  CHANGE-CAUSE
1         <none>
2         kubectl set image deployment/rolling-update-app web=nginx:1.25-alpine --record=true
```

---

### 02. Blue-Green Deployment
Both environments run simultaneously. Traffic cutover is instant by flipping the `version` selector on the routing Service.

```bash
$ kubectl apply -f 01-deployment-strategies/02-blue-green/blue-green-deployments.yaml
deployment.apps/app-blue created
deployment.apps/app-green created
service/app-router-svc created

# Verify service points to BLUE
$ kubectl describe svc app-router-svc | grep Endpoints
Endpoints:         10.244.0.12:80,10.244.0.13:80,10.244.0.14:80

# Instant cutover to GREEN:
$ kubectl patch svc app-router-svc -p '{"spec":{"selector":{"version":"green"}}}'
service/app-router-svc patched

# Verify service now points to GREEN pods
$ kubectl describe svc app-router-svc | grep Endpoints
Endpoints:         10.244.0.15:80,10.244.0.16:80,10.244.0.17:80
```
**Benefits:** Instant rollback if green has bugs (just patch back to `version: blue`). Zero downtime.

---

### 03. Canary Deployment
Roll out changes to a small fraction of real users by using replica weighting.

```bash
$ kubectl apply -f 01-deployment-strategies/03-canary/canary-deployments.yaml
deployment.apps/app-stable created
deployment.apps/app-canary created
service/canary-common-svc created

# Stable has 3 replicas, Canary has 1 replica (both have label 'app: canary-app')
$ kubectl get pods -l app=canary-app --show-labels
NAME                          READY   STATUS    LABELS
app-canary-569d67fb85-b9tz7   1/1     Running   app=canary-app,track=canary
app-stable-787db8488-8kllp    1/1     Running   app=canary-app,track=stable
app-stable-787db8488-k9x1z    1/1     Running   app=canary-app,track=stable
app-stable-787db8488-w5s2v    1/1     Running   app=canary-app,track=stable

# Traffic distribution test:
$ for i in {1..8}; do curl -s http://$(minikube ip):$(kubectl get svc canary-common-svc -o jsonpath='{.spec.ports[0].nodePort}') | grep -o 'nginx/[0-9.]*'; done
nginx/1.24.0
nginx/1.24.0
nginx/1.25.0   <-- Canary hit (~25%)
nginx/1.24.0
nginx/1.24.0
nginx/1.25.0   <-- Canary hit
nginx/1.24.0
nginx/1.24.0
```

---

### 04. Recreate Deployment
All existing Pods are killed before any new Pods are spawned. Suitable when two versions cannot run concurrently (e.g., database schema changes, exclusive lock on volumes).

```bash
$ kubectl apply -f 01-deployment-strategies/04-recreate/recreate-deployment.yaml
deployment.apps/recreate-app created

# Update image and watch
$ kubectl set image deployment/recreate-app web=nginx:1.25-alpine
deployment.apps/recreate-app image updated

$ kubectl get pods -l app=recreate-demo -w
NAME                            READY   STATUS        RESTARTS   AGE
recreate-app-5884bb445f-4vjkl   1/1     Terminating   0          45s
recreate-app-5884bb445f-b8z9m   1/1     Terminating   0          45s
recreate-app-5884bb445f-wq21c   1/1     Terminating   0          45s
recreate-app-6bbd47986b-7h82k   0/1     Pending       0          0s
recreate-app-6bbd47986b-m9s1l   0/1     ContainerCreating 0      0s
recreate-app-6bbd47986b-vx87c   0/1     ContainerCreating 0      0s
recreate-app-6bbd47986b-7h82k   1/1     Running       0          3s
```
**Observation:** There is a brief downtime period while old pods terminate and new pods spin up, but no version concurrency issues occur.

---

## Task 2: Pod Lifecycle & Hooks

### Pod Phases
1. **Pending:** Pod accepted by cluster, but waiting for scheduling or image pull.
2. **Running:** Bound to node, at least one container is running or starting.
3. **Succeeded:** All containers terminated successfully (exit 0).
4. **Failed:** All containers terminated, at least one terminated with non-zero exit code.
5. **Unknown:** Pod state cannot be obtained (typically kubelet network issue).

### Testing Init Containers
```bash
$ kubectl apply -f 02-pod-lifecycle/01-init-container-pod.yaml
pod/init-demo-pod created

$ kubectl get pod init-demo-pod
NAME            READY   STATUS     RESTARTS   AGE
init-demo-pod   0/1     Init:0/1   0          2s

$ kubectl get pod init-demo-pod
NAME            READY   STATUS    RESTARTS   AGE
init-demo-pod   1/1     Running   0          6s

$ kubectl exec init-demo-pod -- cat /usr/share/nginx/html/initialized.txt
Init completed successfully
```

### Testing Lifecycle Hooks (`postStart` / `preStop`)
```bash
$ kubectl apply -f 02-pod-lifecycle/02-lifecycle-hooks-pod.yaml
pod/lifecycle-hooks-pod created

$ kubectl exec lifecycle-hooks-pod -- cat /usr/share/nginx/html/status.html
Container started at Wed Oct  7 20:45:00 UTC 2026
```
