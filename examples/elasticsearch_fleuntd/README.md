# terraform-aws-module-template example

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.4, < 2.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0, < 6.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | 2.17.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | = 2.24.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 2.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.6.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | ~> 4.0.6 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.83.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_efk_es_fluentd"></a> [efk\_es\_fluentd](#module\_efk\_es\_fluentd) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_eks_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_eks_cluster_auth.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_certificate_arn"></a> [aws\_certificate\_arn](#input\_aws\_certificate\_arn) | The ARN of the ACM certificate to use for the domain. | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name | `string` | `"dev"` | no |
| <a name="input_ingress_host"></a> [ingress\_host](#input\_ingress\_host) | The Route 53 domain to associate with the resource. | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace for the resources. | `string` | `"arc"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | `"us-east-1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_kibana_lb_arn"></a> [kibana\_lb\_arn](#output\_kibana\_lb\_arn) | Kibana ingress loadbalancer DNS |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
