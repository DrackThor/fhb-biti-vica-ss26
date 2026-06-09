# Exoscale Zone
variable "zone" {
  description = "Exoscale Zone, in der die VM erstellt wird."
  type        = string
  default     = "at-vie-1"
}

# Name/Prefix für alle Ressourcen
variable "project_harthold" {
  description = "Eindeutiger Name/Prefix für die Abgabe-2-Ressourcen."
  type        = string
  default     = "abgabe-2-harthold"
}

# Unterstütztes Ubuntu-Image.
variable "ubuntu_template_name" {
  description = "Name des Exoscale Ubuntu Templates."
  type        = string
  default     = "Linux Ubuntu 24.04 LTS 64-bit"
}

# Kleine VM reicht für nginx + Systeminfo-Endpunkt.
variable "instance_type" {
  description = "Exoscale Compute Instance Type."
  type        = string
  default     = "standard.micro"
}

# Exoscale verlangt für Compute Instances mindestens 10 GiB Disk.
variable "disk_size" {
  description = "Root-Disk-Größe in GiB."
  type        = number
  default     = 10
}
