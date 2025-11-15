terraform {
  backend "gcs" {
    bucket  = "oliverbinns-tf-state"
    prefix  = "terraform/state"
  }
}