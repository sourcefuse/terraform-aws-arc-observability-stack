################################################################################
## shared
################################################################################
variable "region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region"
}

variable "environment" {
  type        = string
  description = "Environment name"
  default     = "dev"
}

variable "namespace" {
  type        = string
  description = "Namespace for the resources."
  default     = "arc"
}

variable "aws_certificate_arn" {
  description = "The ARN of the ACM certificate to use for the domain."
  type        = string
}

variable "ingress_host" {
  description = "The Route 53 domain to associate with the resource."
  type        = string
}
