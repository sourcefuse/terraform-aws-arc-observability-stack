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
| <a name="provider_helm"></a> [helm](#provider\_helm) | 2.17.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.36.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.k8s_infra](https://registry.terraform.io/providers/hashicorp/helm/2.17.0/docs/resources/release) | resource |
| [kubernetes_namespace.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_k8s_namespace"></a> [create\_k8s\_namespace](#input\_create\_k8s\_namespace) | Whether to create namespace | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name | `string` | n/a | yes |
| <a name="input_k8s_namespace"></a> [k8s\_namespace](#input\_k8s\_namespace) | Kubernetes namespace where signoz to be deployed | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | (optional) Name of signoz instance | `string` | `"signoz"` | no |
| <a name="input_otel_collector_endpoint"></a> [otel\_collector\_endpoint](#input\_otel\_collector\_endpoint) | (optional) The endpoint URL for the OpenTelemetry Collector to which metrics, logs, and traces will be exported. | `string` | `null` | no |
| <a name="input_signoz_infra_monitor_config"></a> [signoz\_infra\_monitor\_config](#input\_signoz\_infra\_monitor\_config) | Configuration object for deploying SigNoz infrastructure monitoring components.<br><br>Attributes:<br>- name: A name identifier for the monitoring deployment (used in naming resources).<br>- storage\_class: (Optional) The Kubernetes storage class to be used for persistent volumes. Defaults to "gp3".<br>- cluster\_name: The name of the Kubernetes cluster where SigNoz is being deployed.<br>- otel\_collector\_endpoint: The endpoint URL for the OpenTelemetry Collector to which metrics, logs, and traces will be exported.<br>- metric\_collection\_interval: (Optional) The interval at which metrics are collected. Defaults to "30s".<br><br>This variable is used to centralize configuration related to monitoring infrastructure via SigNoz. | <pre>object({<br>    name                       = string<br>    storage_class              = optional(string, "gp3")<br>    cluster_name               = string<br>    enable_log_collection      = optional(bool, false)<br>    enable_metrics_collection  = optional(bool, false)<br>    otel_collector_endpoint    = optional(string, null)<br>    metric_collection_interval = optional(string, "30s")<br><br>  })</pre> | <pre>{<br>  "cluster_name": null,<br>  "name": null<br>}</pre> | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
