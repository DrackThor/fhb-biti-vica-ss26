
variable "exoscale_key" {
  type      = string
  sensitive = true
}

variable "exoscale_secret" {
  type      = string
  sensitive = true
}

variable "zone" {
  type    = string
  default = "at-vie-1"
}

variable "ssh_public_key" {
  type        = string
  sensitive   = true
  description = "Public SSH key used for VM access"
}