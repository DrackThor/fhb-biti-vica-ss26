# Provider Exoscale für sämtliche Interaktionen mit Exoscale
provider "exoscale" {
  key    = var.exoscale_api_key
  secret = var.exoscale_api_secret
}

# Provider ACME zur automatischen Erstellung von TLS-Zertifikaten
provider "acme" {
  # Let's Encrypt wird als CA verwendet
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}

# Provider TLS zum Umgang mit den vom ACME-Client ausgestellten TLS-Zertifikaten
provider "tls" {}