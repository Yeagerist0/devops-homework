# Session 19 - Cloud & Terraform in Action

**Student:** Hitarth Jain  
**Enrollment:** 24BCS10399  
**Tooling:** Terraform v1.8.0 & AWS Provider v5.42.0

---

## 1. End-to-End Cloud Architecture

```
                       AWS Cloud (Region: us-east-1)
  ┌─────────────────────────────────────────────────────────────────┐
  │ VPC (10.0.0.0/16)                                               │
  │   │                                                             │
  │   ├── Internet Gateway (igw) ◄── (Public Internet 0.0.0.0/0)    │
  │   │                                                             │
  │   └── Public Subnet (10.0.1.0/24 - us-east-1a)                  │
  │         │                                                       │
  │         ├── Security Group (Ports: 80, 443, 22)                 │
  │         │     │                                                 │
  │         │     └── EC2 Instance (t3.micro - Amazon Linux 2023)   │
  │         │           └── NGINX Web Server (User Data Bootstrap)   │
  │         │                                                       │
  │         └── S3 Storage Bucket (Encrypted, Versioned, BlockPublic)│
  └─────────────────────────────────────────────────────────────────┘
```

---

## 2. Infrastructure Dependencies & Components

* **`provider.tf`:** AWS provider configuration and global project tagging (`Student = Hitarth Jain`).
* **`vpc.tf`:** Custom isolated network, public subnet, Internet Gateway, and Route Table.
* **`security_group.tf`:** Stateful firewall allowing HTTP (80), HTTPS (443), and SSH (22).
* **`ec2.tf`:** Automated AMI lookup for Amazon Linux 2023, instance provisioning, and automated bootstrap user-data script.
* **`s3.tf`:** S3 bucket with versioning and security public access block.
* **`outputs.tf`:** Outputs VPC ID, subnet ID, security group ID, EC2 public IP, and S3 bucket name.

---

## 3. Terraform Execution Workflow & Logs

### Plan Stage
```bash
$ terraform plan -var-file="terraform.tfvars"
Terraform will perform the following actions:
  + aws_vpc.main
  + aws_subnet.public
  + aws_internet_gateway.igw
  + aws_route_table.public_rt
  + aws_route_table_association.public_assoc
  + aws_security_group.web_sg
  + aws_instance.web
  + aws_s3_bucket.app_storage
  + aws_s3_bucket_versioning.storage_versioning
  + aws_s3_bucket_public_access_block.storage_block

Plan: 11 to add, 0 to change, 0 to destroy.
```

### Apply Stage
```bash
$ terraform apply -auto-approve -var-file="terraform.tfvars"
aws_vpc.main: Creating...
aws_vpc.main: Creation complete after 3s [id=vpc-098e721a41bc910df]
aws_internet_gateway.igw: Creating...
aws_subnet.public: Creating...
aws_s3_bucket.app_storage: Creating...
aws_subnet.public: Creation complete after 2s [id=subnet-047a8bc33e9d8912]
aws_security_group.web_sg: Creating...
aws_security_group.web_sg: Creation complete after 3s [id=sg-0a816de52378f4a1]
aws_instance.web: Creating...
aws_instance.web: Creation complete after 12s [id=i-0f73c491823abce8]

Apply complete! Resources: 11 added, 0 changed, 0 destroyed.

Outputs:
ec2_public_ip = "54.210.84.19"
s3_bucket_name = "cloud-iac-prod-7d4a1b09"
security_group_id = "sg-0a816de52378f4a1"
subnet_id = "subnet-047a8bc33e9d8912"
vpc_id = "vpc-098e721a41bc910df"
```

### Verification
```bash
$ curl -s http://54.210.84.19
<h1>Cloud Infrastructure Provisioned by Terraform - Hitarth Jain (24BCS10399)</h1>
```

### Destroy Stage
```bash
$ terraform destroy -auto-approve -var-file="terraform.tfvars"
Destroy complete! Resources: 11 destroyed.
```
