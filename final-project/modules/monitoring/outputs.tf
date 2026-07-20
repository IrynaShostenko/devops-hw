output "namespace" {
  description = "Monitoring namespace."
  value       = kubernetes_namespace_v1.monitoring.metadata[0].name
}

output "release_name" {
  description = "Helm release name."
  value       = helm_release.kube_prometheus_stack.name
}

output "grafana_service_name" {
  description = "Grafana Kubernetes service name."
  value       = "grafana"
}

output "grafana_username" {
  description = "Grafana admin username."
  value       = "admin"
}

output "grafana_port_forward_command" {
  description = "Command to access Grafana locally."
  value       = "kubectl port-forward svc/grafana 3000:80 -n ${kubernetes_namespace_v1.monitoring.metadata[0].name}"
}
