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

  cidr = "0.0.0.0/0"
}
