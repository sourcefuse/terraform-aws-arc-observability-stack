locals {
  signoz_config = {
    name          = "signoz-monitoring"
    storage_class = "gp3"
    cluster_name  = data.aws_eks_cluster.this.name

    k8s_namespace = {
      name   = "signoz"
      create = true
    }


    clickhouse = {
      user           = "admin"
      password       = "27ff0399-0d3a-4bd8-919d-17c2181e6fb9"
      cpu_limit      = "2000m"
      memory_limit   = "4Gi"
      cpu_request    = "100m"
      memory_request = "200Mi"
      storage        = "20Gi"
    }

    signoz_bin = {
      replica_count  = 1
      cpu_limit      = "750m"
      memory_limit   = "1000Mi"
      cpu_request    = "100m"
      memory_request = "200Mi"
      enable_ingress = false
      #   certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/abcde12345"
      #   domain          = "signoz.mycompany.com"
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
}
