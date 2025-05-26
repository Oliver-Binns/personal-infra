locals {
  csv_data = file("repositories.csv")

  repositories = csvdecode(local.csv_data)
}