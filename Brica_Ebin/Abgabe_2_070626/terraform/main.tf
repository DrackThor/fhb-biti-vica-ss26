# Definition des benötigten OpenTofu/Terraform Providers für Exoscale
terraform {
  required_providers {
    exoscale = {
      source  = "exoscale/exoscale"
      version = "~> 0.64"
    }
  }
}

# Verbindung zu Exoscale
# Die Zugangsdaten werden im GitHub Workflow über GitHub Secrets gesetzt
provider "exoscale" {
  key    = var.exoscale_key
  secret = var.exoscale_secret
}

# Security Group für die virtuelle Maschine
resource "exoscale_security_group" "web" {
  name = "ebin-vica-security-group-070626"
}

# Firewall Regel für HTTP Zugriff auf Port 80
resource "exoscale_security_group_rule" "http" {
  security_group_id = exoscale_security_group.web.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 80
  end_port          = 80
}

# Firewall Regel für SSH Zugriff auf Port 22
resource "exoscale_security_group_rule" "ssh" {
  security_group_id = exoscale_security_group.web.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 22
  end_port          = 22
}

# Ubuntu Template anhand des Namens und der Zone suchen
data "exoscale_template" "ubuntu" {
  zone = "at-vie-1"
  name = "Linux Ubuntu 24.04 LTS 64-bit"
}

# Erstellung der Ubuntu VM in Exoscale
resource "exoscale_compute_instance" "vm" {
  name = "ebin-vica-vm"

  # Standort Wien
  zone = "at-vie-1"

  # Ubuntu Template verwenden
  template_id = data.exoscale_template.ubuntu.id

  # Kleine VM reicht für Apache Webserver
  type = "standard.micro"

  # Größe der Systemdisk
  disk_size = 10

  # Zuweisung der Security Group
  security_group_ids = [
    exoscale_security_group.web.id
  ]

  # CloudInit führt die komplette Betriebssystemkonfiguration automatisch aus
  user_data = file("${path.module}/cloud-init.yaml")

  # VM erst erstellen, nachdem die Firewall Regeln vorhanden sind
  depends_on = [
    exoscale_security_group_rule.http,
    exoscale_security_group_rule.ssh
  ]
}