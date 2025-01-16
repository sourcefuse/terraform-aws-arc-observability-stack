output "grafana_lb_arn" {
  description = "Grafana ingress loadbalancer ARN"
  value       = module.prometheus.grafana_lb_arn
}
