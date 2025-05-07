variable "name" {
  type        = string
  description = "(optional) Name of signoz instance"
  default     = "signoz"
}

variable "k8s_namespace" {
  type        = string
  description = "Kubernetes namespace where signoz to be deployed"
}

variable "create_k8s_namespace" {
  type        = bool
  description = "Whether to create namespace"
  default     = true
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "signoz_infra_monitor_config" {
  type = object({
    name                       = string
    storage_class              = optional(string, "gp3")
    cluster_name               = string
    enable_log_collection      = optional(bool, false)
    enable_metrics_collection  = optional(bool, false)
    otel_collector_endpoint    = optional(string, null)
    metric_collection_interval = optional(string, "30s")

  })

  description = <<-EOT
Configuration object for deploying SigNoz infrastructure monitoring components.

Attributes:
- name: A name identifier for the monitoring deployment (used in naming resources).
- storage_class: (Optional) The Kubernetes storage class to be used for persistent volumes. Defaults to "gp3".
- cluster_name: The name of the Kubernetes cluster where SigNoz is being deployed.
- otel_collector_endpoint: The endpoint URL for the OpenTelemetry Collector to which metrics, logs, and traces will be exported.
- metric_collection_interval: (Optional) The interval at which metrics are collected. Defaults to "30s".

This variable is used to centralize configuration related to monitoring infrastructure via SigNoz.
EOT

  default = {
    name         = null
    cluster_name = null
  }
}

// This variable is just to get values
variable "otel_collector_endpoint" {
  type        = string
  description = "(optional) The endpoint URL for the OpenTelemetry Collector to which metrics, logs, and traces will be exported."
  default     = null
}
