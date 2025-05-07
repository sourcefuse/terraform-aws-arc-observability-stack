output "lb_arn" {
  description = "Signoz ingress loadbalancer ARN"
  value       = var.signoz_config.signoz_bin.ingress_enabled ? data.kubernetes_ingress_v1.this[0].status[0].load_balancer[0].ingress[0].hostname : null
}

output "otel_collector_endpoint" {
  description = "OTEL collector endpoint"
  value       = var.signoz_config.install ? "http://${var.signoz_config.name}-otel-collector:4317" : null
}
