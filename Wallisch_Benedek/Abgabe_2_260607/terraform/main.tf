# Erstellt die Exoscale-VM fuer Abgabe 2.
# Die VM wird per CloudInit automatisch als Webserver/API konfiguriert.

locals {
  name = "wallisch-benedek-abgabe2-v3"
  zone = "at-vie-1"
}

data "exoscale_template" "ubuntu" {
  zone = local.zone
  name = "Linux Ubuntu 24.04 LTS 64-bit"
}

resource "exoscale_security_group" "web" {
  name        = "${local.name}-sg"
  description = "Security Group fuer HTTP, HTTPS und SSH"
}

resource "exoscale_security_group_rule" "ssh" {
  security_group_id = exoscale_security_group.web.id
  type              = "INGRESS"
  protocol          = "TCP"
  start_port        = 22
  end_port          = 22
  cidr              = "0.0.0.0/0"
}

resource "exoscale_security_group_rule" "http" {
  security_group_id = exoscale_security_group.web.id
  type              = "INGRESS"
  protocol          = "TCP"
  start_port        = 80
  end_port          = 80
  cidr              = "0.0.0.0/0"
}
resource "exoscale_security_group_rule" "app" {
  security_group_id = exoscale_security_group.web.id
  type              = "INGRESS"
  protocol          = "TCP"
  start_port        = 8080
  end_port          = 8080
  cidr              = "0.0.0.0/0"
}

resource "exoscale_security_group_rule" "https" {
  security_group_id = exoscale_security_group.web.id
  type              = "INGRESS"
  protocol          = "TCP"
  start_port        = 443
  end_port          = 443
  cidr              = "0.0.0.0/0"
}

resource "exoscale_compute_instance" "vm" {
  name               = local.name
  zone               = local.zone
  type               = "standard.small"
  template_id        = data.exoscale_template.ubuntu.id
  disk_size          = 20
  security_group_ids = [exoscale_security_group.web.id]

  user_data = templatefile("${path.module}/cloud-init.yaml.tftpl", {
    vm_name = local.name
    app_py  = indent(6, file("${path.module}/files/app.py"))
  })
}
