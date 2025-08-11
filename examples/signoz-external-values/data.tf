data "aws_ssm_parameter" "domain" {
  name            = "/iac/route53/domain"
  with_decryption = true
}

locals {
  domain = data.aws_ssm_parameter.domain.value
  prefix = "${var.namespace}-${var.environment}"
}


data "aws_acm_certificate" "this" {
  domain      = "*.${local.domain}"
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

data "aws_eks_cluster" "this" {
  name = "${local.prefix}-cluster"
}

data "aws_eks_cluster_auth" "this" {
  name = data.aws_eks_cluster.this.name
}
