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
    condition     = var.search_engine == null ? true : contains(["elasticsearch", "opensearch", null], var.search_engine)
    error_message = "Invalid value for search_engine. Allowed values are 'elasticsearch' , 'opensearch' and null . null - To disable installing Elasticsearch"
  }
}

variable "metrics_monitoring_system" {
  type        = string
  description = "Monotoring system for metrics"
  default     = null
  validation {
    condition     = var.metrics_monitoring_system == null ? true : contains(["prometheus", null], var.metrics_monitoring_system)
    error_message = "Invalid value for metrics_monitoring_system. Allowed values are 'prometheus' and null . null - To disable installing Prometheus or other systems"
  }
}

variable "log_aggregator" {
  type        = string
  description = "(optional) Log aggregator to choose"
  default     = null
  validation {
    condition     = var.log_aggregator == null ? true : contains(["fluentd", "fluent-bit", null], var.log_aggregator)
    error_message = "Invalid value for log_aggregator. Allowed values are 'fluentd' and 'fluent-bit'. To disable installing Log aggregator"
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
    replicas                  = optional(number, 1)
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
      replicas            = optional(number, 1)
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
      name            = optional(string, "alertmanager")
      replica_count   = optional(number, 1)
      cpu_limit       = optional(string, "100m")
      memory_limit    = optional(string, "128Mi")
      cpu_request     = optional(string, "10m")
      memory_request  = optional(string, "32Mi")
      alert_rule_yaml = optional(string, "")
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
    replicas                  = 1
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
