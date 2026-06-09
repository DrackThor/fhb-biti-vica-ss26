# Variable für den Exoscale API Key
variable "exoscale_api_key" {

  # Beschreibung der Variable
  description = "Exoscale API Key"
  # Datentyp der Variable
  type = string
  # Versteckt den Wert in Outputs und Logs
  sensitive = true
}

# Variable für das Exoscale API Secret
variable "exoscale_api_secret" {

  # Beschreibung der Variable
  description = "Exoscale API Secret"
  # Datentyp der Variable
  type = string
  # Versteckt den Wert in Outputs und Logs
  sensitive = true
}


# Variable für die Exoscale Zone
variable "zone" {

  # Beschreibung der Variable
  description = "Exoscale Zone" 
  # Datentyp der Variable
  type = string
  # Standardmäßig wird die Zone Wien verwendet
  default = "at-vie-1"
}