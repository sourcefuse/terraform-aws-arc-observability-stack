output "grafana_lb_dns" {
  description = "Grafana ingress loadbalancer DNS"
  value       = module.prometheus.grafana_lb_dns
}
