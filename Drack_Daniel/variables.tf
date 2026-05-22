variable "exoscale_zone" {
  description = "Exoscale Zone, z.B. ch-gva-2"
  type        = string
  default     = "ch-gva-2"
}

variable "instance_name" {
  description = "Name der VM"
  type        = string
  default     = "info-vm"
}

variable "instance_type" {
  description = "Instance type"
  type        = string
  default     = "standard.small"
}

variable "disk_size_gb" {
  description = "Root disk size in GB"
  type        = number
  default     = 20
}

variable "ssh_key_name" {
  description = "SSH key name in Exoscale (optional)"
  type        = string
  default     = ""
}

variable "cloudinit_file" {
  description = "Pfad zur Cloud-Init Datei"
  type        = string
  default     = "cloudinit.yaml"
}
