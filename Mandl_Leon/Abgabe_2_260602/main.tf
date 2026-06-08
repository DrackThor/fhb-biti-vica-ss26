# --- Provider ---
terraform {
  required_version = ">= 1.6.0"

  required_providers {
    exoscale = {
      source  = "exoscale/exoscale"
      version = "~> 0.69.0"
    }
  }
}

# Exoscale Zugangsdaten kommen aus GitHub Secrets.
provider "exoscale" {
  key    = var.exoscale_api_key
  secret = var.exoscale_api_secret
}

# Ubuntu Image suchen.
data "exoscale_template" "ubuntu" {
  zone = var.zone
  name = var.template_name
}

# Security Group für HTTP.
resource "exoscale_security_group" "web" {
  name        = "sg-${var.vm_name}"
  description = "Allow HTTP access"
}

# Port 80 freigeben.
resource "exoscale_security_group_rule" "http" {
  security_group_id = exoscale_security_group.web.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 80
  end_port          = 80
}

# VM erstellen.
resource "exoscale_compute_instance" "vm" {
  name               = "vm-${var.vm_name}"
  zone               = var.zone
  template_id        = data.exoscale_template.ubuntu.id
  type               = var.instance_type
  disk_size          = var.disk_size
  security_group_ids = [exoscale_security_group.web.id]

  # CloudInit richtet Nginx und die Info-Seite ein.
  user_data = file("${path.module}/cloud-init.yaml")
}
