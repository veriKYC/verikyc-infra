variable "project_id" {
    description = "GCP project ID"
    type = string
}

variable "region" {
    description = "GCP region"
    type = string
    default = "us-central1"
}

variable "environment" {
    description = "Environment name (dev or prod)"
    type = string
}

# db_password and vpc_network removed — Cloud SQL managed outside Terraform for now