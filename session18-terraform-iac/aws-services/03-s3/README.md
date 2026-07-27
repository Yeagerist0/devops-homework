# 03. AWS S3 (Simple Storage Service)

**Student:** Hitarth Jain  
**Enrollment:** 24BCS10399  

---

## 1. What is S3?
**Amazon Simple Storage Service (Amazon S3)** is an object storage service offering industry-leading scalability, data availability, security, and performance. Designed for 99.999999999% (11 9's) of durability.

---

## 2. Core Concepts

### Buckets
* Containers for objects stored in S3.
* Bucket names must be **globally unique** across all AWS accounts worldwide and DNS-compliant (3–63 characters, lowercase).

### Objects
* Fundamental entities stored in S3: comprises data (file content), a Key (name/path), metadata (name-value pairs), and a Version ID. Size up to 5 TB per object.

### Storage Classes

| Storage Class | Availability | Retrieval Fee | Best For |
|---|---|---|---|
| **S3 Standard** | 99.99% | None | Frequently accessed data, active web assets |
| **S3 Intelligent-Tiering** | 99.9% | Automated auto-tiering | Data with unknown or changing access patterns |
| **S3 Standard-IA** | 99.9% | Per GB retrieved | Long-term backups accessed less than once a month |
| **S3 One Zone-IA** | 99.5% | Per GB retrieved | Re-creatable secondary backup data |
| **S3 Glacier Flexible** | 99.99% | Minutes to hours retrieval | Archive data, regulatory retention |
| **S3 Glacier Deep Archive** | 99.99% | Hours retrieval (cheapest) | Long-term digital preservation (7-10+ years) |

### Versioning
* Keeps multiple variants of an object in the same bucket.
* Protects against accidental deletes (creates a Delete Marker instead of permanent destruction) and application overwrite bugs.

### Lifecycle Policies
* Automated rules to transition objects to cheaper storage classes over time or permanently delete expired objects (e.g., transition to S3 Glacier after 90 days, expire after 365 days).

### Encryption
* **Server-Side Encryption:**
  * SSE-S3 (`AES256`): Managed directly by S3.
  * SSE-KMS (`aws:kms`): Customer-managed keys via AWS KMS for auditability.
  * SSE-C: Customer-provided encryption keys.
* **Client-Side Encryption:** Data encrypted locally before transmission.

### Bucket Policies
* JSON-based resource policies attached directly to the S3 bucket to regulate cross-account access, enforce HTTPS (`aws:SecureTransport`), or block unencrypted uploads.

---

## 3. Common Use Cases
* Hosting static websites (HTML/CSS/JS frontend).
* Backup and disaster recovery storage repository.
* Data lake storage for big data analytics (Amazon Athena, Apache Spark).
