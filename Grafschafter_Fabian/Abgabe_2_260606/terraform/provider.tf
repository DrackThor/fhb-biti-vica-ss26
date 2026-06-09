# Terraform-Konfiguration: Versionsanforderungen und Provider-Definition
terraform {
  required_version = ">= 1.3.0"

  required_providers {
    exoscale = {
      source  = "exoscale/exoscale"
      version = "~> 0.62"
    }
  }

  # Remote-State in GitHub Actions (optional: Exoscale SOS als S3-Backend)
  # backend "s3" { ... }
}

# Exoscale Provider - Credentials kommen aus GitHub Secrets (via Umgebungsvariablen)
provider "exoscale" {
  key    = var.exoscale_api_key
  secret = var.exoscale_api_secret
}