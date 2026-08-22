# 05. AWS Database Services: DynamoDB & RDS

**Student:** Hitarth Jain  
**Enrollment:** 24BCS10399  

---

## 1. Amazon DynamoDB (NoSQL)

Amazon DynamoDB is a fully managed, serverless, key-value and document NoSQL database designed for single-digit millisecond latency at any scale.

### Core Concepts:
* **Tables:** Collection of data items (similar to a table in SQL, but schema-less except for the primary key).
* **Items:** A single record within a table (collection of attributes, similar to a row). Size up to 400 KB.
* **Attributes:** Fundamental data element (name and value, similar to a column).
* **Partition Key (HASH):** Mandatory primary key attribute used to distribute items across storage partitions via an internal hash function.
* **Sort Key (RANGE):** Optional second attribute creating a Composite Primary Key. Allows querying ranges within the same partition.
* **Use Cases:** Real-time gaming leaderboards, shopping cart sessions, IoT telemetry ingestion, user authentication tokens.

---

## 2. Amazon RDS (Relational Database Service)

Amazon RDS is a managed service that makes it easy to set up, operate, and scale a relational database in the cloud.

### Core Concepts:
* **Supported Engines:** PostgreSQL, MySQL, MariaDB, Oracle, Microsoft SQL Server, and Amazon Aurora (AWS high-performance cloud-native engine).
* **DB Instances:** Isolated database environments running in a dedicated VPC subnet group.
* **Security:** Network isolation via private subnets, security group rules, encryption at rest via AWS KMS, and SSL/TLS in transit.
* **Automated Backups & Snapshots:** Point-in-time recovery (PITR) up to 35 days, plus manual user snapshots.
* **Multi-AZ Deployments:** High Availability architecture where AWS automatically provisions and maintains a synchronous standby replica in a different Availability Zone. Automated failover in 60–120 seconds if primary fails.
* **Read Replicas:** Asynchronous copies of the primary instance used to offload read-heavy workloads (PostgreSQL, MySQL, MariaDB).
* **Use Cases:** E-commerce transactions (ACID compliance required), ERP applications, CMS (WordPress), financial ledger systems.
