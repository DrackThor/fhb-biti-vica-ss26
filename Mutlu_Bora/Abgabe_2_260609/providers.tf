terraform {
  required_version = ">= 1.6.0"

  # Bleibt absichtlich leer: Bucket, Key und Region werden zur Laufzeit
  # aus backend.hcl geladen (siehe Workflow). So steht kein Bucket-Name im Code.
  backend "s3" {}

  required_providers {
    exoscale = {
      source  = "exoscale/exoscale"
      version = "~> 0.69"
    }
  }
}

# Key/Secret kommen aus den Env-Variablen EXOSCALE_API_KEY / EXOSCALE_API_SECRET.
provider "exoscale" {}