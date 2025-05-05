output "lb_arn" {
  description = "Signoz ingress loadbalancer ARN"
  value       = var.signoz_config.signoz_bin.ingress_enabled ? data.kubernetes_ingress_v1.this[0].status[0].load_balancer[0].ingress[0].hostname : null
}
