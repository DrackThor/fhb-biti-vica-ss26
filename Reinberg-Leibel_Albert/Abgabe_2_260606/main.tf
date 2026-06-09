terraform {
  required_providers {
    exoscale = {
      source  = "exoscale/exoscale"
      version = "0.69.2"
    }
  }
}

# Provider Konfiguration bleibt leer.
# Terraform nutzt stattdessen automatisch die Umgebungsvariablen 
# EXOSCALE_API_KEY und EXOSCALE_API_SECRET (z.B. aus GitHub Actions).
provider "exoscale" {
}

locals {
  zone       = "at-vie-2"                       
  template   = "Linux Ubuntu 26.04 LTS 64-bit"  
}

##1. Das aktuellste Ubuntu-Template in der gewählten Zone suchen
data "exoscale_template" "ubuntu" {
  zone = local.zone
  name = local.template
}

# 2. Security Group (Firewall) erstellen
# Hinweis: SSH (Port 22) ist absichtlich nicht konfiguriert für maximale Sicherheit.
resource "exoscale_security_group" "web" {
  name        = "reinberg-sg"
  description = "Erlaubt reinen Web-Traffic (HTTP und HTTPS)"
}

# 2.1 HTTP erlauben (Port 80)
resource "exoscale_security_group_rule" "http" {
  security_group_id = exoscale_security_group.web.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 80
  end_port          = 80
}

# 2.2 HTTPS erlauben (Port 443)
resource "exoscale_security_group_rule" "https" {
  security_group_id = exoscale_security_group.web.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 443
  end_port          = 443
}

# 3. Die virtuelle Maschine (Compute Instance) erstellen
resource "exoscale_compute_instance" "web_server" {
  zone               = local.zone
  name               = "reinberg-leibel_server"
  template_id        = data.exoscale_template.ubuntu.id
  type               = "standard.micro" 
  disk_size          = 10               
  security_group_ids = [exoscale_security_group.web.id]
  
  # Hier wird unser Cloud-Init Skript eingelesen und an die VM übergeben
  user_data = file("${path.module}/cloud-init.yml")
}

# 4. Ausgabe der öffentlichen IP-Adresse nach dem Deployment
output "server_ip" {
  value       = exoscale_compute_instance.web_server.public_ip_address
  description = "Die oeffentliche IP-Adresse des Webservers"
}
