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
# These variables establish the physical target data center and the naming
# base used to uniquely identify and isolate your resources within Exoscale.

variable "zone" {
  type        = string
  description = "The Exoscale zone (datacenter location) where the virtual machine will be deployed."
  default     = "at-vie-1" # Vienna, Austria
}

variable "vm_name" {
  type        = string
  description = "The base identifier used to dynamically name the virtual machine and its attached security groups."
  default     = "gruenwald"
}

# ==========================================
# DNS & DOMAIN CONFIGURATION
# ==========================================
# These variables are concatenated in locals.tf to dynamically build 
# the Fully Qualified Domain Names (FQDNs) for the application endpoints.

variable "root_domain" {
  type        = string
  description = "The base university domain zone managed within Exoscale."
  default     = "biti-fhb.org"
}

variable "second_level_domain" {
  type        = string
  description = "The personal identifier used to isolate this deployment's routing from other students."
  default     = "gruenwald"
}

variable "stats_prefix" {
  type        = string
  description = "The specific subdomain prefix that routes traffic to the Netdata HTML Dashboard."
  default     = "dashboard"
}

variable "api_prefix" {
  type        = string
  description = "The specific subdomain prefix that routes traffic to the Swagger UI JSON API."
  default     = "api"
}

# ==========================================
# SECURITY
# ==========================================
# Restricts which CIDR block can reach SSH (port 22).
# Defaulting to 0.0.0.0/0 keeps the assignment working from any runner,
# but in production you would set this to your university or VPN range,
# e.g. "1.2.3.0/24", to block internet-wide brute-force scanners.

variable "ssh_allowed_cidr" {
  type        = string
  description = "CIDR block allowed to reach SSH (port 22). Restrict to your IP/VPN range in production."
  default     = "0.0.0.0/0"
}

# ==========================================
# LET'S ENCRYPT / ACME
# ==========================================
# Set to true during testing to avoid hitting Let's Encrypt production rate
# limits. When false (default), the production CA is used automatically.

variable "acme_staging" {
  type        = bool
  description = "Set to true to use the Let's Encrypt staging CA instead of production."
  default     = false
}
