provider "google" {
  project = local.google_project_id
}

data "google_organization" "default" {
  domain = "oliverbinns.info"
}