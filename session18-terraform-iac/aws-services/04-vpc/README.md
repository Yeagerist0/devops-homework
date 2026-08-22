# 04. AWS VPC (Virtual Private Cloud)

**Student:** Hitarth Jain  
**Enrollment:** 24BCS10399  

---

## 1. What is VPC?
**Amazon Virtual Private Cloud (Amazon VPC)** lets you provision a logically isolated section of the AWS Cloud where you can launch AWS resources in a virtual network that you define.

---

## 2. Core VPC Networking Components

### CIDR Blocks
* Classless Inter-Domain Routing notation defining the IP address range (e.g., `10.0.0.0/16` provides 65,536 private IPv4 addresses).

### Subnets
* A range of IP addresses within your VPC, tied to a single Availability Zone (AZ).
* AWS reserves 5 IP addresses per subnet (`.0` network, `.1` router, `.2` DNS, `.3` future use, `.255` broadcast).

### Route Tables
* A set of rules (routes) determining where network traffic from your subnet or gateway is directed.

### Internet Gateway (IGW)
* A horizontally scaled, redundant VPC component that allows bidirectional communication between instances in your VPC and the internet.

### NAT Gateway
* Network Address Translation service that enables instances in a **private subnet** to connect to the internet (for software updates) while preventing external internet traffic from initiating inbound connections to them. Must be deployed in a public subnet.

### Security Groups vs Network ACLs (NACLs)

| Feature | Security Group (SG) | Network ACL (NACL) |
|---|---|---|
| **Level** | Instance / ENI level | Subnet boundary level |
| **State** | **Stateful** (Return traffic automatically permitted) | **Stateless** (Inbound & Outbound must be explicitly allowed) |
| **Rules** | Allow rules only | Allow AND Deny rules |
| **Evaluation**| All rules evaluated before decision | Evaluated in numerical order (lowest first) |

### Public vs Private Subnets
* **Public Subnet:** Route table contains a route to an Internet Gateway (`0.0.0.0/0 -> igw-xxxx`). Instances can have public IPs.
* **Private Subnet:** No direct route to an IGW (`0.0.0.0/0 -> nat-xxxx`). Backend databases and private microservices reside here.
