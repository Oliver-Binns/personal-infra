variable "github_token" {
  type      = string
  sensitive = true
}

provider "github" {
  owner = "oliver-binns"
  token = var.github_token
}

import {
  for_each = tomap({ for repo in local.repositories : repo.name => repo if repo.imported == "true" })

  to = github_repository.public[each.value.name]
  id = each.value.name
}

resource "github_repository" "public" {
  for_each = tomap({ for repo in local.repositories : repo.name => repo })

  name        = each.value.name
  description = each.value.description

  visibility = "public"

  allow_merge_commit = false
  allow_rebase_merge = false

  archive_on_destroy     = true
  delete_branch_on_merge = true

  license_template = "mit"

  has_issues = false
  has_projects = false
  has_wiki = false
}

resource "github_branch_protection" "public" {
  for_each = github_repository.public

  repository_id = each.value.node_id
  pattern       = "main"

  require_signed_commits = true

  required_pull_request_reviews {
    require_code_owner_reviews = true
  }
}