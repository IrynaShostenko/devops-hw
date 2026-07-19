# Lesson DB Module - Flexible Terraform RDS Module

This project implements a reusable Terraform module for creating database infrastructure in AWS.

The module supports two modes:

1. Standard Amazon RDS instance
2. Amazon Aurora cluster

The database type is controlled by the variable:

    use_aurora

If `use_aurora = false`, the module creates a standard RDS instance.

If `use_aurora = true`, the module creates an Aurora cluster with cluster instances.

## Project goal

The goal of this homework is to create a production-ready reusable Terraform module that can provision different database types with minimal variable changes.

The module automatically creates:

- DB Subnet Group
- Security Group
- Parameter Group
- Standard RDS instance or Aurora cluster
- Outputs for endpoint, port, database name and security group

## Project structure

    lesson-db-module/
    ├── main.tf
    ├── backend.tf
    ├── providers.tf
    ├── variables.tf
    ├── outputs.tf
    ├── README.md
    ├── modules/
    │   ├── s3-backend/
    │   ├── vpc/
    │   ├── ecr/
    │   ├── eks/
    │   ├── jenkins/
    │   ├── argo_cd/
    │   └── rds/
    │       ├── shared.tf
    │       ├── rds.tf
    │       ├── aurora.tf
    │       ├── variables.tf
    │       └── outputs.tf
    └── charts/
        └── django-app/

## RDS module structure

The RDS module is located in:

    modules/rds

Files:

    shared.tf      Common resources: subnet group, security group, ingress and egress rules
    rds.tf         Standard RDS instance and DB parameter group
    aurora.tf      Aurora cluster, Aurora instances and cluster parameter group
    variables.tf   Input variables with types, descriptions and defaults
    outputs.tf     Module outputs

## How the module works

The module uses conditional logic with `count`.

For standard RDS:

    use_aurora = false

Terraform creates:

- aws_db_instance
- aws_db_parameter_group

For Aurora:

    use_aurora = true

Terraform creates:

- aws_rds_cluster
- aws_rds_cluster_instance
- aws_rds_cluster_parameter_group

In both cases, Terraform creates:

- aws_db_subnet_group
- aws_security_group
- aws_vpc_security_group_ingress_rule
- aws_vpc_security_group_egress_rule

## Example usage: Standard RDS PostgreSQL

    module "rds" {
      source = "./modules/rds"

      name_prefix = "lesson-db-module"

      use_aurora = false

      vpc_id     = module.vpc.vpc_id
      subnet_ids = module.vpc.private_subnets

      allowed_cidr_blocks = []
      allowed_security_group_ids = []

      engine         = "postgres"
      engine_version = "15.5"
      instance_class = "db.t3.micro"

      allocated_storage = 20
      storage_type      = "gp3"
      storage_encrypted = true

      db_name         = "appdb"
      master_username = "dbadmin"
      master_password = var.rds_master_password

      multi_az            = false
      publicly_accessible = false

      backup_retention_period = 7
      deletion_protection     = false
      skip_final_snapshot     = true

      tags = {
        Environment = "dev"
        Lesson      = "lesson-db-module"
      }
    }

## Example usage: Standard RDS MySQL

    module "rds" {
      source = "./modules/rds"

      name_prefix = "lesson-db-module-mysql"

      use_aurora = false

      vpc_id     = module.vpc.vpc_id
      subnet_ids = module.vpc.private_subnets

      engine         = "mysql"
      engine_version = "8.0"
      instance_class = "db.t3.micro"

      db_name         = "appdb"
      master_username = "dbadmin"
      master_password = var.rds_master_password

      publicly_accessible = false
      skip_final_snapshot = true
    }

## Example usage: Aurora PostgreSQL

    module "rds" {
      source = "./modules/rds"

      name_prefix = "lesson-db-module-aurora"

      use_aurora = true

      vpc_id     = module.vpc.vpc_id
      subnet_ids = module.vpc.private_subnets

      engine         = "postgres"
      engine_version = "15.5"
      instance_class = "db.t3.medium"

      aurora_instance_count = 1

      db_name         = "appdb"
      master_username = "dbadmin"
      master_password = var.rds_master_password

      publicly_accessible = false
      skip_final_snapshot = true
    }

## Root module configuration

In this project, the RDS module is connected in the root `main.tf` file:

    module "rds" {
      source = "./modules/rds"

      name_prefix = var.rds_name_prefix

      use_aurora = var.rds_use_aurora

      vpc_id     = module.vpc.vpc_id
      subnet_ids = module.vpc.private_subnets

      allowed_cidr_blocks        = var.rds_allowed_cidr_blocks
      allowed_security_group_ids = var.rds_allowed_security_group_ids

      engine                 = var.rds_engine
      engine_version         = var.rds_engine_version
      parameter_group_family = var.rds_parameter_group_family

      instance_class        = var.rds_instance_class
      aurora_instance_count = var.rds_aurora_instance_count

      allocated_storage     = var.rds_allocated_storage
      max_allocated_storage = var.rds_max_allocated_storage
      storage_type          = var.rds_storage_type
      storage_encrypted     = var.rds_storage_encrypted

      db_name         = var.rds_db_name
      master_username = var.rds_master_username
      master_password = var.rds_master_password

      port                = var.rds_port
      multi_az            = var.rds_multi_az
      publicly_accessible = var.rds_publicly_accessible

      backup_retention_period   = var.rds_backup_retention_period
      deletion_protection       = var.rds_deletion_protection
      skip_final_snapshot       = var.rds_skip_final_snapshot
      final_snapshot_identifier = var.rds_final_snapshot_identifier

      apply_immediately = var.rds_apply_immediately

      tags = {
        Environment = var.environment
        Lesson      = "lesson-db-module"
      }
    }

## How to switch between RDS and Aurora

To create a standard RDS instance:

    rds_use_aurora = false

To create Aurora:

    rds_use_aurora = true

Only this variable changes the database type.

## How to change database engine

For PostgreSQL:

    rds_engine         = "postgres"
    rds_engine_version = "15.5"

For MySQL:

    rds_engine         = "mysql"
    rds_engine_version = "8.0"

For Aurora PostgreSQL, you can use:

    rds_use_aurora    = true
    rds_engine         = "postgres"
    rds_engine_version = "15.5"

The module automatically converts `postgres` to `aurora-postgresql` when Aurora mode is enabled.

For Aurora MySQL, you can use:

    rds_use_aurora    = true
    rds_engine         = "mysql"
    rds_engine_version = "8.0"

The module automatically converts `mysql` to `aurora-mysql` when Aurora mode is enabled.

## How to change instance class

For a small standard RDS instance:

    rds_instance_class = "db.t3.micro"

For Aurora, use an Aurora-compatible class, for example:

    rds_instance_class = "db.t3.medium"

## How to enable Multi-AZ

For standard RDS:

    rds_multi_az = true

Aurora already provides cluster-based high availability, so standard RDS `multi_az` is mainly relevant when `use_aurora = false`.

## How to configure access

By default, the database is not publicly accessible:

    rds_publicly_accessible = false

Database access can be allowed from CIDR blocks:

    rds_allowed_cidr_blocks = ["10.0.0.0/16"]

Or from specific security groups:

    rds_allowed_security_group_ids = ["sg-xxxxxxxxxxxxxxxxx"]

Private subnets are recommended for database resources.

## Parameter groups

The module creates a parameter group automatically.

For PostgreSQL, default parameters include:

- max_connections
- log_statement
- work_mem

For MySQL, the module uses compatible parameters by default.

Custom parameters can be passed through the `parameters` variable inside the module:

    parameters = {
      max_connections = {
        value        = "150"
        apply_method = "pending-reboot"
      }
    }

The root configuration also supports automatic parameter group family detection through:

    rds_parameter_group_family = null

If needed, it can be set manually:

    rds_parameter_group_family = "postgres15"

## Variables

| Variable | Type | Default | Description |
|---|---|---|---|
| environment | string | dev | Environment name. |
| rds_name_prefix | string | lesson-db-module | Name prefix for RDS resources. |
| rds_use_aurora | bool | false | If true, creates Aurora. If false, creates standard RDS. |
| rds_allowed_cidr_blocks | list(string) | [] | CIDR blocks allowed to connect to DB. |
| rds_allowed_security_group_ids | list(string) | [] | Security groups allowed to connect to DB. |
| rds_engine | string | postgres | Database engine: postgres, mysql, aurora-postgresql or aurora-mysql. |
| rds_engine_version | string | 15.5 | Database engine version. |
| rds_parameter_group_family | string | null | Parameter group family. If null, module generates it automatically. |
| rds_instance_class | string | db.t3.micro | Database instance class. |
| rds_aurora_instance_count | number | 1 | Number of Aurora instances. |
| rds_allocated_storage | number | 20 | Allocated storage in GB for standard RDS. |
| rds_max_allocated_storage | number | 0 | Maximum storage for autoscaling. 0 disables it. |
| rds_storage_type | string | gp3 | Storage type for standard RDS. |
| rds_storage_encrypted | bool | true | Enables storage encryption. |
| rds_db_name | string | appdb | Initial database name. |
| rds_master_username | string | dbadmin | Master username. |
| rds_master_password | string | required | Master password. Sensitive value. |
| rds_port | number | null | Database port. If null, the module uses 5432 or 3306. |
| rds_multi_az | bool | false | Enables Multi-AZ for standard RDS. |
| rds_publicly_accessible | bool | false | Controls public accessibility. |
| rds_backup_retention_period | number | 7 | Backup retention period in days. |
| rds_deletion_protection | bool | false | Enables deletion protection. |
| rds_skip_final_snapshot | bool | true | Skips final snapshot during deletion. |
| rds_final_snapshot_identifier | string | null | Final snapshot name if snapshots are enabled. |
| rds_apply_immediately | bool | true | Applies DB changes immediately. |

## Sensitive values

Database password is sensitive and must not be stored in Git.

Pass it through an environment variable:

    export TF_VAR_rds_master_password="TemporaryPassword123!"

For Jenkins, this project also uses:

    export TF_VAR_jenkins_admin_password="temporary-password-for-plan"

After Terraform operations, unset sensitive variables:

    unset TF_VAR_rds_master_password
    unset TF_VAR_jenkins_admin_password

## Terraform backend

The project contains `backend.tf` for S3 backend and DynamoDB locking.

At the first launch, the S3 bucket and DynamoDB table must exist before this backend can be used.

For local validation without remote backend:

    terraform init -backend=false
    terraform validate

For real usage with backend:

    terraform init
    terraform plan
    terraform apply

## Terraform commands

Initialize Terraform without backend for local validation:

    terraform init -backend=false

Format code:

    terraform fmt -recursive

Validate code:

    terraform validate

Run plan:

    export TF_VAR_jenkins_admin_password="temporary-password-for-plan"
    export TF_VAR_rds_master_password="TemporaryPassword123!"

    terraform plan

    unset TF_VAR_jenkins_admin_password
    unset TF_VAR_rds_master_password

Apply infrastructure:

    export TF_VAR_jenkins_admin_password="your-jenkins-password"
    export TF_VAR_rds_master_password="your-secure-db-password"

    terraform apply

    unset TF_VAR_jenkins_admin_password
    unset TF_VAR_rds_master_password

Destroy infrastructure:

    export TF_VAR_jenkins_admin_password="your-jenkins-password"
    export TF_VAR_rds_master_password="your-secure-db-password"

    terraform destroy

    unset TF_VAR_jenkins_admin_password
    unset TF_VAR_rds_master_password

## Outputs

The root module returns:

- rds_db_type
- rds_engine
- rds_endpoint
- rds_reader_endpoint
- rds_port
- rds_database_name
- rds_security_group_id
- rds_subnet_group_name
- rds_parameter_group_name

The RDS module returns:

- db_type
- engine
- endpoint
- reader_endpoint
- port
- database_name
- security_group_id
- subnet_group_name
- parameter_group_name
- rds_instance_id
- aurora_cluster_id
- aurora_instance_ids

## Cost warning

RDS, Aurora, NAT Gateway, EKS and LoadBalancers may generate costs.

After testing, destroy all resources:

    terraform destroy

Aurora can be more expensive than a small standard RDS instance. For simple testing, use:

    rds_use_aurora = false

## Submission

Submit:

1. GitHub repository link with branch:

       lesson-db-module

2. ZIP archive:

       lesson-db-module_Iryna_Shostenko.zip

3. Ready-to-run Terraform code.
