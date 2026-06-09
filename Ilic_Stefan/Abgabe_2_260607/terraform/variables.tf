# variables.tf
# -----------------------------------------------------------------------------
# Eingabevariablen. Sensible Werte (API-Key/Secret) kommen via TF_VAR_* aus
# GitHub-Secrets. Domain-Werte koennen via GitHub-Variables ueberschrieben werden.
# -----------------------------------------------------------------------------

variable "exoscale_api_key" {
  description = "Exoscale API Key (IAM). Braucht Compute- UND DNS-Rechte."
  type        = string
  sensitive   = true
}

variable "exoscale_api_secret" {
  description = "Exoscale API Secret."
  type        = string
  sensitive   = true
}

variable "zone" {
  description = "Exoscale-Zone (Rechenzentrum)."
  type        = string
  default     = "at-vie-1" # Wien
}

variable "instance_type" {
  description = "Exoscale Instanztyp (micro = guenstig, reicht fuer Caddy + Info-Seite)."
  type        = string
  default     = "standard.micro"
}

variable "disk_size" {
  description = "Boot-Disk-Groesse in GB."
  type        = number
  default     = 10
}

variable "template_name" {
  description = "Name des Ubuntu-Templates."
  type        = string
  default     = "Linux Ubuntu 26.04 LTS 64-bit"
}

variable "vm_name" {
  description = "Basis-Name fuer VM und Security Group."
  type        = string
  default     = "ilic"
}

# --- DNS ---
variable "root_domain" {
  description = "Vom Kurs in Exoscale verwaltete DNS-Zone."
  type        = string
  default     = "biti-fhb.org"
}

variable "second_level_domain" {
  description = "Persoenlicher Subdomain-Teil zur Abgrenzung von anderen Studierenden."
  type        = string
  default     = "ilic"
}

variable "api_prefix" {
  description = "Subdomain-Prefix fuer den JSON-API-Endpunkt."
  type        = string
  default     = "api"
}

# --- Let's Encrypt / ACME ---
variable "acme_staging" {
  description = "true = Let's-Encrypt-Staging-CA (gegen Rate-Limits beim Testen)."
  type        = bool
  default     = false
}

# --- Security ---
variable "ssh_allowed_cidr" {
  description = "CIDR, von dem SSH (22) erreichbar ist."
  type        = string
  default     = "0.0.0.0/0"
}

variable "ssh_public_key" {
  description = "Oeffentlicher SSH-Key (vom Workflow erzeugt). Leer = kein Key."
  type        = string
  default     = ""
}
