terraform {
  # Remote State, damit Create- und Destroy-Workflow denselben State verwenden.
  backend "s3" {
    bucket                      = "aposchinger-abgabe2-state"
    key                         = "abgabe-2/tofu.tfstate"
    region                      = "at-vie-1"
    endpoints                   = { s3 = "https://sos-at-vie-1.exo.io" }
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    use_path_style              = true
  }

  required_providers {
    exoscale = {
      source  = "exoscale/exoscale"
      version = "~> 0.62"
    }
  }
}

# Exoscale Provider. API Key und Secret kommen spaeter aus GitHub Secrets.
provider "exoscale" {}

# SSH-Key wird in Exoscale hinterlegt, damit Zugriff auf die VM moeglich ist.
resource "exoscale_ssh_key" "default" {
  name       = "${var.instance_name}-key"
  public_key = var.ssh_public_key
}

# Security Group fuer die VM.
resource "exoscale_security_group" "web" {
  name = "${var.instance_name}-sg"
}

# SSH Zugriff erlauben.
resource "exoscale_security_group_rule" "ssh" {
  security_group_id = exoscale_security_group.web.id
  type              = "INGRESS"
  protocol          = "TCP"
  start_port        = 22
  end_port          = 22
  cidr              = "0.0.0.0/0"
}

# HTTP Zugriff erlauben.
resource "exoscale_security_group_rule" "http" {
  security_group_id = exoscale_security_group.web.id
  type              = "INGRESS"
  protocol          = "TCP"
  start_port        = 80
  end_port          = 80
  cidr              = "0.0.0.0/0"
}

# Ubuntu Image suchen.
data "exoscale_template" "ubuntu" {
  zone = var.zone
  name = "Linux Ubuntu 22.04 LTS 64-bit"
}

# Virtuelle Maschine erstellen.
resource "exoscale_compute_instance" "vm" {
  zone               = var.zone
  name               = var.instance_name
  type               = var.instance_type
  template_id        = data.exoscale_template.ubuntu.id
  disk_size          = 10
  ssh_key            = exoscale_ssh_key.default.name
  security_group_ids = [exoscale_security_group.web.id]

  # CloudInit wird beim ersten Start der VM ausgefuehrt.
  user_data = file("${path.module}/cloud-init.yaml")
}