# Create a read-only setup for pull requests (plan)
# and a write setup for main branch merges

resource "google_iam_workload_identity_pool" "plan" {
    workload_identity_pool_id = "tf-plan"
    display_name = "TF Plan"
    description = "Pool for terraform plan workloads"
}

resource "google_iam_workload_identity_pool" "apply" {
    workload_identity_pool_id = "tf-apply"
    display_name = "TF Apply"
    description = "Pool for terraform apply workloads"
}

# Service Accounts

resource "google_service_account" "plan" {
    account_id = "tf-plan"
    display_name = "Terraform Plan"
}

resource "google_service_account" "apply" {
    account_id = "tf-apply"
    display_name = "Terraform Apply"
}

# Permissions



# Identity Providers - GitHub

resource "google_iam_workload_identity_pool_provider" "plan" {
    workload_identity_pool_id = google_iam_workload_identity_pool.plan.workload_identity_pool_id
    workload_identity_pool_provider_id = "github-actions"
    display_name = "GitHub Actions"
    description = "OIDC identity pool provider for Terraform Plans run in GitHub Actions"

    attribute_mapping = {
        "google.subject" = "assertion.sub"
        "attribute.repository" = "assertion.repository"
        "attribute.org" = "assertion.repository_owner"
    }

    attribute_condition = <<-EOT
      attribute.org == "Oliver-Binns"
      && attribute.respository == "personal-infra"
    EOT

    oidc {
        issuer_uri = "https://token.actions.githubusercontent.com"
    }
}