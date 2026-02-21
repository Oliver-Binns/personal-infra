provider "google" {
  project = local.google_project_id
}

data "google_organization" "default" {
  domain = "oliverbinns.info"
}

data "google_billing_account" "default" {
  billing_account = "billingAccounts/016282-310295-698AE7"
  open            = true
}