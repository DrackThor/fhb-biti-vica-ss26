# =============================================================================
# variables.tf – Eingabevariablen für das Terraform-Modul
# Alle sensiblen Werte kommen als GitHub Secrets in die Pipeline
# =============================================================================

variable "exoscale_api_key" {
  description = "Exoscale API Key (aus GitHub Secret EXOSCALE_API_KEY)"
  type        = string
  sensitive   = true
}

variable "exoscale_api_secret" {
  description = "Exoscale API Secret (aus GitHub Secret EXOSCALE_API_SECRET)"
  type        = string
  sensitive   = true
}

variable "zone" {
  description = "Exoscale Zone, in der die Infrastruktur erstellt wird"
  type        = string
  default     = "at-vie-1" # Wien – niedrige Latenz für AT-Standorte
}

variable "ssh_public_key" {
  description = "Öffentlicher SSH-Key für den Zugang zur VM (aus GitHub Secret SSH_PUBLIC_KEY)"
  type        = string
  sensitive   = true
}

variable "domain" {
  description = "Vollständiger Domainname (FQDN) der VM, zB vica.example.com"
  type        = string
}

variable "letsencrypt_email" {
  description = "E-Mail-Adresse für Let's Encrypt Zertifikate (Ablaufbenachrichtigungen)"
  type        = string
}
