terraform {
  required_version = ">= 1.9.0"

  required_providers {
    exoscale = {
      source  = "exoscale/exoscale"
      version = "~> 0.62"
    }
  }
}
