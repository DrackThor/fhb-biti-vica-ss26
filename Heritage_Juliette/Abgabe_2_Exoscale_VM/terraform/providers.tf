# Exoscale Provider-Konfiguration.
# Die Zugangsdaten werden nicht im Code gespeichert,
# sondern später über GitHub Actions Secrets als Variablen übergeben.
provider "exoscale" {
  key    = var.exoscale_api_key
  secret = var.exoscale_api_secret
}
