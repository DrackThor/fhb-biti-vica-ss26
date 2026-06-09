# Konfiguration des benötigten Exoscale Providers
terraform {
  required_providers {
    exoscale = {
      # Quelle des Providers
      source  = "exoscale/exoscale"
      # Verwendete Provider-Version
      version = "~> 0.62"
    }
  }
}

# Verbindung zu Exoscale herstellen
provider "exoscale" {
  # API Key für die Authentifizierung
  key    = var.exoscale_api_key
  # API Secret für die Authentifizierung
  secret = var.exoscale_api_secret
}

# Auswahl des Ubuntu 24.04 Templates aus Exoscale
data "exoscale_template" "ubuntu" {
  # Exoscale Zone
  zone = "at-vie-1"
  # Name des Betriebssystem-Templates
  name = "Linux Ubuntu 24.04 LTS 64-bit"
}

# Erstellung einer Security Group für die VM
resource "exoscale_security_group" "web" {
  # Name der Security Group
  name = "david-web-sg"
  # Beschreibung der Security Group
  description = "Security Group fuer SSH und HTTP Zugriff"
}

# Firewall-Regel für SSH-Zugriff
resource "exoscale_security_group_rule" "ssh" {
  # Verknüpfung mit der Security Group
  security_group_id = exoscale_security_group.web.id

  # Eingehender Datenverkehr
  type = "INGRESS"

  # Verwendetes Protokoll
  protocol = "TCP"

  # Freigabe von Port 22
  start_port = 22
  end_port   = 22

  # Zugriff von allen IP-Adressen erlauben
  cidr = "0.0.0.0/0"
}

# Firewall-Regel für HTTP-Zugriff
resource "exoscale_security_group_rule" "http" {
  # Verknüpfung mit der Security Group
  security_group_id = exoscale_security_group.web.id

  # Eingehender Datenverkehr
  type = "INGRESS"

  # Verwendetes Protokoll
  protocol = "TCP"

  # Freigabe von Port 80
  start_port = 80
  end_port   = 80

  # Zugriff von allen IP-Adressen erlauben
  cidr = "0.0.0.0/0"
}

# Erstellung der virtuellen Maschine
resource "exoscale_compute_instance" "vm" {
  # Exoscale Zone
  zone = "at-vie-1"

  # Name der virtuellen Maschine
  name = "david-vm"

  # Instanztyp der VM
  type = "standard.small"

  # Verwendetes Ubuntu Template
  template_id = data.exoscale_template.ubuntu.id

  # Festplattengröße in GB
  disk_size = 10

  # Zuweisung der Security Group zur VM
  security_group_ids = [exoscale_security_group.web.id]

  # Ausführung der CloudInit-Konfiguration beim ersten Start
  user_data = file("cloud-init.yaml")
}