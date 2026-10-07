# Session 12 - Kubernetes Ingress, ConfigMaps & Secrets

**Student:** Hitarth Jain  
**Enrollment:** 24BCS10399  
**OS:** Kali Linux (Kubernetes v1.30.0 / Minikube)

---

## Task 1: ConfigMap Hands-on Demo

ConfigMaps decouple application code from environment-specific configuration values (URLs, ports, log levels, flags).

```bash
$ kubectl apply -f manifests/01-configmap-demo.yaml
configmap/app-config created
pod/configmap-pod-demo created

$ kubectl get cm app-config
NAME         DATA   AGE
app-config   4      25s

$ kubectl logs configmap-pod-demo
Env Var: production
Config File:
database.pool.size=20
cache.enabled=true
feature.dark_mode=enabled
```

---

## Task 2: Kubernetes Secrets Hands-on Demo

Secrets store sensitive configuration data (passwords, tokens, SSH keys, certificates).

```bash
$ kubectl apply -f manifests/02-secret-demo.yaml
secret/app-db-credentials created
pod/secret-pod-demo created

$ kubectl get secret app-db-credentials
NAME                 TYPE     DATA   AGE
app-db-credentials   Opaque   2      14s

$ kubectl logs secret-pod-demo
API_KEY injected: ak_live_99214a1a5b8
Secret file:
SuperSecretPass123!
```

### Why Secrets Must NEVER Be Committed to Git
1. **Base64 is NOT Encryption:** Base64 is merely an encoding scheme (`echo -n "password" | base64`). Anyone who clones or reads the Git repository can decode the values in one second using `base64 -d`.
2. **Git History is Permanent:** Once a credential enters Git history, git commit history retains it even if deleted in a subsequent commit unless history is purged with tools like BFG Repo-Cleaner or git-filter-repo.
3. **Enterprise Alternatives:**
   * **Sealed Secrets (Bitnami):** Asymmetric encryption where public keys encrypt secrets for git, and the cluster's controller uses the private key to decrypt.
   * **External Secrets Operator (ESO):** Syncs directly from AWS Secrets Manager, HashiCorp Vault, or GCP Secret Manager into Kubernetes Secrets at runtime.
   * **SOPS / Age / Mozilla SOPS:** Encrypts YAML values while keeping keys readable in Git.

---

## Task 3: Ingress Hands-on Demo

Ingress operates at OSI Layer 7 (HTTP/HTTPS) and routes traffic based on hostname and URI paths to backing Services.

```bash
$ minikube addons enable ingress
* ingress is an active addon

$ kubectl apply -f manifests/03-ingress-demo.yaml
deployment.apps/web-frontend created
service/frontend-svc created
ingress.networking.k8s.io/demo-ingress created

$ kubectl get ingress demo-ingress
NAME           CLASS   HOSTS              ADDRESS        PORTS   AGE
demo-ingress   nginx   app.localdev.me    192.168.49.2   80      32s

# Test access using hostname
$ curl -H "Host: app.localdev.me" http://$(minikube ip)/
<!DOCTYPE html>
<html>
<head><title>Welcome to nginx!</title></head>
...
```

---

## Task 4: Ingress vs Ingress Controller

| Feature | Ingress | Ingress Controller |
|---|---|---|
| **What is it?** | A Kubernetes API object (declarative ruleset: hosts, paths, TLS, backends). | An actual running daemon/proxy (e.g. NGINX Ingress, Traefik, HAProxy, Envoy). |
| **Active / Passive** | Passive YAML definition in etcd. By itself, it routes zero traffic. | Active daemon watching API server for Ingress objects and dynamically reconfiguring its reverse proxy. |
| **Analogy** | A flight ticket showing route and gate number. | The airplane and pilot executing the flight. |
| **Examples** | `networking.k8s.io/v1 Ingress` manifest | Ingress-NGINX controller, Traefik, Kong, AWS Load Balancer Controller |

Both are required: Without the Ingress Controller pod running, an Ingress resource sits dormant and achieves nothing.

---

## Task 5: Troubleshooting Scenario

### 1. Identifying the Problem
Deploying `troubleshooting/01-broken-manifest.yaml`:
```bash
$ kubectl apply -f troubleshooting/01-broken-manifest.yaml
deployment.apps/broken-app created
service/broken-svc created

$ kubectl get pods -l app=broken-app
NAME                          READY   STATUS                            RESTARTS   AGE
broken-app-798dfb9f67-8j12x   0/1     CreateContainerConfigError        0          15s
```

### 2. Investigation Steps
```bash
$ kubectl describe pod broken-app-798dfb9f67-8j12x
...
Events:
  Type     Reason     Age                From               Message
  ----     ------     ----               ----               -------
  Warning  Failed     10s (x3 over 25s)  kubelet            Error: couldn't find key NON_EXISTENT_KEY in Secret default/app-db-credentials
```

### 3. Root Cause Analysis
1. **Pod Failure:** Pod references key `NON_EXISTENT_KEY` inside secret `app-db-credentials`. The secret only contains `DB_PASSWORD` and `API_KEY`.
2. **Service Failure:** Service `targetPort` was set to `8080`, whereas the container was configured on port `80`.

### 4. Fix & Verification
Applied `troubleshooting/02-fixed-manifest.yaml`:
```bash
$ kubectl apply -f troubleshooting/02-fixed-manifest.yaml
deployment.apps/broken-app configured
service/broken-svc configured

$ kubectl get pods -l app=broken-app
NAME                          READY   STATUS    RESTARTS   AGE
broken-app-6bb8849b5c-k78lp   1/1     Running   0          9s

$ kubectl run curl-fix --image=curlimages/curl --rm -it --restart=Never -- curl -s http://broken-svc
<!DOCTYPE html>
<html><head><title>Welcome to nginx!</title></head></html>
```
Issue resolved and traffic confirmed functional!
