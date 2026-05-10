variable "repository_id" {
    description = "Artifact Registry repository name"
    type        = string
}

variable "region" {
    description = "GCP region"
    type        = string
}

variable "environment" {
    description = "Environment name"
    type        = string
}

variable "description" {
    description = "Repository description"
    type        = string
    default     = ""
}