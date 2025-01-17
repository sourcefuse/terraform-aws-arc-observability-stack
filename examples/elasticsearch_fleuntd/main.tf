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
      version = "2.17.0"
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

provider "aws" {
  region = var.region
}

/*
Pre req
- CSI driver is deployed on EKS cluster, this is required for Elasticsearch
- AWS Loadbalancer controller is installed

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
      aws_certificate_arn = var.aws_certificate_arn
      ingress_host        = var.ingress_host

    }
  }

  fluentd_config = {
    k8s_namespace = {
      name   = "logging"
      create = false
    }
    name                = "fluentd"
    search_engine       = "elasticsearch"
    cpu_limit           = "100m"
    memory_limit        = "512Mi"
    cpu_request         = "100m"
    memory_request      = "128Mi"
    logstash_dateformat = "%Y.%m.%d"
    log_level           = "info"
  }
}
