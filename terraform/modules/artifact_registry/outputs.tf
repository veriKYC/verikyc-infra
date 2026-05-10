output "repository_url" {
    description = "Full URL of the Artifact Registry repository"
    value       = "${var.region}-docker.pkg.dev/${var.repository_id}"
}