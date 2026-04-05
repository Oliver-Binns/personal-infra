resource "google_project" "wedding" {
  name       = "Happily Ever After"
  project_id = "obinns-happily-ever-after"

  org_id          = data.google_organization.default.org_id
  billing_account = data.google_billing_account.default.id

  labels = {
    "firebase" = "enabled"
  }
}

resource "google_project_service" "wedding" {
  provider = google-beta.no_user_project_override
  project  = google_project.wedding.project_id
  for_each = toset([
    "androidpublisher.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudbilling.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "eventarc.googleapis.com",
    "firebase.googleapis.com",
    "firebaseextensions.googleapis.com",
    "run.googleapis.com",
    # Enabling the ServiceUsage API allows the new project to be quota checked from now on.
    "serviceusage.googleapis.com",
  ])
  service = each.key

  # Don't disable the service if the resource block is removed by accident.
  disable_on_destroy = false
}

resource "google_project_iam_member" "wedding-plan" {
  project = google_project.wedding.project_id
  member  = data.google_service_account.plan.member
  role    = "roles/serviceusage.serviceUsageConsumer"
}

resource "google_firebase_project" "wedding" {
  provider = google-beta
  project  = google_project.wedding.project_id

  # Waits for the required APIs to be enabled.
  depends_on = [
    google_project_service.wedding
  ]
}

resource "google_firestore_database" "database" {
  project     = google_project.wedding.project_id
  name        = "rsvp"
  location_id = "europe-west2"
  type        = "FIRESTORE_NATIVE"
}

resource "google_firebase_web_app" "basic" {
  provider     = google-beta
  project      = google_project.wedding.project_id
  display_name = "Happily Ever After"
}

resource "google_firebase_apple_app" "wedding" {
  provider     = google-beta
  project      = google_project.wedding.project_id
  display_name = "Happily Ever After"
  bundle_id    = "uk.co.oliverbinns.Wedding"
}

resource "google_firebase_android_app" "wedding" {
  provider     = google-beta
  project      = google_project.wedding.project_id
  display_name = "Happily Ever After"
  package_name = "uk.co.oliverbinns.wedding"
}
