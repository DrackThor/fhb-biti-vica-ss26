# 1. Security Group erstellen
resource "exoscale_security_group" "web_sg" {
  name        = "web-and-ssh-sg"
  description = "Erlaubt SSH (22) und HTTP (80)"
}

# SSH Regel (Port 22)
resource "exoscale_security_group_rule" "ssh" {
  security_group_id = exoscale_security_group.web_sg.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 22
  end_port          = 22
}

# HTTP Regel (Port 80)
resource "exoscale_security_group_rule" "http" {
  security_group_id = exoscale_security_group.web_sg.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 80
  end_port          = 80
}

# 2. Ubuntu Template finden
data "exoscale_template" "ubuntu" {
  zone = var.zone
  name = "Linux Ubuntu 22.04 LTS 64-bit"
}

# 3. Die VM erstellen
resource "exoscale_compute_instance" "ubuntu_vm" {
  zone               = var.zone
  name               = "djov-server"
  template_id        = data.exoscale_template.ubuntu.id
  type               = var.instance_type
  disk_size          = 35
  security_group_ids = [exoscale_security_group.web_sg.id]
  user_data          = file("${path.module}/cloud-init.yaml")
}
