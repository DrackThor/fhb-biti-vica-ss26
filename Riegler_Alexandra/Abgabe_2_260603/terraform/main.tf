# benötigter Provider  auswählen hier: Exoscale
terraform {
  required_providers {
    exoscale = {
      source = "exoscale/exoscale"
    }
  }
}

## Authentifizierung: 
# - key und secret Werte au *.tfvars einlesen 
# - werden in terrafrom ausgaben geschützt behandet da "sensitive=true"
variable "exoscale_api_key" {
  description = "Exoscale API key used for authentication"
  type        = string
  sensitive   = true
}

variable "exoscale_api_secret" {
  description = "Exoscale API secret used for authentication"
  type        = string
  sensitive   = true
}
# - Anmeldung bei exoscale
provider "exoscale" {
  key    = var.exoscale_api_key
  secret = var.exoscale_api_secret
}
## Ab hier Konfiguration in Exoscale - BEGINN
#  Zone und OS auswählen für template abfragen
data "exoscale_template" "my_template" {
  zone = "at-vie-1"
  name = "Linux Ubuntu 26.04 LTS 64-bit"
}
# VM erstellen, 
# - Regeln der security Group dieser VM zugeordnet.
# - beim Start wird cloud-Init Konfig durchgeführt.
# -- Vorlage  cloudinit.yaml.tftpl;  details in app.py für Webanwendung 
resource "exoscale_compute_instance" "my_instance" {
  zone        = "at-vie-1"
  name        = "vm-ar-ubuntu"
  template_id = data.exoscale_template.my_template.id
  type        = "standard.medium"
  disk_size   = 18
  security_group_ids = [
    exoscale_security_group.http.id
  ]
  user_data = templatefile("${path.module}/cloudinit.yaml.tftpl", {
    app_py = file("${path.module}/app.py") # Flask Web App
  })

}
#  DNS Konfiguration
# - domain  wird abgefragt 
data "exoscale_domain" "my_domain" {
  name = "biti-fhb.org"
}
# - DNS-A Record erstellt
# -- dns name ist gleich mit dem Hostnamen
resource "exoscale_domain_record" "my_host" {
  domain      = data.exoscale_domain.my_domain.id
  name        = exoscale_compute_instance.my_instance.name
  record_type = "A"
  content     = exoscale_compute_instance.my_instance.public_ip_address
}

#  Security Group erstellen 
resource "exoscale_security_group" "http" {
  name = "arsec-sg-http"
}


# - HTTP (port 80)

resource "exoscale_security_group_rule" "http" {
  security_group_id = exoscale_security_group.http.id
  type              = "INGRESS"
  protocol          = "TCP"
  start_port        = 80
  end_port          = 80
  cidr              = "0.0.0.0/0"
}

## Ab hier Konfiguration in Exoscale - ENDE