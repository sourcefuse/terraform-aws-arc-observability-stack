## Create self Signed certificate
resource "tls_private_key" "elasticsearch" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_ssm_parameter" "elasticsearch_private_key" {
  name        = "/${var.namespace}/${var.environment}/elasticsearch/${var.name}/private-key"
  description = "Elasticsearch private key"
  type        = "SecureString"
  value       = tls_private_key.elasticsearch.private_key_pem

  tags = var.tags
}

resource "tls_self_signed_cert" "elasticsearch" {
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth"
  ]

  dns_names = [
    var.name,
    "${var.name}.${var.k8s_namespace}",
    "${var.name}.${var.k8s_namespace}.svc",
    "${var.name}.${var.k8s_namespace}.svc.cluster.local"
  ]

  subject {
    common_name  = var.name
    organization = var.tls_self_signed_cert_data.organisation == null ? "${var.name} Organization" : var.tls_self_signed_cert_data.organisation
  }

  validity_period_hours = var.tls_self_signed_cert_data.validity_period_hours
  early_renewal_hours   = var.tls_self_signed_cert_data.early_renewal_hours

  private_key_pem = tls_private_key.elasticsearch.private_key_pem
}

resource "aws_ssm_parameter" "elasticsearch_ert_pem" {
  name        = "/${var.namespace}/${var.environment}/elasticsearch/${var.name}/cert_pem"
  description = "Elasticsearch private key"
  type        = "SecureString"
  value       = tls_self_signed_cert.elasticsearch.cert_pem

  tags = var.tags
}

resource "kubernetes_namespace" "this" {
  count = var.create_k8s_namespace ? 1 : 0
  metadata {
    name = var.k8s_namespace
  }
}

resource "kubernetes_secret" "elasticsearch_tls" {
  metadata {
    name      = "elasticsearch-certificates"
    namespace = var.k8s_namespace
  }

  data = {
    "tls.crt" = base64encode(tls_self_signed_cert.elasticsearch.cert_pem)
    "tls.key" = base64encode(tls_private_key.elasticsearch.private_key_pem)
  }

  type = "Opaque"

  depends_on = [kubernetes_namespace.this]
}

resource "random_password" "elasticsearch" {
  length           = 16
  special          = true
  upper            = true
  lower            = true
  numeric          = true
  override_special = "!@#$%^&*()-_=+[]{}<>?"
}

resource "aws_ssm_parameter" "elasticsearch_creds" {
  name        = "/${var.namespace}/${var.environment}/elasticsearch/${var.name}/creds"
  description = "Elasticsearch creds"
  type        = "SecureString" # Use SecureString for sensitive data
  value = jsonencode({
    user     = "elastic"
    password = random_password.elasticsearch.result
  })
  tags = var.tags
}

resource "helm_release" "elasticsearch" {
  name       = var.name
  namespace  = var.k8s_namespace
  chart      = "elasticsearch"
  repository = "https://helm.elastic.co"
  version    = "8.5.1"

  values = [
    templatefile("${path.module}/elasticsearch-values.tftpl", {
      name          = var.name
      port          = var.cluster_config.port
      transportPort = var.cluster_config.transport_port
      user          = var.cluster_config.user
      password      = random_password.elasticsearch.result
      log_level     = var.cluster_config.log_level

      cpu_limit      = var.cluster_config.cpu_limit
      memory_limit   = var.cluster_config.memory_limit
      cpu_request    = var.cluster_config.cpu_request
      memory_request = var.cluster_config.memory_request
      storage        = var.cluster_config.storage
      storage_class  = var.cluster_config.storage_class
      replica_count  = var.cluster_config.replica_count
    })
  ]

  force_update = true

  depends_on = [kubernetes_namespace.this, kubernetes_secret.elasticsearch_tls]
}

resource "helm_release" "kibana" {
  name       = var.kibana_config.name
  namespace  = var.k8s_namespace
  chart      = "kibana"
  repository = "https://helm.elastic.co"
  version    = "8.5.1"

  values = [
    templatefile("${path.module}/kibana-values.tftpl", {
      name              = var.kibana_config.name
      replica_count     = var.kibana_config.replica_count
      elasticsearch_url = var.kibana_config.elasticsearch_url
      user              = var.kibana_config.user
      http_port         = var.kibana_config.http_port
      log_level         = var.kibana_config.log_level

      cpu_limit           = var.kibana_config.cpu_limit
      memory_limit        = var.kibana_config.memory_limit
      cpu_request         = var.kibana_config.cpu_request
      memory_request      = var.kibana_config.memory_request
      ingress_enabled     = var.kibana_config.ingress_enabled
      ingress_host        = var.kibana_config.ingress_host
      aws_certificate_arn = var.kibana_config.aws_certificate_arn
      lb_visibility       = var.kibana_config.lb_visibility
    })
  ]

  force_update = true

  depends_on = [kubernetes_namespace.this, kubernetes_secret.elasticsearch_tls, helm_release.elasticsearch]
}

data "kubernetes_ingress_v1" "this" {
  count = var.kibana_config.ingress_enabled ? 1 : 0
  metadata {
    name      = var.kibana_config.name
    namespace = var.k8s_namespace
  }
  depends_on = [helm_release.kibana]
}
