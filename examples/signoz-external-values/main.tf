// Deploy Signoz stack with Clickhouse , OTEL collector etc
module "signoz" {
  source = "../../"

  environment = var.environment
  namespace   = var.namespace

  search_engine = "signoz-clickhouse"
  signoz_config = local.signoz_config
}

// Deploy metrics and log collection agents
module "logs_metrics" {
  source = "../../"

  environment = var.environment
  namespace   = var.namespace

  log_aggregator            = "signoz"
  tracing_stack             = "signoz"
  metrics_monitoring_system = "signoz"

  signoz_infra_monitor_config = local.metrics_logs_config

  depends_on = [module.signoz]
}
