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

variable "db_password" {
    description = "PostgreSQL user password"
    type        = string
    sensitive   = true
}

variable "vpc_network" {
    description = "VPC network self-link for Cloud SQL private IP"
    type        = string
}