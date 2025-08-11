################################################################################
## shared
################################################################################

variable "environment" {
  type        = string
  description = "Environment name"
  default     = "poc"
}

variable "namespace" {
  type        = string
  default     = "arc"
  description = "namespace for the prject"
}
