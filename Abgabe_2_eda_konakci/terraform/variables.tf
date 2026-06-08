# Exoscale API Key. Wird in GitHub Actions aus dem Secret EXOSCALE_API_KEY befüllt.
variable "exoscale_api_key" {
  description = "Exoscale API Key"
  type        = string
  sensitive   = true
}

# Exoscale API Secret. Wird in GitHub Actions aus dem Secret EXOSCALE_API_SECRET befüllt.
variable "exoscale_api_secret" {
  description = "Exoscale API Secret"
  type        = string
  sensitive   = true
}

# Exoscale Zone, in der die VM erstellt wird. at-vie-1 ist eine verfügbare Wiener Zone.
variable "zone" {
  description = "Exoscale Zone für die VM"
  type        = string
  default     = "at-vie-1"
}

# Name der VM und gleichzeitig Prefix für andere Ressourcen.
variable "instance_name" {
  description = "Name der Exoscale Compute Instance"
  type        = string
  default     = "vica-vm-details-ek"
}

# Offizielles Ubuntu Template. Ubuntu 22.04 LTS ist aktuell unterstützt und stabil.
variable "template_name" {
  description = "Exoscale Template Name für das Betriebssystem"
  type        = string
  default     = "Linux Ubuntu 22.04 LTS 64-bit"
}

# Kleine Instanz reicht für Nginx und die statische/JSON-Ausgabe.
variable "instance_type" {
  description = "Exoscale Instance Type"
  type        = string
  default     = "standard.small"
}

# Root Disk Größe in GiB. Exoscale verlangt mindestens 10 GiB.
variable "disk_size" {
  description = "Root Disk Größe in GiB"
  type        = number
  default     = 10
}

# Optionaler SSH Public Key. Wenn leer, wird kein SSH Key importiert.
variable "ssh_public_key" {
  description = "Optionaler SSH Public Key für Debugging-Zugriff"
  type        = string
  default     = ""
}

# CIDR für SSH Zugriff. Standardmäßig bewusst restriktiv deaktiviert.
# Für Debugging z.B. auf 1.2.3.4/32 setzen.
variable "ssh_allowed_cidr" {
  description = "CIDR, aus dem SSH erlaubt ist; leer deaktiviert SSH-Regel"
  type        = string
  default     = ""
}

# Optional: DNS-Zone, die bereits bei Exoscale DNS existiert, z.B. example.com.
# Wenn leer, wird keine DNS-Konfiguration erstellt und die Ausgabe erfolgt über die öffentliche IP.
variable "dns_domain" {
  description = "Optional vorhandene Exoscale DNS-Zone, z.B. example.com"
  type        = string
  default     = ""
}

# Optionaler Record-Name innerhalb der Zone, z.B. vm-details für vm-details.example.com.
variable "dns_record_name" {
  description = "Optionaler DNS Record Name innerhalb der Zone"
  type        = string
  default     = "vm-details"
}

# E-Mail-Adresse für Let's Encrypt. Nur nötig, wenn DNS/FQDN verwendet wird.
variable "letsencrypt_email" {
  description = "E-Mail für Let's Encrypt Registrierung"
  type        = string
  default     = "admin@example.com"
}
