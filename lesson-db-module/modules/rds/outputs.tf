output "db_type" {
  description = "Created database type."
  value       = var.use_aurora ? "aurora" : "rds"
}

output "engine" {
  description = "Selected database engine."
  value       = local.selected_engine
}

output "endpoint" {
  description = "Database writer endpoint."
  value       = var.use_aurora ? aws_rds_cluster.main[0].endpoint : aws_db_instance.main[0].address
}

output "reader_endpoint" {
  description = "Aurora reader endpoint. Null for standard RDS."
  value       = var.use_aurora ? aws_rds_cluster.main[0].reader_endpoint : null
}

output "port" {
  description = "Database port."
  value       = local.db_port
}

output "database_name" {
  description = "Initial database name."
  value       = var.db_name
}

output "security_group_id" {
  description = "Database security group ID."
  value       = aws_security_group.main.id
}

output "subnet_group_name" {
  description = "Database subnet group name."
  value       = aws_db_subnet_group.main.name
}

output "parameter_group_name" {
  description = "Database parameter group name."
  value = var.use_aurora ? (
    aws_rds_cluster_parameter_group.main[0].name
    ) : (
    aws_db_parameter_group.main[0].name
  )
}

output "rds_instance_id" {
  description = "Standard RDS instance ID. Null when Aurora is used."
  value       = var.use_aurora ? null : aws_db_instance.main[0].id
}

output "aurora_cluster_id" {
  description = "Aurora cluster ID. Null when standard RDS is used."
  value       = var.use_aurora ? aws_rds_cluster.main[0].id : null
}

output "aurora_instance_ids" {
  description = "Aurora cluster instance IDs. Empty list when standard RDS is used."
  value       = var.use_aurora ? aws_rds_cluster_instance.writer[*].id : []
}
