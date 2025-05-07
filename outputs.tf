output "kibana_lb_dns" {
  description = "Kibana ingress loadbalancer DNS"
  value       = var.search_engine == "elasticsearch" ? module.elasticsearch[0].lb_arn : null
}

output "grafana_lb_dns" {
  description = "Grafana ingress loadbalancer DNS"
  value       = var.metrics_monitoring_system == "prometheus" ? module.prometheus[0].lb_arn : null
}

output "signoz_lb_dns" {
  description = "Signoz ingress loadbalancer DNS"
  value = (
    var.search_engine == "signoz-clickhouse"
  ) ? module.signoz[0].lb_arn : null

}

output "otel_collector_endpoint" {
  description = "OTEL collector endpoint"
  value = (
    var.search_engine == "signoz-clickhouse"
  ) ? module.signoz[0].otel_collector_endpoint : null

}
