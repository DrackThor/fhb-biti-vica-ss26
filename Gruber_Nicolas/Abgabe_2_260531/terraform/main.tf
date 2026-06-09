# Hauptkonfiguration - Erstellt die Exoscale VM mit Webserver
# Die VM zeigt System-Informationen ueber HTTP(S) an

# ============================================================
# Security Group - Firewall-Regeln fuer die VM
# ============================================================
resource "exoscale_security_group" "web_sg" {
  name        = "${var.project_name}-security-group"
  description = "Erlaubt SSH, HTTP und HTTPS Zugriff auf die VM"
}

# Port 22 - SSH Zugriff fuer Administration
resource "exoscale_security_group_rule" "allow_ssh" {
  security_group_id = exoscale_security_group.web_sg.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 22
  end_port          = 22
  description       = "SSH Zugriff erlauben"
}

# Port 80 - HTTP Zugriff fuer Webserver
resource "exoscale_security_group_rule" "allow_http" {
  security_group_id = exoscale_security_group.web_sg.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 80
  end_port          = 80
  description       = "HTTP Zugriff erlauben"
}

# Port 443 - HTTPS Zugriff fuer verschluesselten Webserver
resource "exoscale_security_group_rule" "allow_https" {
  security_group_id = exoscale_security_group.web_sg.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 443
  end_port          = 443
  description       = "HTTPS Zugriff erlauben"
}

# ============================================================
# SSH Key - Wird auf der VM hinterlegt
# ============================================================
resource "exoscale_ssh_key" "deploy_key" {
  name       = "${var.project_name}-deploy-key"
  public_key = var.ssh_public_key
}

# ============================================================
# Template - Ubuntu 24.04 LTS als Basis-Image
# ============================================================
data "exoscale_template" "ubuntu" {
  zone = var.zone
  name = "Linux Ubuntu 24.04 LTS 64-bit"
}

# ============================================================
# Cloud-Init Template - Variablen in die Konfiguration einsetzen
# ============================================================
locals {
  # Cloud-Init YAML wird als Template verarbeitet
  # Terraform-Variablen werden dabei ersetzt
  user_data = templatefile("${path.module}/../cloudinit/cloud-init.yaml", {
    domain_name          = var.domain_name
    cloudflare_api_token = var.cloudflare_api_token
    cloudflare_zone_id   = var.cloudflare_zone_id
    letsencrypt_email    = var.letsencrypt_email
  })
}

# ============================================================
# Compute Instance - Die eigentliche VM
# ============================================================
resource "exoscale_compute_instance" "webserver" {
  name = "${var.project_name}-vm"
  zone = var.zone
  type = var.instance_type

  # Ubuntu 24.04 LTS Template
  template_id = data.exoscale_template.ubuntu.id

  # Netzwerk-Sicherheitsregeln anwenden
  security_group_ids = [exoscale_security_group.web_sg.id]

  # SSH Key fuer Zugriff registrieren
  ssh_keys = [exoscale_ssh_key.deploy_key.name]

  # Festplatten-Groesse
  disk_size = var.disk_size_gb

  # IPv6 Unterstuetzung aktivieren
  ipv6 = true

  # Cloud-Init Script fuer automatische Konfiguration beim ersten Boot
  user_data = local.user_data
}
