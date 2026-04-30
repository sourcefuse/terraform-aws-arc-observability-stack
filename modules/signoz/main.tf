resource "random_password" "clickhouse" {
  length  = 16
  special = false
  upper   = true
  lower   = true
  numeric = true
}

resource "kubernetes_namespace" "this" {
  count = var.create_k8s_namespace ? 1 : 0
  metadata {
    name = var.k8s_namespace
  }
}

resource "helm_release" "signoz" {
  name       = var.name
  namespace  = var.k8s_namespace
  repository = "https://charts.signoz.io"
  chart      = "signoz"
  version    = var.signoz_config.chart_version

  values = length(var.signoz_config.chart_values) == 0 ? [
    templatefile("${path.module}/signoz.tftpl", {
      name           = var.signoz_config.name
      storage_class  = var.signoz_config.storage_class
      cluster_name   = var.signoz_config.cluster_name
      password       = random_password.clickhouse.result
      clickhouse     = var.signoz_config.clickhouse
      otel_collector = var.signoz_config.otel_collector
      signoz_bin     = var.signoz_config.signoz_bin
      alertmanager   = var.signoz_config.alertmanager
    })
  ] : var.signoz_config.chart_values

  force_update = true
  depends_on   = [kubernetes_namespace.this, random_password.clickhouse]
}

resource "time_sleep" "wait_for_alb" {
  count = var.signoz_config.signoz_bin != null && var.signoz_config.signoz_bin.ingress_enabled && var.signoz_config.signoz_bin.alb_hostname == null ? 1 : 0

  create_duration = "120s"
  depends_on      = [helm_release.signoz]
}

data "kubernetes_ingress_v1" "this" {
  count = var.signoz_config.signoz_bin != null && var.signoz_config.signoz_bin.ingress_enabled && var.signoz_config.signoz_bin.alb_hostname == null ? 1 : 0

  metadata {
    name      = var.signoz_config.name
    namespace = var.k8s_namespace
  }

  depends_on = [time_sleep.wait_for_alb]
}

data "aws_route53_zone" "this" {
  count        = var.signoz_config.signoz_bin != null && var.signoz_config.signoz_bin.root_domain != null ? 1 : 0
  name         = var.signoz_config.signoz_bin != null ? var.signoz_config.signoz_bin.root_domain : null
  private_zone = false
}

locals {
  ingress_hostname      = var.signoz_config.signoz_bin != null && var.signoz_config.signoz_bin.alb_hostname != null ? var.signoz_config.signoz_bin.alb_hostname : try(data.kubernetes_ingress_v1.this[0].status[0].load_balancer[0].ingress[0].hostname, "")
  create_route53_record = var.signoz_config.signoz_bin != null && var.signoz_config.signoz_bin.root_domain != null && var.signoz_config.signoz_bin.alb_hostname != null
}

resource "aws_route53_record" "this" {
  count = local.create_route53_record ? 1 : 0

  zone_id = data.aws_route53_zone.this[0].zone_id
  name    = var.signoz_config.signoz_bin.domain
  type    = "CNAME"
  ttl     = "300"
  records = [local.ingress_hostname]
}
