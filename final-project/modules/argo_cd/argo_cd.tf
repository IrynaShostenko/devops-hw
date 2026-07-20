resource "helm_release" "argo_cd" {
  name             = var.release_name
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = var.namespace
  create_namespace = true
  timeout          = 900

  values = [
    file("${path.module}/values.yaml")
  ]
}

resource "helm_release" "argo_cd_apps" {
  name      = "argocd-apps"
  chart     = "${path.module}/charts/argocd-apps"
  namespace = var.namespace
  timeout   = 300

  values = [
    yamlencode({
      argocdNamespace = var.namespace

      repositories = [
        {
          name = "devops-hw"
          type = "git"
          url  = var.app_repo_url
        }
      ]

      applications = [
        {
          name              = var.app_name
          namespace         = var.app_namespace
          repoURL           = var.app_repo_url
          targetRevision    = var.app_target_revision
          path              = var.app_chart_path
          destinationServer = var.destination_server
        }
      ]
    })
  ]

  depends_on = [
    helm_release.argo_cd
  ]
}
