resource "kubernetes_storage_class_v1" "jenkins_gp3" {
  metadata {
    name = var.storage_class_name
  }

  storage_provisioner    = "ebs.csi.aws.com"
  reclaim_policy         = "Delete"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true

  parameters = {
    type      = "gp3"
    encrypted = "true"
  }
}

resource "helm_release" "jenkins" {
  name             = var.release_name
  repository       = "https://charts.jenkins.io"
  chart            = "jenkins"
  namespace        = var.namespace
  create_namespace = true
  timeout          = 900

  values = [
    templatefile("${path.module}/values.yaml", {
      jenkins_admin_password = var.admin_password
    })
  ]

  depends_on = [
    kubernetes_storage_class_v1.jenkins_gp3
  ]
}
