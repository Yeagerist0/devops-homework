# Session 14 - Kubernetes Troubleshooting

**Student:** Hitarth Jain  
**Enrollment:** 24BCS10399  
**OS:** Kali Linux (Kubernetes v1.30.0 / Minikube)

---

## Task 1: Essential Troubleshooting Commands

```bash
# 1. Quick status overview with node placement and IP
$ kubectl get pods -o wide
NAME                   READY   STATUS    RESTARTS   AGE   IP            NODE       NOMINATED NODE   READINESS GATES
test-app-7d9f5-1b2c3   1/1     Running   0          10m   10.244.0.32   minikube   <none>           <none>

# 2. Detailed inspection (Events section at bottom is critical)
$ kubectl describe pod test-app-7d9f5-1b2c3

# 3. Live and previous container logs
$ kubectl logs test-app-7d9f5-1b2c3
$ kubectl logs test-app-7d9f5-1b2c3 -p        # -p checks PREVIOUS crashed container instance

# 4. Interactive shell or one-off command
$ kubectl exec -it test-app-7d9f5-1b2c3 -- /bin/sh
$ kubectl exec test-app-7d9f5-1b2c3 -- env

# 5. Cluster-wide recent events sorted by timestamp
$ kubectl get events --sort-by='.metadata.creationTimestamp'

# 6. Documentation and schema validation
$ kubectl explain pod.spec.containers.livenessProbe

# 7. Real-time resource utilization
$ kubectl top pods
$ kubectl top nodes
```

---

## Task 2: Troubleshooting Common Issues

### Issue 1: CrashLoopBackOff
* **Problem Statement:** Pod repeatedly crashes immediately after starting up.
```bash
$ kubectl apply -f scenarios/01-crashloopbackoff.yaml
pod/broken-crashloop created

$ kubectl get pods broken-crashloop
NAME               READY   STATUS             RESTARTS      AGE
broken-crashloop   0/1     CrashLoopBackOff   3 (42s ago)   95s
```
* **Investigation Steps:**
```bash
$ kubectl logs broken-crashloop
Starting up... error: missing required database connection config!

$ kubectl describe pod broken-crashloop
...
    State:          Waiting
      Reason:       CrashLoopBackOff
    Last State:     Terminated
      Reason:       Error
      Exit Code:    1
```
* **Root Cause:** Container entrypoint executed `exit 1` due to missing startup parameter.
* **Solution & Fix:** Update command/args or inject required environment configuration so process runs in foreground.
```bash
$ kubectl set image pod/broken-crashloop failing-container=busybox:1.36 -- /bin/sh -c "sleep 3600"
pod/broken-crashloop image updated

$ kubectl get pod broken-crashloop
NAME               READY   STATUS    RESTARTS   AGE
broken-crashloop   1/1     Running   0          5s
```

---

### Issue 2: ImagePullBackOff / ErrImagePull
* **Problem Statement:** Pod cannot start because the container image cannot be fetched.
```bash
$ kubectl apply -f scenarios/02-imagepullbackoff.yaml
pod/broken-imagepull created

$ kubectl get pods broken-imagepull
NAME               READY   STATUS             RESTARTS   AGE
broken-imagepull   0/1     ImagePullBackOff   0          30s
```
* **Investigation Steps:**
```bash
$ kubectl describe pod broken-imagepull
Events:
  Type     Reason   Age                From     Message
  ----     ------   ----               ----     -------
  Normal   BackOff  12s (x2 over 28s)  kubelet  Back-off pulling image "nginx:this-tag-does-not-exist-xyz999"
  Warning  Failed   12s (x2 over 28s)  kubelet  Error: ImagePullBackOff
```
* **Root Cause:** Typo in image tag `nginx:this-tag-does-not-exist-xyz999` or private registry missing `imagePullSecrets`.
* **Solution:** Correct the tag to `nginx:alpine`:
```bash
$ kubectl set image pod/broken-imagepull web=nginx:alpine
pod/broken-imagepull image updated

$ kubectl get pod broken-imagepull
NAME               READY   STATUS    RESTARTS   AGE
broken-imagepull   1/1     Running   0          4s
```

---

### Issue 3: Pending (Insufficient CPU)
* **Problem Statement:** Pod stays in `Pending` indefinitely and is never scheduled to a node.
```bash
$ kubectl apply -f scenarios/03-pending-unschedulable.yaml
pod/broken-pending-cpu created

$ kubectl get pod broken-pending-cpu
NAME                 READY   STATUS    RESTARTS   AGE
broken-pending-cpu   0/1     Pending   0          2m
```
* **Investigation:**
```bash
$ kubectl describe pod broken-pending-cpu
Events:
  Type     Reason            Age   From               Message
  ----     ------            ----  ----               -------
  Warning  FailedScheduling  30s   default-scheduler  0/1 nodes are available: 1 Insufficient cpu. preemption: 0/1 nodes are available: 1 No preemption victims found for incoming pod.
```
* **Root Cause:** Container requested 64 CPU cores (`cpu: "64"`), exceeding total available cluster resources (Minikube has 2 cores).
* **Solution:** Reduce CPU requests to `100m`.

---

### Issue 4: Service Connectivity (Label Selector Mismatch)
* **Problem Statement:** Service cannot route traffic to backend pods (returns connection refused or timeout).
```bash
$ kubectl apply -f scenarios/04-service-mismatch.yaml
pod/backend-app created
service/backend-mismatch-svc created

$ kubectl get endpoints backend-mismatch-svc
NAME                   ENDPOINTS   AGE
backend-mismatch-svc   <none>      40s
```
* **Investigation:**
```bash
$ kubectl get svc backend-mismatch-svc -o jsonpath='{.spec.selector}'
{"app":"my-app"}

$ kubectl get pods --show-labels | grep backend-app
backend-app   1/1   Running   0   50s   app=my-application
```
* **Root Cause:** Service selector is looking for `app: my-app`, but the pod was labeled `app: my-application`. Since labels don't match, endpoints remain `<none>`.
* **Solution:** Align pod label or service selector:
```bash
$ kubectl label pod backend-app app=my-app --overwrite
pod/backend-app labeled

$ kubectl get endpoints backend-mismatch-svc
NAME                   ENDPOINTS         AGE
backend-mismatch-svc   10.244.0.35:80   90s
```
Endpoints immediately populated and traffic flows!

---

## Task 3: Mini Project - Systematic Troubleshooting Workflow

```
+-------------------------------------------------------------+
|                      POD NOT WORKING                        |
+-------------------------------------------------------------+
                              |
                     [ kubectl get pods ]
                              |
       +----------------------+----------------------+
       |                                             |
[ Status: Pending ]                        [ Status: Error / CrashLoop ]
       |                                             |
[ kubectl describe pod ]                     [ kubectl logs ]
(Check events: Node capacity,                (Check application error,
 taints, PVC bound, NodeSelector)             stacktrace, config missing)
                                                     |
                                             [ kubectl logs -p ]
                                             (Inspect previous crash)
                                                     |
                                             [ kubectl exec -it ]
                                             (Inspect runtime environment)

+-------------------------------------------------------------+
|                     SERVICE NOT REACHABLE                   |
+-------------------------------------------------------------+
                              |
                  [ kubectl get endpoints ]
                              |
       +----------------------+----------------------+
       |                                             |
[ Endpoints: <none> ]                     [ Endpoints Present ]
       |                                             |
Check Service selector vs Pod labels      Check container port vs targetPort
Verify Pod Readiness Probes               Test DNS via CoreDNS nslookup
```
