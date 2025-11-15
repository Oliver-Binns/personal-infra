resource "google_storage_bucket" "state" {
  name          = "oliverbinns-tf-state"
  location      = "US"
  storage_class = "STANDARD"

  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }
}

resource "google_storage_bucket_iam_member" "terraform_state_project_owner_admin" {
  bucket = google_storage_bucket.state.name
  role   = "roles/storage.admin"
  member = "projectOwner:${google_project.default.project_id}"
}