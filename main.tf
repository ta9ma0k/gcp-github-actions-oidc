terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.10.0"
    }
  }
}

resource "google_iam_workload_identity_pool" "main" {
  project = var.project_id
  workload_identity_pool_id = "${var.project_id}-pool"
  description = "For OpenID Connect"
  display_name = "${var.project_id}-pool"
  timeouts {}
}

resource "google_iam_workload_identity_pool_provider" "github_provider" {
  project = var.project_id
  workload_identity_pool_id = google_iam_workload_identity_pool.main.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-actions-provider"
  display_name = "Github Identity Provider"
  disabled = false
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
    allowed_audiences = []
  }
  attribute_mapping = {
    "google.subject"       = "assertion.sub",
    "attribute.actor"      = "assertion.actor",
    "attribute.repository" = "assertion.repository",
  }
}

resource "google_service_account_iam_binding" "github_actions_sa" {
  service_account_id = data.google_service_account.github_actions_sa.id
  members =  ["principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.main.name}/attribute.repository/${var.github_repository}"]
  role = "roles/iam.workloadIdentityUser"
}

data "google_service_account" "github_actions_sa" {
  account_id = var.service_account_id
  
}
