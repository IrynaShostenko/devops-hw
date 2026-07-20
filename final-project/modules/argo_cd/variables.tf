variable "namespace" {
  description = "Kubernetes namespace for Argo CD"
  type        = string
  default     = "argocd"
}

variable "release_name" {
  description = "Helm release name for Argo CD"
  type        = string
  default     = "argocd"
}

variable "app_name" {
  description = "Argo CD application name"
  type        = string
  default     = "django-app"
}

variable "app_namespace" {
  description = "Namespace where Django app will be deployed"
  type        = string
  default     = "default"
}

variable "app_repo_url" {
  description = "Git repository URL with Helm chart"
  type        = string
  default     = "https://github.com/IrynaShostenko/devops-hw.git"
}

variable "app_target_revision" {
  description = "Git branch watched by Argo CD"
  type        = string
  default     = "final-project"
}

variable "app_chart_path" {
  description = "Path to Django Helm chart in Git repository"
  type        = string
  default     = "final-project/charts/django-app"
}

variable "destination_server" {
  description = "Kubernetes API server for Argo CD destination"
  type        = string
  default     = "https://kubernetes.default.svc"
}
