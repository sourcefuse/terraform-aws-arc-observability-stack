resource "random_password" "clickhouse" {
  length           = 16
  special          = true
  upper            = true
  lower            = true
  numeric          = true
  override_special = "!@#$%_=+<>"
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
      password       = ""
      clickhouse     = var.signoz_config.clickhouse
      otel_collector = var.signoz_config.otel_collector
      signoz_bin     = var.signoz_config.signoz_bin
      alertmanager   = var.signoz_config.alertmanager
    })
  ]

  force_update = true
  depends_on   = [kubernetes_namespace.this]
}

//clickhouseOperator ----> what is this

resource "helm_release" "k8s_infra" {
  name       = "${var.name}-k8s-infra"
  namespace  = var.k8s_namespace
  repository = "https://charts.signoz.io"
  chart      = "k8s-infra"
  version    = "0.12.1"

  values = [
    templatefile("${path.module}/k8s-infra.tftpl", {
      name          = var.signoz_config.name
      storage_class = var.signoz_config.storage_class
      cluster_name  = var.signoz_config.cluster_name
      environment   = var.environment
    })
  ]

  force_update = true
  depends_on   = [kubernetes_namespace.this]
}


/*
TODO:
* Ingress certificate and ALB
* Password for clickhouse
* Collection interval
* Whats the user of OTEL agent

*/
