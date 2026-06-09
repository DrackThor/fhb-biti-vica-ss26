# Ubuntu Template suchen
data "exoscale_template" "ubuntu" {
  zone = var.zone
  name = var.instance_template
}

# Security Group erstellen (Firewall)
resource "exoscale_security_group" "sg" {
  name = "${var.instance_name}-sg"
}

# Port 80 öffnen (HTTP, wird auf HTTPS umgeleitet)
resource "exoscale_security_group_rule" "http" {
  security_group_id = exoscale_security_group.sg.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 80
  end_port          = 80
}

# Port 443 öffnen (HTTPS)
resource "exoscale_security_group_rule" "https" {
  security_group_id = exoscale_security_group.sg.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 443
  end_port          = 443
}

# Port 22 öffnen (SSH)
resource "exoscale_security_group_rule" "ssh" {
  security_group_id = exoscale_security_group.sg.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 22
  end_port          = 22
}

# VM erstellen
resource "exoscale_compute_instance" "vm" {
  zone        = var.zone
  name        = var.instance_name
  template_id = data.exoscale_template.ubuntu.id
  type        = var.instance_type
  disk_size   = 20

  security_group_ids = [
    exoscale_security_group.sg.id
  ]

  # Cloud-Init wird beim ersten Boot ausgeführt
  user_data = file("${path.module}/cloud-init.yaml")
}
