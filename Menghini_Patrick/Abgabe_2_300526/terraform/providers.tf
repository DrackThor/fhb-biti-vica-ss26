terraform {
  required_providers {
    exoscale = {
      source  = "exoscale/exoscale"
      version = "~> 0.64.0"
    }
  }
}

provider "exoscale" {}
