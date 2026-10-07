# Session 20 - Monitoring, Observability & GitOps

**Student:** Hitarth Jain  
**Enrollment:** 24BCS10399  
**Tooling:** Prometheus, Grafana, Alertmanager, ArgoCD

---

## Task 1: Monitoring Fundamentals & Alerts

Monitoring tells you **whether a system is working** and alerts you when predefined thresholds are violated.

### 1. Key Metrics Monitored
* **Node CPU Utilization:** Evaluated using `node_cpu_seconds_total` across all cores.
* **Memory Utilization:** Evaluated against `container_spec_memory_limit_bytes` to prevent `OOMKilled` crashes.
* **Application Health:** Heartbeat `/healthz` HTTP probes scraped every 15s.

### 2. Alert Rules Implementation
Configured in [configs/alert-rules.yaml](configs/alert-rules.yaml):
* `HighCpuUsage`: Triggers warning when CPU > 85% for 2 minutes.
* `PodMemoryThresholdExceeded`: Triggers critical alert when container reaches 90% of memory limit.
* `ServiceDown`: Triggers immediately when target `up == 0`.

---

## Task 2: Observability - The Three Pillars

Observability tells you **why a system is broken** by inferring internal states from external outputs.

```
                  ┌──────────────────────┐
                  │    OBSERVABILITY     │
                  └──────────┬───────────┘
         ┌───────────────────┼───────────────────┐
         ▼                   ▼                   ▼
    [ METRICS ]           [ LOGS ]           [ TRACES ]
 "Is something wrong?"  "What happened?"   "Where is delay?"
   Aggregated counts      Timestamped        Distributed
   and gauges over time    event streams      request journey
 (Prometheus / Datadog)  (Loki / ELK Stack) (Jaeger / OpenTelemetry)
```

### 1. Metrics
* Numeric values measured over intervals of time (counters, gauges, histograms).
* Highly efficient to store and query with minimal network overhead.

### 2. Logs
* Structured (JSON) or plaintext records with timestamps detailing specific application events, exceptions, and debug traces.
* Collected via Fluentd, Promtail, or Logstash into Grafana Loki or Elasticsearch.

### 3. Distributed Traces
* End-to-end representation of a single user request across microservices.
* Uses unique `TraceID` and `SpanID` to locate bottlenecks and latency spikes across distributed service meshes.

---

## Task 3: GitOps with ArgoCD

### 1. What is GitOps?
GitOps is an operational framework where **Git is the single source of truth** for declarative infrastructure and applications.

### 2. Core Principles
1. **Declarative Descriptions:** The entire desired state of the cluster is described in Git manifests.
2. **Version Controlled & Immutable:** Every change is tracked, auditable, and easily rollbacked via `git revert`.
3. **Automated Pull Reconciliation:** Software agents inside the cluster (e.g. ArgoCD, Flux) pull changes from Git continuously rather than pushing via external CI credentials.
4. **Self-Healing:** If someone makes an ad-hoc change in the cluster (`kubectl edit`), the GitOps controller detects the drift and automatically reverts the cluster to match Git.

### 3. ArgoCD Application Manifest
Manifest: [gitops-argocd/application.yaml](gitops-argocd/application.yaml)
* Sync policy configured with `selfHeal: true` and `prune: true`.
* Target repository: `https://github.com/Yeagerist0/devops-homework.git` pointing to the Helm chart.
