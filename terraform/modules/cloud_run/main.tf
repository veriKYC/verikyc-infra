resource "google_cloud_run_v2_service" "service" {
    name     = var.service_name
    location = var.region
    project  = var.project_id

    ingress = var.ingress

    template {
        scaling {
            min_instance_count = var.min_instances
            max_instance_count = var.max_instances
        }

        dynamic "volumes" {
            for_each = var.gcs_model_bucket != "" ? [1] : []
            content {
                name = "models"
                gcs {
                    bucket    = var.gcs_model_bucket
                    read_only = true
                }
            }
        }

        containers {
            image = var.image  # Initial value only — CI/CD owns the image after first deploy

            resources {
                limits = {
                    cpu    = var.cpu
                    memory = var.memory
                }
            }

            dynamic "env" {
                for_each = var.env_vars
                content {
                    name  = env.key
                    value = env.value
                }
            }

            dynamic "env" {
                for_each = var.secret_env_vars
                content {
                    name = env.key
                    value_source {
                        secret_key_ref {
                            secret  = env.value.secret
                            version = env.value.version
                        }
                    }
                }
            }

            dynamic "volume_mounts" {
                for_each = var.gcs_model_bucket != "" ? [1] : []
                content {
                    name       = "models"
                    mount_path = "/models"
                }
            }
        }
    }

    lifecycle {
        ignore_changes = [
            template[0].containers[0].image,
            client,
            client_version,
        ]
    }
}

# Allow unauthenticated access (public services only)
resource "google_cloud_run_v2_service_iam_member" "public" {
    count    = var.allow_unauthenticated ? 1 : 0
    project  = var.project_id
    location = var.region
    name     = google_cloud_run_v2_service.service.name
    role     = "roles/run.invoker"
    member   = "allUsers"
}
