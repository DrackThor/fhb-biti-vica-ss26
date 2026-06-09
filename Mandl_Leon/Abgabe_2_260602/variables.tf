# Exoscale API Key aus GitHub Secrets.
variable "exoscale_api_key" {
  type      = string
  sensitive = true
}

# Exoscale API Secret aus GitHub Secrets.
variable "exoscale_api_secret" {
  type      = string
  sensitive = true
}

# Exoscale Zone für die VM.
variable "zone" {
  type    = string
  default = "at-vie-1"
}

# Name der VM.
variable "vm_name" {
  type    = string
  default = "abgabe2-leon-mandl"
}

# Ubuntu Image.
variable "template_name" {
  type    = string
  default = "Linux Ubuntu 24.04 LTS 64-bit"
}

# VM Größe.
variable "instance_type" {
  type    = string
  default = "standard.micro"
}

# Root Disk Größe in GB.
variable "disk_size" {
  type    = number
  default = 10
}
