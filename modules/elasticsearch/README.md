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
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.0.6 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ssm_parameter.elasticsearch_creds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.elasticsearch_ert_pem](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.elasticsearch_private_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [helm_release.elasticsearch](https://registry.terraform.io/providers/hashicorp/helm/2.17.0/docs/resources/release) | resource |
| [helm_release.kibana](https://registry.terraform.io/providers/hashicorp/helm/2.17.0/docs/resources/release) | resource |
| [kubernetes_namespace.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_secret.elasticsearch_tls](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [random_password.elasticsearch](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [tls_private_key.elasticsearch](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_self_signed_cert.elasticsearch](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/self_signed_cert) | resource |
| [kubernetes_ingress_v1.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/ingress_v1) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_config"></a> [cluster\_config](#input\_cluster\_config) | Configuration for Elasticsearch | <pre>object({<br>    port           = optional(string, "9200")<br>    transport_port = optional(string, "9300")<br>    user           = optional(string, "elastic")<br>    log_level      = optional(string, "INFO") // values include DEBUG, INFO, WARN, and ERROR.<br>    cpu_limit      = optional(string, "2000m")<br>    memory_limit   = optional(string, "4Gi")<br>    cpu_request    = optional(string, "1000m")<br>    memory_request = optional(string, "2Gi")<br>    storage_class  = optional(string, "gp2")<br>    storage        = optional(string, "30Gi")<br>    replica_count  = optional(string, 3)<br>  })</pre> | n/a | yes |
| <a name="input_create_k8s_namespace"></a> [create\_k8s\_namespace](#input\_create\_k8s\_namespace) | Whether to create namespace | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name | `string` | n/a | yes |
| <a name="input_k8s_namespace"></a> [k8s\_namespace](#input\_k8s\_namespace) | Kubernetes namespace where Elasticsearch to be deployed | `string` | n/a | yes |
| <a name="input_kibana_config"></a> [kibana\_config](#input\_kibana\_config) | Configuration for Kibana | <pre>object({<br>    name                = optional(string, "kibana")<br>    replica_count       = optional(string, 3)<br>    elasticsearch_url   = optional(string, "https://elasticsearch-master:9200")<br>    http_port           = optional(string, "5601")<br>    user                = optional(string, "elastic")<br>    log_level           = optional(string, "info") // values include Options are all, fatal, error, warn, info, debug, trace, off<br>    cpu_limit           = optional(string, "500m")<br>    memory_limit        = optional(string, "1Gi")<br>    cpu_request         = optional(string, "250m")<br>    memory_request      = optional(string, "500Mi")<br>    ingress_enabled     = optional(bool, false)<br>    ingress_host        = optional(string, "")<br>    aws_certificate_arn = optional(string, "")<br>    lb_visibility       = optional(string, "internet-facing")<br>  })</pre> | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | (optional) Name of Elasticsearch cluster | `string` | `"elasticsearch-master"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace for the resources. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | (optional) Tags for AWS resources | `map(string)` | `{}` | no |
| <a name="input_tls_self_signed_cert_data"></a> [tls\_self\_signed\_cert\_data](#input\_tls\_self\_signed\_cert\_data) | (optional) Self Signed TLS certificate data | <pre>object({<br>    organisation          = optional(string, null)<br>    validity_period_hours = optional(number, 26280) # 3 years<br>    early_renewal_hours   = optional(number, 168)   # 1 week<br>  })</pre> | <pre>{<br>  "early_renewal_hours": 168,<br>  "organisation": null,<br>  "validity_period_hours": 26280<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_host"></a> [host](#output\_host) | Elastic Search host |
| <a name="output_lb_arn"></a> [lb\_arn](#output\_lb\_arn) | Kibana ingress loadbalancer ARN |
| <a name="output_password"></a> [password](#output\_password) | Elastic Search user's password |
| <a name="output_port"></a> [port](#output\_port) | Elastic Search port |
| <a name="output_user"></a> [user](#output\_user) | Elastic Search user |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
