# Provide Oliver-Binns/terraform-provider-googleplay with access to the TF Test Service Account

resource "google_iam_workload_identity_pool" "provider" {
  workload_identity_pool_id = "terraform-provider-googleplay"
  display_name              = "terraform-provider-googleplay testing workflow"
  description               = "Pool for terraform-provider-googleplay workflows"
}

# Service Account

resource "google_service_account" "provider" {
  account_id   = "terraform-provider-googleplay"
  display_name = "Google Play Terraform Provider testing"
}

# Permissions - Provider

resource "google_service_account_iam_member" "provider" {
  service_account_id = google_service_account.provider.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.provider.name}/attribute.repository/Oliver-Binns/terraform-provider-googleplay"
}

resource "google_project_iam_member" "provider" {
  for_each = toset([
    "roles/iam.roleViewer",
    "roles/iam.serviceAccountViewer",
    "roles/iam.workloadIdentityPoolViewer",
  ])

  project = local.google_project_id
  member  = "serviceAccount:${google_service_account.provider.email}"
  role    = each.value
}

# Identity Providers - GitHub

resource "google_iam_workload_identity_pool_provider" "provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.provider.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-actions"
  display_name                       = "GitHub Actions"
  description                        = "OIDC identity pool provider for testing the Google Play Terraform provider"

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
    "attribute.org"        = "assertion.repository_owner"
  }

  attribute_condition = <<-EOT
      && attribute.org == "Oliver-Binns"
      && attribute.repository == "Oliver-Binns/terraform-provider-googleplay"
    EOT

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}
