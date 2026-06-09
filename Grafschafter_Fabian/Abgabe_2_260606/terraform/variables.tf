# Exoscale API-Key (wird aus GitHub Secrets befüllt)
variable "exoscale_api_key" {
  type        = string
  description = "Exoscale API Key"
  sensitive   = true
}

# Exoscale API-Secret (wird aus GitHub Secrets befüllt)
variable "exoscale_api_secret" {
  type        = string
  description = "Exoscale API Secret"
  sensitive   = true
}

# Zielzone - at-vie-2 = Vienna (Österreich), alternativ ch-gva-2
variable "zone" {
  type        = string
  description = "Exoscale Zone"
  default     = "at-vie-2"
}

# Name der VM - wird für DNS, Hostname etc. verwendet
variable "instance_name" {
  type        = string
  description = "Name der Compute Instance"
  default     = "fhb-biti-vica-ss26"
}

# Ubuntu LTS Template
variable "template_name" {
  type        = string
  description = "Name des OS-Templates"
  default     = "Linux Ubuntu 24.04 LTS 64-bit"
}

# Instance-Typ: small genügt für einen Info-Webserver
variable "instance_type" {
  type        = string
  description = "Exoscale Compute Instance Type"
  default     = "standard.small"
}

# Disk-Größe in GB
variable "disk_size" {
  type        = number
  description = "Root-Disk-Größe in GB"
  default     = 20
}

variable "ssh_public_key" {
  type        = string
  description = "SSH Public Key für VM-Zugriff"
}