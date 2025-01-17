variable "environment" {
  type        = string
  description = "Environment name"
}

variable "namespace" {
  type        = string
  description = "Namespace for the resources."
}

variable "name" {
  type        = string
  description = "(optional) Name of prometheus instance"
  default     = "prometheus"
}

variable "k8s_namespace" {
  type        = string
  description = "Kubernetes namespace where prometheus to be deployed"
  default     = "metrics"
}

variable "create_k8s_namespace" {
  type        = bool
  description = "Whether to create namespace"
  default     = true
}

variable "replica_count" {
  type        = number
  description = "(optional) Number of replicas for Prometheus"
  default     = 1
}

variable "log_level" {
  type        = string
  description = "(optional) Log level for prometheus service"
  default     = "info"
}

variable "resources" {
  description = "Resource limits and requests for prometheus"
  type = object({
    cpu_limit      = optional(string, "100m")
    memory_limit   = optional(string, "512Mi")
    cpu_request    = optional(string, "100m")
    memory_request = optional(string, "128Mi")
  })
  default = {
    cpu_limit      = "100m"
    memory_limit   = "512Mi"
    cpu_request    = "100m"
    memory_request = "128Mi"
  }
}

variable "storage" {
  description = "The storage size allocated for the resource (e.g., PersistentVolume)."
  type        = string
  default     = "8Gi"
}

variable "storage_class" {
  description = "The storage class"
  type        = string
  default     = "gp2"
}

variable "enable_kube_state_metrics" {
  description = "Flag to enable or disable kube-state-metrics. Set to true to enable."
  type        = bool
  default     = true
}

variable "enable_node_exporter" {
  description = "Flag to enable or disable the node exporter for system metrics. Set to true to enable."
  type        = bool
  default     = true
}

variable "retention_period" {
  description = "Retention period for Prometheis metrics"
  type        = string
  default     = "15d"
}

variable "grafana_config" {
  description = "Configuration for Grafana, including ingress settings, admin credentials, and Prometheus integration."
  type = object({
    name                = optional(string, "grafana")
    replicas            = optional(number, 1)
    ingress_enabled     = optional(bool, false)
    lb_visibility       = optional(string, "internet-facing") # Options: "internal" or "internet-facing"
    aws_certificate_arn = optional(string, "")
    ingress_host        = optional(string, "")
    admin_user          = optional(string, "admin")
    prometheus_endpoint = optional(string, "prometheus")
    cpu_limit           = optional(string, "100m")
    memory_limit        = optional(string, "128Mi")
    cpu_request         = optional(string, "100m")
    memory_request      = optional(string, "128Mi")
    storage             = optional(string, "2Gi")
    dashboard_list = optional(list(object({
      name = string
      json = string
    })), [])
  })
  default = {
    ingress_enabled     = false
    lb_visibility       = "internet-facing"
    admin_user          = "admin"
    prometheus_endpoint = "prometheus"
  }
}

variable "tags" {
  type        = map(string)
  description = "(optional) Tags for AWS resources"
  default     = {}
}

variable "blackbox_exporter_config" {
  description = "Configuration for Blackbox exporter."
  type = object({
    name           = optional(string, "blackbox-exporter")
    replica_count  = optional(number, 1)
    cpu_limit      = optional(string, "100m")
    memory_limit   = optional(string, "500Mi")
    cpu_request    = optional(string, "100m")
    memory_request = optional(string, "50Mi")
    monitoring_targets = list(object({
      name                     = string                         # Target name (e.g., google)
      url                      = string                         # URL to monitor (e.g., https://google.com)
      scrape_interval          = optional(string, "60s")        # Scrape interval (e.g., 60s)
      scrape_timeout           = optional(string, "60s")        # Scrape timeout (e.g., 60s)
      status_code_pattern_list = optional(string, "[http_2xx]") # Blackbox module to use (e.g., http_2xx)
    }))
  })
  default = {
    name               = "blackbox-exporter"
    monitoring_targets = []
  }
}

variable "alertmanager_config" {
  description = "Configuration for AlertManager exporter."
  type = object({
    name                        = optional(string, "alertmanager")
    replica_count               = optional(number, 1)
    cpu_limit                   = optional(string, "100m")
    memory_limit                = optional(string, "128Mi")
    cpu_request                 = optional(string, "10m")
    memory_request              = optional(string, "32Mi")
    custom_alerts               = optional(string, "")
    alert_notification_settings = optional(string, "")
  })
  default = {
    name = "alertmanager"
  }
}
