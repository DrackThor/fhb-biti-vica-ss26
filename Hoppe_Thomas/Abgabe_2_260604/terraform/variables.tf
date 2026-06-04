# =============================================================================
# variables.tf – Eingabevariablen für die Exoscale Infrastruktur
# Werte werden via GitHub Secrets und Workflow-Inputs übergeben
# =============================================================================

# --- Exoscale Zugangsdaten ---------------------------------------------------

variable "exoscale_api_key" {
  description = "Exoscale API Key (aus GitHub Secret EXOSCALE_API_KEY)"
  type        = string
  sensitive   = true # Wird nicht im Terraform-Output angezeigt
}

variable "exoscale_api_secret" {
  description = "Exoscale API Secret (aus GitHub Secret EXOSCALE_API_SECRET)"
  type        = string
  sensitive   = true # Wird nicht im Terraform-Output angezeigt
}

# --- Projekt Konfiguration ---------------------------------------------------

variable "project_name" {
  description = "Name des Projekts – wird als Präfix für alle Ressourcen verwendet"
  type        = string
  default     = "biti-vica-abgabe2"
}

variable "zone" {
  description = "Exoscale Zone (Rechenzentrum). at-vie-1 = Wien"
  type        = string
  default     = "at-vie-1"
}

# --- VM Konfiguration --------------------------------------------------------

variable "instance_type" {
  description = "Exoscale Instanztyp. standard.small = 2 vCPU, 2GB RAM"
  type        = string
  default     = "standard.small"
}

variable "disk_size" {
  description = "Festplattengröße in GB"
  type        = number
  default     = 20
}

# --- SSH Zugriff -------------------------------------------------------------

variable "ssh_public_key" {
  description = "Öffentlicher SSH-Schlüssel für VM-Zugriff (aus GitHub Secret SSH_PUBLIC_KEY)"
  type        = string
}

# --- Domain & TLS ------------------------------------------------------------

variable "domain" {
  description = "Domain/FQDN für die VM (z.B. vm.example.com). Muss auf die Elastic IP zeigen."
  type        = string
}

variable "letsencrypt_email" {
  description = "E-Mail-Adresse für Let's Encrypt Zertifikate (Ablauf-Benachrichtigungen)"
  type        = string
}
