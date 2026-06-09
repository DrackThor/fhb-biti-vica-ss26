# =============================================================================
# variables.tf – Eingabevariablen für die Exoscale-Infrastruktur
# =============================================================================
# Sensible Werte (API Keys) kommen aus GitHub Secrets und werden als
# Umgebungsvariablen (TF_VAR_*) in den Workflow injiziert.
# =============================================================================

variable "exoscale_api_key" {
  description = "Exoscale API Key – wird aus GitHub Secret injiziert"
  type        = string
  sensitive   = true
}

variable "exoscale_api_secret" {
  description = "Exoscale API Secret – wird aus GitHub Secret injiziert"
  type        = string
  sensitive   = true
}

variable "zone" {
  description = "Exoscale Zone, in der die VM erstellt wird"
  type        = string
  default     = "at-vie-1" # Wien – DSGVO-konformer Standort
}

variable "instance_name" {
  description = "Name der Compute Instance"
  type        = string
  default     = "vm-info-server"
}

variable "instance_type" {
  description = "Exoscale Instanztyp (CPU/RAM)"
  type        = string
  default     = "standard.small" # 2 vCPU, 2 GB RAM
}

variable "disk_size" {
  description = "Root-Disk-Größe in GB"
  type        = number
  default     = 20
}

variable "domain_name" {
  description = "FQDN für HTTPS (leer = nur IP-Zugang)"
  type        = string
  default     = ""
}

variable "admin_email" {
  description = "E-Mail für Let's Encrypt Zertifikat"
  type        = string
  default     = "admin@example.com"
}
