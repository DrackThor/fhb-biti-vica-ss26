# versions.tf
# ---------------------------------------------------------------------------
# Legt die benoetigten Tool-/Provider-Versionen fest und konfiguriert das
# Remote-State-Backend (Exoscale SOS, S3-kompatibel). Das Remote-Backend ist
# noetig, damit der separate "Destroy"-Workflow den State des "Create"-Workflows
# wiederfindet (jeder Workflow-Lauf startet auf einem frischen Runner).
# ---------------------------------------------------------------------------

terraform {
  required_version = ">= 1.6.0" # gilt auch fuer OpenTofu (>= 1.6)

  required_providers {
    exoscale = {
      source  = "exoscale/exoscale"
      version = ">= 0.62"
    }
  }

  # Remote-State in Exoscale SOS (S3-kompatibel).
  # Der Bucket-Name wird beim "tofu init" via -backend-config uebergeben
  # (er kann pro Person/Organisation unterschiedlich sein). Alle uebrigen
  # Werte sind statisch auf die Zone at-vie-1 (Wien) abgestimmt.
  backend "s3" {
    key    = "abgabe2/terraform.tfstate" # Objektname des State-Files im Bucket
    region = "at-vie-1"                   # SOS-"Region" == Exoscale-Zone

    endpoints = {
      s3 = "https://sos-at-vie-1.exo.io" # SOS-Endpunkt der Zone at-vie-1
    }

    # Exoscale SOS ist nicht AWS -> AWS-spezifische Pruefungen abschalten:
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requester_charged      = true
    skip_metadata_api_check     = true
    skip_s3_checksum            = true # SOS unterstuetzt die AWS-Checksummen nicht
    use_path_style              = true # Path-Style-URLs statt virtual-hosted-style
  }
}

# Provider-Konfiguration:
# API-Key/Secret werden NICHT hier hinterlegt, sondern automatisch aus den
# Umgebungsvariablen EXOSCALE_API_KEY / EXOSCALE_API_SECRET gelesen (im Workflow
# als GitHub-Secrets gesetzt). So landen keine Geheimnisse im Code/State.
provider "exoscale" {}
