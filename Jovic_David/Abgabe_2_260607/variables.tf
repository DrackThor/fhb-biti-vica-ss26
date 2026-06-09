variable "exoscale_key" {
  description = "Dein Exoscale API Key"
  type        = string
  sensitive   = true
}

variable "exoscale_secret" {
  description = "Dein Exoscale API Secret"
  type        = string
  sensitive   = true
}

variable "zone" {
  description = "Die Exoscale Zone (z. B. ch-gva-2, de-muc-1)"
  type        = string
  default     = "de-muc-1"
}

variable "instance_type" {
  description = "Größe der VM"
  type        = string
  default     = "standard.medium"
}
