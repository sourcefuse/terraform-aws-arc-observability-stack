variable "name" {
  type        = string
  description = "(optional) Name of fluent-bit instance"
  default     = "fluent-bit"
}

variable "k8s_namespace" {
  type        = string
  description = "Kubernetes namespace where fluent-bit to be deployed"
}

variable "create_k8s_namespace" {
  type        = bool
  description = "Whether to create namespace"
  default     = true
}

variable "signoz_config" {
  type = object({
    name          = string
    storage_class = optional(string, "gp3")
    cluster_name  = string
    clickhouse = optional(object({
      user           = optional(string, "admin")
      password       = optional(string, "27ff0399-0d3a-4bd8-919d-17c2181e6fb9")
      cpu_limit      = optional(string, "2000m")
      memory_limit   = optional(string, "4Gi")
      cpu_request    = optional(string, "100m")
      memory_request = optional(string, "200Mi")
      storage        = optional(string, "20Gi")
    }))

    signoz_bin = optional(object({
      replica_count   = optional(number, 1)
      cpu_limit       = optional(string, "750m")
      memory_limit    = optional(string, "1000Mi")
      cpu_request     = optional(string, "100m")
      memory_request  = optional(string, "200Mi")
      enable_ingress  = optional(bool, false)
      certificate_arn = optional(string, null)
      domain          = optional(string, "signoz.example.com")
      storage         = optional(string, "1Gi")
    }))

    alertmanager = optional(object({
      enable          = optional(bool, false)
      replica_count   = optional(number, 1)
      cpu_limit       = optional(string, "750m")
      memory_limit    = optional(string, "1000Mi")
      cpu_request     = optional(string, "100m")
      memory_request  = optional(string, "200Mi")
      storage         = optional(string, "100Mi")
      enable_ingress  = optional(bool, false)
      certificate_arn = optional(string, null)
      domain          = optional(string, "signoz.example.com")
    }))

    otel_collector = optional(object({
      replica_count   = optional(number, 1)
      cpu_limit       = optional(string, "1")
      memory_limit    = optional(string, "2Gi")
      cpu_request     = optional(string, "100m")
      memory_request  = optional(string, "200Mi")
      storage         = optional(string, "100Mi")
      enable_ingress  = optional(bool, false)
      certificate_arn = optional(string, null)
      domain          = optional(string, "signoz.example.com")
    }))
  })

  description = <<-EOT
  Configuration for observability components in the monitoring stack. This variable encapsulates
  settings for the following components:

  - ClickHouse:
    Used as the backend storage engine for observability data (like traces and metrics).
    Includes credentials and resource limits/requests for tuning performance.

  - SigNoz:
    Provides the UI and analytics for monitoring and tracing applications.
    Includes ingress setup and compute resource configuration.

  - Alertmanager:
    Handles alerting rules and notifications for monitoring data.
    Includes configuration for storage, scaling, and ingress settings.

  - OTEL Collector:
    Collects telemetry data (logs, metrics, traces) from the applications and
    routes it to appropriate backends.
    Includes resource definitions and optional ingress configuration.

  This structure enables centralized management of observability stack deployment in Kubernetes
  via Terraform.
  EOT
}

variable "environment" {
  type        = string
  description = "Environment name"
}
