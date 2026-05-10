output "secret_ids" {
    description = "Map of secret name to secret resource ID"
    value       = { for k, v in google_secret_manager_secret.secret : k => v.id }
}