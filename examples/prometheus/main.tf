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
- AWS Loadbalancer controller has to be created
*/
module "prometheus" {
  source = "../../"

  environment = var.environment
  namespace   = var.namespace

  metrics_monitoring_system = "prometheus"

  prometheus_config = {
    k8s_namespace = {
      name   = "metrics"
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
      replicas            = 1
      ingress_enabled     = true
      ingress_host        = var.ingress_host
      aws_certificate_arn = var.aws_certificate_arn
      lb_visibility       = "internet-facing"
      dashboard_list = [
        {
          name = "node-metrics"
          json = templatefile("${path.module}/grafana-dashbord.json", {})
        }
      ]
    }

    blackbox_exporter_config = {
      name = "blackbox-exporter"
      monitoring_targets = [{
        name                     = "google"
        url                      = "https://google.com"
        scrape_interval          = "60s"
        status_code_pattern_list = "[http_2xx]" // Note :- This i string not list
      }]
    }

    alertmanager_config = {
      name            = "alertmanager"
      replica_count   = 1
      alert_rule_yaml = ""
    }

  }
}
