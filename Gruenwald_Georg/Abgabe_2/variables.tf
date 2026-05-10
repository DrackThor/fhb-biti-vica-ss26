variable "exoscale_api_key" { sensitive = true }
variable "exoscale_api_secret" { sensitive = true }

variable "zone" { default = "at-vie-1" }
variable "root_domain" { description = "The base domain (e.g., example.com" }
variable "stats_domain" { description = "Subdomain for Netdata" }
variable "api_domain" { description = "Subdomain for Swagger UI" }
variable "admin_email" { description = "Email for Let's Encrypt" }
