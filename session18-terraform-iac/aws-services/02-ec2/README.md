# 02. AWS EC2 (Elastic Compute Cloud)

**Student:** Hitarth Jain  
**Enrollment:** 24BCS10399  

---

## 1. What is EC2?
**Amazon Elastic Compute Cloud (Amazon EC2)** provides scalable, on-demand compute capacity in the cloud. It eliminates the need to invest in hardware upfront, allowing rapid building and deployment of applications on virtual machines (instances).

---

## 2. Core Concepts

### Amazon Machine Image (AMI)
* A pre-configured template providing the information required to launch an instance (OS, architecture, application server, initial packages).
* Types: AWS Public AMIs (Amazon Linux, Ubuntu, Debian), AWS Marketplace AMIs, and Custom AMIs created from existing instances.

### Instance Types
Classified by compute, memory, storage, and networking capacity:
* **General Purpose:** `t3`, `t4g`, `m6i` (balanced compute and memory).
* **Compute Optimized:** `c6i`, `c7g` (high-performance processors for batch processing, video encoding).
* **Memory Optimized:** `r6i`, `r7g` (databases, in-memory caches like Redis).
* **Storage Optimized:** `i3en`, `d3` (high sequential read/write, data warehousing).

### Key Pairs
* Public-key cryptography used to securely authenticate to Linux (SSH via port 22) or Windows (RDP via port 3389). AWS stores the public key; you hold the private key (`.pem`).

### Security Groups
* Acts as a **virtual stateful firewall** at the instance level.
* **Stateful:** If inbound traffic is allowed, corresponding outbound response traffic is automatically permitted regardless of outbound rules.
* By default, blocks all inbound traffic and allows all outbound traffic.

### Elastic Block Store (EBS)
* Persistent, network-attached block storage volumes for EC2 instances.
* Volume types: General Purpose SSD (`gp3`), Provisioned IOPS SSD (`io2`), Throughput Optimized HDD (`st1`).
* Can take point-in-time Snapshots backed up to Amazon S3.

### Public vs Private IP
* **Public IP:** Routable on the public Internet. Assigned dynamically from AWS's pool; changes upon instance stop/start unless an Elastic IP (static IPv4) is allocated.
* **Private IP:** Non-routable on the public internet. Used for internal VPC communication; remains unchanged throughout instance lifecycle.

### Instance Lifecycle
`Pending` ──► `Running` ──► `Stopping` ──► `Stopped` ──► `Terminated`

---

## 3. Common Use Cases
* Web server fleets running behind an Application Load Balancer (ALB).
* Self-hosted database clusters (PostgreSQL, Cassandra).
* Continuous integration worker nodes (Jenkins agents, GitLab runners).
