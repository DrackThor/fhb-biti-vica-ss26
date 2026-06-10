variable "exoscale_api_key" {
  description = "Exoscale API Key"
  type        = string
  sensitive   = true   # wird in Logs nicht angezeigt
}

variable "exoscale_api_secret" {
  description = "Exoscale API Secret"
  type        = string
  sensitive   = true
}

variable "zone" {
  description = "Exoscale Zone"
  type        = string
  default     = "at-vie-1"   # Wien als Default
}

variable "vica-ss26-key" {
  description = "SSH Key"
  type        = string
  default = "vica-ss26-key"
}