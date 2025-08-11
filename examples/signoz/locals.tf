data "aws_ssm_parameter" "domain" {
  name            = "/iac/route53/domain"
  with_decryption = true
}

locals {
  domain = data.aws_ssm_parameter.domain.value
}


data "aws_acm_certificate" "this" {
  domain      = "*.${local.domain}"
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

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
      aws_certificate_arn = data.aws_acm_certificate.this.arn
      root_domain         = local.domain
      domain              = "signoz.${local.domain}"
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
