resource "google_project" "wedding" {
  name            = "Happily Ever After"
  project_id      = "happily-ever-after"

  org_id          = data.google_organization.default.org_id
  billing_account = data.google_billing_account.default.id
}