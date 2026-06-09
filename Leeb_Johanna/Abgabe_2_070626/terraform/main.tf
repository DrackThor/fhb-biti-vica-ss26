# Terraform-Einstellungen und Provider-Definition
terraform {
  required_providers {
    exoscale = {
      source  = "exoscale/exoscale"
      version = "~> 0.53.0" # definition der zu verwendeneden Provider version
    }
  }

  
}

# Verbindung zu Exoscale mit den Zugangsdaten herstellen
provider "exoscale" {
  key    = var.exoscale_key
  secret = var.exoscale_secret
}

# Security Group (Firewall) anlegen
resource "exoscale_security_group" "web_sg" {
  name        = "jole207-web-sg"
  description = "Erlaubt eingehenden HTTP-Verkehr auf Port 80 fuer jole207"
}

# Regel hinzufügen: Erlaube HTTP (Port 80) von überall (0.0.0.0/0)
resource "exoscale_security_group_rule" "http_rule" {
  security_group_id = exoscale_security_group.web_sg.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 80
  end_port          = 80
}

# automatische Suche nach dem aktuellen Ubuntu Template 
data "exoscale_template" "ubuntu" {
  zone = "at-vie-1" # für die Region Wien
  name = "Linux Ubuntu 24.04 LTS 64-bit"
}

#  Erstellen der VM
resource "exoscale_compute_instance" "sysinfo_vm" {
  zone        = "at-vie-1" # Standort in Wien
  name        = "jole207-sysinfo-vm" 
  type        = "standard.micro" # kleinstmögliche Maschieneninstanztyp
  disk_size   = 10 # zwingend erforderlich - Mindestgröße der Platte in GB
  template_id = data.exoscale_template.ubuntu.id # ID des zuvor gefundenen Templatesn nutzen

  # zuvor erstellete personalisierte Firewall an die VM hängen
  security_group_ids = [exoscale_security_group.web_sg.id]

  # Das Cloud-Init-Skript einlesen und an die VM übergeben
  user_data = file("${path.module}/cloud-init.yaml")
}
