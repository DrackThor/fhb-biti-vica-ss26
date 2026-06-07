terraform {
  required_version = ">= 1.0"
  required_providers {
    exoscale = {
      source  = "exoscale/exoscale"
      version = "~> 0.59.0"
    }
  }
  backend "s3" {
    bucket                      = "djov-tfstate"
    key                         = "production/terraform.tfstate"
    region                      = "at-vie-1"
    endpoints = {
      s3 = "https://sos-at-vie-1.exo.io"
    }
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true
  }
}


provider "exoscale" {
  key    = var.exoscale_key
  secret = var.exoscale_secret
}
