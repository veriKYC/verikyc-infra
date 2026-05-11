terraform {
    required_version = ">= 1.5"

    required_providers {
        google = {
            source  = "hashicorp/google"
            version = "~> 5.0"
        }
    }

    backend "remote" {
      organization = "verikyc"

      workspaces {
        name = "verikyc-infra-dev"
      }
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

    service_name = "verikyc-${var.environment}"
    image = "${var.region}-docker.pkg.dev/${var.project_id}/verikyc-docker/verikyc-backend:latest"
    cpu = "1"
    memory = "512Mi"
    allow_unauthenticated = true
    ingress = "INGRESS_TRAFFIC_ALL"

    env_vars = {
        SPRING_PROFILES_ACTIVE = var.environment
        CV_SERVICE_URL = module.cv_service.service_url
    }

    secret_env_vars = {
        JWT_SECRET = {
            secret  = "JWT_SECRET"
            version = "latest"
        }
        SPRING_DATASOURCE_PASSWORD = {
            secret  = "POSTGRES_PASSWORD"
            version = "latest"
        }
    }
}

module "cv_service" {
    source     = "./modules/cloud_run"
    project_id = var.project_id
    region     = var.region

    service_name          = "verikyc-cv-${var.environment}"
    image                 = "${var.region}-docker.pkg.dev/${var.project_id}/verikyc-docker/verikyc-cv:latest"
    cpu                   = "2"
    memory                = "2Gi"
    allow_unauthenticated = false
    ingress               = "INGRESS_TRAFFIC_INTERNAL_ONLY"
}

module "cloud_sql" {                                                                                             
    source     = "./modules/cloud_sql"                                                                             
    project_id = var.project_id                                                                                    
    region     = var.region                                                                                        
                                                                                                                
    environment       = var.environment                                                                         
    database_name     = "verikyc_db"
    database_user     = "verikyc_user"
    database_password = var.db_password
    vpc_network       = var.vpc_network
}

