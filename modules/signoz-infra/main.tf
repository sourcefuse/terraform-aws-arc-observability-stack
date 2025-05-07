resource "kubernetes_namespace" "this" {
  count = var.create_k8s_namespace ? 1 : 0
  metadata {
    name = var.k8s_namespace
  }
}

resource "helm_release" "k8s_infra" {
  name       = "${var.name}-k8s-infra"
  namespace  = var.k8s_namespace
  repository = "https://charts.signoz.io"
  chart      = "k8s-infra"
  version    = "0.12.1"

  values = [
    templatefile("${path.module}/k8s-infra.tftpl", {
      name                       = var.signoz_infra_monitor_config.name
      otel_collector_endpoint    = var.otel_collector_endpoint
      storage_class              = var.signoz_infra_monitor_config.storage_class
      cluster_name               = var.signoz_infra_monitor_config.cluster_name
      metric_collection_interval = var.signoz_infra_monitor_config.metric_collection_interval
      environment                = var.environment
      enable_log_collection      = var.signoz_infra_monitor_config.enable_log_collection
      enable_metrics_collection  = var.signoz_infra_monitor_config.enable_metrics_collection
    })
  ]

  force_update = true
  depends_on   = [kubernetes_namespace.this]
}
