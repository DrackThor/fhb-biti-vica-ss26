variable "zone" {
  description = "Exoscale Zone, in der die VM erstellt wird"
  type        = string
  default     = "at-vie-1"
}

variable "instance_name" {
  description = "Name der Exoscale VM"
  type        = string
  default     = "ubuntu-webserver-trinko"
}

variable "instance_type" {
  description = "Größe der VM"
  type        = string
  default     = "standard.medium"
}

variable "disk_size" {
  description = "Größe der Systemdisk in GB"
  type        = number
  default     = 10
}

variable "ubuntu_template" {
  description = "Ubuntu Image, das für die VM verwendet wird"
  type        = string
  default     = "Linux Ubuntu 24.04 LTS 64-bit"
}

variable "domain_name" {
  description = "Domain, die in Exoscale DNS verwaltet wird"
  type        = string
  default     = "biti-fhb.org"
}

variable "dns_name" {
  description = "Subdomain für die VM"
  type        = string
  default     = "vm-info"
}

variable "certbot_email" {
  description = "E-Mail-Adresse für Let's Encrypt / Certbot"
  type        = string
  default     = "2410640051@hochschule-burgenland.at"
}