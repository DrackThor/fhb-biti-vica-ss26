# Security Group für die VM.
resource "exoscale_security_group" "vm_sg" {

  # Name der Security Group.
  name = "${var.instance_name}-sg"
}

# HTTP-Zugriff erlauben.
resource "exoscale_security_group_rule" "http_ingress" {

  # Zugehörige Security Group.
  security_group_id = exoscale_security_group.vm_sg.id

  # Eingehender Traffic.
  type = "INGRESS"

  # TCP Port 80.
  protocol   = "TCP"
  start_port = 80
  end_port   = 80

  # Zugriff aus dem gesamten Internet.
  cidr = "0.0.0.0/0"
}

# HTTPS-Zugriff erlauben.
resource "exoscale_security_group_rule" "https_ingress" {

  security_group_id = exoscale_security_group.vm_sg.id

  type = "INGRESS"

  protocol   = "TCP"
  start_port = 443
  end_port   = 443

  cidr = "0.0.0.0/0"
}

# SSH-Zugriff erlauben.
# Wird für Debugging und Administration benötigt.
resource "exoscale_security_group_rule" "ssh_ingress" {

  security_group_id = exoscale_security_group.vm_sg.id

  type = "INGRESS"

  protocol   = "TCP"
  start_port = 22
  end_port   = 22

# Exoscale VM erstellen.
resource "exoscale_compute_instance" "vm" {

  # Zone der VM.
  zone = var.zone

  # Name der VM.
  name = var.instance_name

  # Ubuntu Template.
  template = var.instance_template

  # VM-Größe.
  type = var.instance_type

  # Root-Disk-Größe.
  disk_size = 20

  # Öffentliche IP automatisch zuweisen.
  ipv6 = false

  # Security Group zuweisen.
  security_group_ids = [
    exoscale_security_group.vm_sg.id
  ]
}
  cidr = "0.0.0.0/0"
}
