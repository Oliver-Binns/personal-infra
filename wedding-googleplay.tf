resource "google_service_account" "googleplay_deploy" {
  project = google_project.wedding.project_id

  account_id   = "googleplay-deploy"
  display_name = "Google Play Deploy"
}

resource "google_service_account_key" "googleplay_deploy" {
  service_account_id = google_service_account.googleplay_deploy.name
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
