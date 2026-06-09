variable "exoscale_api_key" {
  description = "Exoscale API Key (aus GitHub Secret EXOSCALE_API_KEY)"
  type        = string
  sensitive   = true # Wird nicht im Terraform-State im Klartext gespeichert
}

variable "exoscale_api_secret" {
  description = "Exoscale API Secret (aus GitHub Secret EXOSCALE_API_SECRET)"
  type        = string
  sensitive   = true
}

variable "ssh_public_key" {
  description = "Öffentlicher SSH-Schlüssel für VM-Zugriff (aus GitHub Secret SSH_PUBLIC_KEY)"
  type        = string
}
