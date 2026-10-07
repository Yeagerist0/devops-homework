# DevOps Heroes - Homework Submission

**Student:** Hitarth Jain  
**Enrollment:** 24BCS10399  
**Repository:** https://github.com/Yeagerist0/devops-homework

This repository contains the completed, reproducible exercises for all DevOps homework sessions. Every configuration, manifest, script, and output was executed and validated on my environment (Kali Linux, Docker 28.5.2, Minikube / Kubernetes v1.30, Terraform v1.8, Helm v3.14).

---

## Course Materials & Submission Links
- [Homework Brief Document](https://docs.google.com/document/d/1cjXFYf2Thm8cBEN-0C48B-v02cj3jGLd47lcO18prHE/edit?usp=sharing)
- [Section A Submission Form](https://forms.gle/ydjAJcwxjpjBXgxB8)
- [Section B Submission Form](https://forms.gle/pAuXQaokwVzhRzit6)

---

## Curriculum Index

### Section A: Linux, Networking, Git, Docker & K8s Core

| Session | Topic | Work / Submission |
|---|---|---|
| **1** | DevOps Engineer Roadmap | [Roadmap](session1-devops-engineer-roadmap/session1.md) |
| **2** | Linux Fundamentals | [Linux Homework](session2-linux/linux-homework.md) · [Notes](session2-linux/session2.md) |
| **3** | Shell Scripting | [System Info Script](session3-shell-scripting/system-info.sh) · [Tasks](session3-shell-scripting/task.md) |
| **4** | Networking Fundamentals | [Networking Practice](session4-networking/networking-homework.md) · [IP Notes](session4-networking/ip.md) |
| **5** | Git & GitHub | [Git Homework](session5-git-github/git-homework.md) |
| **6-7**| Docker Fundamentals & Images | [Hello World Applications](session6-7-docker/hello-world-apps/README.md) · [Multi-Stage Build](session6-7-docker/multi-stage-dockerfile/README.md) |
| **8** | Docker Networking & Volumes | [Docker Networking](session8-docker-networking-volume/docker-networking-homework.md) · [reproduce.sh](session8-docker-networking-volume/reproduce.sh) |
| **9** | Kubernetes Fundamentals | [Kubernetes Fundamentals](session9-k8s/Readme.md) · [session9-kubernetes-fundamentals](session9-kubernetes-fundamentals/README.md) |
| **10**| Pods, ReplicaSets & Deployments | [Core Objects](session10-k8s-core-objects/Readme.md) · [session10-kubernetes-pods-deployments](session10-kubernetes-pods-deployments/README.md) |
| **11**| Kubernetes Services & Networking | [Services Guide](session-11-kubernetes-services/service.md) · [session11-kubernetes-networking-services](session11-kubernetes-networking-services/README.md) |
| **12**| Ingress, ConfigMaps & Secrets | [Ingress Lab](session-12-ingress-configmaps-secrets/lab.md) · [session12-kubernetes-ingress-configmaps-secrets](session12-kubernetes-ingress-configmaps-secrets/README.md) |

---

### Section B: Advanced K8s, Helm, CI/CD, DevSecOps, Cloud/IaC, Observability & Capstone

| Session | Topic | Work / Submission |
|---|---|---|
| **13**| Kubernetes Storage, HPA & Probes | [session13-kubernetes-storage-hpa-probes/README.md](session13-kubernetes-storage-hpa-probes/README.md) |
| **14**| Kubernetes Troubleshooting | [session14-kubernetes-troubleshooting/README.md](session14-kubernetes-troubleshooting/README.md) |
| **15**| Helm Package Manager | [session15-helm/README.md](session15-helm/README.md) · [my-webapp Chart](session15-helm/my-webapp) |
| **16**| CI/CD & GitHub Actions | [session16-cicd-github-actions/README.md](session16-cicd-github-actions/README.md) · [Workflow](session16-cicd-github-actions/.github/workflows/cicd.yml) |
| **17**| Complete CI/CD & DevSecOps | [session17-complete-cicd-devsecops/README.md](session17-complete-cicd-devsecops/README.md) · [Pipeline](session17-complete-cicd-devsecops/.github/workflows/devsecops-pipeline.yml) |
| **18**| Terraform & Infrastructure as Code | [session18-terraform-iac/README.md](session18-terraform-iac/README.md) · [AWS S3 Demo](session18-terraform-iac/terraform-s3-demo) |
| **19**| Cloud & Terraform in Action | [session19-cloud-terraform-in-action/README.md](session19-cloud-terraform-in-action/README.md) |
| **20**| Monitoring, Observability & GitOps | [session20-monitoring-observability-gitops/README.md](session20-monitoring-observability-gitops/README.md) · [ArgoCD App](session20-monitoring-observability-gitops/gitops-argocd) |
| **21**| Final DevOps Project & Troubleshooting | [session21-final-devops-project/README.md](session21-final-devops-project/README.md) |

---

## Session Summaries

* **Session 2 - Linux:** Soft vs hard links with inode proof, `adduser` vs `useradd` as root, `journalctl` filters, command cheat sheet practice.
* **Session 3 - Shell Scripting:** `system-info.sh` interactive script capturing date, hostname, user, disk usage, and redirected process tables.
* **Session 4 - Networking:** 16 essential commands executed with output (`ip`, `ping`, `traceroute`, `ss`, `netstat`, `dig`, `nslookup`, `curl`, `nc`).
* **Session 5 - Git:** `git commit -m` vs `-a -m`, feature branch cherry-picking onto main with revision graph analysis.
* **Session 6-7 - Docker:** Hello World container applications (Node, Python, Java, Apache, React, Nginx) + multi-stage optimization benchmark.
* **Session 8 - Docker Networking & Volumes:** Multi-network container topology, host networking, live bind mounts, and `reproduce.sh` automated harness.
* **Session 9 - Kubernetes Fundamentals:** Minikube setup, cluster status verification, control plane/worker node architecture, first Pod and Deployment.
* **Session 10 - Pods, ReplicaSets & Deployments:** All 4 deployment strategies implemented (Rolling Update, Blue-Green, Canary, Recreate), along with Pod lifecycle hooks (`postStart`/`preStop`) and initContainers.
* **Session 11 - Networking & Services:** All 5 service types demonstrated (ClusterIP, NodePort, LoadBalancer, ExternalName, Headless), architectural comparisons, plus detailed guides on FQDN and CoreDNS.
* **Session 12 - Ingress, ConfigMaps & Secrets:** Environment and volume injection for ConfigMaps and base64 Secrets, security best practices (why secrets are omitted from git), Ingress routing, and troubleshooting.
* **Session 13 - Storage, HPA & Probes:** PersistentVolumes, PVCs, StorageClasses, dynamic provisioning, Horizontal Pod Autoscaler load test, and Startup/Liveness/Readiness probes.
* **Session 14 - Troubleshooting:** Systematic debug runbooks for `CrashLoopBackOff`, `ImagePullBackOff`, `Pending`, label selector mismatches, and DNS failures.
* **Session 15 - Helm:** Complete CLI mastery (`create`, `install`, `upgrade`, `history`, `rollback`), full rollback verification, and custom `my-webapp` chart.
* **Session 16 - CI/CD & GitHub Actions:** Automated CI/CD pipeline covering test execution, artifact upload, multi-stage Docker build, and deployment automation.
* **Session 17 - Complete CI/CD & DevSecOps:** Shift-left security pipeline integrating Gitleaks secret scanning, Semgrep SAST, Trivy SCA & container vulnerability scanning, and security gates.
* **Session 18 - Terraform & IaC:** AWS S3 Terraform demo project (`init`, `fmt`, `validate`, `plan`, `apply`, `destroy`), plus comprehensive research guides for IAM, EC2, S3, VPC, DynamoDB, and RDS.
* **Session 19 - Cloud & Terraform in Action:** End-to-end cloud infrastructure provisioning (VPC, public subnet, Internet Gateway, security groups, EC2 web server, S3 bucket).
* **Session 20 - Monitoring, Observability & GitOps:** Prometheus metrics scraping, alert rules, 3 observability pillars (metrics, logs, traces), and automated ArgoCD GitOps reconciliation.
* **Session 21 - Final DevOps Project & Troubleshooting:** End-to-end enterprise capstone combining Node.js microservice, Docker, Terraform, K8s, Helm, DevSecOps pipeline, ArgoCD GitOps, and multi-tier failure troubleshooting.
