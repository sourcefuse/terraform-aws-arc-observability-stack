locals {

  k8s_namespace = "signoz"
  clickhouse = {
    user           = "admin"
    cpu_limit      = "2000m"
    memory_limit   = "4Gi"
    cpu_request    = "100m"
    memory_request = "200Mi"
    storage        = "20Gi"
  }

  signoz_bin = {
    replica_count       = 1
    cpu_limit           = "750m"
    memory_limit        = "1000Mi"
    cpu_request         = "100m"
    memory_request      = "200Mi"
    ingress_enabled     = true
    aws_certificate_arn = data.aws_acm_certificate.this.arn
    root_domain         = local.domain
    domain              = "signoz.${local.domain}"
    lb_visibility       = "internet-facing"
  }

  alertmanager = {
    enable         = true
    replica_count  = 1
    cpu_limit      = "500m"
    memory_limit   = "500Mi"
    cpu_request    = "100m"
    memory_request = "200Mi"
    storage        = "200Mi"
  }

  otel_collector = {
    cpu_limit      = "1"
    memory_limit   = "2Gi"
    cpu_request    = "200m"
    memory_request = "300Mi"
    storage        = "200Mi"
  }


  ## Signoz heml chart values. ###########################
  signoz_config = {
    name          = "signoz"
    storage_class = "gp3"
    cluster_name  = data.aws_eks_cluster.this.name

    chart_values = [
      templatefile("${path.module}/values/signoz.yaml", {
        name           = "signoz"
        storage_class  = "gp3"
        cluster_name   = data.aws_eks_cluster.this.name
        password       = "27ff0399-0d3a-4bd8-919d-17c2181e6fb9"
        clickhouse     = local.clickhouse
        otel_collector = local.otel_collector
        signoz_bin     = local.signoz_bin
        alertmanager   = local.alertmanager
        endpoints      = local.endpoints_to_monitor
      })
    ]

    signoz_bin    = local.signoz_bin
    chart_version = "0.88.2"
    k8s_namespace = {
      name   = local.k8s_namespace
      create = true
    }
  }


  metrics_logs_config = {
    name          = "signoz"
    storage_class = "gp3"
    cluster_name  = data.aws_eks_cluster.this.name


    chart_values = [
      templatefile("${path.module}/values/signoz-infra.yaml", {
        name                       = "signoz"
        storage_class              = "gp3"
        cluster_name               = data.aws_eks_cluster.this.name
        metric_collection_interval = "30s"
        otel_collector_endpoint    = "http://signoz-otel-collector:4317"
      })
    ]

    chart_version = "0.13.0"

    k8s_namespace = {
      name   = local.k8s_namespace
      create = false
    }
  }



  endpoints_to_monitor = [
    {
      endpoint            = "https://example.com/"
      method              = "GET"
      collection_interval = "60s"
    }
  ]
}
