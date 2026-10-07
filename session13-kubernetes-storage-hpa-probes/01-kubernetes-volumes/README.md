# Task 1: Kubernetes Volumes & Storage

**Student:** Hitarth Jain  
**Enrollment:** 24BCS10399  

---

## 1. Volume Types Overview

Because containers inside Pods have an ephemeral filesystem (any write operations are wiped when a container restarts), Kubernetes provides Volume abstractions.

---

### A. `emptyDir`
* **Lifecycle:** Tied to the Pod's lifecycle. Created when a Pod is assigned to a node; destroyed permanently when the Pod is deleted.
* **Use Case:** Scratch space, sorting large datasets in memory/disk, or sharing data between multiple containers in the same Pod (e.g., logging sidecar).

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: emptydir-demo
spec:
  containers:
  - name: writer
    image: busybox:1.36
    command: ["sh", "-c", "echo 'Hello from Writer' > /data/shared.txt; sleep 3600"]
    volumeMounts:
    - name: scratch-volume
      mountPath: /data
  - name: reader
    image: busybox:1.36
    command: ["sh", "-c", "sleep 2; cat /data/shared.txt; sleep 3600"]
    volumeMounts:
    - name: scratch-volume
      mountPath: /data
  volumes:
  - name: scratch-volume
    emptyDir: {}
```

---

### B. `hostPath`
* **Lifecycle:** Mounts a file or directory from the host worker node's filesystem directly into the Pod.
* **Use Case:** DaemonSets needing access to node internals (e.g., cAdvisor reading `/sys`, Fluentd reading `/var/log`).
* **Caution:** If the Pod moves to a different node, data does not follow. Security risk in production multi-tenant clusters.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: hostpath-demo
spec:
  containers:
  - name: log-collector
    image: busybox:1.36
    command: ["sh", "-c", "ls -l /host-logs; sleep 3600"]
    volumeMounts:
    - name: host-log-volume
      mountPath: /host-logs
  volumes:
  - name: host-log-volume
    hostPath:
      path: /var/log
      type: Directory
```

---

### C. PersistentVolume (PV) vs PersistentVolumeClaim (PVC)
* **PersistentVolume (PV):** A piece of storage in the cluster provisioned by an administrator or dynamically provisioned via StorageClass. It exists independently of any Pod lifecycle.
* **PersistentVolumeClaim (PVC):** A request for storage by a user (specifying size and access modes: ReadWriteOnce, ReadOnlyMany, ReadWriteMany).
* **Binding:** The Control Plane matches a PVC to an available PV with adequate capacity and matching access mode.

#### PV Definition:
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: static-pv-demo
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  hostPath:
    path: /mnt/data
```

#### PVC Definition:
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: static-pvc-demo
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
```

---

### D. StorageClass & Dynamic Provisioning
* **Static Provisioning:** Cluster admin manually creates PVs beforehand. PVC binds to an existing PV.
* **Dynamic Provisioning:** Storage is created **on demand** automatically when a PVC requests it.
* A **StorageClass** defines which storage provisioner (e.g. AWS EBS CSI `ebs.csi.aws.com`, Google GCE-PD, Ceph, Minikube hostpath-provisioner) to use and parameters like volume type (`gp3`, `io2`).

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-ssd
provisioner: kubernetes.io/no-provisioner # or aws-ebs / standard
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
```

When a user submits a PVC specifying `storageClassName: standard`, the provisioner automatically provisions the underlying physical volume and creates a matching PV bound to the PVC.
