output "workload_identity_provider" {
    description = "WIF provider resource name — used in GitHub Actions workflows"
    value       = google_iam_workload_identity_pool_provider.github.name
}

output "service_account_email" {
    description = "GitHub Actions service account email"
    value       = google_service_account.github_actions.email
}