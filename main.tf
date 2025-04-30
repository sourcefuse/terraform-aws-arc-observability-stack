
module "elasticsearch" {
  source = "./modules/elasticsearch"

  count = var.search_engine == "elasticsearch" ? 1 : 0

  environment = var.environment
  namespace   = var.namespace

  k8s_namespace        = var.elasticsearch_config.k8s_namespace.name
  create_k8s_namespace = var.elasticsearch_config.k8s_namespace.create

  tls_self_signed_cert_data = var.elasticsearch_config.tls_self_signed_cert_data
  cluster_config            = var.elasticsearch_config.cluster_config
  kibana_config             = var.elasticsearch_config.kibana_config
}

module "fluentd" {
  source = "./modules/fluentd"

  count = var.log_aggregator == "fluentd" ? 1 : 0

  name                 = var.fluentd_config.name
  k8s_namespace        = var.fluentd_config.k8s_namespace.name
  create_k8s_namespace = var.fluentd_config.k8s_namespace.create

  search_engine = var.search_engine
  log_level     = var.fluentd_config.log_level
  resources = {
    cpu_limit      = var.fluentd_config.cpu_limit
    memory_limit   = var.fluentd_config.memory_limit
    cpu_request    = var.fluentd_config.cpu_request
    memory_request = var.fluentd_config.memory_request
  }
  search_engine_config = {
    logstash_dateformat = var.fluentd_config.logstash_dateformat
    host                = var.search_engine == "elasticsearch" ? module.elasticsearch[0].host : null
    port                = var.search_engine == "elasticsearch" ? module.elasticsearch[0].port : null
    user                = var.search_engine == "elasticsearch" ? module.elasticsearch[0].user : null
    password            = var.search_engine == "elasticsearch" ? module.elasticsearch[0].password : null
    opensearch_url      = var.fluentd_config.opensearch_url
    aws_region          = var.fluentd_config.aws_region
    aws_role_arn        = var.fluentd_config.aws_role_arn
  }
}


module "fluentbit" {
  source = "./modules/fluent-bit"

  count = var.log_aggregator == "fluent-bit" ? 1 : 0

  name                 = var.fluentbit_config.name
  k8s_namespace        = var.fluentbit_config.k8s_namespace.name
  create_k8s_namespace = var.fluentbit_config.k8s_namespace.create

  search_engine = var.search_engine
  log_level     = var.fluentbit_config.log_level
  resources = {
    cpu_limit      = var.fluentbit_config.cpu_limit
    memory_limit   = var.fluentbit_config.memory_limit
    cpu_request    = var.fluentbit_config.cpu_request
    memory_request = var.fluentbit_config.memory_request
  }
  search_engine_config = {
    logstash_dateformat = var.fluentbit_config.logstash_dateformat
    time_format         = var.fluentbit_config.time_format
    host                = var.search_engine == "elasticsearch" ? module.elasticsearch[0].host : var.fluentbit_config.host
    port                = var.search_engine == "elasticsearch" ? module.elasticsearch[0].port : var.fluentbit_config.port
    user                = var.search_engine == "elasticsearch" ? module.elasticsearch[0].user : null
    password            = var.search_engine == "elasticsearch" ? module.elasticsearch[0].password : null
    aws_region          = var.fluentbit_config.aws_region
    aws_role_arn        = var.fluentbit_config.aws_role_arn
  }
}

module "prometheus" {
  source = "./modules/prometheus"

  count = var.metrics_monitoring_system == "prometheus" ? 1 : 0

  environment = var.environment
  namespace   = var.namespace

  name                 = var.prometheus_config.name
  k8s_namespace        = var.prometheus_config.k8s_namespace.name
  create_k8s_namespace = var.prometheus_config.k8s_namespace.create

  log_level                 = var.prometheus_config.log_level
  replica_count             = var.prometheus_config.replica_count
  storage                   = var.prometheus_config.storage
  enable_kube_state_metrics = var.prometheus_config.enable_kube_state_metrics
  enable_node_exporter      = var.prometheus_config.enable_node_exporter

  resources = {
    cpu_limit      = var.prometheus_config.cpu_limit
    memory_limit   = var.prometheus_config.memory_limit
    cpu_request    = var.prometheus_config.cpu_request
    memory_request = var.prometheus_config.memory_request
  }

  grafana_config = var.prometheus_config.grafana_config

  blackbox_exporter_config = var.prometheus_config.blackbox_exporter_config

  alertmanager_config = var.prometheus_config.alertmanager_config

  tags = var.tags
}

module "jaeger" {
  source = "./modules/jaeger"

  count = var.tracing_stack == "jaeger" ? 1 : 0

  name                 = var.prometheus_config.name
  k8s_namespace        = var.prometheus_config.k8s_namespace.name
  create_k8s_namespace = var.prometheus_config.k8s_namespace.create

  log_level = var.prometheus_config.log_level
  # replica_count             = var.prometheus_config.replica_count
  # storage                   = var.prometheus_config.storage


  resources = {
    cpu_limit      = var.prometheus_config.cpu_limit
    memory_limit   = var.prometheus_config.memory_limit
    cpu_request    = var.prometheus_config.cpu_request
    memory_request = var.prometheus_config.memory_request
  }

}

module "signoz" {
  source = "./modules/signoz"

  count = (
    var.search_engine == "signoz" ||
    var.log_aggregator == "signoz" ||
    var.metrics_monitoring_system == "signoz" ||
    var.tracing_stack == "signoz"
  ) ? 1 : 0


  k8s_namespace        = var.signoz_config.k8s_namespace.name
  create_k8s_namespace = var.signoz_config.k8s_namespace.create
  environment          = var.environment

  signoz_config = var.signoz_config

}
