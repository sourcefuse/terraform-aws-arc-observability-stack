<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.4, < 2.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0, < 6.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | 2.17.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.3 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.6.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | ~> 4.0.6 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.83.1 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | 2.17.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.35.1 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.3 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ssm_parameter.grafana_creds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [helm_release.blackbox_exporter](https://registry.terraform.io/providers/hashicorp/helm/2.17.0/docs/resources/release) | resource |
| [helm_release.prometheus](https://registry.terraform.io/providers/hashicorp/helm/2.17.0/docs/resources/release) | resource |
| [kubernetes_config_map.dashboards](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map) | resource |
| [kubernetes_namespace.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [random_password.grafana](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [kubernetes_ingress_v1.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/ingress_v1) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alertmanager_config"></a> [alertmanager\_config](#input\_alertmanager\_config) | Configuration for AlertManager exporter. | <pre>object({<br>    name                        = optional(string, "alertmanager")<br>    replica_count               = optional(number, 1)<br>    cpu_limit                   = optional(string, "100m")<br>    memory_limit                = optional(string, "128Mi")<br>    cpu_request                 = optional(string, "10m")<br>    memory_request              = optional(string, "32Mi")<br>    custom_alerts               = optional(string, "")<br>    alert_notification_settings = optional(string, "")<br>  })</pre> | <pre>{<br>  "name": "alertmanager"<br>}</pre> | no |
| <a name="input_blackbox_exporter_config"></a> [blackbox\_exporter\_config](#input\_blackbox\_exporter\_config) | Configuration for Blackbox exporter. | <pre>object({<br>    name           = optional(string, "blackbox-exporter")<br>    replica_count  = optional(number, 1)<br>    cpu_limit      = optional(string, "100m")<br>    memory_limit   = optional(string, "500Mi")<br>    cpu_request    = optional(string, "100m")<br>    memory_request = optional(string, "50Mi")<br>    monitoring_targets = list(object({<br>      name                     = string                         # Target name (e.g., google)<br>      url                      = string                         # URL to monitor (e.g., https://google.com)<br>      scrape_interval          = optional(string, "60s")        # Scrape interval (e.g., 60s)<br>      scrape_timeout           = optional(string, "60s")        # Scrape timeout (e.g., 60s)<br>      status_code_pattern_list = optional(string, "[http_2xx]") # Blackbox module to use (e.g., http_2xx)<br>    }))<br>  })</pre> | <pre>{<br>  "monitoring_targets": [],<br>  "name": "blackbox-exporter"<br>}</pre> | no |
| <a name="input_create_k8s_namespace"></a> [create\_k8s\_namespace](#input\_create\_k8s\_namespace) | Whether to create namespace | `bool` | `true` | no |
| <a name="input_enable_kube_state_metrics"></a> [enable\_kube\_state\_metrics](#input\_enable\_kube\_state\_metrics) | Flag to enable or disable kube-state-metrics. Set to true to enable. | `bool` | `true` | no |
| <a name="input_enable_node_exporter"></a> [enable\_node\_exporter](#input\_enable\_node\_exporter) | Flag to enable or disable the node exporter for system metrics. Set to true to enable. | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name | `string` | n/a | yes |
| <a name="input_grafana_config"></a> [grafana\_config](#input\_grafana\_config) | Configuration for Grafana, including ingress settings, admin credentials, and Prometheus integration. | <pre>object({<br>    name                = optional(string, "grafana")<br>    replicas            = optional(number, 1)<br>    ingress_enabled     = optional(bool, false)<br>    lb_visibility       = optional(string, "internet-facing") # Options: "internal" or "internet-facing"<br>    aws_certificate_arn = optional(string, "")<br>    ingress_host        = optional(string, "")<br>    admin_user          = optional(string, "admin")<br>    prometheus_endpoint = optional(string, "prometheus")<br>    cpu_limit           = optional(string, "100m")<br>    memory_limit        = optional(string, "128Mi")<br>    cpu_request         = optional(string, "100m")<br>    memory_request      = optional(string, "128Mi")<br>    storage             = optional(string, "2Gi")<br>    dashboard_list = optional(list(object({<br>      name = string<br>      json = string<br>    })), [])<br>  })</pre> | <pre>{<br>  "admin_user": "admin",<br>  "ingress_enabled": false,<br>  "lb_visibility": "internet-facing",<br>  "prometheus_endpoint": "prometheus"<br>}</pre> | no |
| <a name="input_k8s_namespace"></a> [k8s\_namespace](#input\_k8s\_namespace) | Kubernetes namespace where prometheus to be deployed | `string` | `"metrics"` | no |
| <a name="input_log_level"></a> [log\_level](#input\_log\_level) | (optional) Log level for prometheus service | `string` | `"info"` | no |
| <a name="input_name"></a> [name](#input\_name) | (optional) Name of prometheus instance | `string` | `"prometheus"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace for the resources. | `string` | n/a | yes |
| <a name="input_replica_count"></a> [replica\_count](#input\_replica\_count) | (optional) Number of replicas for Prometheus | `number` | `1` | no |
| <a name="input_resources"></a> [resources](#input\_resources) | Resource limits and requests for prometheus | <pre>object({<br>    cpu_limit      = optional(string, "100m")<br>    memory_limit   = optional(string, "512Mi")<br>    cpu_request    = optional(string, "100m")<br>    memory_request = optional(string, "128Mi")<br>  })</pre> | <pre>{<br>  "cpu_limit": "100m",<br>  "cpu_request": "100m",<br>  "memory_limit": "512Mi",<br>  "memory_request": "128Mi"<br>}</pre> | no |
| <a name="input_retention_period"></a> [retention\_period](#input\_retention\_period) | Retention period for Prometheis metrics | `string` | `"15d"` | no |
| <a name="input_storage"></a> [storage](#input\_storage) | The storage size allocated for the resource (e.g., PersistentVolume). | `string` | `"8Gi"` | no |
| <a name="input_storage_class"></a> [storage\_class](#input\_storage\_class) | The storage class | `string` | `"gp2"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (optional) Tags for AWS resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_lb_dns"></a> [lb\_dns](#output\_lb\_dns) | Grafana ingress loadbalancer DNS |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
