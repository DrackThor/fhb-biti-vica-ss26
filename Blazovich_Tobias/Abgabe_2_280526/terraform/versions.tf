terraform {
  # Mindestversion von OpenTofu/Terraform
  required_version = ">= 1.6.0"

  # Verwendete Provider definieren
  required_providers {
    # Exoscale Provider für die Erstellung der Infrastruktur
    exoscale = {
      # Quelle des Providers
      source  = "exoscale/exoscale"
      # Verwendete Provider Version
      version = "~> 0.64"
    }
  }
}