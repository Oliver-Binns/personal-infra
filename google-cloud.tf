provider "google" {
  project = local.google_project_id
}

provider "google-beta" {
  user_project_override = true
}

provider "google-beta" {
  alias                 = "no_user_project_override"
  user_project_override = false
}

data "google_organization" "default" {
  domain = "oliverbinns.info"
}

data "google_billing_account" "default" {
  billing_account = "billingAccounts/016282-310295-698AE7"
  open            = true
}

data "google_service_account" "plan" {
  project    = local.google_project_id
  account_id = "tf-plan"
}