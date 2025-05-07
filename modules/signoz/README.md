<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.4, < 2.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0, < 6.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | 2.17.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.3 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.96.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | 2.17.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.36.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.7.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_route53_record.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [helm_release.signoz](https://registry.terraform.io/providers/hashicorp/helm/2.17.0/docs/resources/release) | resource |
| [kubernetes_namespace.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [random_password.clickhouse](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [aws_route53_zone.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |
| [kubernetes_ingress_v1.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/ingress_v1) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_k8s_namespace"></a> [create\_k8s\_namespace](#input\_create\_k8s\_namespace) | Whether to create namespace | `bool` | `true` | no |
| <a name="input_k8s_namespace"></a> [k8s\_namespace](#input\_k8s\_namespace) | Kubernetes namespace where signoz to be deployed | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | (optional) Name of signoz instance | `string` | `"signoz"` | no |
| <a name="input_signoz_config"></a> [signoz\_config](#input\_signoz\_config) | Configuration for observability components in the monitoring stack. This variable encapsulates<br>settings for the following components:<br><br>- ClickHouse:<br>  Used as the backend storage engine for observability data (like traces and metrics).<br>  Includes credentials and resource limits/requests for tuning performance.<br><br>- SigNoz:<br>  Provides the UI and analytics for monitoring and tracing applications.<br>  Includes ingress setup and compute resource configuration.<br><br>- Alertmanager:<br>  Handles alerting rules and notifications for monitoring data.<br>  Includes configuration for storage, scaling, and ingress settings.<br><br>- OTEL Collector:<br>  Collects telemetry data (logs, metrics, traces) from the applications and<br>  routes it to appropriate backends.<br>  Includes resource definitions and optional ingress configuration.<br><br>This structure enables centralized management of observability stack deployment in Kubernetes<br>via Terraform. | <pre>object({<br>    install       = optional(bool, true)<br>    name          = optional(string, "signoz")<br>    storage_class = optional(string, "gp3")<br>    cluster_name  = string<br>    clickhouse = optional(object({<br>      user           = optional(string, "admin")<br>      cpu_limit      = optional(string, "2000m")<br>      memory_limit   = optional(string, "4Gi")<br>      cpu_request    = optional(string, "100m")<br>      memory_request = optional(string, "200Mi")<br>      storage        = optional(string, "20Gi")<br>    }))<br><br>    signoz_bin = optional(object({<br>      replica_count       = optional(number, 1)<br>      cpu_limit           = optional(string, "750m")<br>      memory_limit        = optional(string, "1000Mi")<br>      cpu_request         = optional(string, "100m")<br>      memory_request      = optional(string, "200Mi")<br>      ingress_enabled     = optional(bool, false)<br>      aws_certificate_arn = optional(string, null)<br>      domain              = string<br>      lb_visibility       = optional(string, "internet-facing") # Options: "internal" or "internet-facing"<br>      root_domain         = optional(string, null)              // if root domain is provided, it creates DNS record<br>      storage             = optional(string, "1Gi")<br>    }))<br><br>    alertmanager = optional(object({<br>      enable          = optional(bool, false)<br>      replica_count   = optional(number, 1)<br>      cpu_limit       = optional(string, "750m")<br>      memory_limit    = optional(string, "1000Mi")<br>      cpu_request     = optional(string, "100m")<br>      memory_request  = optional(string, "200Mi")<br>      storage         = optional(string, "100Mi")<br>      ingress_enabled = optional(bool, false)<br>      certificate_arn = optional(string, null)<br>      domain          = optional(string, "signoz.example.com")<br>    }))<br><br>    otel_collector = optional(object({<br>      replica_count   = optional(number, 1)<br>      cpu_limit       = optional(string, "1")<br>      memory_limit    = optional(string, "2Gi")<br>      cpu_request     = optional(string, "100m")<br>      memory_request  = optional(string, "200Mi")<br>      storage         = optional(string, "100Mi")<br>      ingress_enabled = optional(bool, false)<br>      certificate_arn = optional(string, null)<br>      domain          = optional(string, "signoz.example.com")<br>    }))<br>  })</pre> | <pre>{<br>  "cluster_name": null,<br>  "install": false,<br>  "name": null<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_lb_arn"></a> [lb\_arn](#output\_lb\_arn) | Signoz ingress loadbalancer ARN |
| <a name="output_otel_collector_endpoint"></a> [otel\_collector\_endpoint](#output\_otel\_collector\_endpoint) | OTEL collector endpoint |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
