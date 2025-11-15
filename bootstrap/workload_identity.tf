# Create a read-only setup for pull requests (plan)
# and a write setup for main branch merges

resource "google_iam_workload_identity_pool" "plan" {
  workload_identity_pool_id = "tf-plan"
  display_name              = "TF Plan"
  description               = "Pool for terraform plan workloads"
}

resource "google_iam_workload_identity_pool" "apply" {
  workload_identity_pool_id = "tf-apply"
  display_name              = "TF Apply"
  description               = "Pool for terraform apply workloads"
}

# Service Accounts

resource "google_service_account" "plan" {
  account_id   = "tf-plan"
  display_name = "Terraform Plan"
}

resource "google_service_account" "apply" {
  account_id   = "tf-apply"
  display_name = "Terraform Apply"
}

# Permissions

resource "google_service_account_iam_member" "plan" {
  service_account_id = google_service_account.plan.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.plan.name}/attribute.repository/personal-infra"
}

resource "google_project_iam_member" "plan" {
  for_each = toset([
    "roles/iam.roleViewer",
    "roles/iam.serviceAccountViewer",
    "roles/iam.workloadIdentityPoolViewer",
  ])

  project = google_project.default.project_id
  member  = "serviceAccount:${google_service_account.plan.email}"
  role    = each.value
}

resource "google_project_iam_custom_role" "plan" {
  role_id     = "TFPlan"
  title       = "TF Plan"
  description = "Custom role to support additional actions when planning"
  permissions = toset([
    "serviceusage.services.get",
    "serviceusage.services.list",
    "storage.buckets.get",
    "storage.buckets.getIamPolicy",
    "storage.objects.getIamPolicy",
  ])
}

resource "google_project_iam_member" "plan_role" {
  project = google_project.default.project_id
  member  = "serviceAccount:${google_service_account.plan.email}"
  role    = google_project_iam_custom_role.plan.name
}

# Identity Providers - GitHub

resource "google_iam_workload_identity_pool_provider" "plan" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.plan.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-actions"
  display_name                       = "GitHub Actions"
  description                        = "OIDC identity pool provider for Terraform Plans run in GitHub Actions"

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
    "attribute.org"        = "assertion.repository_owner"
  }

  attribute_condition = <<-EOT
      attribute.org == "Oliver-Binns"
      && attribute.repository == "Oliver-Binns/personal-infra"
    EOT

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}