terraform {

  # Definiert den Exoscale Provider
  required_providers {
    
    exoscale = {

      # Provider Quelle
      source  = "exoscale/exoscale"
      
      # Verwendete Provider Version
      version = "~> 0.68.0"
    }
  }
}

provider "exoscale" {

  # Exoscale API Key
  key = var.exoscale_key
  
  # Exoscale API Secret
  secret = var.exoscale_secret
}