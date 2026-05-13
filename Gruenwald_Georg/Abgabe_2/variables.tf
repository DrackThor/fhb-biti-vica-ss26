# ==========================================
# EXOSCALE AUTHENTICATION
# ==========================================
# These variables are automatically injected by the GitHub Actions pipeline
# via repository secrets. They are marked as sensitive so OpenTofu will 
# redact them from all console logs to prevent security leaks.

variable "exoscale_api_key" {
  type        = string
  description = "The API key used to authenticate with the Exoscale cloud provider."
  sensitive   = true
}

variable "exoscale_api_secret" {
  type        = string
  description = "The API secret matching the API key for Exoscale authentication."
  sensitive   = true
}

# ==========================================
# COMPUTE & LOCATION SETTINGS
# ==========================================

variable "zone" {
  type        = string
  description = "The Exoscale zone (datacenter location) where the virtual machine will be deployed."
  default     = "at-vie-1" # Vienna, Austria
}

variable "vm_name" {
  type        = string
  description = "The base identifier used to dynamically name the virtual machine and its attached security groups."
  default     = "ggruenwald"
}

# ==========================================
# DNS & DOMAIN CONFIGURATION
# ==========================================
# These variables are concatenated in main.tf to dynamically build 
# the Fully Qualified Domain Names (FQDNs) for the application endpoints.

variable "root_domain" {
  type        = string
  description = "The base university domain zone managed within Exoscale."
  default     = "biti-fhb.org"
}

variable "second_level_domain" {
  type        = string
  description = "The personal identifier used to isolate this deployment's routing from other students."
  default     = "ggruenwald"
}

variable "stats_prefix" {
  type        = string
  description = "The specific subdomain prefix that routes traffic to the Netdata HTML Dashboard."
  default     = "stats"
}

variable "api_prefix" {
  type        = string
  description = "The specific subdomain prefix that routes traffic to the Swagger UI JSON API."
  default     = "api"
}
