terraform {
  required_providers {
    exoscale = {
      source  = "exoscale/exoscale"
      version = "~> 0.59"
    }
  }
  backend "local" {}
}

# API credentials via environment variables:
# EXOSCALE_API_KEY and EXOSCALE_API_SECRET
provider "exoscale" {}

data "exoscale_template" "ubuntu" {
  zone = var.zone
  name = "Linux Ubuntu 24.04 LTS 64-bit"
}

resource "exoscale_security_group" "web" {
  name        = "blakaj-vminfo-sg"
  description = "Allow HTTP and SSH access"
}

resource "exoscale_security_group_rule" "http" {
  security_group_id = exoscale_security_group.web.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 80
  end_port          = 80
}

resource "exoscale_security_group_rule" "https" {
  security_group_id = exoscale_security_group.web.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 443
  end_port          = 443
}

resource "exoscale_security_group_rule" "ssh" {
  security_group_id = exoscale_security_group.web.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 22
  end_port          = 22
}

resource "exoscale_compute_instance" "vm" {
  name               = "blakaj-vminfo"
  zone               = var.zone
  template_id        = data.exoscale_template.ubuntu.id
  type               = var.instance_type
  disk_size          = var.disk_size
  security_group_ids = [exoscale_security_group.web.id]
  user_data          = file("${path.module}/cloud-init.yaml")
}
