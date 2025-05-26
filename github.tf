variable "github_token" {
  type      = string
  sensitive = true
}

provider "github" {
  owner = "oliver-binns"
  token = var.github_token
}

import {
  for_each = { for k, v in local.repositories : k => v if v.imported == "true" }

  to = github_repository.public[each.value.name]
  id = each.value.name
}

resource "github_repository" "public" {
  for_each = local.repositories

  name        = each.value.name
  description = each.value.description

  visibility = "public"

  allow_merge_commit = false
  allow_rebase_merge = false

  archive_on_destroy     = true
  delete_branch_on_merge = true

  license_template = "mit"

  has_issues   = false
  has_projects = false
  has_wiki     = false
}

import {
  for_each = { for k, v in local.repositories : k => v if v.imported == "true" }

  to = github_branch_protection.public[each.value.name]
  id = "${each.value.name}:main"
}


resource "github_branch_protection" "public" {
  for_each = github_repository.public

  repository_id = each.value.node_id
  pattern       = "main"

  enforce_admins = true

  require_signed_commits          = true
  require_conversation_resolution = true

  required_pull_request_reviews {
    required_approving_review_count = 0
    require_code_owner_reviews = true
  }

  required_status_checks {
    strict = true
    contexts = [
      local.repositories[each.value.name].status_check
    ]
  }
}