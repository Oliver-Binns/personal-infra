variable "github_token" {
  type      = string
  sensitive = true
}

provider "github" {
  owner = "oliver-binns"
  token = var.github_token
}

import {
  to = github_repository.ios
  id = "crescendo"
}

resource "github_repository" "ios" {
  name        = "Crescendo"
  description = "This app allows you to play Apple Music playlists for timed musical party games, such as pass the parcel or musical chairs."

  visibility = "public"

  allow_merge_commit = false
  allow_rebase_merge = false

  archive_on_destroy = true

  license_template = "mit"
}

resource "github_branch_protection" "ios" {
  repository_id = github_repository.ios.node_id
  pattern       = "main"

  require_signed_commits = true

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}