output "s3_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  value       = module.s3_backend.s3_bucket_name
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table for Terraform locks"
  value       = module.s3_backend.dynamodb_table_name
}

output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.vpc.vpc_id
}

output "public_subnets" {
  description = "IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = module.ecr.repository_url
}

output "ecr_repository_name" {
  description = "Name of the ECR repository"
  value       = module.ecr.repository_name
}

output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_arn" {
  description = "EKS cluster ARN"
  value       = module.eks.cluster_arn
}

output "eks_node_group_name" {
  description = "EKS node group name"
  value       = module.eks.node_group_name
}

output "ebs_csi_addon_name" {
  description = "EBS CSI driver addon name"
  value       = module.eks.ebs_csi_addon_name
}

output "ebs_csi_driver_role_name" {
  description = "IAM role name for EBS CSI driver"
  value       = module.eks.ebs_csi_driver_role_name
}

output "jenkins_release_name" {
  description = "Jenkins Helm release name"
  value       = module.jenkins.release_name
}

output "jenkins_namespace" {
  description = "Jenkins namespace"
  value       = module.jenkins.namespace
}

output "jenkins_admin_username" {
  description = "Jenkins admin username"
  value       = module.jenkins.admin_username
}

output "jenkins_admin_password" {
  description = "Jenkins admin password"
  value       = module.jenkins.admin_password
  sensitive   = true
}

output "argocd_release_name" {
  description = "Argo CD Helm release name"
  value       = module.argo_cd.release_name
}

output "argocd_namespace" {
  description = "Argo CD namespace"
  value       = module.argo_cd.namespace
}

output "argocd_application_name" {
  description = "Argo CD application name"
  value       = module.argo_cd.application_name
}

output "rds_db_type" {
  description = "Created database type."
  value       = module.rds.db_type
}

output "rds_engine" {
  description = "Selected database engine."
  value       = module.rds.engine
}

output "rds_endpoint" {
  description = "Database writer endpoint."
  value       = module.rds.endpoint
}

output "rds_reader_endpoint" {
  description = "Aurora reader endpoint. Null for standard RDS."
  value       = module.rds.reader_endpoint
}

output "rds_port" {
  description = "Database port."
  value       = module.rds.port
}

output "rds_database_name" {
  description = "Initial database name."
  value       = module.rds.database_name
}

output "rds_security_group_id" {
  description = "Database security group ID."
  value       = module.rds.security_group_id
}

output "rds_subnet_group_name" {
  description = "Database subnet group name."
  value       = module.rds.subnet_group_name
}

output "rds_parameter_group_name" {
  description = "Database parameter group name."
  value       = module.rds.parameter_group_name
}

output "monitoring_namespace" {
  description = "Monitoring namespace."
  value       = module.monitoring.namespace
}

output "monitoring_release_name" {
  description = "Monitoring Helm release name."
  value       = module.monitoring.release_name
}

output "grafana_service_name" {
  description = "Grafana service name."
  value       = module.monitoring.grafana_service_name
}

output "grafana_username" {
  description = "Grafana admin username."
  value       = module.monitoring.grafana_username
}

output "grafana_port_forward_command" {
  description = "Command to access Grafana locally."
  value       = module.monitoring.grafana_port_forward_command
}
