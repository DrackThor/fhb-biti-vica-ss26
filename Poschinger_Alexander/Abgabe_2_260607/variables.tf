# Exoscale Zone, in der die VM erstellt wird
variable "zone" {
  description = "Exoscale Zone fuer die VM"
  type        = string
  default     = "at-vie-1"
}

# Name der virtuellen Maschine
variable "instance_name" {
  description = "Name der Exoscale VM"
  type        = string
  default     = "poschinger-abgabe-2-vm"
}

# Groesse der VM
variable "instance_type" {
  description = "Exoscale Instance Type"
  type        = string
  default     = "standard.small"
}

# SSH Public Key fuer den Zugriff auf die VM
variable "ssh_public_key" {
  description = "SSH Public Key fuer die VM"
  type        = string
  sensitive   = true
}