provider "google" { }

data "google_organization" "default" {
  domain = "oliverbinns.info"
}

resource "google_project" "default" {
  name       = "personal-infra"
  project_id = "seraphic-elixir-305011"
  org_id     = data.google_organization.default.org_id

  billing_account = data.google_billing_account.default.id
}

