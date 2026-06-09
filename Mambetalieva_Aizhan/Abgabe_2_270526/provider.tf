# Definiert die benötigten Provider und Versionen für das Projekt
terraform {
  required_version = ">= 1.0"
  required_providers {
    exoscale = {
      source  = "exoscale/exoscale"
      version = "~> 0.54.0"
    }
  }
}

# Konfiguriert den Exoscale-Anbieter mit den Variablen aus GitHub Actions
provider "exoscale" {
  key    = var.exoscale_key
  secret = var.exoscale_secret
}

variable "exoscale_key" {
  type      = string
  sensitive = true
}

variable "exoscale_secret" {
  type      = string
  sensitive = true
}

variable "zone" {
  type    = string
  default = "at-vie-1" # Standardzone ist Wien für die FH Burgenland
}
