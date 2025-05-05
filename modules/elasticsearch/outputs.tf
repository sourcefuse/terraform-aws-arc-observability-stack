output "user" {
  description = "Elastic Search user"
  value       = var.cluster_config.user
}

output "password" {
  description = "Elastic Search user's password"
  value       = random_password.elasticsearch.result
}

output "port" {
  description = "Elastic Search port"
  value       = var.cluster_config.port
}

output "host" {
  description = "Elastic Search host"
  value       = var.name
}

output "lb_dns" {
  description = "Kibana ingress loadbalancer DNS"
  value       = var.kibana_config.ingress_enabled ? data.kubernetes_ingress_v1.this[0].status[0].load_balancer[0].ingress[0].hostname : null
}
