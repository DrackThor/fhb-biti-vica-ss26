# providers.tf
# -----------------------------------------------------------------------------
# Provider-Definition. KEIN Remote-Backend: Der State wird lokal gehalten und
# vom Deploy-Workflow als GitHub-Actions-Artefakt hochgeladen. Der
# Destroy-Workflow laedt ihn wieder herunter. Vorteil: kein SOS-Bucket noetig.
# -----------------------------------------------------------------------------

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    exoscale = {
      source  = "exoscale/exoscale"
      version = "~> 0.69"
    }
  }
}

provider "exoscale" {
  key    = var.exoscale_api_key
  secret = var.exoscale_api_secret
}
