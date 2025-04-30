resource "kubernetes_namespace" "this" {
  count = var.create_k8s_namespace ? 1 : 0
  metadata {
    name = var.k8s_namespace
  }
}

resource "helm_release" "jaeger" {
  name       = var.name
  namespace  = var.k8s_namespace
  repository = "https://jaegertracing.github.io/helm-charts"
  chart      = "jaeger"
  version    = "3.4.1"

  values = [
    templatefile("${path.module}/jaeger.tftpl", {
      name                = var.name
      search_engine       = var.search_engine
      host                = var.search_engine_config.host
      port                = var.search_engine_config.port
      http_user           = var.search_engine_config.user
      http_passwd         = var.search_engine_config.password
      log_level           = var.log_level
      logstash_dateformat = var.search_engine_config.logstash_dateformat
      time_format         = var.search_engine_config.time_format
      cpu_limit           = var.resources.cpu_limit
      memory_limit        = var.resources.memory_limit
      cpu_request         = var.resources.cpu_request
      memory_request      = var.resources.memory_request
      aws_region          = var.search_engine_config.aws_region
      aws_role_arn        = var.search_engine_config.aws_role_arn
    })
  ]

  force_update = true
  depends_on   = [kubernetes_namespace.this]
}
