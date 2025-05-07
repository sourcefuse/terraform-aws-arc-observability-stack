output "kibana_lb_arn" {
  description = "Kibana ingress loadbalancer DNS"
  value       = module.efk_es_fluentd.kibana_lb_dns
}
