output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_arn" {
  description = "EKS cluster ARN"
  value       = aws_eks_cluster.main.arn
}

output "node_group_name" {
  description = "EKS node group name"
  value       = aws_eks_node_group.main.node_group_name
}

output "ebs_csi_addon_name" {
  description = "EBS CSI driver addon name"
  value       = aws_eks_addon.ebs_csi_driver.addon_name
}

output "ebs_csi_driver_role_name" {
  description = "IAM role name for EBS CSI driver"
  value       = aws_iam_role.ebs_csi_driver_role.name
}

output "cluster_certificate_authority_data" {
  description = "EKS cluster certificate authority data"
  value       = aws_eks_cluster.main.certificate_authority[0].data
}
