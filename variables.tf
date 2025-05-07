variable "environment" {
  type        = string
  description = "Environment name"
}

variable "namespace" {
  type        = string
  description = "Namespace for the resources."
}

variable "tags" {
  type        = map(string)
  description = "(optional) Tags for AWS resources"
  default     = {}
}

variable "search_engine" {
  type        = string
  description = "(optional) Search engine for logs"
  default     = null // elasticsearch
  validation {
    condition     = var.search_engine == null ? true : contains(["elasticsearch", "opensearch", "signoz-clickhouse", null], var.search_engine)
    error_message = "Invalid value for search_engine. Allowed values are 'elasticsearch' , 'opensearch' , 'signoz-clickhouse' and null . null - To disable installing Elasticsearch"
  }
}

variable "metrics_monitoring_system" {
  type        = string
  description = "Monotoring system for metrics"
  default     = null
  validation {
    condition     = var.metrics_monitoring_system == null ? true : contains(["prometheus", "signoz", null], var.metrics_monitoring_system)
    error_message = "Invalid value for metrics_monitoring_system. Allowed values are 'prometheus' , 'signoz' and null . null - To disable installing Prometheus or other systems"
  }
}

variable "log_aggregator" {
  type        = string
  description = "(optional) Log aggregator to choose"
  default     = null
  validation {
    condition     = var.log_aggregator == null ? true : contains(["fluentd", "fluent-bit", "signoz", null], var.log_aggregator)
    error_message = "Invalid value for log_aggregator. Allowed values are 'signoz' , 'fluentd' and 'fluent-bit'. To disable installing Log aggregator"
  }
}

variable "tracing_stack" {
  type        = string
  description = "(optional) Distributed tracing stack"
  default     = null
  validation {
    condition     = var.tracing_stack == null ? true : contains(["jaeger", "signoz", null], var.tracing_stack)
    error_message = "Invalid value for tracing_stack. Allowed values are 'jaeger'"
  }
}

variable "elasticsearch_config" {
  description = "Configuration settings for deploying Elasticsearch"
  type = object({
    name = optional(string, "elasticsearch-master") # Name of the Elasticsearch cluster
    k8s_namespace = object({
      name   = optional(string, "logging")
      create = optional(bool, true)
    })

    tls_self_signed_cert_data = optional(object({     # Self-signed TLS certificate data
      organisation          = optional(string, null)  # Organisation name for certificate
      validity_period_hours = optional(number, 26280) # 3 years validity
      early_renewal_hours   = optional(number, 168)   # 1 week early renewal
    }))

    cluster_config = object({
      port           = optional(string, "9200")    # Elasticsearch HTTP port
      transport_port = optional(string, "9300")    # Elasticsearch transport port
      user           = optional(string, "elastic") # Elasticsearch username
      log_level      = optional(string, "INFO")    # Log level (DEBUG, INFO, WARN, ERROR)
      cpu_limit      = optional(string, "2000m")   # CPU limit for the Elasticsearch container
      memory_limit   = optional(string, "4Gi")     # Memory limit for the Elasticsearch container
      cpu_request    = optional(string, "1000m")   # CPU request for the Elasticsearch container
      memory_request = optional(string, "2Gi")     # Memory request for the Elasticsearch container
      storage_class  = optional(string, "gp2")
      storage        = optional(string, "30Gi") # Persistent volume storage for Elasticsearch
      replica_count  = optional(string, 3)
    })

    kibana_config = object({
      name                = optional(string, "kibana")
      replica_count       = optional(string, 3)
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
  })

  default = {
    name = "elasticsearch-master"

    k8s_namespace = {
      name   = "logging"
      create = true
    }

    tls_self_signed_cert_data = {
      organisation          = null
      validity_period_hours = 26280
      early_renewal_hours   = 168
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
      storage        = "30Gi"
      replica_count  = 3
    }

    kibana_config = {
      name              = "kibana"
      elasticsearch_url = "https://elasticsearch-master:9200"
      http_port         = "5601"
      user              = "elastic"
      log_level         = "info"
      cpu_limit         = "500m"
      memory_limit      = "1Gi"
      cpu_request       = "250m"
      memory_request    = "500Mi"
      ingress_enabled   = false
      ingress_host      = ""

    }
  }
}

variable "fluentd_config" {
  description = "Configuration for Fluentd"
  type = object({
    k8s_namespace = object({
      name   = optional(string, "logging")
      create = optional(bool, false)
    })
    name                = optional(string, "fluentd")
    cpu_limit           = optional(string, "100m")
    memory_limit        = optional(string, "512Mi")
    cpu_request         = optional(string, "100m")
    memory_request      = optional(string, "128Mi")
    logstash_dateformat = optional(string, "%Y.%m.%d") # Default time format
    log_level           = optional(string, "info")     # Default log level
    opensearch_url      = optional(string, "")
    aws_region          = optional(string, "")
    aws_role_arn        = optional(string, "")
  })
  default = {
    name = "fluentd"
    k8s_namespace = {
      name   = "logging"
      create = false
    }
    search_engine       = "elasticsearch"
    cpu_limit           = "100m"
    memory_limit        = "512Mi"
    cpu_request         = "100m"
    memory_request      = "128Mi"
    logstash_dateformat = "%Y.%m.%d"
  }
}

variable "fluentbit_config" {
  description = "Configuration for Fluentbit"
  type = object({
    k8s_namespace = object({
      name   = optional(string, "logging")
      create = optional(bool, false)
    })
    name                = optional(string, "fluent-bit")
    cpu_limit           = optional(string, "100m")
    memory_limit        = optional(string, "512Mi")
    cpu_request         = optional(string, "100m")
    memory_request      = optional(string, "128Mi")
    logstash_dateformat = optional(string, "%Y.%m.%d") # Default time format
    time_format         = optional(string, "%Y-%m-%dT%H:%M:%S.%L")
    log_level           = optional(string, "info") # Default log level
    aws_region          = optional(string, "")
    aws_role_arn        = optional(string, "")
  })
  default = {
    name = "fluent-bit"
    k8s_namespace = {
      name   = "logging"
      create = false
    }
    search_engine       = "elasticsearch"
    cpu_limit           = "100m"
    memory_limit        = "512Mi"
    cpu_request         = "100m"
    memory_request      = "128Mi"
    logstash_dateformat = "%Y.%m.%d"
  }
}

variable "prometheus_config" {
  description = "Configuration settings for deploying Prometheus"
  type = object({
    name = optional(string, "prometheus")
    k8s_namespace = object({
      name   = optional(string, "metrics")
      create = optional(bool, true)
    })
    log_level                 = optional(string, "info")
    replica_count             = optional(number, 1)
    storage                   = optional(string, "8Gi")
    storage_class             = optional(string, "gp2")
    enable_kube_state_metrics = optional(bool, true)
    enable_node_exporter      = optional(bool, true)
    cpu_limit                 = optional(string, "100m")
    memory_limit              = optional(string, "512Mi")
    cpu_request               = optional(string, "100m")
    memory_request            = optional(string, "128Mi")
    retention_period          = optional(string, "15d")

    grafana_config = object({
      name                = optional(string, "grafana")
      replica_count       = optional(number, 1)
      ingress_enabled     = optional(bool, false)
      lb_visibility       = optional(string, "internet-facing") # Options: "internal" or "internet-facing"
      aws_certificate_arn = optional(string, "")
      ingress_host        = optional(string, "")
      admin_user          = optional(string, "admin")
      cpu_limit           = optional(string, "100m")
      memory_limit        = optional(string, "128Mi")
      cpu_request         = optional(string, "100m")
      memory_request      = optional(string, "128Mi")
      dashboard_list = optional(list(object({
        name = string
        json = string
      })), [])
    })

    blackbox_exporter_config = object({
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

    alertmanager_config = object({
      name                        = optional(string, "alertmanager")
      replica_count               = optional(number, 1)
      cpu_limit                   = optional(string, "100m")
      memory_limit                = optional(string, "128Mi")
      cpu_request                 = optional(string, "10m")
      memory_request              = optional(string, "32Mi")
      custom_alerts               = optional(string, "")
      alert_notification_settings = optional(string, "")
    })
  })
  default = {
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
    replica_count             = 1
    storage                   = "8Gi"
    enable_kube_state_metrics = true
    enable_node_exporter      = true
    retention_period          = "15d"

    grafana_config = {
      ingress_enabled     = false
      lb_visibility       = "internet-facing"
      admin_user          = "admin"
      prometheus_endpoint = "prometheus"
    }
    blackbox_exporter_config = {
      name               = "blackbox-exporter"
      monitoring_targets = []
    }
    alertmanager_config = {
      name = "alertmanager"
    }
  }

}

variable "signoz_config" {
  type = object({
    k8s_namespace = object({
      name   = optional(string, "signoz")
      create = optional(bool, false)
    })
    name          = optional(string, "signoz")
    storage_class = optional(string, "gp3")
    cluster_name  = string
    clickhouse = optional(object({
      user           = optional(string, "admin")
      cpu_limit      = optional(string, "2000m")
      memory_limit   = optional(string, "4Gi")
      cpu_request    = optional(string, "100m")
      memory_request = optional(string, "200Mi")
      storage        = optional(string, "20Gi")
    }))

    signoz_bin = optional(object({
      replica_count       = optional(number, 1)
      cpu_limit           = optional(string, "750m")
      memory_limit        = optional(string, "1000Mi")
      cpu_request         = optional(string, "100m")
      memory_request      = optional(string, "200Mi")
      ingress_enabled     = optional(bool, false)
      aws_certificate_arn = optional(string, null)
      domain              = string
      root_domain         = optional(string, null)              // if root domain is provided, it creates DNS record
      lb_visibility       = optional(string, "internet-facing") # Options: "internal" or "internet-facing"
    }))

    alertmanager = optional(object({
      enable              = optional(bool, false)
      replica_count       = optional(number, 1)
      cpu_limit           = optional(string, "750m")
      memory_limit        = optional(string, "1000Mi")
      cpu_request         = optional(string, "100m")
      memory_request      = optional(string, "200Mi")
      storage             = optional(string, "100Mi")
      enable_ingress      = optional(bool, false)
      aws_certificate_arn = optional(string, null)
      domain              = optional(string, "signoz.example.com")
    }))

    otel_collector = optional(object({
      cpu_limit           = optional(string, "1")
      memory_limit        = optional(string, "2Gi")
      cpu_request         = optional(string, "100m")
      memory_request      = optional(string, "200Mi")
      storage             = optional(string, "100Mi")
      enable_ingress      = optional(bool, false)
      aws_certificate_arn = optional(string, null)
      domain              = optional(string, "signoz.example.com")
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
  default = {
    k8s_namespace = {
      name   = "signoz"
      create = true
    }
    name         = null
    cluster_name = null
  }
}

variable "signoz_infra_monitor_config" {
  type = object({
    k8s_namespace = optional(object({
      name   = optional(string, "signoz")
      create = optional(bool, false)
    }))
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
- if any one ofr the values enable_log_collection,enable_metrics_collection is true, then helm chart gets installed

This variable is used to centralize configuration related to monitoring infrastructure via SigNoz.
EOT

  default = {
    name         = null
    cluster_name = null
  }
}
