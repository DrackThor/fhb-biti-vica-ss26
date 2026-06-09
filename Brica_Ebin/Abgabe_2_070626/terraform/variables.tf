# Exoscale API Key
# Der Wert wird im GitHub Workflow aus dem GitHub Secret EXOSCALE_API_KEY gesetzt
variable "exoscale_key" {
  type        = string
  description = "API Key für den Zugriff auf Exoscale"
  sensitive   = true
}

# Exoscale API Secret
# Der Wert wird im GitHub Workflow aus dem GitHub Secret EXOSCALE_API_SECRET gesetzt
variable "exoscale_secret" {
  type        = string
  description = "API Secret für den Zugriff auf Exoscale"
  sensitive   = true
}