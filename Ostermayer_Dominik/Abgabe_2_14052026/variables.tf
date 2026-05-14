
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