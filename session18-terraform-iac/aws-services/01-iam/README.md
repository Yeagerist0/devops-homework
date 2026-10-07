# 01. AWS IAM (Identity and Access Management)

**Student:** Hitarth Jain  
**Enrollment:** 24BCS10399  

---

## 1. What is IAM?
**AWS Identity and Access Management (IAM)** is a global web service that helps you securely control access to AWS resources. IAM controls **authentication** (who is signed in) and **authorization** (what permissions they have).

---

## 2. Core IAM Building Blocks

### Users
* An IAM User represents an individual human or application workload that needs to interact with AWS.
* Authenticates via console password or programmatic Access Key ID & Secret Access Key.

### Groups
* A collection of IAM Users.
* Allows permissions to be granted to multiple users at once (e.g., `developers`, `admins`, `security-auditors`). Groups cannot contain other groups.

### Roles
* An identity with permission policies that determine what the identity can and cannot do in AWS.
* **Does not have permanent credentials:** Assigned temporarily to trusted entities, such as EC2 instances (`InstanceProfile`), Lambda functions, or external federated identities (OIDC/SAML).

### Policies
* JSON documents that explicitly define permissions.
* Policy structure:
  ```json
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "AllowS3ReadWrite",
        "Effect": "Allow",
        "Action": [
          "s3:GetObject",
          "s3:PutObject"
        ],
        "Resource": "arn:aws:s3:::my-company-bucket/*"
      }
    ]
  }
  ```

### Permissions Evaluation
* Explicit Deny always overrides any Allow.
* Default behavior is Implicit Deny (if not explicitly allowed, access is forbidden).

---

## 3. Principle of Least Privilege
Users and roles should only be granted the minimum necessary permissions required to perform their specific job functions, and nothing more.

---

## 4. IAM Best Practices
1. **Lock away AWS Root Account:** Never use the root account for daily administration; enable MFA immediately.
2. **Enforce MFA (Multi-Factor Authentication):** Mandate hardware or virtual MFA for all administrative users.
3. **Use IAM Roles for Applications:** Never hardcode Access Keys in EC2 instances or code. Attach an IAM Role via Instance Profile instead.
4. **Regular Credential Rotation:** Rotate programmatic access keys periodically.
5. **Auditing with CloudTrail & IAM Access Advisor:** Review unused permissions regularly.

---

## 5. Common Use Cases
* Granting a microservice running on EKS temporary access to write to DynamoDB via IAM Roles for Service Accounts (IRSA).
* Providing cross-account access between `staging` and `production` AWS environments without sharing credentials.
