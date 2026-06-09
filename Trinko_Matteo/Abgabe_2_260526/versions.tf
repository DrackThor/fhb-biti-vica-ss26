terraform {
  required_providers {
    # Exoscale Provider, damit OpenTofu mit der Exoscale API sprechen kann
    exoscale = {
      source  = "exoscale/exoscale"
      version = "~> 0.69"
    }
  }

  # Mindestversion für OpenTofu
  required_version = ">= 1.6.0"
}