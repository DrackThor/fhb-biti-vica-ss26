variable "exoscale_api_key" {
  type      = string
  sensitive = true
}

variable "exoscale_api_secret" {
  type      = string
  sensitive = true
}

variable "zone" {
  type    = string
  default = "at-vie-1"
}

variable "vm_name" {
  type    = string
  default = "vm-ggruenwald"
}

variable "root_domain" {
  type        = string
  default     = "biti-fhb.org"
  description = "The base domain (e.g., example.com)"
}

variable "second_level_domain" {
  type        = string
  default     = "ggruenwald"
  description = "2LD for sharing base domain"
}

variable "stats_prefix" {
  type        = string
  default     = "stats"
  description = "Subdomain for Netdata"
}

variable "api_prefix" {
  type        = string
  default     = "api"
  description = "Subdomain for Swagger UI"
}
