# Der Exoscale Provider liest die Zugangsdaten aus Terraform-Variablen.
# In GitHub Actions werden diese Werte über Repository Secrets gesetzt.
provider "exoscale" {
  key    = var.exoscale_api_key
  secret = var.exoscale_api_secret
}
