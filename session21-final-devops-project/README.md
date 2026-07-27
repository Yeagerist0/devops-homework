# Session 21 - Final DevOps Project & Troubleshooting Capstone

**Student:** Hitarth Jain  
**Enrollment:** 24BCS10399  
**Status:** Complete End-to-End Implementation

---

## 1. Project Overview

This capstone project represents a production-grade, enterprise DevOps and GitOps lifecycle combining all disciplines covered throughout the curriculum:
1. **Application Layer:** Express.js REST microservice instrumented with Prometheus `/metrics` and health endpoints.
2. **Containerization:** Hardened, non-root multi-stage Docker build.
3. **Infrastructure as Code:** Terraform-managed AWS VPC network foundation.
4. **Container Orchestration:** Kubernetes Deployment, ClusterIP Service, NGINX Ingress, PersistentVolumeClaim storage, and HorizontalPodAutoscaler.
5. **Package Management:** Parameterized Helm chart.
6. **Continuous Integration & DevSecOps:** GitHub Actions pipeline incorporating automated unit testing, secret scanning, container scanning, and security gates.
7. **Observability & GitOps:** Prometheus metrics scraping and automated reconciliation via ArgoCD.
8. **Real-World Troubleshooting:** Systematic debugging and resolution of intentionally introduced multi-tier failures.

---

## 2. End-to-End Architecture Diagram

```
[ Developer ] 
      │
      ├── (git commit & push) 
      ▼
  [ GitHub Repository ]
      │
      ├── (Webhook Trigger)
      ▼
┌─────────────────────────────────────────────────────────────┐
│                 CI / DevSecOps Pipeline                     │
│                                                             │
│  [ npm test ] ──► [ Secret Scan ] ──► [ Docker Build ]       │
│                         │                    │              │
│                         ▼                    ▼              │
│                  [ SAST / SCA ]       [ Trivy Scan ]        │
│                                              │              │
│                                              ▼              │
│                                    [ Push to Registry ]     │
└─────────────────────────────┬───────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                       GitOps & CD                           │
│                                                             │
│   [ ArgoCD Controller ] ◄── (Pulls Helm Chart from Git)     │
│             │                                               │
│             ▼ (Auto-Sync & Self-Heal)                       │
│   [ Kubernetes Cluster ]                                    │
│         ├── Ingress Controller ──► [ NGINX Ingress ]        │
│         ├── Service (ClusterIP)                             │
│         ├── Deployment (3 Replicas, Non-Root)               │
│         ├── Storage (PersistentVolumeClaim)                 │
│         └── HPA (Autoscaling on CPU > 60%)                  │
│                                                             │
│   [ Prometheus & Grafana ] ──► (Scrapes /metrics)           │
└─────────────────────────────────────────────────────────────┘
```

---

## 3. Technologies Used

* **OS & Environment:** Kali Linux, Docker 28.5.2, Minikube / K8s v1.30
* **Backend:** Node.js 20, Express, `prom-client`
* **IaC:** HashiCorp Terraform v1.8, AWS Provider v5.42
* **Orchestration & Packaging:** Kubernetes, Helm v3.14
* **Security & CI/CD:** GitHub Actions, Gitleaks, Trivy, Semgrep
* **Monitoring & GitOps:** Prometheus, ArgoCD

---

## 4. Component Implementation Details

### A. Application & Docker Setup
* Source files located in `application/` (`server.js`, `package.json`, `test.js`).
* Dockerfile located in `docker/Dockerfile`:
  * Multi-stage build separates dependency caching from runtime.
  * Dedicated non-root user `nodeuser` (UID 1001) prevents container breakout privileges.
  * Built-in `HEALTHCHECK` verifies `/healthz` responsiveness.

### B. Kubernetes Deployment & Helm
* Manifests located in `kubernetes/manifests.yaml`:
  * `Deployment`: 3 replicas, resource requests/limits, Startup/Liveness/Readiness probes.
  * `Service`: ClusterIP load balancer mapping port 80 to 8080.
  * `Ingress`: Host-based routing for `devops-final.local`.
  * `HPA`: Scales from 2 to 6 replicas when CPU exceeds 60%.
  * `PVC`: Persistent storage mounted to `/data`.
* Packaged as a clean reusable Helm chart under `helm/enterprise-app/`.

### C. Terraform Cloud Infrastructure
* Configurations in `terraform/main.tf` provisioning isolated VPC and public subnet with standard tagging.

### D. CI/CD & DevSecOps Pipeline
* Workflow located in `.github/workflows/final-pipeline.yml`:
  * Runs automated unit tests.
  * Builds and scans container image for vulnerabilities.
  * Verifies Helm chart syntax.
  * Triggers GitOps reconciliation.

---

## 5. Final Troubleshooting Challenge (Multi-Issue Resolution)

### Challenge 1: `CrashLoopBackOff` on Container Startup
* **Symptom:** Pod fails immediately after launch with restart count increasing rapidly.
* **Investigation:**
  ```bash
  $ kubectl logs -l app=final-devops-app
  Error: Cannot find module 'prom-client'
  ```
* **Root Cause:** Dependencies from `package.json` were omitted during production container image layering.
* **Fix:** Updated Dockerfile to execute `npm ci --only=production` before copying app files.
* **Verification:** Container status switched to `Running (1/1)` with 0 restarts.

### Challenge 2: Ingress 502 Bad Gateway
* **Symptom:** Accessing `http://devops-final.local` returns HTTP 502 Bad Gateway.
* **Investigation:**
  ```bash
  $ kubectl describe ingress final-devops-ingress
  $ kubectl describe svc final-devops-svc
  Endpoints: <none>
  ```
* **Root Cause:** Ingress was forwarding to service port 80, but the Service `targetPort` was mistakenly pointing to 3000 instead of 8080.
* **Fix:** Corrected `targetPort: 8080` in `kubernetes/manifests.yaml`.
* **Verification:** Service endpoints populated with all 3 Pod IP addresses and Ingress returned `200 OK`.

### Challenge 3: HPA Unknown Metrics Target
* **Symptom:** `kubectl get hpa` reported `TARGETS: <unknown>/60%`.
* **Investigation:**
  ```bash
  $ kubectl describe hpa final-devops-hpa
  Warning: FailedGetResourceMetric: missing request for cpu
  ```
* **Root Cause:** Container specification did not define `resources.requests.cpu`. Kubernetes HPA cannot compute percentage utilization without a baseline request.
* **Fix:** Added `resources.requests.cpu: "100m"` to PodSpec.
* **Verification:** `kubectl get hpa` now reports real-time CPU percentages (`TARGETS: 2%/60%`).

---

## 6. Lessons Learned

1. **Shift Security Left:** Fixing a vulnerability in the Dockerfile stage takes 5 minutes, compared to days after deploying to a shared cluster.
2. **Always Define Resource Requests:** CPU and memory requests are mandatory not just for scheduler bin-packing, but for HPA autoscaling calculations and OOM protection.
3. **GitOps Eliminates Configuration Drift:** Manual hotfixes via `kubectl edit` inevitably cause configuration drift; having ArgoCD enforce Git as the single source of truth ensures true idempotency.
