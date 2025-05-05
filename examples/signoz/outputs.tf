output "signoz_lb_arn" {
  description = "Signoz ingress loadbalancer DNS"
  value       = module.signoz.signoz_lb_dns
}
