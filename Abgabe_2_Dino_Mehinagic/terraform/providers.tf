terraform {
  required_providers {
    exoscale = {
      source  = "exoscale/exoscale"
      version = "~> 0.54.0" # Nutze die aktuell stabile Version
    }
  }
}

provider "exoscale" {
  # Die Credentials werden über Umgebungsvariablen (GitHub Secrets) übergeben
  key    = var.exoscale_key
  secret = var.exoscale_secret
}