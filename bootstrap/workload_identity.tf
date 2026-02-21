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

# Permissions - Plan

resource "google_service_account_iam_member" "plan" {
  service_account_id = google_service_account.plan.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.plan.name}/attribute.repository/Oliver-Binns/personal-infra"
}

resource "google_storage_bucket_iam_member" "tf_state_plan_read" {
  bucket = google_storage_bucket.state.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.plan.email}"
}

resource "google_storage_bucket_iam_member" "service_account_tf_state_plan" {
  bucket = google_storage_bucket.state.name

  # write permissions are required for state lock
  role   = "roles/storage.objectUser"
  member = "serviceAccount:${google_service_account.plan.email}"
}

resource "google_organization_iam_member" "plan" {
  for_each = toset([
    "roles/viewer",
    "roles/billing.viewer",
    "roles/iam.organizationRoleViewer",
  ])

  org_id = data.google_organization.default.org_id
  member = "serviceAccount:${google_service_account.plan.email}"
  role   = each.value
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

# Permissions - Apply

resource "google_service_account_iam_member" "apply" {
  service_account_id = google_service_account.apply.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principal://iam.googleapis.com/${google_iam_workload_identity_pool.apply.name}/subject/repo:Oliver-Binns/personal-infra:ref:refs/heads/main"
}

resource "google_storage_bucket_iam_member" "service_account_tf_state_apply" {
  bucket = google_storage_bucket.state.name

  # write permissions are required for state lock
  role   = "roles/storage.objectUser"
  member = "serviceAccount:${google_service_account.apply.email}"
}

resource "google_organization_iam_member" "apply" {
  for_each = toset([
    "roles/viewer",
    "roles/billing.admin",
    "roles/iam.organizationRoleAdmin",
    "roles/resourcemanager.projectCreator",
  ])

  org_id = data.google_organization.default.org_id
  member = "serviceAccount:${google_service_account.apply.email}"
  role   = each.value
}

resource "google_project_iam_member" "apply" {
  for_each = toset([
    "roles/iam.roleAdmin",
    "roles/iam.serviceAccountAdmin",
    "roles/iam.workloadIdentityPoolAdmin",
    "roles/resourcemanager.projectIamAdmin",
  ])

  project = google_project.default.project_id
  member  = "serviceAccount:${google_service_account.apply.email}"
  role    = each.value
}

resource "google_project_iam_custom_role" "apply" {
  role_id     = "TFApply"
  title       = "TF Apply"
  description = "Custom role to support additional actions when applying"
  permissions = toset([
    "serviceusage.services.get",
    "serviceusage.services.list",
    "storage.buckets.get",
    "storage.buckets.getIamPolicy",
    "storage.objects.getIamPolicy",
  ])
}

resource "google_project_iam_member" "apply_role" {
  project = google_project.default.project_id
  member  = "serviceAccount:${google_service_account.apply.email}"
  role    = google_project_iam_custom_role.apply.name
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

resource "google_iam_workload_identity_pool_provider" "apply" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.apply.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-actions"
  display_name                       = "GitHub Actions"
  description                        = "OIDC identity pool provider for Terraform Applys run in GitHub Actions"

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
    "attribute.org"        = "assertion.repository_owner"
  }

  attribute_condition = <<-EOT
      google.subject == 'repo:Oliver-Binns/personal-infra:ref:refs/heads/main'
      && attribute.org == "Oliver-Binns"
      && attribute.repository == "Oliver-Binns/personal-infra"
    EOT

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}
