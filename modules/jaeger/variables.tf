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

variable "search_engine" {
  type        = string
  description = "(optional) Search engine for logs"
  default     = "elasticsearch" // elasticsearch
  validation {
    condition     = contains(["elasticsearch", "opensearch"], var.search_engine)
    error_message = "Invalid value for search_engine. Allowed values are 'elasticsearch' and 'opensearch'."
  }
}

variable "log_level" {
  type        = string
  description = "(optional) Log level for fluent-bit service"
  default     = "info"
}

variable "resources" {
  description = "Resource limits and requests for fluent-bit"
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

variable "search_engine_config" {
  description = "Logging and connection configuration for Fluentbit"
  type = object({
    logstash_dateformat = optional(string, "%Y.%m.%d")
    time_format         = optional(string, "%Y-%m-%dT%H:%M:%S.%L")
    host                = optional(string, "elasticsearch-master")
    port                = optional(string, "9200")
    user                = optional(string, "elastic")
    password            = string
    aws_region          = optional(string, "")
    aws_role_arn        = optional(string, "")
  })
  default = {
    logstash_dateformat = "%Y.%m.%d"
    host                = "elasticsearch-master"
    port                = "9200"
    user                = "elastic"
    password            = ""
  }
}
