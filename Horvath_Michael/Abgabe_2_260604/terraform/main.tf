# Terraform Konfiguration – welche Provider werden benötigt?
# Ein "Provider" ist quasi das Plugin das Terraform beibringt, mit Exoscale zu reden
terraform {
  required_providers {
    exoscale = {
      source  = "exoscale/exoscale"
      version = "~> 0.62"
    }
  }

  backend "s3" {
    bucket = "mhorvath-terraform-state"
    key    = "terraform.tfstate"
    region = "at-vie-1"

    endpoints = {
      s3 = "https://sos-at-vie-1.exo.io"
    }

    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    use_path_style              = true
  }
}

# Provider konfigurieren – API Keys kommen aus Umgebungsvariablen
# EXOSCALE_API_KEY und EXOSCALE_API_SECRET werden von GitHub Secrets gesetzt
# Wir schreiben sie NIE direkt in den Code!
provider "exoscale" {
  key    = var.exoscale_api_key
  secret = var.exoscale_api_secret
}

# Security Group = Firewall-Regeln für die VM
# Wir erlauben nur SSH (22), HTTP (80) und HTTPS (443)
resource "exoscale_security_group" "vm_sg" {
  name = "${var.vm_name}-sg"
}

resource "exoscale_security_group_rule" "ssh" {
  security_group_id = exoscale_security_group.vm_sg.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 22
  end_port          = 22
}

resource "exoscale_security_group_rule" "http" {
  security_group_id = exoscale_security_group.vm_sg.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 80
  end_port          = 80
}

resource "exoscale_security_group_rule" "https" {
  security_group_id = exoscale_security_group.vm_sg.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 443
  end_port          = 443
}

# Das Ubuntu Template suchen – wir suchen nach dem Namen aus variables.tf
data "exoscale_template" "ubuntu" {
  zone = var.exoscale_zone
  name = var.template_name
}

# Die eigentliche VM (in Exoscale: "Compute Instance")
resource "exoscale_compute_instance" "vm" {
  zone = var.exoscale_zone
  name = var.vm_name

  # Verknüpfung mit dem Template und dem Instance-Typ
template_id = data.exoscale_template.ubuntu.id
  type        = var.vm_type
  disk_size   = var.disk_size

  # Security Group zuweisen (unsere Firewall von oben)
  security_group_ids = [exoscale_security_group.vm_sg.id]

  # CloudInit – das Script das beim ersten Boot ausgeführt wird
  # templatefile() liest die Datei ein und ersetzt Variablen darin
  user_data = templatefile("${path.module}/cloud-init.yaml", {
    vm_name = var.vm_name
  })
}