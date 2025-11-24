locals {
  csv_data     = file("repositories.csv")
  repositories = tomap({ for repo in csvdecode(local.csv_data) : repo.name => repo })

  google_project_id = "seraphic-elixir-305011"
}