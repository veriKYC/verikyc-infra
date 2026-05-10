output "service_url" {
    description = "Public URL of the Cloud Run service"
    value       = google_cloud_run_v2_service.service.uri
}

output "service_name" {
    value = google_cloud_run_v2_service.service.name    
}