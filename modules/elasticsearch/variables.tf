variable "environment" {
  type        = string
  description = "Environment name"
}

variable "namespace" {
  type        = string
  description = "Namespace for the resources."
}

variable "k8s_namespace" {
  type        = string
  description = "Kubernetes namespace where Elasticsearch to be deployed"
}

variable "create_k8s_namespace" {
  type        = bool
  description = "Whether to create namespace"
  default     = true
}

variable "name" {
  type        = string
  description = "(optional) Name of Elasticsearch cluster"
  default     = "elasticsearch-master"
}

variable "tls_self_signed_cert_data" {
  type = object({
    organisation          = optional(string, null)
    validity_period_hours = optional(number, 26280) # 3 years
    early_renewal_hours   = optional(number, 168)   # 1 week
  })
  description = "(optional) Self Signed TLS certificate data "
  default = {
    organisation          = null
    validity_period_hours = 26280
    early_renewal_hours   = 168
  }
}

variable "cluster_config" {
  description = "Configuration for Elasticsearch"
  type = object({
    port           = optional(string, "9200")
    transport_port = optional(string, "9300")
    user           = optional(string, "elastic")
    log_level      = optional(string, "INFO") // values include DEBUG, INFO, WARN, and ERROR.
    cpu_limit      = optional(string, "2000m")
    memory_limit   = optional(string, "4Gi")
    cpu_request    = optional(string, "1000m")
    memory_request = optional(string, "2Gi")
    storage_class  = optional(string, "gp2")
    storage        = optional(string, "30Gi")
    replicas       = optional(string, 3)
  })
}

variable "kibana_config" {
  description = "Configuration for Kibana"
  type = object({
    name                = optional(string, "kibana")
    elasticsearch_url   = optional(string, "https://elasticsearch-master:9200")
    http_port           = optional(string, "5601")
    user                = optional(string, "elastic")
    log_level           = optional(string, "info") // values include Options are all, fatal, error, warn, info, debug, trace, off
    cpu_limit           = optional(string, "500m")
    memory_limit        = optional(string, "1Gi")
    cpu_request         = optional(string, "250m")
    memory_request      = optional(string, "500Mi")
    ingress_enabled     = optional(bool, false)
    ingress_host        = optional(string, "")
    aws_certificate_arn = optional(string, "")
    lb_visibility       = optional(string, "internet-facing")
  })
}

variable "tags" {
  type        = map(string)
  description = "(optional) Tags for AWS resources"
  default     = {}
}

# TODO:
# replicas: 3
# minimumMasterNodes: 2
