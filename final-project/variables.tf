variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-west-2"
}

variable "bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  type        = string
  default     = "iryna-devops-tf-state-559292737982"
}

variable "table_name" {
  description = "Name of the DynamoDB table for Terraform state locking"
  type        = string
  default     = "terraform-locks"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnets" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "availability_zones" {
  description = "Availability zones for subnets"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

variable "vpc_name" {
  description = "Name prefix for VPC resources"
  type        = string
  default     = "final-project-vpc"
}

variable "ecr_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "final-project-ecr"
}

variable "scan_on_push" {
  description = "Enable image scanning on push for ECR"
  type        = bool
  default     = true
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "final-project-eks"
}

variable "eks_cluster_version" {
  description = "Kubernetes version for EKS"
  type        = string
  default     = "1.33"
}

variable "eks_node_instance_types" {
  description = "EC2 instance types for EKS worker nodes"
  type        = list(string)
  default     = ["t3.small"]
}

variable "eks_desired_size" {
  description = "Desired number of EKS worker nodes"
  type        = number
  default     = 3
}

variable "eks_min_size" {
  description = "Minimum number of EKS worker nodes"
  type        = number
  default     = 2
}

variable "eks_max_size" {
  description = "Maximum number of EKS worker nodes"
  type        = number
  default     = 3
}

variable "jenkins_admin_password" {
  description = "Jenkins admin password"
  type        = string
  sensitive   = true
}
variable "environment" {
  description = "Environment name."
  type        = string
  default     = "dev"
}

variable "rds_name_prefix" {
  description = "Name prefix for RDS module resources."
  type        = string
  default     = "final-project"
}

variable "rds_use_aurora" {
  description = "If true, creates Aurora cluster. If false, creates standard RDS instance."
  type        = bool
  default     = false
}

variable "rds_allowed_cidr_blocks" {
  description = "CIDR blocks allowed to connect to the database."
  type        = list(string)
  default     = []
}

variable "rds_allowed_security_group_ids" {
  description = "Security group IDs allowed to connect to the database."
  type        = list(string)
  default     = []
}

variable "rds_engine" {
  description = "Database engine: postgres, mysql, aurora-postgresql or aurora-mysql."
  type        = string
  default     = "postgres"
}

variable "rds_engine_version" {
  description = "Database engine version."
  type        = string
  default     = "15.18"
}

variable "rds_parameter_group_family" {
  description = "Parameter group family. If null, module generates it from engine and version."
  type        = string
  default     = null
}

variable "rds_instance_class" {
  description = "Database instance class."
  type        = string
  default     = "db.t3.micro"
}

variable "rds_aurora_instance_count" {
  description = "Number of Aurora instances."
  type        = number
  default     = 1
}

variable "rds_allocated_storage" {
  description = "Allocated storage for standard RDS instance in GB."
  type        = number
  default     = 20
}

variable "rds_max_allocated_storage" {
  description = "Maximum allocated storage for standard RDS autoscaling. Set 0 to disable."
  type        = number
  default     = 0
}

variable "rds_storage_type" {
  description = "Storage type for standard RDS instance."
  type        = string
  default     = "gp3"
}

variable "rds_storage_encrypted" {
  description = "Whether database storage encryption is enabled."
  type        = bool
  default     = true
}

variable "rds_db_name" {
  description = "Initial database name."
  type        = string
  default     = "appdb"
}

variable "rds_master_username" {
  description = "Master database username."
  type        = string
  default     = "dbadmin"
}

variable "rds_master_password" {
  description = "Master database password. Pass through TF_VAR_rds_master_password."
  type        = string
  sensitive   = true
}

variable "rds_port" {
  description = "Database port. If null, module uses 5432 for PostgreSQL and 3306 for MySQL."
  type        = number
  default     = null
}

variable "rds_multi_az" {
  description = "Whether Multi-AZ is enabled for standard RDS instance."
  type        = bool
  default     = false
}

variable "rds_publicly_accessible" {
  description = "Whether database is publicly accessible."
  type        = bool
  default     = false
}

variable "rds_backup_retention_period" {
  description = "Backup retention period in days."
  type        = number
  default     = 0
}

variable "rds_deletion_protection" {
  description = "Whether deletion protection is enabled."
  type        = bool
  default     = false
}

variable "rds_skip_final_snapshot" {
  description = "Whether final snapshot is skipped during deletion."
  type        = bool
  default     = true
}

variable "rds_final_snapshot_identifier" {
  description = "Final snapshot identifier when rds_skip_final_snapshot is false."
  type        = string
  default     = null
}

variable "rds_apply_immediately" {
  description = "Whether database changes are applied immediately."
  type        = bool
  default     = true
}

variable "monitoring_namespace" {
  description = "Kubernetes namespace for Prometheus and Grafana."
  type        = string
  default     = "monitoring"
}

variable "monitoring_release_name" {
  description = "Helm release name for monitoring stack."
  type        = string
  default     = "monitoring"
}

variable "grafana_admin_password" {
  description = "Grafana admin password."
  type        = string
  sensitive   = true
}
