resource "google_project_service" "service" {
  for_each = toset([
    "apikeys.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com"
  ])

  service            = each.value
  disable_on_destroy = false
}