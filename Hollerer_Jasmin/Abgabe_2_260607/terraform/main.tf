# =============================================================================
# main.tf – Exoscale Infrastruktur für BITI VICA Abgabe 2
# Erstellt eine Ubuntu VM mit nginx, die Systeminformationen als HTML und JSON
# unter zwei unterschiedlichen Endpunkten bereitstellt.
# =============================================================================

terraform {
  required_providers {
    exoscale = {
      # Offizieller Exoscale Terraform Provider
      source  = "exoscale/exoscale"
      version = "~> 0.59"
    }
  }
}

# Provider-Konfiguration – Credentials kommen aus GitHub Secrets (via Env-Variablen)
provider "exoscale" {
  key    = var.exoscale_api_key
  secret = var.exoscale_api_secret
}

# =============================================================================
# SSH Key Pair – wird für den initialen Zugriff auf die VM benötigt
# Der öffentliche Schlüssel wird als Variable übergeben (GitHub Secret)
# =============================================================================
resource "exoscale_ssh_key" "deploy_key" {
  name       = "vica-deploy-key"
  public_key = var.ssh_public_key
}

# =============================================================================
# Security Group – definiert Firewall-Regeln für die VM
# =============================================================================
resource "exoscale_security_group" "web" {
  name        = "vica-web-sg"
  description = "Erlaubt SSH, HTTP und HTTPS Zugriff"
}

# Regel: SSH (Port 22) – für Administration
resource "exoscale_security_group_rule" "ssh" {
  security_group_id = exoscale_security_group.web.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0" # In Produktion einschränken!
  start_port        = 22
  end_port          = 22
}

# Regel: HTTP (Port 80) – für den Web-Endpunkt
resource "exoscale_security_group_rule" "http" {
  security_group_id = exoscale_security_group.web.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 80
  end_port          = 80
}

# Regel: HTTPS (Port 443) – für TLS (Zusatzpunkte)
resource "exoscale_security_group_rule" "https" {
  security_group_id = exoscale_security_group.web.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 443
  end_port          = 443
}

# =============================================================================
# Compute Instance – die eigentliche VM
# =============================================================================
resource "exoscale_compute_instance" "web" {
  name               = "vica-sysinfo"
  zone               = "at-vie-1"                      # Rechenzentrum Wien
  template_id        = data.exoscale_template.ubuntu.id
  type               = "standard.small"                # 2 vCPU, 2 GB RAM
  disk_size          = 50                              # GB
  security_group_ids = [exoscale_security_group.web.id]
  ssh_key            = exoscale_ssh_key.deploy_key.name

  # CloudInit user_data – konfiguriert das OS vollautomatisch beim ersten Boot
  user_data = file("${path.module}/cloud-init.yaml")
}

# =============================================================================
# Data Source: Ubuntu 22.04 LTS Template suchen
# =============================================================================
data "exoscale_template" "ubuntu" {
  zone   = "at-vie-1"
  name   = "Linux Ubuntu 22.04 LTS 64-bit"
}
