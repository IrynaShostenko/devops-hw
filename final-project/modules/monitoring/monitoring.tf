resource "kubernetes_namespace_v1" "monitoring" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "kube_prometheus_stack" {
  name       = var.release_name
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = kubernetes_namespace_v1.monitoring.metadata[0].name

  timeout = 900

  values = [
    templatefile("${path.module}/values.yaml", {
      grafana_admin_password = var.grafana_admin_password
    })
  ]

  depends_on = [
    kubernetes_namespace_v1.monitoring
  ]
}
