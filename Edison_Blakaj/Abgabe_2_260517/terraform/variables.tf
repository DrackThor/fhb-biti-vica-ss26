variable "zone" {
  description = "Exoscale zone"
  type        = string
  default     = "at-vie-1"
}

variable "instance_type" {
  description = "Compute instance type"
  type        = string
  default     = "standard.micro"
}

variable "disk_size" {
  description = "Disk size in GB"
  type        = number
  default     = 20
}
