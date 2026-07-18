output "release_name" {
  description = "Argo CD Helm release name"
  value       = helm_release.argo_cd.name
}

output "namespace" {
  description = "Argo CD namespace"
  value       = helm_release.argo_cd.namespace
}

output "application_name" {
  description = "Argo CD application name"
  value       = var.app_name
}
