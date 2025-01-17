output "kibana_lb_arn" {
  description = "Kibana ingress loadbalancer ARN"
  value       = module.efk_es_fluentbit.kibana_lb_arn
}
