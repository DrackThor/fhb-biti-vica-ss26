# variables.tf
# Eingabeparameter der Konfiguration. Alle haben sinnvolle Defaults, damit der
# Workflow ohne weitere Eingaben lauffaehig ist.

variable "zone" {
  description = "Exoscale-Zone, in der die VM erstellt wird (muss zur Backend-Region passen)."
  type        = string
  default     = "at-vie-1" # Wien
}

variable "instance_name" {
  description = "Name der Compute-Instanz."
  type        = string
  default     = "mhabel-vminfo"
}

variable "instance_type" {
  description = "Exoscale-Instanztyp (Groesse). standard.micro ist klein und guenstig."
  type        = string
  default     = "standard.micro"
}

variable "disk_size" {
  description = "Groesse der Boot-Disk in GB."
  type        = number
  default     = 10
}

variable "template_name" {
  description = "Name des Betriebssystem-Templates (unterstuetztes Ubuntu)."
  type        = string
  default     = "Linux Ubuntu 24.04 LTS 64-bit"
}

variable "ssh_public_key" {
  description = <<-EOT
    Optionaler SSH-Public-Key. Ist er leer, wird kein SSH-Key angelegt;
    der Web-Endpunkt funktioniert auch ohne SSH-Zugang.
  EOT
  type        = string
  default     = ""
}
