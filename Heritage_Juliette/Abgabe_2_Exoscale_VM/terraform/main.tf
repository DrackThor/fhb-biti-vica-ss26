# Ubuntu-Template anhand des Namens in der Exoscale-Zone suchen.
data "exoscale_template" "ubuntu" {
  zone = var.zone
  name = var.instance_template
}

# Security Group für die VM.
resource "exoscale_security_group" "vm_sg" {
  name = "${var.instance_name}-sg"
}

# HTTP-Zugriff erlauben.
resource "exoscale_security_group_rule" "http_ingress" {
  security_group_id = exoscale_security_group.vm_sg.id
  type              = "INGRESS"

  protocol   = "TCP"
  start_port = 80
  end_port   = 80

  cidr = "0.0.0.0/0"
}

# HTTPS-Zugriff erlauben.
resource "exoscale_security_group_rule" "https_ingress" {
  security_group_id = exoscale_security_group.vm_sg.id
  type              = "INGRESS"

  protocol   = "TCP"
  start_port = 443
  end_port   = 443

  cidr = "0.0.0.0/0"
}

# SSH-Zugriff erlauben.
resource "exoscale_security_group_rule" "ssh_ingress" {
  security_group_id = exoscale_security_group.vm_sg.id
  type              = "INGRESS"

  protocol   = "TCP"
  start_port = 22
  end_port   = 22

  cidr = "0.0.0.0/0"
}

# Exoscale VM erstellen.
resource "exoscale_compute_instance" "vm" {
  zone = var.zone
  name = var.instance_name

  template_id = data.exoscale_template.ubuntu.id
  type        = var.instance_type
  # Cloud-Init automatisch laden.
  user_data = file("${path.module}/cloud-init.yaml.tftpl")

  disk_size = 20
  ipv6      = false

  security_group_ids = [
    exoscale_security_group.vm_sg.id
  ]
}
