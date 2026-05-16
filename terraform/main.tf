terraform {
    required_version = ">= 1.5"

    required_providers {
        google = {
            source  = "hashicorp/google"
            version = "~> 5.0"
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

module "artifact_registry" {
    source = "./modules/artifact_registry"
    repository_id = "verikyc-docker"
    region = var.region
    environment = var.environment
    description = "VeriKYC Docker images"
}

module "iam" {
    source = "./modules/iam"
    project_id = var.project_id
    github_org = "veriKYC"
}

module "backend" {
    source = "./modules/cloud_run"
    project_id = var.project_id
    region = var.region

    service_name = "verikyc-backend-${var.environment}"
    image = "us-docker.pkg.dev/cloudrun/container/hello:latest"
    cpu = "1"
    memory = "512Mi"
    allow_unauthenticated = true
    ingress = "INGRESS_TRAFFIC_ALL"

    env_vars = {
        SPRING_PROFILES_ACTIVE = var.environment
        CV_SERVICE_URL         = module.cv_service.service_url
        SPRING_DATASOURCE_URL  = "jdbc:postgresql://136.119.83.108:5432/verikyc_db"
        GCS_BUCKET_NAME = google_storage_bucket.uploads.name
    }

    secret_env_vars = {
        JWT_SECRET = {
            secret  = "JWT_SECRET"
            version = "latest"
        }
        JWT_EXPIRY_MS = {
            secret  = "JWT_EXPIRY_MS"
            version = "latest"
        }
        SPRING_DATASOURCE_PASSWORD = {
            secret  = "POSTGRES_PASSWORD"
            version = "latest"
        }
        SPRING_DATASOURCE_USERNAME = {
            secret  = "POSTGRES_USER"
            version = "latest"
        }
    }
}

module "cv_service" {
    source     = "./modules/cloud_run"
    project_id = var.project_id
    region     = var.region

    service_name          = "verikyc-cv-${var.environment}"
    image                 = "us-docker.pkg.dev/cloudrun/container/hello:latest"
    cpu                   = "2"
    memory                = "2Gi"
    allow_unauthenticated = false
    ingress               = "INGRESS_TRAFFIC_INTERNAL_ONLY"

    gcs_model_bucket = "verikyc-uploads-dev"
}

resource "google_storage_bucket" "uploads" {                                                           
    name                        = "verikyc-uploads-${var.environment}"                                   
    location                    = var.region                                                             
    project                     = var.project_id                                                         
    uniform_bucket_level_access = true                                                                   

    lifecycle_rule {
        condition { age = 90 }
        action    { type = "Delete" }
    }
}

resource "google_storage_bucket_iam_member" "backend_gcs_access" {
    bucket = google_storage_bucket.uploads.name
    role   = "roles/storage.objectAdmin"
    member = "serviceAccount:273522577681-compute@developer.gserviceaccount.com"
}

# Cloud SQL already exists — provisioned manually during bootstrap.
# Import into Terraform state later with: terraform import module.cloud_sql...
# module "cloud_sql" {
#     source     = "./modules/cloud_sql"
#     project_id = var.project_id
#     region     = var.region
#     environment       = var.environment
#     database_name     = "verikyc_db"
#     database_user     = "verikyc_user"
#     database_password = var.db_password
#     vpc_network       = var.vpc_network
# }

