resource "google_service_account" "googleplay_deploy" {
  project = google_project.wedding.project_id

  account_id   = "googleplay-deploy"
  display_name = "Google Play Deploy"
}

resource "google_service_account_iam_member" "googleplay_deploy" {
  service_account_id = google_service_account.googleplay_deploy.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principal://iam.googleapis.com/${google_iam_workload_identity_pool.wedding_deploy.name}/subject/repo:Oliver-Binns/happily-ever-after:ref:refs/heads/main"
}

resource "googleplay_user" "googleplay_deploy" {
  email = google_service_account.googleplay_deploy.email
}

resource "googleplay_app_iam" "googleplay_deploy" {
  app_id  = "4975313787980303395"
  user_id = googleplay_user.googleplay_deploy.email
  permissions = [
    "CAN_MANAGE_PRODUCTION_RELEASES"
  ]
}
