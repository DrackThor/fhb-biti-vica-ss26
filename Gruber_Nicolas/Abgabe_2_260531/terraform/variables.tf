# Eingabe-Variablen fuer die Infrastruktur-Konfiguration

# --- Exoscale API Zugangsdaten (sensitiv) ---

variable "exoscale_api_key" {
  description = "API Key fuer Exoscale Zugriff"
  type        = string
  sensitive   = true
}

variable "exoscale_api_secret" {
  description = "API Secret fuer Exoscale Zugriff"
  type        = string
  sensitive   = true
}

# --- VM Konfiguration ---

# Rechenzentrum-Standort (at-vie-2 = Wien, Oesterreich)
variable "zone" {
  description = "Exoscale Rechenzentrum Zone"
  type        = string
  default     = "at-vie-2"
}

# Projektname fuer einheitliches Naming
variable "project_name" {
  description = "Projektname fuer Ressourcen-Benennung"
  type        = string
  default     = "gruber-sysinfo"
}

# VM Groesse - standard.micro reicht fuer diesen Zweck
variable "instance_type" {
  description = "VM Instance Type (Groesse)"
  type        = string
  default     = "standard.micro"
}

# SSH Key fuer Remote-Zugriff auf die VM
variable "ssh_public_key" {
  description = "Oeffentlicher SSH-Schluessel fuer VM-Zugang"
  type        = string
}

# Festplatten-Groesse der VM in GB
variable "disk_size_gb" {
  description = "Festplatten-Groesse in GB"
  type        = number
  default     = 10
}

# --- DNS und SSL Konfiguration (optional, fuer HTTPS) ---

# Domain fuer den Webserver (leer = nur HTTP ueber IP)
variable "domain_name" {
  description = "Domain fuer HTTPS Zugriff (optional)"
  type        = string
  default     = ""
}

# Cloudflare Token fuer DNS-Verwaltung
variable "cloudflare_api_token" {
  description = "Cloudflare API Token mit DNS-Bearbeitungsrechten"
  type        = string
  sensitive   = true
  default     = ""
}

# Cloudflare Zone ID der verwendeten Domain
variable "cloudflare_zone_id" {
  description = "Zone ID der Cloudflare Domain"
  type        = string
  default     = ""
}

# E-Mail fuer Let's Encrypt Zertifikate
variable "letsencrypt_email" {
  description = "E-Mail Adresse fuer SSL-Zertifikat Benachrichtigungen"
  type        = string
  default     = ""
}
