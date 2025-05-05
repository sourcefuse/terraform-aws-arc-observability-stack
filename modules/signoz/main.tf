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
  version    = "0.78.0"

  values = [
    templatefile("${path.module}/signoz.tftpl", {
      name           = var.signoz_config.name
      storage_class  = var.signoz_config.storage_class
      cluster_name   = var.signoz_config.cluster_name
      password       = "27ff0399-0d3a-4bd8-919d-17c2181e6fb9" //random_password.clickhouse.result
      clickhouse     = var.signoz_config.clickhouse
      otel_collector = var.signoz_config.otel_collector
      signoz_bin     = var.signoz_config.signoz_bin
      alertmanager   = var.signoz_config.alertmanager
    })
  ]

  force_update = true
  depends_on   = [kubernetes_namespace.this, random_password.clickhouse]
}

data "kubernetes_ingress_v1" "this" {
  count = var.signoz_config.signoz_bin.ingress_enabled ? 1 : 0
  metadata {
    name      = "${var.name}-monitoring"
    namespace = var.k8s_namespace
  }

  depends_on = [helm_release.signoz]
}

resource "helm_release" "k8s_infra" {
  name       = "${var.name}-k8s-infra"
  namespace  = var.k8s_namespace
  repository = "https://charts.signoz.io"
  chart      = "k8s-infra"
  version    = "0.12.1"

  values = [
    templatefile("${path.module}/k8s-infra.tftpl", {
      name                       = var.signoz_config.name
      storage_class              = var.signoz_config.storage_class
      cluster_name               = var.signoz_config.cluster_name
      metric_collection_interval = var.signoz_config.signoz_bin.metric_collection_interval
      environment                = var.environment
    })
  ]

  force_update = true
  depends_on   = [kubernetes_namespace.this]
}

data "aws_route53_zone" "this" {
  count        = var.signoz_config.signoz_bin.root_domain != null ? 1 : 0
  name         = var.signoz_config.signoz_bin.root_domain
  private_zone = false
}


resource "aws_route53_record" "this" {
  count = var.signoz_config.signoz_bin.root_domain != null ? 1 : 0

  zone_id = data.aws_route53_zone.this[0].zone_id
  name    = var.signoz_config.signoz_bin.domain
  type    = "CNAME"
  ttl     = "300"
  records = [data.kubernetes_ingress_v1.this[0].status[0].load_balancer[0].ingress[0].hostname]
}

/*
TODO:
* Password for clickhouse
* enable diable metrics based on need

*/
