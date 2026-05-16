# Service account for GitHub Actions CI/CD
resource "google_service_account" "github_actions" {
    account_id   = "github-actions-sa"
    display_name = "GitHub Action Service Account"
    project      = var.project_id
}

# Workload Identity Pool — trusts GitHub's OIDC tokens
resource "google_iam_workload_identity_pool" "github" {
    workload_identity_pool_id = "github-pool"
    display_name              = "GitHub Actions Pool"
    project                   = var.project_id
}

# Workload Identity Provider — maps GitHub repo to GCP identity
resource "google_iam_workload_identity_pool_provider" "github" {
    workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
    workload_identity_pool_provider_id = "github-provider"
    project                            = var.project_id

    oidc {
        issuer_uri = "https://token.actions.githubusercontent.com"
    }

    attribute_mapping = {
        "google.subject"             = "assertion.sub"
        "attribute.repository"       = "assertion.repository"
        "attribute.repository_owner" = "assertion.repository_owner"
    }

    # Restrict to tokens from the veriKYC GitHub organisation only
    attribute_condition = "attribute.repository_owner == \"${var.github_org}\""
}

# Allow any repo in the veriKYC org to impersonate the service account
resource "google_service_account_iam_member" "github_wif" {
    service_account_id = google_service_account.github_actions.name
    role               = "roles/iam.workloadIdentityUser"
    member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository_owner/${var.github_org}"
}

# Grant service account permissions it needs
resource "google_project_iam_member" "artifact_registry_writer" {
    project = var.project_id
    role    = "roles/artifactregistry.writer"
    member  = "serviceAccount:${google_service_account.github_actions.email}"
}

resource "google_project_iam_member" "cloud_run_developer" {
    project = var.project_id
    role    = "roles/run.developer"
    member  = "serviceAccount:${google_service_account.github_actions.email}"
}

resource "google_project_iam_member" "service_account_user" {
    project = var.project_id
    role    = "roles/iam.serviceAccountUser"
    member  = "serviceAccount:${google_service_account.github_actions.email}"
}
