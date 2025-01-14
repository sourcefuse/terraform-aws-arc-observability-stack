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
