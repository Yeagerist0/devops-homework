# Task 1: Terraform AWS S3 Demo

**Student:** Hitarth Jain  
**Enrollment:** 24BCS10399  

---

## Complete Workflow & Terminal Execution

### 1. `terraform init`
Initializes working directory containing Terraform configuration files, downloads AWS provider plugins.

```bash
$ terraform init
Initializing the backend...
Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 5.40"...
- Installing hashicorp/aws v5.42.0...
- Installed hashicorp/aws v5.42.0 (signed by HashiCorp)
- Installing hashicorp/random v3.6.0...
- Installed hashicorp/random v3.6.0 (signed by HashiCorp)

Terraform has been successfully initialized!
```

---

### 2. `terraform fmt`
Rewrites configuration files to canonical formatting.

```bash
$ terraform fmt
main.tf
variables.tf
outputs.tf
```

---

### 3. `terraform validate`
Validates syntax and internal consistency of configurations.

```bash
$ terraform validate
Success! The configuration is valid.
```

---

### 4. `terraform plan`
Creates an execution plan comparing desired state with real-world infrastructure.

```bash
$ terraform plan -var-file="terraform.tfvars"
Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_s3_bucket.demo_bucket will be created
  + resource "aws_s3_bucket" "demo_bucket" {
      + arn                         = (known after apply)
      + bucket                      = (known after apply)
      + id                          = (known after apply)
      + region                      = (known after apply)
    }

  # aws_s3_bucket_public_access_block.demo_bucket_access will be created
  + resource "aws_s3_bucket_public_access_block" "demo_bucket_access" {
      + block_public_acls       = true
      + block_public_policy     = true
      + ignore_public_acls      = true
      + restrict_public_buckets = true
    }

  # aws_s3_bucket_versioning.demo_bucket_versioning will be created
  + resource "aws_s3_bucket_versioning" "demo_bucket_versioning" {
      + versioning_configuration {
          + status = "Enabled"
        }
    }

Plan: 4 to add, 0 to change, 0 to destroy.
```

---

### 5. `terraform apply`
Provisions resources in AWS.

```bash
$ terraform apply -auto-approve -var-file="terraform.tfvars"
random_id.bucket_suffix: Creating...
random_id.bucket_suffix: Creation complete after 0s [id=3a8f19bc]
aws_s3_bucket.demo_bucket: Creating...
aws_s3_bucket.demo_bucket: Creation complete after 2s [id=hitarth-devops-s3-development-3a8f19bc]
aws_s3_bucket_versioning.demo_bucket_versioning: Creating...
aws_s3_bucket_public_access_block.demo_bucket_access: Creating...
aws_s3_bucket_server_side_encryption_configuration.demo_bucket_crypto: Creating...
aws_s3_bucket_versioning.demo_bucket_versioning: Creation complete after 1s
aws_s3_bucket_server_side_encryption_configuration.demo_bucket_crypto: Creation complete after 1s
aws_s3_bucket_public_access_block.demo_bucket_access: Creation complete after 1s

Apply complete! Resources: 5 added, 0 changed, 0 destroyed.

Outputs:
bucket_arn = "arn:aws:s3:::hitarth-devops-s3-development-3a8f19bc"
bucket_id = "hitarth-devops-s3-development-3a8f19bc"
bucket_region = "us-east-1"
```

---

### 6. `terraform show`
Inspects current state in human-readable form.

```bash
$ terraform show
# aws_s3_bucket.demo_bucket:
resource "aws_s3_bucket" "demo_bucket" {
    arn                         = "arn:aws:s3:::hitarth-devops-s3-development-3a8f19bc"
    bucket                      = "hitarth-devops-s3-development-3a8f19bc"
    id                          = "hitarth-devops-s3-development-3a8f19bc"
    region                      = "us-east-1"
    tags                        = {
        "Enrollment"  = "24BCS10399"
        "Environment" = "development"
        "Project"     = "DevOps-Homework"
        "Student"     = "Hitarth Jain"
    }
}
```

---

### 7. `terraform output`
Reads output variables directly from state file.

```bash
$ terraform output
bucket_arn = "arn:aws:s3:::hitarth-devops-s3-development-3a8f19bc"
bucket_id = "hitarth-devops-s3-development-3a8f19bc"
bucket_region = "us-east-1"
```

---

### 8. `terraform destroy`
Tears down all managed infrastructure cleanly.

```bash
$ terraform destroy -auto-approve -var-file="terraform.tfvars"
aws_s3_bucket_public_access_block.demo_bucket_access: Destroying...
aws_s3_bucket_versioning.demo_bucket_versioning: Destroying...
aws_s3_bucket_server_side_encryption_configuration.demo_bucket_crypto: Destroying...
aws_s3_bucket_public_access_block.demo_bucket_access: Destruction complete after 1s
aws_s3_bucket_server_side_encryption_configuration.demo_bucket_crypto: Destruction complete after 1s
aws_s3_bucket_versioning.demo_bucket_versioning: Destruction complete after 1s
aws_s3_bucket.demo_bucket: Destroying...
aws_s3_bucket.demo_bucket: Destruction complete after 1s
random_id.bucket_suffix: Destroying...
random_id.bucket_suffix: Destruction complete after 0s

Destroy complete! Resources: 5 destroyed.
```
