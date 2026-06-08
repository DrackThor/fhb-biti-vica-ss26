# Variablen-Definitionen für die Exoscale Infrastruktur

# API-Zugangsdaten für Exoscale (sensitiv - werden nicht geloggt)
variable "exoscale_api_key" {
  description = "Exoscale API Key"
  type        = string
  sensitive   = true
}

variable "exoscale_api_secret" {
  description = "Exoscale API Secret"
  type        = string
  sensitive   = true
}

# Exoscale Zone (Rechenzentrum)
# Verfügbare Zonen: ch-gva-2, ch-dk-2, de-fra-1, de-muc-1, at-vie-1, at-vie-2
variable "exoscale_zone" {
  description = "Exoscale Zone für die VM"
  type        = string
  default     = "de-fra-1"
}

# Name des Projekts - wird für Resource-Naming verwendet
variable "project_name" {
  description = "Projektname für Resource-Benennung"
  type        = string
  default     = "vm-info"
}

# Instance-Typ (VM-Größe)
# Verfügbare Typen: tiny, small, medium, large, extra-large, etc.
variable "instance_type" {
  description = "Exoscale Instance Type (VM-Größe)"
  type        = string
  default     = "standard.micro"
}

# SSH Public Key für den Zugriff auf die VM
variable "ssh_public_key" {
  description = "SSH Public Key für VM-Zugriff"
  type        = string
}

# ============================================================
# Cloudflare DNS & SSL (optional)
# ============================================================

# Domain-Name fuer DNS (z.B. "vm-info.example.com")
variable "domain_name" {
  description = "Domain-Name fuer DNS (optional, leer = kein DNS/SSL)"
  type        = string
}

# Cloudflare API Token (DNS-Edit Permissions)
variable "cloudflare_api_token" {
  description = "Cloudflare API Token mit DNS-Edit-Berechtigung"
  type        = string
  sensitive   = true
}

# Cloudflare Zone ID
variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID der Domain"
  type        = string
}

# E-Mail-Adresse fuer Let's Encrypt Benachrichtigungen
variable "letsencrypt_email" {
  description = "E-Mail fuer Let's Encrypt Zertifikatsbenachrichtigungen"
  type        = string
}

# Disk-Größe in GB
variable "disk_size" {
  description = "Disk-Größe in GB"
  type        = number
  default     = 10
}
