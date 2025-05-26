variable "github_token" {
  type      = string
  sensitive = true
}

provider "github" {
  owner = "oliver-binns"
  token = var.github_token
}

import {
  for_each = tomap({ for repo in local.repositories : repo.name => repo })

  to = github_repository.ios[each.value.name]
  id = each.value.name
}

resource "github_repository" "ios" {
  for_each = tomap({ for repo in local.repositories : repo.name => repo })

  name        = each.value.name
  description = each.value.description

  visibility = "public"

  allow_merge_commit = false
  allow_rebase_merge = false

  archive_on_destroy     = true
  delete_branch_on_merge = true

  license_template = "mit"
}

resource "github_branch_protection" "trunk" {
  for_each = github_repository.ios

  repository_id = each.value.node_id
  pattern       = "main"

  require_signed_commits = true

  required_pull_request_reviews {
    require_code_owner_reviews = true
  }
}