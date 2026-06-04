# =============================================================================
# main.tf Ã¢ÂÂ Exoscale VM Infrastruktur fÃÂ¼r BITI VICA SS26 Abgabe 2
# Erstellt eine Ubuntu VM mit Elastic IP, Security Group und SSH Key
# =============================================================================

terraform {
  required_providers {
    exoscale = {
      source  = "exoscale/exoscale"
      version = "~> 0.59"
    }
  }

  # Terraform State wird in GitHub Actions als Artifact gespeichert.
  # FÃÂ¼r produktive Umgebungen: Remote Backend (S3/Exoscale Object Storage) verwenden.
  required_version = ">= 1.3.0"
}

# Provider-Konfiguration: Zugangsdaten kommen aus Umgebungsvariablen
# EXOSCALE_API_KEY und EXOSCALE_API_SECRET (via GitHub Secrets)
provider "exoscale" {
  key    = var.exoscale_api_key
  secret = var.exoscale_api_secret
}

# -----------------------------------------------------------------------------
# SSH Key Pair Ã¢ÂÂ wird fÃÂ¼r den Zugriff auf die VM benÃÂ¶tigt
# Der ÃÂ¶ffentliche SchlÃÂ¼ssel wird via Variable ÃÂ¼bergeben (GitHub Secret)
# -----------------------------------------------------------------------------
resource "exoscale_ssh_key" "vm_key" {
  name       = "${var.project_name}-key"
  public_key = var.ssh_public_key
}

# -----------------------------------------------------------------------------
# Security Group Ã¢ÂÂ definiert erlaubte eingehende Verbindungen
# -----------------------------------------------------------------------------
resource "exoscale_security_group" "vm_sg" {
  name        = "${var.project_name}-sg"
  description = "Security Group fuer BITI VICA Abgabe 2 VM"
}

# SSH-Zugriff (Port 22) Ã¢ÂÂ fÃÂ¼r Wartung und Debugging
resource "exoscale_security_group_rule" "ssh" {
  security_group_id = exoscale_security_group.vm_sg.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 22
  end_port          = 22
}

# HTTP (Port 80) Ã¢ÂÂ fÃÂ¼r Let's Encrypt Zertifikat-Validierung und HTTPÃ¢ÂÂHTTPS Redirect
resource "exoscale_security_group_rule" "http" {
  security_group_id = exoscale_security_group.vm_sg.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 80
  end_port          = 80
}

# HTTPS (Port 443) Ã¢ÂÂ Hauptendpunkt der Anwendung
resource "exoscale_security_group_rule" "https" {
  security_group_id = exoscale_security_group.vm_sg.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 443
  end_port          = 443
}

# ICMP (Ping) Ã¢ÂÂ fÃÂ¼r Netzwerk-Debugging
resource "exoscale_security_group_rule" "icmp" {
  security_group_id = exoscale_security_group.vm_sg.id
  type              = "INGRESS"
  protocol          = "ICMP"
  cidr              = "0.0.0.0/0"
  icmp_type         = 8
  icmp_code         = 0
}

# -----------------------------------------------------------------------------
# Elastic IP Ã¢ÂÂ statische ÃÂ¶ffentliche IP-Adresse
# Bleibt konstant, auch wenn die VM neugestartet wird
# -----------------------------------------------------------------------------
resource "exoscale_elastic_ip" "vm_eip" {
  zone        = var.zone
  description = "Elastic IP fuer ${var.project_name}"

  # Healthcheck: Exoscale prÃÂ¼ft ob die VM erreichbar ist
  healthcheck {
    mode            = "https"
    port            = 443
    uri             = "/api/health"
    interval        = 10
    timeout         = 5
    strikes_ok      = 2
    strikes_fail    = 3
    tls_skip_verify = true
  }
}

# -----------------------------------------------------------------------------
# Compute Instance (VM) Ã¢ÂÂ Ubuntu mit CloudInit Konfiguration
# -----------------------------------------------------------------------------
resource "exoscale_compute_instance" "vm" {
  zone = var.zone
  name = var.project_name

  # Ubuntu 24.04 LTS Ã¢ÂÂ Long Term Support, 5 Jahre Sicherheitsupdates
  template_id = data.exoscale_template.ubuntu.id

  # InstanzgrÃÂ¶ÃÂe: small = 2 vCPU, 2GB RAM Ã¢ÂÂ ausreichend fÃÂ¼r dieses Projekt
  type = var.instance_type

  disk_size = var.disk_size

  # SSH Key fÃÂ¼r Zugriff
  ssh_keys = [exoscale_ssh_key.vm_key.name]

  # Security Group
  security_group_ids = [exoscale_security_group.vm_sg.id]

  # Elastic IP der VM zuweisen
  elastic_ip_ids = [exoscale_elastic_ip.vm_eip.id]

  # CloudInit User-Data: Konfiguriert das Betriebssystem automatisch beim ersten Start.
  # templatefile() liest die YAML-Datei und ersetzt Variablen (${domain}, ${email})
  user_data = templatefile("${path.module}/../cloud-init/cloud-init.yaml", {
    domain = var.domain
    email  = var.letsencrypt_email
    eip    = exoscale_elastic_ip.vm_eip.ip_address
  })

  # Sicherstellen, dass EIP und Security Group existieren bevor die VM erstellt wird
  depends_on = [
    exoscale_elastic_ip.vm_eip,
    exoscale_security_group.vm_sg,
    exoscale_ssh_key.vm_key,
  ]
}

# -----------------------------------------------------------------------------
# Data Source: Aktuelles Ubuntu 24.04 LTS Template von Exoscale
# -----------------------------------------------------------------------------
data "exoscale_template" "ubuntu" {
  zone   = var.zone
  name   = "Linux Ubuntu 24.04 LTS 64-bit"
  visibility = "public" # Nur offizielle Exoscale Templates
}
