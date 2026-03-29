resource "google_iam_workload_identity_pool" "wedding_googleplay_deploy" {
  project = google_project.wedding.project_id

  workload_identity_pool_id = "googleplay-deploy"
  display_name              = "Google Play Deploy"
  description               = "Pool to deploy apps to Google Play"
  disabled                  = false
}

resource "google_iam_workload_identity_pool_provider" "wedding_googleplay_deploy" {
  project = google_project.wedding.project_id

  workload_identity_pool_id          = google_iam_workload_identity_pool.wedding_googleplay_deploy.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-actions"
  display_name                       = "GitHub Actions"
  description                        = "OIDC identity pool provider for Google Play Deploys in GitHub Actions"

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

resource "google_service_account" "wedding_googleplay_deploy" {
  project = google_project.wedding.project_id

  account_id   = "googleplay-deploy"
  display_name = "Google Play Deploy"
}

resource "google_service_account_iam_member" "wedding_googleplay_deploy" {
  service_account_id = google_service_account.wedding_googleplay_deploy.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principal://iam.googleapis.com/${google_iam_workload_identity_pool.wedding_googleplay_deploy.name}/subject/repo:Oliver-Binns/happily-ever-after:ref:refs/heads/main"
}

resource "googleplay_user" "wedding_googleplay_deploy" {
  email              = google_service_account.wedding_googleplay_deploy.email
  global_permissions = ["CAN_VIEW_APP_QUALITY_GLOBAL"]
}

resource "googleplay_app_iam" "wedding_googleplay_deploy" {
  app_id  = "4975313787980303395"
  user_id = googleplay_user.wedding_googleplay_deploy.email
  permissions = [
    "CAN_MANAGE_TRACK_APKS"
  ]
}
