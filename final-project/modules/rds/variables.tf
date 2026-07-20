variable "name_prefix" {
  description = "Name prefix for all RDS module resources."
  type        = string

  validation {
    condition     = length(var.name_prefix) > 0
    error_message = "name_prefix must not be empty."
  }
}

variable "use_aurora" {
  description = "If true, creates an Aurora cluster. If false, creates a standard RDS instance."
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "VPC ID where database security group will be created."
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for DB Subnet Group. Private subnets are recommended."
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "At least two subnet IDs are required for RDS subnet group."
  }
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to connect to the database."
  type        = list(string)
  default     = []
}

variable "allowed_security_group_ids" {
  description = "Security group IDs allowed to connect to the database."
  type        = list(string)
  default     = []
}

variable "engine" {
  description = "Database engine. For standard RDS use postgres or mysql. For Aurora use postgres, mysql, aurora-postgresql or aurora-mysql."
  type        = string
  default     = "postgres"

  validation {
    condition     = contains(["postgres", "mysql", "aurora-postgresql", "aurora-mysql"], var.engine)
    error_message = "engine must be one of: postgres, mysql, aurora-postgresql, aurora-mysql."
  }
}

variable "engine_version" {
  description = "Database engine version."
  type        = string
  default     = "15.5"
}

variable "parameter_group_family" {
  description = "Parameter group family. If null, it is generated from engine and engine_version."
  type        = string
  default     = null
}

variable "parameters" {
  description = "Custom database parameters. If null, default parameters are used."
  type = map(object({
    value        = string
    apply_method = optional(string, "immediate")
  }))
  default = null
}

variable "instance_class" {
  description = "Database instance class."
  type        = string
  default     = "db.t3.micro"
}

variable "aurora_instance_count" {
  description = "Number of Aurora cluster instances. The first instance acts as writer."
  type        = number
  default     = 1

  validation {
    condition     = var.aurora_instance_count >= 1
    error_message = "aurora_instance_count must be at least 1."
  }
}

variable "allocated_storage" {
  description = "Allocated storage in GB for standard RDS instance."
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Maximum allocated storage in GB for RDS autoscaling. Set 0 to disable."
  type        = number
  default     = 0
}

variable "storage_type" {
  description = "Storage type for standard RDS instance."
  type        = string
  default     = "gp3"
}

variable "storage_encrypted" {
  description = "Whether storage encryption is enabled."
  type        = bool
  default     = true
}

variable "db_name" {
  description = "Initial database name."
  type        = string
  default     = "appdb"
}

variable "master_username" {
  description = "Master database username."
  type        = string
  default     = "dbadmin"
}

variable "master_password" {
  description = "Master database password. Must be provided from a secure source."
  type        = string
  sensitive   = true
}

variable "port" {
  description = "Database port. If null, 5432 is used for PostgreSQL and 3306 for MySQL."
  type        = number
  default     = null
}

variable "multi_az" {
  description = "Whether Multi-AZ is enabled for standard RDS instance."
  type        = bool
  default     = false
}

variable "publicly_accessible" {
  description = "Whether the database is publicly accessible."
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Backup retention period in days."
  type        = number
  default     = 7
}

variable "deletion_protection" {
  description = "Whether deletion protection is enabled."
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Whether to skip final snapshot during database deletion."
  type        = bool
  default     = true
}

variable "final_snapshot_identifier" {
  description = "Final snapshot identifier when skip_final_snapshot is false."
  type        = string
  default     = null
}

variable "apply_immediately" {
  description = "Whether database modifications are applied immediately."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags for resources."
  type        = map(string)
  default     = {}
}
