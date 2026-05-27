# API Zugangsdaten (werden über Umgebungsvariablen übergeben)
variable "exoscale_api_key" {
  type      = string
  sensitive = true
}

variable "exoscale_api_secret" {
  type      = string
  sensitive = true
}

# Exoscale Zone (Wien)
variable "zone" {
  type    = string
  default = "at-vie-1"
}

# VM Name
variable "instance_name" {
  type    = string
  default = "prieller-vm"
}

# Betriebssystem
variable "instance_template" {
  type    = string
  default = "Linux Ubuntu 26.04 LTS 64-bit"
}

# VM Größe
variable "instance_type" {
  type    = string
  default = "standard.small"
}
