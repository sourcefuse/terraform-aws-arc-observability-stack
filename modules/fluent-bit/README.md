<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.4, < 2.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0, < 6.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | 2.17.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | 2.17.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.35.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.fluent-bit](https://registry.terraform.io/providers/hashicorp/helm/2.17.0/docs/resources/release) | resource |
| [kubernetes_namespace.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_k8s_namespace"></a> [create\_k8s\_namespace](#input\_create\_k8s\_namespace) | Whether to create namespace | `bool` | `true` | no |
| <a name="input_k8s_namespace"></a> [k8s\_namespace](#input\_k8s\_namespace) | Kubernetes namespace where fluent-bit to be deployed | `string` | n/a | yes |
| <a name="input_log_level"></a> [log\_level](#input\_log\_level) | (optional) Log level for fluent-bit service | `string` | `"info"` | no |
| <a name="input_name"></a> [name](#input\_name) | (optional) Name of fluent-bit instance | `string` | `"fluent-bit"` | no |
| <a name="input_resources"></a> [resources](#input\_resources) | Resource limits and requests for fluent-bit | <pre>object({<br>    cpu_limit      = optional(string, "100m")<br>    memory_limit   = optional(string, "512Mi")<br>    cpu_request    = optional(string, "100m")<br>    memory_request = optional(string, "128Mi")<br>  })</pre> | <pre>{<br>  "cpu_limit": "100m",<br>  "cpu_request": "100m",<br>  "memory_limit": "512Mi",<br>  "memory_request": "128Mi"<br>}</pre> | no |
| <a name="input_search_engine"></a> [search\_engine](#input\_search\_engine) | (optional) Search engine for logs | `string` | `"elasticsearch"` | no |
| <a name="input_search_engine_config"></a> [search\_engine\_config](#input\_search\_engine\_config) | Logging and connection configuration for Fluentbit | <pre>object({<br>    logstash_dateformat = optional(string, "%Y.%m.%d")<br>    time_format         = optional(string, "%Y-%m-%dT%H:%M:%S.%L")<br>    host                = optional(string, "elasticsearch-master")<br>    port                = optional(string, "9200")<br>    user                = optional(string, "elastic")<br>    password            = string<br>    aws_region          = optional(string, "")<br>    aws_role_arn        = optional(string, "")<br>  })</pre> | <pre>{<br>  "host": "elasticsearch-master",<br>  "logstash_dateformat": "%Y.%m.%d",<br>  "password": "",<br>  "port": "9200",<br>  "user": "elastic"<br>}</pre> | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
