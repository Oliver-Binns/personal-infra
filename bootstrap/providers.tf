provider "google" {
  project = "seraphic-elixir-305011"
}

resource "google_project" "default" {
  name       = "My Project"
  project_id = "seraphic-elixir-305011"
  org_id     = "943988285976"

  billing_account = data.google_billing_account.default.id
}

