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

        containers {
            image = var.image

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
        }
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
