# ---- Data Sources ----

# Aktuelles Ubuntu-Template aus dem Exoscale-Katalog abrufen
data "exoscale_template" "ubuntu" {
  zone = var.zone
  name = var.template_name
}

# Standard-Security-Group als Basis referenzieren
data "exoscale_security_group" "default" {
  name = "default"
}

resource "exoscale_ssh_key" "deployer" {
  name       = "grafschafter-deployer"
  public_key = var.ssh_public_key
}

# Eigene Security Group: nur HTTP, HTTPS und SSH erlaubt
resource "exoscale_security_group" "web" {
  name        = "${var.instance_name}-sg"
  description = "Erlaubt HTTP (80), HTTPS (443) und SSH (22)"
}

# Eingehende SSH-Verbindungen (Port 22) für Administration
resource "exoscale_security_group_rule" "ssh" {
  security_group_id = exoscale_security_group.web.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 22
  end_port          = 22
}

# Eingehender HTTP-Traffic (Port 80) für den Webserver
resource "exoscale_security_group_rule" "http" {
  security_group_id = exoscale_security_group.web.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 80
  end_port          = 80
}

# Eingehender HTTPS-Traffic (Port 443) für TLS (Bonus)
resource "exoscale_security_group_rule" "https" {
  security_group_id = exoscale_security_group.web.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 443
  end_port          = 443
}

# Ausgehender Traffic: alles erlaubt (für apt, curl, etc.)
resource "exoscale_security_group_rule" "egress" {
  security_group_id = exoscale_security_group.web.id
  type              = "EGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 1
  end_port          = 65535
}

# ---- Compute Instance ----

# Cloud-Init user_data als Template einlesen - enthält die gesamte OS-Konfiguration
locals {
  cloud_init = file("${path.module}/cloud-init.yaml")
}

# Exoscale Compute Instance (Ubuntu VM)
resource "exoscale_compute_instance" "vm" {
  zone        = var.zone
  name        = var.instance_name
  template_id = data.exoscale_template.ubuntu.id
  type        = var.instance_type
  disk_size   = var.disk_size
  ssh_key = exoscale_ssh_key.deployer.name

  # Cloud-Init user_data: vollständige OS-Konfiguration
  user_data = local.cloud_init

  # Security Group zuweisen
  security_group_ids = [
    exoscale_security_group.web.id,
  ]

  # Sicherstellen, dass Security Group vor VM existiert
  depends_on = [exoscale_security_group.web]
}