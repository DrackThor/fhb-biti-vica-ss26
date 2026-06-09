# Exoscale Provider Konfiguration
# Benötigt API Key und Secret für die Authentifizierung bei Exoscale

terraform {
  # Minimale Terraform-Version
  required_version = ">= 1.0"

  # Exoscale Provider Quelle und Version
  required_providers {
    exoscale = {
      source  = "exoscale/exoscale"
      version = "~> 0.62"
    }
  }
}

# Provider-Konfiguration mit Variablen für API-Zugangsdaten
# Die Zugangsdaten werden über Variablen oder Umgebungsvariablen bereitgestellt
provider "exoscale" {
  key    = var.exoscale_api_key
  secret = var.exoscale_api_secret
}
