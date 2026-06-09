resource "exoscale_security_group" "web" {
  # Name der Security Group in Exoscale
  name = "${var.instance_name}-sg"

  # Beschreibung, damit in Exoscale klar ist, wofür diese Security Group verwendet wird
  description = "Security group for ubuntu webserver"
}

resource "exoscale_security_group_rule" "ssh" {
  # Verknüpft die Regel mit der oben erstellten Security Group
  security_group_id = exoscale_security_group.web.id

  # SSH verwendet TCP
  type     = "INGRESS"
  protocol = "TCP"

  # Port 22 für SSH-Zugriff
  start_port = 22
  end_port   = 22

  # Erlaubt Zugriff von überall
  cidr = "0.0.0.0/0"
}

resource "exoscale_security_group_rule" "http" {
  # Verknüpft die Regel mit der Security Group
  security_group_id = exoscale_security_group.web.id

  # HTTP verwendet TCP
  type     = "INGRESS"
  protocol = "TCP"

  # Port 80 für HTTP
  start_port = 80
  end_port   = 80

  # Erlaubt HTTP-Zugriff von überall
  cidr = "0.0.0.0/0"
}

resource "exoscale_security_group_rule" "https" {
  # Verknüpft die Regel mit der Security Group
  security_group_id = exoscale_security_group.web.id

  # HTTPS verwendet TCP
  type     = "INGRESS"
  protocol = "TCP"

  # Port 443 für HTTPS
  start_port = 443
  end_port   = 443

  # Erlaubt HTTPS-Zugriff von überall
  cidr = "0.0.0.0/0"
}