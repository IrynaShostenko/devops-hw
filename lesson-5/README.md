# Lesson 5 - Terraform AWS Infrastructure

This project creates AWS infrastructure using Terraform and a modular project structure.

The infrastructure includes:

- S3 bucket for Terraform state storage
- DynamoDB table for Terraform state locking
- VPC with public and private subnets
- Internet Gateway
- NAT Gateway
- Route tables and route table associations
- ECR repository for Docker images

## Project structure

    lesson-5/
    ├── main.tf
    ├── backend.tf
    ├── variables.tf
    ├── outputs.tf
    ├── README.md
    └── modules/
        ├── s3-backend/
        │   ├── s3.tf
        │   ├── dynamodb.tf
        │   ├── variables.tf
        │   └── outputs.tf
        ├── vpc/
        │   ├── vpc.tf
        │   ├── routes.tf
        │   ├── variables.tf
        │   └── outputs.tf
        └── ecr/
            ├── ecr.tf
            ├── variables.tf
            └── outputs.tf

## Root files

### main.tf

The main file connects all Terraform modules:

- s3-backend
- vpc
- ecr

It also configures the AWS provider.

### variables.tf

This file contains root-level variables with default values.

These variables are passed to modules from `main.tf`.

### backend.tf

This file configures remote Terraform state storage in S3.

The backend uses:

- S3 bucket for storing the state file
- DynamoDB table for state locking
- encryption enabled

### outputs.tf

This file displays important output values after `terraform apply`, such as:

- S3 bucket name
- DynamoDB table name
- VPC ID
- public subnet IDs
- private subnet IDs
- ECR repository name
- ECR repository URL

## Modules

## s3-backend module

The `s3-backend` module creates resources for remote Terraform state storage.

Resources created:

- S3 bucket
- S3 bucket versioning
- S3 server-side encryption
- S3 public access block
- S3 lifecycle configuration
- DynamoDB table for state locking

Security improvements:

- Public access to the bucket is blocked.
- Server-side encryption is enabled.
- Old non-current versions of state files are cleaned up using a lifecycle policy.

## vpc module

The `vpc` module creates network infrastructure.

Resources created:

- VPC
- 3 public subnets
- 3 private subnets
- Internet Gateway
- NAT Gateway
- Elastic IP for NAT Gateway
- Public route table
- Private route table
- Route table associations

The public subnets have access to the internet through the Internet Gateway.

The private subnets have outbound internet access through the NAT Gateway.

## ecr module

The `ecr` module creates an Elastic Container Registry repository.

Resources created:

- ECR repository
- ECR repository policy
- ECR lifecycle policy

Security and cleanup settings:

- Image scanning on push is enabled.
- Repository encryption is enabled.
- Untagged images older than 14 days are expired.
- Only the last 10 tagged images with prefix `v` are kept.

## AWS region

The project uses the following AWS region:

    us-west-2

## Terraform commands

Initialize Terraform:

    terraform init

Format Terraform files:

    terraform fmt -recursive

Validate Terraform configuration:

    terraform validate

Show execution plan:

    terraform plan

Apply infrastructure changes:

    terraform apply

Destroy infrastructure:

    terraform destroy

## Backend initialization workflow

At the first setup, the S3 bucket and DynamoDB table must exist before Terraform can use them as a backend.

The workflow is:

1. Create S3 and DynamoDB resources.
2. Enable the S3 backend in `backend.tf`.
3. Migrate local state to remote state:

       terraform init -migrate-state

For existing infrastructure, use:

    terraform init -reconfigure

## Current outputs

The project outputs:

- `s3_bucket_name`
- `dynamodb_table_name`
- `vpc_id`
- `public_subnets`
- `private_subnets`
- `ecr_repository_name`
- `ecr_repository_url`

## Notes

The NAT Gateway may generate AWS costs while it exists.

After the homework is reviewed, the infrastructure can be removed with:

    terraform destroy