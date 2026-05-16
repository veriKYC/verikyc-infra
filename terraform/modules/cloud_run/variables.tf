variable "service_name" {
    type = string
}

variable "region" {
    type = string
}

variable "project_id" {
    type = string
}

variable "image" {
    description = "Full container image URL"
    type        = string
}

variable "cpu" {
    type    = string
    default = "1"
}

variable "memory" {
    type    = string
    default = "512Mi"
}

variable "min_instances" {
    type    = number
    default = 0
}

variable "max_instances" {
    type    = number
    default = 3
}

variable "ingress" {
    description = "INGRESS_TRAFFIC_ALL or INGRESS_TRAFFIC_INTERNAL_ONLY"
    type        = string
    default     = "INGRESS_TRAFFIC_ALL"
}

variable "allow_unauthenticated" {
    description = "Whether to allow public access"
    type        = bool
    default     = true
}

variable "env_vars" {
    description = "Plain environment variables"
    type        = map(string)
    default     = {}
}

variable "secret_env_vars" {
    description = "Environment variables sourced from Secret Manager"
    type        = map(object({ secret = string, version = string }))
    default     = {}
}

variable "gcs_model_bucket" {                                                                                                                                                     
    description = "GCS bucket for model volume mount. Empty string = no mount."                                                                                                     
    type        = string                                                                                                                                                        
    default     = ""
  }