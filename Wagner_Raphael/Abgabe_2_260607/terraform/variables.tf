# Exoscale-Zone fuer VM und Object-Storage-State. Wien ist fuer den Kurs naheliegend.
variable "zone" {
  description = "Exoscale-Zone, in der die Abgabe-Infrastruktur erstellt wird."
  type        = string
  default     = "at-vie-1"
}

# Eindeutiger VM-Name, damit die Ressource im gemeinsamen Exoscale-Account erkennbar ist.
variable "instance_name" {
  description = "Name der Exoscale Compute-Instanz."
  type        = string
  default     = "rwagner-abgabe2-vminfo"
}

# Kleine VM-Groesse reicht fuer die Info-Webseite und vermeidet unnoetige Kosten.
variable "instance_type" {
  description = "Exoscale Instance Type fuer die VM."
  type        = string
  default     = "standard.micro"
}

# Boot-Disk-Groesse in GB. 10 GB reichen fuer Ubuntu, Caddy und die App.
variable "disk_size" {
  description = "Groesse der Boot-Disk in GB."
  type        = number
  default     = 10
}

# Ubuntu 24.04 LTS ist ein aktuell unterstuetztes LTS-Betriebssystem.
variable "template_name" {
  description = "Name des Ubuntu-Templates in Exoscale."
  type        = string
  default     = "Linux Ubuntu 24.04 LTS 64-bit"
}

# Optionaler SSH-Key. Die Aufgabe braucht keinen manuellen SSH-Zugriff.
variable "ssh_public_key" {
  description = "Optionaler SSH Public Key. Leer bedeutet: kein SSH-Key wird erstellt."
  type        = string
  default     = ""
}

# Optional: vorhandene Exoscale-DNS-Zone fuer Bonuspunkte mit FQDN und HTTPS.
variable "dns_zone" {
  description = "Optional vorhandene Exoscale-DNS-Zone, z. B. example.at. Leer deaktiviert DNS/HTTPS."
  type        = string
  default     = ""
}

# Optionaler Hostname innerhalb der Zone. Ergibt z. B. vica-rwagner.example.at.
variable "dns_record_name" {
  description = "DNS-Record-Name innerhalb von dns_zone."
  type        = string
  default     = "vica-rwagner"
}

# SSH bleibt absichtlich konfigurierbar; fuer die Abgabe ist HTTP/HTTPS wichtiger.
variable "ssh_cidr" {
  description = "CIDR, aus dem SSH erreichbar sein darf."
  type        = string
  default     = "0.0.0.0/0"
}
