# OpenTofu liest diesen Block wie Terraform. Er pinnt die Provider grob genug,
# damit die Abgabe reproduzierbar bleibt, aber nicht an eine Patch-Version klebt.
terraform {
  required_version = ">= 1.8.0"

  required_providers {
    exoscale = {
      source  = "exoscale/exoscale"
      version = "~> 0.69"
    }
  }

  # Der State liegt in Exoscale SOS, weil Create- und Destroy-Workflow auf
  # getrennten GitHub-Runnern laufen und sonst keinen gemeinsamen State haetten.
  backend "s3" {
    key    = "wagner-raphael/abgabe-2/terraform.tfstate"
    region = "at-vie-1"

    endpoints = {
      s3 = "https://sos-at-vie-1.exo.io"
    }

    # Exoscale SOS ist S3-kompatibel, aber kein AWS-Konto. Diese Optionen
    # deaktivieren AWS-spezifische Pruefungen, die bei SOS nicht passen.
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requester_charged      = true
    skip_metadata_api_check     = true
    skip_s3_checksum            = true
    use_path_style              = true
  }
}

# Der Provider liest EXOSCALE_API_KEY und EXOSCALE_API_SECRET aus der Umgebung.
# Dadurch landen keine Zugangsdaten im Code oder im Git-Repository.
provider "exoscale" {}
