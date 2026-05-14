terraform {
  required_version = ">= 1.6.0"

  required_providers {
    exoscale = {
      # Offizieller Exoscale Provider.
      source  = "exoscale/exoscale"
      version = "~> 0.64"
    }
  }
}
