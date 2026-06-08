terraform {
  # Lege genaue Versionen der verwendeten Provider fest
  required_providers {
    exoscale = {
      source  = "exoscale/exoscale"
      version = "0.69.2"
    }
    acme = {
      source  = "ruokei/acme"
      version = "0.0.8"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.2.1"
    }
  }
}
