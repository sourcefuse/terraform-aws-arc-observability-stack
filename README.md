# terraform-aws-module-template

## Overview

SourceFuse AWS Reference Architecture (ARC) Terraform module for managing _________.

## Usage

To see a full example, check out the [main.tf](./example/main.tf) file in the example folder.  

```hcl
module "this" {
  source = "git::https://github.com/sourcefuse/terraform-aws-refarch-<module_name>"
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.4, < 2.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0, < 6.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 2.0.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.6.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | ~> 4.0.6 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_elasticsearch"></a> [elasticsearch](#module\_elasticsearch) | ./modules/elasticsearch | n/a |
| <a name="module_fluentbit"></a> [fluentbit](#module\_fluentbit) | ./modules/fluent-bit | n/a |
| <a name="module_fluentd"></a> [fluentd](#module\_fluentd) | ./modules/fluentd | n/a |
| <a name="module_prometheus"></a> [prometheus](#module\_prometheus) | ./modules/prometheus | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_elasticsearch_config"></a> [elasticsearch\_config](#input\_elasticsearch\_config) | Configuration settings for deploying Elasticsearch | <pre>object({<br>    name = optional(string, "elasticsearch-master") # Name of the Elasticsearch cluster<br>    k8s_namespace = object({<br>      name   = optional(string, "logging")<br>      create = optional(bool, true)<br>    })<br><br>    tls_self_signed_cert_data = optional(object({     # Self-signed TLS certificate data<br>      organisation          = optional(string, null)  # Organisation name for certificate<br>      validity_period_hours = optional(number, 26280) # 3 years validity<br>      early_renewal_hours   = optional(number, 168)   # 1 week early renewal<br>    }))<br><br>    cluster_config = object({<br>      port           = optional(string, "9200")    # Elasticsearch HTTP port<br>      transport_port = optional(string, "9300")    # Elasticsearch transport port<br>      user           = optional(string, "elastic") # Elasticsearch username<br>      log_level      = optional(string, "INFO")    # Log level (DEBUG, INFO, WARN, ERROR)<br>      cpu_limit      = optional(string, "2000m")   # CPU limit for the Elasticsearch container<br>      memory_limit   = optional(string, "4Gi")     # Memory limit for the Elasticsearch container<br>      cpu_request    = optional(string, "1000m")   # CPU request for the Elasticsearch container<br>      memory_request = optional(string, "2Gi")     # Memory request for the Elasticsearch container<br>      storage_class  = optional(string, "gp2")<br>      storage        = optional(string, "30Gi") # Persistent volume storage for Elasticsearch<br>      replicas       = optional(string, 3)<br>    })<br><br>    kibana_config = object({<br>      name                = optional(string, "kibana")<br>      http_port           = optional(string, "5601")<br>      user                = optional(string, "elastic")<br>      log_level           = optional(string, "info") // values include Options are all, fatal, error, warn, info, debug, trace, off<br>      cpu_limit           = optional(string, "500m")<br>      memory_limit        = optional(string, "1Gi")<br>      cpu_request         = optional(string, "250m")<br>      memory_request      = optional(string, "500Mi")<br>      ingress_enabled     = optional(bool, false)<br>      ingress_host        = optional(string, "")<br>      aws_certificate_arn = optional(string, "")<br>      lb_visibility       = optional(string, "internet-facing")<br>    })<br>  })</pre> | <pre>{<br>  "cluster_config": {<br>    "cpu_limit": "2000m",<br>    "cpu_request": "1000m",<br>    "log_level": "INFO",<br>    "memory_limit": "4Gi",<br>    "memory_request": "2Gi",<br>    "port": "9200",<br>    "replicas": 3,<br>    "storage": "30Gi",<br>    "transport_port": "9300",<br>    "user": "elastic"<br>  },<br>  "k8s_namespace": {<br>    "create": true,<br>    "name": "logging"<br>  },<br>  "kibana_config": {<br>    "cpu_limit": "500m",<br>    "cpu_request": "250m",<br>    "elasticsearch_url": "https://elasticsearch-master:9200",<br>    "http_port": "5601",<br>    "ingress_enabled": false,<br>    "ingress_host": "",<br>    "log_level": "info",<br>    "memory_limit": "1Gi",<br>    "memory_request": "500Mi",<br>    "name": "kibana",<br>    "user": "elastic"<br>  },<br>  "name": "elasticsearch-master",<br>  "tls_self_signed_cert_data": {<br>    "early_renewal_hours": 168,<br>    "organisation": null,<br>    "validity_period_hours": 26280<br>  }<br>}</pre> | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name | `string` | n/a | yes |
| <a name="input_fluentbit_config"></a> [fluentbit\_config](#input\_fluentbit\_config) | Configuration for Fluentbit | <pre>object({<br>    k8s_namespace = object({<br>      name   = optional(string, "logging")<br>      create = optional(bool, false)<br>    })<br>    name                = optional(string, "fluent-bit")<br>    cpu_limit           = optional(string, "100m")<br>    memory_limit        = optional(string, "512Mi")<br>    cpu_request         = optional(string, "100m")<br>    memory_request      = optional(string, "128Mi")<br>    logstash_dateformat = optional(string, "%Y.%m.%d") # Default time format<br>    time_format         = optional(string, "%Y-%m-%dT%H:%M:%S.%L")<br>    log_level           = optional(string, "info") # Default log level<br>    aws_region          = optional(string, "")<br>    aws_role_arn        = optional(string, "")<br>  })</pre> | <pre>{<br>  "cpu_limit": "100m",<br>  "cpu_request": "100m",<br>  "k8s_namespace": {<br>    "create": false,<br>    "name": "logging"<br>  },<br>  "logstash_dateformat": "%Y.%m.%d",<br>  "memory_limit": "512Mi",<br>  "memory_request": "128Mi",<br>  "name": "fluent-bit",<br>  "search_engine": "elasticsearch"<br>}</pre> | no |
| <a name="input_fluentd_config"></a> [fluentd\_config](#input\_fluentd\_config) | Configuration for Fluentd | <pre>object({<br>    k8s_namespace = object({<br>      name   = optional(string, "logging")<br>      create = optional(bool, false)<br>    })<br>    name                = optional(string, "fluentd")<br>    cpu_limit           = optional(string, "100m")<br>    memory_limit        = optional(string, "512Mi")<br>    cpu_request         = optional(string, "100m")<br>    memory_request      = optional(string, "128Mi")<br>    logstash_dateformat = optional(string, "%Y.%m.%d") # Default time format<br>    log_level           = optional(string, "info")     # Default log level<br>    opensearch_url      = optional(string, "")<br>    aws_region          = optional(string, "")<br>    aws_role_arn        = optional(string, "")<br>  })</pre> | <pre>{<br>  "cpu_limit": "100m",<br>  "cpu_request": "100m",<br>  "k8s_namespace": {<br>    "create": false,<br>    "name": "logging"<br>  },<br>  "logstash_dateformat": "%Y.%m.%d",<br>  "memory_limit": "512Mi",<br>  "memory_request": "128Mi",<br>  "name": "fluentd",<br>  "search_engine": "elasticsearch"<br>}</pre> | no |
| <a name="input_log_aggregator"></a> [log\_aggregator](#input\_log\_aggregator) | (optional) Log aggregator to choose | `string` | `"fluentd"` | no |
| <a name="input_monitoring_system"></a> [monitoring\_system](#input\_monitoring\_system) | Monotoring system for metrics | `string` | `"prometheus"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace for the resources. | `string` | n/a | yes |
| <a name="input_prometheus_config"></a> [prometheus\_config](#input\_prometheus\_config) | Configuration settings for deploying Prometheus | <pre>object({<br>    name = optional(string, "prometheus")<br>    k8s_namespace = object({<br>      name   = optional(string, "metrics")<br>      create = optional(bool, true)<br>    })<br>    log_level                 = optional(string, "info")<br>    replicas                  = optional(number, 1)<br>    storage                   = optional(string, "8Gi")<br>    storage_class             = optional(string, "gp2")<br>    enable_kube_state_metrics = optional(bool, true)<br>    enable_node_exporter      = optional(bool, true)<br>    cpu_limit                 = optional(string, "100m")<br>    memory_limit              = optional(string, "512Mi")<br>    cpu_request               = optional(string, "100m")<br>    memory_request            = optional(string, "128Mi")<br>    retention_period          = optional(string, "15d")<br><br>    grafana_config = object({<br>      name                = optional(string, "grafana")<br>      replicas            = optional(number, 1)<br>      ingress_enabled     = optional(bool, false)<br>      lb_visibility       = optional(string, "internal") # Options: "internal" or "internet-facing"<br>      aws_certificate_arn = optional(string, "")<br>      ingress_host        = optional(string, "")<br>      admin_user          = optional(string, "admin")<br>      cpu_limit           = optional(string, "100m")<br>      memory_limit        = optional(string, "128Mi")<br>      cpu_request         = optional(string, "100m")<br>      memory_request      = optional(string, "128Mi")<br>    })<br>  })</pre> | <pre>{<br>  "enable_kube_state_metrics": true,<br>  "enable_node_exporter": true,<br>  "grafana_config": {<br>    "admin_user": "admin",<br>    "ingress_enabled": false,<br>    "lb_visibility": "internet-facing",<br>    "prometheus_endpoint": "prometheus"<br>  },<br>  "k8s_namespace": {<br>    "create": true,<br>    "name": "metrics"<br>  },<br>  "log_level": "info",<br>  "replicas": 1,<br>  "resources": {<br>    "cpu_limit": "100m",<br>    "cpu_request": "100m",<br>    "memory_limit": "512Mi",<br>    "memory_request": "128Mi"<br>  },<br>  "retention_period": "15d",<br>  "storage": "8Gi"<br>}</pre> | no |
| <a name="input_search_engine"></a> [search\_engine](#input\_search\_engine) | (optional) Search engine for logs | `string` | `"elasticsearch"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (optional) Tags for AWS resources | `map(string)` | `{}` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Versioning  
This project uses a `.version` file at the root of the repo which the pipeline reads from and does a git tag.  

When you intend to commit to `main`, you will need to increment this version. Once the project is merged,
the pipeline will kick off and tag the latest git commit.  

## Development

### Prerequisites

- [terraform](https://learn.hashicorp.com/terraform/getting-started/install#installing-terraform)
- [terraform-docs](https://github.com/segmentio/terraform-docs)
- [pre-commit](https://pre-commit.com/#install)
- [golang](https://golang.org/doc/install#install)
- [golint](https://github.com/golang/lint#installation)

### Configurations

- Configure pre-commit hooks
  ```sh
  pre-commit install
  ```

### Versioning

while Contributing or doing git commit please specify the breaking change in your commit message whether its major,minor or patch

For Example

```sh
git commit -m "your commit message #major"
```
By specifying this , it will bump the version and if you don't specify this in your commit message then by default it will consider patch and will bump that accordingly

### Tests
- Tests are available in `test` directory
- Configure the dependencies
  ```sh
  cd test/
  go mod init github.com/sourcefuse/terraform-aws-refarch-<module_name>
  go get github.com/gruntwork-io/terratest/modules/terraform
  ```
- Now execute the test  
  ```sh
  go test -timeout  30m
  ```

## Authors

This project is authored by:
- SourceFuse ARC Team
