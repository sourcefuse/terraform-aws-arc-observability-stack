output "lb_arn" {
  description = "Grafana ingress loadbalancer ARN"
  value       = var.grafana_config.ingress_enabled ? data.kubernetes_ingress_v1.this[0].status[0].load_balancer[0].ingress[0].hostname : null
}
