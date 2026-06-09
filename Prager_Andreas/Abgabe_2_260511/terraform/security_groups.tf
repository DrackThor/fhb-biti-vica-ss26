# Definition der Security Groups zur Kontrolle des Traffics
resource "exoscale_security_group" "web" {
  name = "${var.namespace}-sg-web"
}

resource "exoscale_security_group" "ssh" {
  name = "${var.namespace}-sg-ssh"
}

# HTTP (port 80)
resource "exoscale_security_group_rule" "http" {
  security_group_id = exoscale_security_group.web.id
  type              = "INGRESS"
  protocol          = "TCP"
  start_port        = 80
  end_port          = 80
  cidr              = "0.0.0.0/0"
}

# HTTPS (port 443)
resource "exoscale_security_group_rule" "https" {
  security_group_id = exoscale_security_group.web.id
  type              = "INGRESS"
  protocol          = "TCP"
  start_port        = 443
  end_port          = 443
  cidr              = "0.0.0.0/0"
}

# SSH (port 22)
resource "exoscale_security_group_rule" "ssh" {
  security_group_id = exoscale_security_group.ssh.id
  type              = "INGRESS"
  protocol          = "TCP"
  start_port        = 22
  end_port          = 22
  cidr              = "0.0.0.0/0"
}
