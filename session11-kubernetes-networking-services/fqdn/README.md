# Task 3: Fully Qualified Domain Names (FQDN) in Kubernetes

**Student:** Hitarth Jain  
**Enrollment:** 24BCS10399  

---

## 1. What is an FQDN?
A **Fully Qualified Domain Name (FQDN)** is the complete, unambiguous domain name specifying its exact location in the DNS hierarchy tree (down to the root zone).

In Kubernetes, internal service discovery assigns an FQDN to every Service and Pod, allowing components to communicate seamlessly across namespaces without hardcoding dynamic IP addresses.

---

## 2. Kubernetes DNS Naming Convention

The standard format for a Service FQDN is:

$$\text{<service-name>}.\text{<namespace>}.\text{svc}.\text{cluster.local}$$

Where:
* `<service-name>`: Name of the Kubernetes Service resource
* `<namespace>`: Namespace where the Service is deployed
* `svc`: Resource category indicator (identifies it as a Service)
* `cluster.local`: Default cluster domain suffix (defined in kubelet / CoreDNS)

---

## 3. Namespace-based DNS Resolution

Given a client Pod running in namespace `frontend`:

| Destination Service | Namespace | Short Name | Relative Domain | Full FQDN |
|---|---|---|---|---|
| Same namespace (`auth-svc`) | `frontend` | `auth-svc` | `auth-svc.frontend` | `auth-svc.frontend.svc.cluster.local` |
| Different namespace (`payment-svc`) | `payments` | *(Requires NS)* | `payment-svc.payments` | `payment-svc.payments.svc.cluster.local` |
| Database (`postgres-db`) | `database` | *(Requires NS)* | `postgres-db.database` | `postgres-db.database.svc.cluster.local` |

### How `resolv.conf` Powers Search Paths
Inside every container, `/etc/resolv.conf` is injected with search domains:
```bash
$ kubectl exec -it test-pod -- cat /etc/resolv.conf
search frontend.svc.cluster.local svc.cluster.local cluster.local
nameserver 10.96.0.10
options ndots:5
```
Because of `search frontend.svc.cluster.local`, calling `curl auth-svc` automatically checks `auth-svc.frontend.svc.cluster.local`.

---

## 4. Pod-to-Service Communication
* **Pods are ephemeral:** Their IPs change upon restart, crash, or rescheduling.
* **Services provide stability:** A Service gets a static virtual ClusterIP and DNS entry.
* **Kube-proxy** programs local IPVS/iptables rules to translate the ClusterIP to healthy endpoint Pod IPs automatically.
