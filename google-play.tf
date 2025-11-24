provider "googleplay" {
  service_account_json_base64 = filebase64("~/service-account.json")
  developer_id                = "5166846112789481453"
}

resource "googleplay_user" "oliver" {
  email              = "mail@oliverbinns.info"
  global_permissions = ["CAN_MANAGE_PERMISSIONS_GLOBAL"]
}

resource "googleplay_user" "provider" {
  email              = google_service_account.provider.email
  global_permissions = ["CAN_MANAGE_PERMISSIONS_GLOBAL"]
}

resource "googleplay_user" "service_account" {
  email              = "google-play-console@seraphic-elixir-305011.iam.gserviceaccount.com"
  global_permissions = ["CAN_MANAGE_PERMISSIONS_GLOBAL"]
}

resource "googleplay_user" "example" {
  email              = "example@oliverbinns.info"
  global_permissions = ["CAN_VIEW_APP_QUALITY_GLOBAL"]
}