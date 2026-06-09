# Exoscale Zone der VM
variable "zone" {

    description = "Exoscale Zone"

    # Datentyp der Variable
    type = string

    # Standardwert
    default = "at-vie-1"
}

# Name der virtuellen Maschine
variable "vm_name" {

    description = "Name der VM"

    type = string

    default = "f-blazovich-vm"
}

# Größe der Disk in GB
variable "disk_size" {

    description = "Disk Größe in GB"

    type = number

    default = 15
}

# Größe beziehungsweise Typ der VM
variable "instance_type" {

    description = "VM Größe"

    type = string

    default = "standard.small"
}

# Verwendetes Ubuntu Template
variable "ubuntu_template" {

  description = "Ubuntu Image, das für die VM verwendet wird"

  type        = string

  default     = "Linux Ubuntu 24.04 LTS 64-bit"
}

# Exoscale API Key
variable "exoscale_key" {

    description = "Exoscale Key"

    type = string

    # Versteckt den Wert in Outputs/Logs
    sensitive = true
}

# Exoscale API Secret
variable "exoscale_secret" {

    description = "Exoscale Secret"
    
    type = string
    
    # Versteckt den Wert in Outputs/Logs
    sensitive = true
}

