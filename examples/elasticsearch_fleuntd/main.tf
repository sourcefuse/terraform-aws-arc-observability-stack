################################################################################
## defaults
################################################################################
terraform {
  required_version = ">= 1.4, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0, < 6.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.6"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "= 2.24.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.0"
    }
  }
}

data "aws_eks_cluster" "this" {
  name = "${var.namespace}-${var.environment}-sl-k8s-cluster"
}

data "aws_eks_cluster_auth" "this" {
  name = "${var.namespace}-${var.environment}-sl-k8s-cluster"
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}


/*
Pre req
- CSI driver is deployed on EKS cluster, this is required for Elasticsearch
*/
module "efk_es_fluentd" {
  source = "../../"

  environment = var.environment
  namespace   = var.namespace

  search_engine  = "elasticsearch"
  log_aggregator = "fluentd"

  elasticsearch_config = {
    name = "elasticsearch-master"
    k8s_namespace = {
      name   = "logging"
      create = true
    }

    tls_self_signed_cert_data = {
      organisation          = "ARC"
      validity_period_hours = 26280 # 3 years validity
      early_renewal_hours   = 168   # 1 week early renewal
    }

    cluster_config = {
      port           = "9200"
      transport_port = "9300"
      user           = "elastic"
      log_level      = "INFO"
      cpu_limit      = "2000m"
      memory_limit   = "4Gi"
      cpu_request    = "1000m"
      memory_request = "2Gi"
      storage_class  = "gp2"
      storage        = "40Gi"
    }

    kibana_config = {
      log_level      = "info"
      cpu_limit      = "500m"
      memory_limit   = "1Gi"
      cpu_request    = "250m"
      memory_request = "500Mi"

      ingress_enabled     = true
      aws_certificate_arn = "arn:aws:acm:us-east-1:884360309640:certificate/7e4d8c74-46e7-4d99-a523-6db4336d9a0a" // TODO: remove
      ingress_host        = "kibana.arc-poc.link"                                                                 // TODO: remove

    }

    fluentd_config = {
      k8s_namespace = {
        name   = "logging"
        create = false
      }
      name                = "fluentd1"
      search_engine       = "elasticsearch"
      cpu_limit           = "100m"
      memory_limit        = "512Mi"
      cpu_request         = "100m"
      memory_request      = "128Mi"
      logstash_dateformat = "%Y.%m.%d"
      log_level           = "info"
    }

    fluentbit_config = {
      k8s_namespace = {
        name   = "logging"
        create = false
      }
      name                = "fluent-bit"
      search_engine       = "elasticsearch"
      cpu_limit           = "200m"
      memory_limit        = "512Mi"
      cpu_request         = "100m"
      memory_request      = "200Mi"
      logstash_dateformat = "%Y.%m.%d"
      log_level           = "info"
    }

    prometheus_config = {
      k8s_namespace = {
        name   = "metrics1"
        create = true
      }
      log_level = "info"
      resources = {
        cpu_limit      = "100m"
        memory_limit   = "512Mi"
        cpu_request    = "100m"
        memory_request = "128Mi"
      }
      replicas                  = 1
      storage                   = "8Gi"
      enable_kube_state_metrics = true
      enable_node_exporter      = true
      retention_period          = "30d"

      grafana_config = {
        ingress_enabled     = false
        replicas            = 1
        ingress_enabled     = true
        ingress_host        = "grafana.arc-poc.link"
        aws_certificate_arn = "arn:aws:acm:us-east-1:884360309640:certificate/7e4d8c74-46e7-4d99-a523-6db4336d9a0a" // TODO: remove
        lb_visibility       = "internet-facing"
      }
    }
  }
}
