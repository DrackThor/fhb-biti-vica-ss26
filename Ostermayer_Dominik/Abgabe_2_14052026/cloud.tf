
# HCP Terraform for GitHub Actions - Terraform Cloud Configuration
# This file configures Terraform to use Terraform Cloud for state management and remote operations, specifying the
terraform {
  cloud {
    organization = "dominik-vica"

    workspaces {
      name = "abgabe-2-exoscale-webserver"
    }
  }
}