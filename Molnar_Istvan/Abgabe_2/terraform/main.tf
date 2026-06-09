# =============================================================================
# main.tf – Exoscale Infrastruktur für VM-Info-Endpunkt
# =============================================================================
# Erstellt eine Ubuntu-VM auf Exoscale, die über CloudInit automatisch
# konfiguriert wird und technische Systeminformationen als HTTP-Endpunkt
# (HTML + JSON) bereitstellt.
# =============================================================================

terraform {
  required_version = ">= 1.3.0"

  required_providers {
    exoscale = {
      source  = "exoscale/exoscale"
      version = "~> 0.62"
    }
  }

  # Lokaler State – wird im GitHub Actions Runner gespeichert
  # (reicht für dieses Projekt, kein separates Backend nötig)
  backend "local" {}
}

# -----------------------------------------------------------------------------
# Provider-Konfiguration
# Credentials kommen aus GitHub Secrets (als TF_VAR_* Umgebungsvariablen):
#   EXOSCALE_API_KEY → TF_VAR_exoscale_api_key
#   EXOSCALE_API_SECRET → TF_VAR_exoscale_api_secret
# -----------------------------------------------------------------------------
provider "exoscale" {
  key    = var.exoscale_api_key
  secret = var.exoscale_api_secret
}

# -----------------------------------------------------------------------------
# Security Group: Firewall-Regeln für die VM
# Erlaubt HTTP (80), HTTPS (443) und ICMP (ping) von überall
# SSH wird NICHT geöffnet – kein SSH-Zugang nötig, CloudInit erledigt alles
# -----------------------------------------------------------------------------
resource "exoscale_security_group" "vm_info_sg" {
  name        = "${var.instance_name}-sg"
  description = "Security Group fuer VM-Info Web-Server"
}

resource "exoscale_security_group_rule" "http" {
  security_group_id = exoscale_security_group.vm_info_sg.id
  description       = "HTTP fuer Web-Server"
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 80
  end_port          = 80
}

resource "exoscale_security_group_rule" "https" {
  security_group_id = exoscale_security_group.vm_info_sg.id
  description       = "HTTPS fuer verschluesselten Web-Zugang"
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 443
  end_port          = 443
}

resource "exoscale_security_group_rule" "icmp" {
  security_group_id = exoscale_security_group.vm_info_sg.id
  description       = "ICMP fuer Erreichbarkeits-Tests (ping)"
  type              = "INGRESS"
  protocol          = "ICMP"
  cidr              = "0.0.0.0/0"
  icmp_code         = 0
  icmp_type         = 8
}

# -----------------------------------------------------------------------------
# CloudInit User-Data: konfiguriert das OS vollständig automatisiert
# templatefile() liest cloudinit.yaml und ersetzt die Variablen darin
# -----------------------------------------------------------------------------
locals {
  cloudinit = templatefile("${path.module}/cloudinit.yaml", {
    hostname    = var.instance_name
    domain      = var.domain_name
    admin_email = var.admin_email
  })
}

# -----------------------------------------------------------------------------
# Compute Instance: Ubuntu VM auf Exoscale
# Kein SSH Key nötig – CloudInit übernimmt die gesamte Konfiguration
# -----------------------------------------------------------------------------
resource "exoscale_compute_instance" "vm_info" {
  zone = var.zone

  # Ubuntu 24.04 LTS Template (offizielles Exoscale-Template)
  template_id = data.exoscale_template.ubuntu.id

  # Instanztyp: "standard.small" = 2 vCPU, 2 GB RAM
  type = var.instance_type

  name               = var.instance_name
  security_group_ids = [exoscale_security_group.vm_info_sg.id]

  # CloudInit User-Data: wird beim ersten Boot automatisch ausgeführt
  user_data = local.cloudinit

  disk_size = var.disk_size

  depends_on = [exoscale_security_group.vm_info_sg]
}

# -----------------------------------------------------------------------------
# Template-Lookup: sucht das offizielle Ubuntu 24.04 LTS Template
# -----------------------------------------------------------------------------
data "exoscale_template" "ubuntu" {
  zone   = var.zone
  name   = "Linux Ubuntu 24.04 LTS 64-bit"
  filter = "featured" # nur offizielle Exoscale-Templates
}
