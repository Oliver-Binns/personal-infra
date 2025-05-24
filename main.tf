terraform {
  required_providers {
    googleplay = {
      source  = "Oliver-Binns/googleplay"
      version = "~> 0.4.3"
    }

    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }

  cloud {
    hostname     = "app.terraform.io"
    organization = "oliver-binns"
    workspaces {
      tags = ["personal-infra"]
    }
  }

  required_version = ">= 1.2.0"
}

