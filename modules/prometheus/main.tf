resource "random_password" "grafana" {
  length           = 16
  special          = true
  upper            = true
  lower            = true
  numeric          = true
  override_special = "!@#$%_=+<>"
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
  chart      = "kube-prometheus-stack"
  version    = "68.2.1"

  values = [
    templatefile("${path.module}/prometheus-stack-values.tftpl", {
      name                        = var.name
      replica_count               = var.replica_count
      log_level                   = var.log_level
      replica_count               = var.replica_count
      cpu_limit                   = var.resources.cpu_limit
      memory_limit                = var.resources.memory_limit
      cpu_request                 = var.resources.cpu_request
      memory_request              = var.resources.memory_request
      enable_kube_state_metrics   = var.enable_kube_state_metrics
      enable_node_exporter        = var.enable_node_exporter
      storage                     = var.storage
      storage_class               = var.storage_class
      retention_period            = var.retention_period
      monitoring_targets          = var.blackbox_exporter_config.monitoring_targets
      blackbox_exporter_svc       = "${var.blackbox_exporter_config.name}.${var.k8s_namespace}.svc.cluster.local"
      admin_user                  = var.grafana_config.admin_user
      admin_password              = random_password.grafana.result
      ingress_enabled             = var.grafana_config.ingress_enabled
      ingress_host                = var.grafana_config.ingress_host
      lb_visibility               = var.grafana_config.lb_visibility
      aws_certificate_arn         = var.grafana_config.aws_certificate_arn
      custom_alerts               = var.alertmanager_config.custom_alerts
      alert_notification_settings = var.alertmanager_config.custom_alerts
    })
  ]

  force_update = true
  depends_on   = [kubernetes_namespace.this]
}

resource "kubernetes_config_map" "dashboards" {

  for_each = { for idx, value in var.grafana_config.dashboard_list : value.name => value }
  metadata {
    name      = each.value.name
    namespace = var.k8s_namespace
    labels = {
      grafana_dashboard = "1"
    }
  }
  data = {
    "${each.value.name}.json" = each.value.json
  }
}

resource "helm_release" "blackbox_exporter" {
  name       = var.blackbox_exporter_config.name
  namespace  = var.k8s_namespace
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus-blackbox-exporter"
  version    = "9.1.0"

  values = [
    templatefile("${path.module}/blackbox-exporter-values.tftpl", {
      name               = var.blackbox_exporter_config.name
      replica_count      = var.blackbox_exporter_config.replica_count
      cpu_limit          = var.blackbox_exporter_config.cpu_limit
      memory_limit       = var.blackbox_exporter_config.memory_limit
      cpu_request        = var.blackbox_exporter_config.cpu_request
      memory_request     = var.blackbox_exporter_config.memory_request
      monitoring_targets = var.blackbox_exporter_config.monitoring_targets
    })
  ]

  force_update = true
  depends_on   = [kubernetes_namespace.this]
}


data "kubernetes_ingress_v1" "this" {
  count = var.grafana_config.ingress_enabled ? 1 : 0
  metadata {
    name      = "${var.name}-prometheus"
    namespace = var.k8s_namespace
  }

  depends_on = [helm_release.prometheus]
}
