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
