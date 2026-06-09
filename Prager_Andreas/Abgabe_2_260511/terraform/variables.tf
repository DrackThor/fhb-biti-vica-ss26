############################
# Exoscale Credentials
############################

variable "exoscale_api_key" {
  description = "Exoscale API key used for authentication"
  type        = string
  sensitive   = true
}

variable "exoscale_api_secret" {
  description = "Exoscale API secret used for authentication"
  type        = string
  sensitive   = true
}

############################
# Infrastructure Settings
############################

variable "zone" {
  description = "Exoscale zone where resources will be deployed (e.g. at-vie-1)"
  type        = string
  default     = "at-vie-1"
}

variable "instance_type" {
  description = "VM instance size (Exoscale compute offering)"
  type        = string
  default     = "standard.micro"
}

variable "vm_disk_size" {
  description = "Disk size of the provisioned VM instance in GB"
  type        = number
  default     = 10
}

############################
# SSH Configuration
############################

variable "ssh_public_key" {
  description = "Path to your local SSH public key file"
  type        = string
}

############################
# Project Configuration
############################
variable "owner_name" {
  description = "Name of the owner"
  type        = string
}

variable "owner_mail" {
  description = "Mail address of the owner"
  type        = string
}

variable "namespace" {
  description = "Namespace of the project - Used for resource naming and dns a record for web server"
  type        = string
}
