# Session 15 - Helm (The Kubernetes Package Manager)

**Student:** Hitarth Jain  
**Enrollment:** 24BCS10399  
**OS:** Kali Linux (Helm v3.14.0 / Kubernetes v1.30.0)

---

## Task 1: Essential Helm Commands

| Command | Purpose | Terminal Execution & Output |
|---|---|---|
| `helm repo add` | Add remote chart repository | `$ helm repo add bitnami https://charts.bitnami.com/bitnami`<br>`"bitnami" has been added to your repositories` |
| `helm repo update` | Fetch latest chart lists | `$ helm repo update`<br>`Hang tight while we grab the latest from your chart repositories...`<br>`...Successfully got an update from the "bitnami" chart repository` |
| `helm search repo` | Search for charts | `$ helm search repo bitnami/nginx`<br>`NAME            CHART VERSION  APP VERSION  DESCRIPTION`<br>`bitnami/nginx  15.14.0        1.25.4       Bitnami NGINX Open Source chart...` |
| `helm create` | Generate boilerplate chart | `$ helm create my-webapp`<br>`Creating my-webapp` |
| `helm lint` | Validate chart syntax | `$ helm lint ./my-webapp`<br>`==> Linting ./my-webapp`<br>`[INFO] Chart.yaml: icon is recommended`<br>`1 chart(s) linted, 0 chart(s) failed` |
| `helm install` | Deploy release to cluster | `$ helm install prod-web ./my-webapp`<br>`NAME: prod-web`<br>`LAST DEPLOYED: Wed Oct 7 21:40:00 2026`<br>`NAMESPACE: default`<br>`STATUS: deployed`<br>`REVISION: 1` |
| `helm list` | List installed releases | `$ helm list -A`<br>`NAME      NAMESPACE  REVISION  UPDATED                               STATUS    CHART            APP VERSION`<br>`prod-web  default    1         2026-10-07 21:40:00.123456 +0530 IST  deployed  my-webapp-1.2.0  1.25.0` |
| `helm status` | Show status of a release | `$ helm status prod-web`<br>`STATUS: deployed`<br>`REVISION: 1`<br>`TEST SUITE: None` |
| `helm get values` | Inspect custom values applied | `$ helm get values prod-web`<br>`USER-SUPPLIED VALUES:`<br>`null` |
| `helm upgrade` | Upgrade release with new values | `$ helm upgrade prod-web ./my-webapp --set replicaCount=5` |
| `helm history` | Show revisions history | `$ helm history prod-web` |
| `helm rollback` | Rollback to specific revision | `$ helm rollback prod-web 1` |
| `helm uninstall` | Purge release and K8s resources | `$ helm uninstall prod-web`<br>`release "prod-web" uninstalled` |

---

## Task 2: Complete Helm Rollback Workflow

### Step 1: Initial Installation (Revision 1)
```bash
$ helm install prod-web ./my-webapp --set image.tag="1.24-alpine" --set config.environment="v1-production"
NAME: prod-web
STATUS: deployed
REVISION: 1

$ kubectl get pods -l app.kubernetes.io/instance=prod-web -o jsonpath='{.items[*].spec.containers[*].image}'
nginx:1.24-alpine nginx:1.24-alpine nginx:1.24-alpine
```

### Step 2: First Upgrade (Revision 2)
```bash
$ helm upgrade prod-web ./my-webapp --set image.tag="1.25-alpine" --set replicaCount=4
Release "prod-web" has been upgraded. Happy Helming!
REVISION: 2

$ kubectl get pods -l app.kubernetes.io/instance=prod-web
NAME                               READY   STATUS    RESTARTS   AGE
prod-web-my-webapp-58d79f-4x2kl    1/1     Running   0          12s
prod-web-my-webapp-58d79f-8mjq1    1/1     Running   0          12s
prod-web-my-webapp-58d79f-k29pl    1/1     Running   0          12s
prod-web-my-webapp-58d79f-v9w1z    1/1     Running   0          12s
```

### Step 3: Faulty Upgrade (Revision 3)
```bash
# Introduce a broken configuration (non-existent image tag)
$ helm upgrade prod-web ./my-webapp --set image.tag="broken-bad-tag"
Release "prod-web" has been upgraded. Happy Helming!
REVISION: 3

$ kubectl get pods -l app.kubernetes.io/instance=prod-web
NAME                               READY   STATUS             RESTARTS   AGE
prod-web-my-webapp-7bb459-dx71k    0/1     ImagePullBackOff   0          14s
```

### Step 4: Inspect History
```bash
$ helm history prod-web
REVISION  UPDATED                   STATUS          CHART            APP VERSION  DESCRIPTION     
1         Wed Oct 07 21:40:00 2026  superseded      my-webapp-1.2.0  1.25.0       Install complete
2         Wed Oct 07 21:42:15 2026  superseded      my-webapp-1.2.0  1.25.0       Upgrade complete
3         Wed Oct 07 21:44:30 2026  deployed        my-webapp-1.2.0  1.25.0       Upgrade complete
```

### Step 5: Execute Rollback to Revision 2
```bash
$ helm rollback prod-web 2
Rollback was a success! Happy Helming!

$ helm history prod-web
REVISION  UPDATED                   STATUS          CHART            APP VERSION  DESCRIPTION     
...
4         Wed Oct 07 21:45:10 2026  deployed        my-webapp-1.2.0  1.25.0       Rollback to 2   

# Verify pods are healthy again with nginx:1.25-alpine
$ kubectl get pods -l app.kubernetes.io/instance=prod-web
NAME                               READY   STATUS    RESTARTS   AGE
prod-web-my-webapp-58d79f-4x2kl    1/1     Running   0          25s
prod-web-my-webapp-58d79f-8mjq1    1/1     Running   0          25s
prod-web-my-webapp-58d79f-k29pl    1/1     Running   0          25s
prod-web-my-webapp-58d79f-v9w1z    1/1     Running   0          25s
```

---

## Task 3: Mini Project (`my-webapp/` Chart)
The complete custom Helm chart has been implemented under `my-webapp/`:
* [Chart.yaml](my-webapp/Chart.yaml): Metadata and versioning
* [values.yaml](my-webapp/values.yaml): Default configurable values
* [templates/_helpers.tpl](my-webapp/templates/_helpers.tpl): Dynamic name and label helper macros
* [templates/deployment.yaml](my-webapp/templates/deployment.yaml): Parameterized Deployment
* [templates/service.yaml](my-webapp/templates/service.yaml): Configurable Service
* [templates/configmap.yaml](my-webapp/templates/configmap.yaml): Dynamic ConfigMap serving custom HTML
