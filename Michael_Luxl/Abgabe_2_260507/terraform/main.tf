# Hauptkonfiguration für die Exoscale Infrastruktur
# Erstellt eine VM mit Nginx-Webserver, der VM-Informationen anzeigt

# ============================================================
# Security Group - Definiert erlaubte Netzwerk-Traffic-Regeln
# ============================================================
resource "exoscale_security_group" "vm_sg" {
  name        = "${var.project_name}-sg"
  description = "Security Group für VM-Info Webserver"
}

# SSH-Zugriff (Port 22) erlauben
resource "exoscale_security_group_rule" "ssh" {
  security_group_id = exoscale_security_group.vm_sg.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 22
  end_port          = 22
  description       = "SSH-Zugriff"
}

# HTTP-Zugriff (Port 80) erlauben
resource "exoscale_security_group_rule" "http" {
  security_group_id = exoscale_security_group.vm_sg.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 80
  end_port          = 80
  description       = "HTTP-Zugriff"
}

# HTTPS-Zugriff (Port 443) erlauben
resource "exoscale_security_group_rule" "https" {
  security_group_id = exoscale_security_group.vm_sg.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 443
  end_port          = 443
  description       = "HTTPS-Zugriff"
}

# ============================================================
# SSH Key - Für den Zugriff auf die VM
# ============================================================
resource "exoscale_ssh_key" "vm_key" {
  name       = "${var.project_name}-key"
  public_key = var.ssh_public_key
}

# ============================================================
# Ubuntu Template - Referenz auf das Ubuntu 22.04 Image
# ============================================================
data "exoscale_template" "ubuntu" {
  zone = var.exoscale_zone
  # Ubuntu 22.04 LTS (Jammy Jellyfish) - exakt matchen
  name = "Linux Ubuntu 22.04 LTS 64-bit"
}

# ============================================================
# CloudInit-Konfiguration - Automatisierte VM-Konfiguration
# ============================================================
# Erstellt die CloudInit-Konfiguration als Template
# Variablen (Domain, Cloudflare-Credentials) werden hier injiziert
locals {
  cloudinit_content = templatefile("${path.module}/../cloudinit/cloud-init.yaml", {
    domain_name         = var.domain_name
    cloudflare_api_token = var.cloudflare_api_token
    cloudflare_zone_id  = var.cloudflare_zone_id
    letsencrypt_email   = var.letsencrypt_email
  })
}

# ============================================================
# Compute Instance - Die eigentliche VM
# ============================================================
resource "exoscale_compute_instance" "vm" {
  # Name der VM
  name = "${var.project_name}-vm"
  # Zone (Rechenzentrum)
  zone = var.exoscale_zone
  # Instance-Typ (VM-Größe)
  type = var.instance_type
  # Ubuntu 22.04 Template aus Data Source
  template_id = data.exoscale_template.ubuntu.id
  # Security Group mit den erlaubten Ports
  security_group_ids = [exoscale_security_group.vm_sg.id]
  # SSH Keys für den Zugriff (Liste)
  ssh_keys = [exoscale_ssh_key.vm_key.name]
  # Disk-Größe in GB (mindestens 10)
  disk_size = var.disk_size
  # IPv6 aktivieren
  ipv6 = true
  # CloudInit-Konfiguration für automatische Einrichtung
  user_data = local.cloudinit_content
}
