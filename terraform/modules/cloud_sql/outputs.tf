output "instance_name" {
  value = google_sql_database_instance.postgres.name
}

output "connection_name" {
  description = "Used by Cloud Run to connect via Cloud SQL Auth Proxy"
  value       = google_sql_database_instance.postgres.connection_name
}

output "database_name" {
  value = var.database_name
}
