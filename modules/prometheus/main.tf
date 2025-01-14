resource "random_password" "grafana" {
  length           = 16
  special          = true
  upper            = true
  lower            = true
  numeric          = true
  override_special = "!@#$%^_=+<>"
}

resource "aws_ssm_parameter" "grafana_creds" {
  name        = "/${var.namespace}/${var.environment}/grafana/${var.name}/creds"
  description = "Grafana creds"
  type        = "SecureString" # Use SecureString for sensitive data
  value = jsonencode({
    user     = var.grafana_config.admin_user
    password = random_password.grafana.result
  })
  tags = var.tags
}

resource "kubernetes_namespace" "this" {
  count = var.create_k8s_namespace ? 1 : 0
  metadata {
    name = var.k8s_namespace
  }
}

resource "helm_release" "prometheus" {
  name       = var.name
  namespace  = var.k8s_namespace
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  version    = "26.1.0"

  values = [
    templatefile("${path.module}/promethus-values.tftpl", {
      name                      = var.name
      log_level                 = var.log_level
      replicas                  = var.replicas
      cpu_limit                 = var.resources.cpu_limit
      memory_limit              = var.resources.memory_limit
      cpu_request               = var.resources.cpu_request
      memory_request            = var.resources.memory_request
      enable_kube_state_metrics = var.enable_kube_state_metrics
      enable_node_exporter      = var.enable_node_exporter
      storage                   = var.storage
      storage_class             = var.storage_class
      retention_period          = var.retention_period
    })
  ]

  force_update = true
  depends_on   = [kubernetes_namespace.this]
}

resource "helm_release" "grafana" {
  name       = var.grafana_config.name
  namespace  = var.k8s_namespace
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  version    = "8.8.2"

  values = [
    templatefile("${path.module}/grafana-values.tftpl", {
      name                = var.grafana_config.name
      replicas            = var.grafana_config.replicas
      cpu_limit           = var.grafana_config.cpu_limit
      memory_limit        = var.grafana_config.memory_limit
      cpu_request         = var.grafana_config.cpu_request
      memory_request      = var.grafana_config.memory_request
      admin_user          = var.grafana_config.admin_user
      admin_password      = random_password.grafana.result
      ingress_enabled     = var.grafana_config.ingress_enabled
      ingress_host        = var.grafana_config.ingress_host
      lb_visibility       = var.grafana_config.lb_visibility
      aws_certificate_arn = var.grafana_config.aws_certificate_arn
      prometheus_endpoint = var.name // This is the Prometheus service name
      cpu_limit           = var.grafana_config.cpu_limit
      memory_limit        = var.grafana_config.memory_limit
      cpu_request         = var.grafana_config.cpu_request
      memory_request      = var.grafana_config.memory_request
    })
  ]

  force_update = true
  depends_on   = [kubernetes_namespace.this]
}
