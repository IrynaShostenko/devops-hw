output "release_name" {
  description = "Jenkins Helm release name"
  value       = helm_release.jenkins.name
}

output "namespace" {
  description = "Jenkins namespace"
  value       = helm_release.jenkins.namespace
}

output "admin_username" {
  description = "Jenkins admin username"
  value       = var.admin_username
}

output "admin_password" {
  description = "Jenkins admin password"
  value       = var.admin_password
  sensitive   = true
}
