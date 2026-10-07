# Session 17 - Complete CI/CD & DevSecOps

**Student:** Hitarth Jain  
**Enrollment:** 24BCS10399  
**Security Framework:** Shift-Left DevSecOps (SAST, SCA, Secret Scanning, Container Hardening)

---

## 1. DevSecOps Philosophy: Shifting Left

In traditional DevOps, security testing occurred at the end of the SDLC, causing expensive delays and urgent rollbacks. **DevSecOps** injects automated security testing into every stage of the CI/CD pipeline.

### End-to-End Flow Diagram
```
    [ Code Commit ]
           │
           ▼
  [ Secret Scanning ] ── (Gitleaks) ──► Blocks if API keys/passwords found
           │
           ▼
      [ SAST ] ──────── (Semgrep) ────► Static code analysis (anti-patterns)
           │
           ▼
      [ SCA ] ───────── (Trivy FS) ───► Dependency vulnerability audit (CVEs)
           │
           ▼
    [ Docker Build ] ── Multi-stage, non-root user (UID 1000)
           │
           ▼
  [ Container Scan ] ── (Trivy Image) ► Fails pipeline if CRITICAL CVEs unfixed
           │
           ▼
   [ Security Gate ] ── Passes only when 0 Critical vulnerabilities remain
           │
           ▼
  [ Deploy to K8s ] ─── Restricted PodSecurityStandards (Capabilities dropped)
```

---

## 2. Security Tools & Configurations

### A. Secret Scanning: Gitleaks
* Scans commit history for unencrypted API tokens, private keys, and passwords.
* Configured in [security-configs/.gitleaks.toml](security-configs/.gitleaks.toml).
* Output: `✓ 0 leaks detected in repository history`.

### B. SAST: Semgrep
* Analyzes source code without executing it to detect insecure functions, injections, or insecure headers.
* Ruleset defined in [security-configs/semgrep.yml](security-configs/semgrep.yml).

### C. SCA & Container Image Scanning: Trivy
* Scans OS packages and application dependencies against known CVE databases.
* Security Gate: `--exit-code 1 --severity CRITICAL` enforces an automated build failure if a critical unpatched vulnerability is discovered in the image.

### D. Hardened Runtime (Kubernetes Pod Security Standard)
Manifest: [k8s/deployment.yaml](k8s/deployment.yaml)
* `runAsNonRoot: true`: Refuses execution if process runs as UID 0.
* `allowPrivilegeEscalation: false`: Disallows child processes from gaining more privileges than parent.
* `capabilities.drop: ["ALL"]`: Drops all Linux kernel capabilities.

---

## 3. Pipeline Output Log

```
==> Job: Secret Scanning (Gitleaks)
    Running gitleaks...
    INF scanning commits: 25 commits evaluated
    INF no leaks found

==> Job: SAST (Semgrep)
    Running 12 rules on 3 files...
    Scanning session17-complete-cicd-devsecops/app/server.js
    Scan completed in 0.8s. 0 findings.

==> Job: SCA Vulnerability Scan (Trivy FS)
    2026-10-07T21:55:00Z INFO Vulnerability scanning is enabled
    Number of language-specific files: 1
    express (npm): 0 vulnerabilities found

==> Job: Container Build & Image Scan
    Successfully built devsecops-secured-app:sha-9e2f16b
    Scanning devsecops-secured-app:sha-9e2f16b...
    devsecops-secured-app:sha-9e2f16b (alpine 3.20.0)
    Total: 0 (CRITICAL: 0, HIGH: 0)

==> Job: Deploy to Kubernetes
    kubectl apply -f session17-complete-cicd-devsecops/k8s/deployment.yaml
    deployment.apps/secured-microservice configured
    service/secured-microservice-svc unchanged
    Pipeline completed successfully in 1m 42s!
```
