terraform {
    required_version = ">= 1.5"

    required_providers {
        google = {
            source = {
                source = "hashicorp/google"
                version = "~> 5.0"
            }
        }
    }

    backend "gcs" {
        bucket = "verikyc-terraform-state"
        prefix = "terraform/state"
    }
}

provider "google"{
    project = var.project_id
    region = var.region
}