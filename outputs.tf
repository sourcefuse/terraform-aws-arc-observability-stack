output "kibana_lb_arn" {
  description = "Kibana ingress loadbalancer ARN"
  value       = var.search_engine == "elasticsearch" ? module.elasticsearch[0].lb_arn : null
}

output "grafana_lb_arn" {
  description = "Grafana ingress loadbalancer ARN"
  value       = var.metrics_monitoring_system == "prometheus" ? module.prometheus[0].lb_arn : null
}
