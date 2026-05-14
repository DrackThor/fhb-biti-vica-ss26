# Exoscale API Key.
variable "exoscale_api_key" {
  description = "Exoscale API key"
  type        = string
  sensitive   = true
}

# Exoscale API Secret.
variable "exoscale_api_secret" {
  description = "Exoscale API secret"
  type        = string
  sensitive   = true
}

# Exoscale Zone.
variable "zone" {
  description = "Exoscale zone"
  type        = string
  default     = "at-vie-1"
}

# Name der VM.
variable "instance_name" {
  description = "Name of the VM"
  type        = string
  default     = "fhb-biti-vica-vm"
}

# Ubuntu Template.
variable "instance_template" {
  description = "Ubuntu template"
  type        = string
  default     = "Linux Ubuntu 24.04 LTS 64-bit"
}

# Größe der VM.
variable "instance_type" {
  description = "Exoscale instance type"
  type        = string
  default     = "standard.small"
}
