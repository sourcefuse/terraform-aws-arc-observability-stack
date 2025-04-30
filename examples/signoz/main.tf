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
  name = "${var.namespace}-${var.environment}-cluster"
}

data "aws_eks_cluster_auth" "this" {
  name = data.aws_eks_cluster.this.name
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

module "signoz" {
  source = "../../"

  environment = var.environment
  namespace   = var.namespace


  search_engine             = "signoz"
  log_aggregator            = "signoz"
  tracing_stack             = "signoz"
  metrics_monitoring_system = "signoz"

  signoz_config = local.signoz_config
}
