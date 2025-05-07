data "aws_caller_identity" "current" {}

locals {
  signoz_config = {
    name          = "signoz"
    storage_class = "gp3"
    cluster_name  = data.aws_eks_cluster.this.name

    k8s_namespace = {
      name   = "signoz"
      create = true
    }


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
      aws_certificate_arn = "arn:aws:acm:us-east-1:${data.aws_caller_identity.current.account_id}:certificate/7e4d8c74-46e7-4d99-a523-6db4336d9a0a"
      root_domain         = "${var.namespace}-${var.environment}.link"
      domain              = "signoz.${var.namespace}-${var.environment}.link"
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
  }


  metrics_logs_config = {
    name          = "signoz"
    storage_class = "gp3"
    cluster_name  = data.aws_eks_cluster.this.name

    k8s_namespace = {
      name   = "signoz"
      create = false
    }
    enable_log_collection      = true
    enable_metrics_collection  = true
    otel_collector_endpoint    = module.signoz.otel_collector_endpoint
    metric_collection_interval = "30s"

  }
}
