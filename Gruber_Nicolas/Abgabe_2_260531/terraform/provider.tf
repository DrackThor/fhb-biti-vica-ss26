# Provider-Konfiguration fuer Exoscale
# Definiert den Terraform Provider und die Authentifizierung

terraform {
  # Terraform Version >= 1.0 erforderlich
  required_version = ">= 1.0"

  required_providers {
    # Exoscale Provider fuer Cloud-Ressourcen
    exoscale = {
      source  = "exoscale/exoscale"
      version = "~> 0.62"
    }
  }
}

# Exoscale Provider mit API-Credentials
# Authentifizierung erfolgt ueber Variablen (GitHub Secrets)
provider "exoscale" {
  key    = var.exoscale_api_key
  secret = var.exoscale_api_secret
}
