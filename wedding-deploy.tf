resource "google_iam_workload_identity_pool" "wedding_deploy" {
  project = google_project.wedding.project_id

  workload_identity_pool_id = "firebase-deploy"
  display_name              = "Firebase Deploy"
  description               = "Pool to deploy Cloud Functions and other Firebase resources"
  disabled                  = false
}

resource "google_service_account" "wedding_deploy" {
  project = google_project.wedding.project_id

  account_id   = "firebase-deploy"
  display_name = "Firebase Deploy"
}

resource "google_service_account_iam_member" "wedding_deploy" {
  service_account_id = google_service_account.wedding_deploy.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principal://iam.googleapis.com/${google_iam_workload_identity_pool.wedding_deploy.name}/subject/repo:Oliver-Binns/happily-ever-after:ref:refs/heads/main"
}

resource "google_project_iam_member" "wedding_deploy" {
  for_each = toset([
    "roles/iam.serviceAccountUser",
    "roles/cloudbuild.builds.builder",
    "roles/cloudfunctions.developer"
  ])

  project = google_project.wedding.project_id
  member  = google_service_account.wedding_deploy.member
  role    = each.value
}

resource "google_iam_workload_identity_pool_provider" "wedding_deploy" {
  project = google_project.wedding.project_id

  workload_identity_pool_id          = google_iam_workload_identity_pool.wedding_deploy.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-actions"
  display_name                       = "GitHub Actions"
  description                        = "OIDC identity pool provider for Firebase Deploys in GitHub Actions"

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
    "attribute.org"        = "assertion.repository_owner"
  }

  attribute_condition = <<-EOT
      google.subject == 'repo:Oliver-Binns/happily-ever-after:ref:refs/heads/main'
      && attribute.org == "Oliver-Binns"
      && attribute.repository == "Oliver-Binns/happily-ever-after"
    EOT

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}
