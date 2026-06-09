# =====================================================================
# variables.tf  -  Alle Eingabewerte fuer die Konfiguration
# =====================================================================

variable "exoscale_api_key" {
  type        = string
  description = "Exoscale IAM API Key (kommt aus einem GitHub Secret)"
  sensitive   = true
}

variable "exoscale_api_secret" {
  type        = string
  description = "Exoscale IAM API Secret (kommt aus einem GitHub Secret)"
  sensitive   = true
}

variable "zone" {
  type        = string
  description = "Exoscale-Zone (Rechenzentrum). at-vie-1 = Wien."
  default     = "at-vie-1"
}

variable "template_name" {
  type        = string
  description = "Name des Ubuntu-Images in Exoscale"
  default     = "Linux Ubuntu 24.04 LTS 64-bit"
}

variable "instance_type" {
  type        = string
  description = "Groesse/Typ der VM (z.B. standard.micro, standard.small)"
  default     = "standard.small"
}

variable "ssh_public_key" {
  type        = string
  description = "Optionaler SSH Public Key fuer Debug-Zugriff. Leer = kein SSH."
  default     = ""
}
