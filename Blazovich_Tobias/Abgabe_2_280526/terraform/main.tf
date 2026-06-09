# Verbindung zum Exoscale Provider herstellen
provider "exoscale" {

  # API Key für die Authentifizierung
  key = var.exoscale_api_key
  # API Secret für die Authentifizierung
  secret = var.exoscale_api_secret

}

# Ubuntu Template aus der gewählten Zone laden
data "exoscale_template" "ubuntu" {

  # Exoscale Zone
  zone = var.zone
  # Verwendetes Betriebssystem
  name = "Linux Ubuntu 22.04 LTS 64-bit"

}

# Security Group für die VM erstellen
resource "exoscale_security_group" "web" {

  # Name der Security Group
  name = "web-security-group"

}

# Virtuelle Maschine in Exoscale erstellen
resource "exoscale_compute_instance" "web" {

  # Name der VM
  name = "web-server"
  # Zone der VM
  zone = var.zone
  # Verwendetes Ubuntu Template
  template_id = data.exoscale_template.ubuntu.id
  # Größe und Leistung der VM
  type = "standard.small"
  # Größe der virtuellen Festplatte in GB
  disk_size = 10
   # Security Group der VM zuweisen
  security_group_ids = [exoscale_security_group.web.id]
  # CloudInit Datei beim Start der VM ausführen
  user_data = file("cloud-init.yaml")

}

# Firewall Regel für HTTP Zugriff erstellen
resource "exoscale_security_group_rule" "http" {
    
  # Zugehörige Security Group
  security_group_id = exoscale_security_group.web.id
  # Eingehender Netzwerkverkehr erlauben
  type              = "INGRESS"
  # TCP Protokoll verwenden
  protocol          = "TCP"
  # Zugriff von allen IP Adressen erlauben
  cidr              = "0.0.0.0/0"
  # Start Port für HTTP
  start_port        = 80
  # End Port für HTTP
  end_port          = 80
}

# Firewall Regel für HTTPS Zugriff erstellen
resource "exoscale_security_group_rule" "https" {
    
  # Zugehörige Security Group
  security_group_id = exoscale_security_group.web.id
  # Eingehender Netzwerkverkehr erlauben
  type              = "INGRESS"
  # TCP Protokoll verwenden
  protocol          = "TCP"
  # Zugriff von allen IP Adressen erlauben
  cidr              = "0.0.0.0/0"
  # Start Port für HTTPS
  start_port        = 443
  # End Port für HTTPS
  end_port          = 443
}

# Firewall Regel für SSH Zugriff erstellen
resource "exoscale_security_group_rule" "ssh" {
    
  # Zugehörige Security Group
  security_group_id = exoscale_security_group.web.id
  # Eingehender Netzwerkverkehr erlauben
  type              = "INGRESS"
  # TCP Protokoll verwenden
  protocol          = "TCP"
  # Zugriff von allen IP Adressen erlauben
  cidr              = "0.0.0.0/0"
  # Start Port für SSH
  start_port        = 22
  # End Port für SSH
  end_port          = 22
}



