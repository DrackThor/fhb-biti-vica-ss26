terraform {
  required_providers {
    exoscale = {
      source  = "exoscale/exoscale"
      version = ">= 0.12.0"
    }
  }
  required_version = ">= 1.4.0"
  backend "local" {} # Empfehlung: ersetze durch Remote Backend (Terraform Cloud, S3, ...)
}

provider "exoscale" {
  # Die API Credentials werden über Umgebungsvariablen oder GitHub Secrets gesetzt
  # EXOSCALE_API_KEY und EXOSCALE_API_SECRET
  # Optional: endpoint = "https://api.exoscale.ch/compute"
}
