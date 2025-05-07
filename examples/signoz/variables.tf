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
  default     = "poc"
}

variable "namespace" {
  type        = string
  description = "Namespace for the resources."
  default     = "arc"
}
