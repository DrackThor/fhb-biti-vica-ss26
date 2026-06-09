# =============================================================================
# main.tf – Exoscale Infrastruktur für das VM-Info-Dashboard
# Erstellt eine Ubuntu-VM mit HTTP(S)-Endpunkt für Systeminfos
# =============================================================================

terraform {
  required_providers {
    exoscale = {
      source  = "exoscale/exoscale"
      version = "~> 0.62"
    }
  }
  # State wird lokal im GitHub Actions Runner gespeichert.
  # Der Deploy-Workflow cached die terraform.tfstate Datei zwischen
  # den Runs, damit destroy die erstellten Ressourcen wieder findet.
}

# Provider-Konfiguration – Credentials kommen aus Umgebungsvariablen
# EXOSCALE_API_KEY und EXOSCALE_API_SECRET
provider "exoscale" {
  key    = var.exoscale_api_key
  secret = var.exoscale_api_secret
}

# ---------------------------------------------------------------------------
# SSH-Schlüsselpaar – öffentlicher Key wird auf die VM deployt
# ---------------------------------------------------------------------------
resource "exoscale_ssh_key" "vm_key" {
  name       = "vica-ss26-key"
  public_key = var.ssh_public_key
}

# ---------------------------------------------------------------------------
# Security Group – Firewall-Regeln für die VM
# ---------------------------------------------------------------------------
resource "exoscale_security_group" "vm_sg" {
  name        = "vica-ss26-sg"
  description = "Security Group fuer das VM-Info-Dashboard"
}

# SSH-Zugang (Port 22)
resource "exoscale_security_group_rule" "ssh" {
  security_group_id = exoscale_security_group.vm_sg.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 22
  end_port          = 22
}

# HTTP-Zugang (Port 80) – für Let's Encrypt ACME Challenge & Redirect
resource "exoscale_security_group_rule" "http" {
  security_group_id = exoscale_security_group.vm_sg.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 80
  end_port          = 80
}

# HTTPS-Zugang (Port 443) – verschlüsselter Endpunkt
resource "exoscale_security_group_rule" "https" {
  security_group_id = exoscale_security_group.vm_sg.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 443
  end_port          = 443
}

# ICMP – damit die VM per ping erreichbar ist
resource "exoscale_security_group_rule" "icmp" {
  security_group_id = exoscale_security_group.vm_sg.id
  type              = "INGRESS"
  protocol          = "ICMP"
  cidr              = "0.0.0.0/0"
  icmp_type         = 8
  icmp_code         = 0
}

# ---------------------------------------------------------------------------
# Compute Instance – Ubuntu VM
# ---------------------------------------------------------------------------
resource "exoscale_compute_instance" "vm" {
  zone = var.zone
  name = "vica-ss26-vm"

  # Ubuntu 24.04 LTS – wird über eine Variable oder Data Source gesetzt
  template_id = data.exoscale_template.ubuntu.id

  # Instanzgröße: 2 vCPU, 4 GB RAM
  type = "standard.medium"

  # 50 GB Root-Disk
  disk_size = 50

  # SSH-Key zuweisen
  ssh_key = exoscale_ssh_key.vm_key.name

  # Security Group zuweisen
  security_group_ids = [exoscale_security_group.vm_sg.id]

  # CloudInit User-Data – konfiguriert das System vollautomatisch
  user_data = file("${path.module}/../cloud-init/user-data.yaml")

  # Elastische IP (EIP) zuweisen, damit die VM eine feste öffentliche IP hat
  elastic_ip_ids = [exoscale_elastic_ip.vm_eip.id]
}

# ---------------------------------------------------------------------------
# Elastic IP – feste öffentliche IP-Adresse für die VM
# ---------------------------------------------------------------------------
resource "exoscale_elastic_ip" "vm_eip" {
  zone        = var.zone
  description = "EIP fuer das VM-Info-Dashboard"

  # Healthcheck – prüft ob der HTTPS-Endpunkt erreichbar ist
 healthcheck {
    mode         = "http"
    port         = 80
    uri          = "/api"
    interval     = 10
    timeout      = 3
    strikes_ok   = 2
    strikes_fail = 3
  }
}

# ---------------------------------------------------------------------------
# Data Source – aktuelles Ubuntu 24.04 LTS Template
# ---------------------------------------------------------------------------
data "exoscale_template" "ubuntu" {
  zone = var.zone
  name = "Linux Ubuntu 24.04 LTS 64-bit"
}
