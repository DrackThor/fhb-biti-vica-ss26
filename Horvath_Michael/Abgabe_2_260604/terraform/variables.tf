# Die Exoscale Zone, in der die VM erstellt wird.
variable "exoscale_zone" {
  description = "Exoscale Zone"
  type        = string
  default     = "at-vie-1"
}

# Der Name der VM – wird auch als Hostname gesetzt
variable "vm_name" {
  description = "Name der VM"
  type        = string
  default     = "mhorvath-vm"
}

# VM-Typ bestimmt CPU und RAM.
# "standard.medium" = 2 vCPU, 4GB RAM
variable "vm_type" {
  description = "Exoscale Voreinstellungen RAM und CPU"
  type        = string
  default     = "standard.medium"
}

# Das Betriebssystem-Template.
# Dabei wird Ubuntu 24.04 LTS genutzt
variable "template_name" {
  description = "Template Name"
  type        = string
  default     = "Linux Ubuntu 24.04 LTS 64-bit"
}

# Disk-Größe 10GB
variable "disk_size" {
  description = "Disk-Größe"
  type        = number
  default     = 10
}

# API Key – wird aus GitHub Secrets als Umgebungsvariable übergeben
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