output "signoz_lb_arn" {
  description = "Signoz ingress loadbalancer DNS"
  value       = module.signoz.signoz_lb_dns
}

output "otel_collector_endpoint" {
  description = "OTEL collector endpoint"
  value       = module.signoz.otel_collector_endpoint
}
