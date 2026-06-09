# Ubuntu 24.04 Template suchen
data "exoscale_template" "ubuntu" {
  zone = "at-vie-1"
  name = "Linux Ubuntu 24.04 LTS 64-bit"
}

# SSH-Key in Exoscale registrieren
resource "exoscale_ssh_key" "erik" {
  name       = "erik-hammermueller-key"
  public_key = var.ssh_public_key
}

# Security Group für Webserver
resource "exoscale_security_group" "web" {
  name = "erik-hammermueller-sg"
}

# SSH Zugriff erlauben
resource "exoscale_security_group_rule" "ssh" {
  security_group_id = exoscale_security_group.web.id

  type       = "INGRESS"
  protocol   = "TCP"
  start_port = 22
  end_port   = 22

  cidr = "0.0.0.0/0"
}

# HTTP Zugriff erlauben
resource "exoscale_security_group_rule" "http" {
  security_group_id = exoscale_security_group.web.id

  type       = "INGRESS"
  protocol   = "TCP"
  start_port = 80
  end_port   = 80

  cidr = "0.0.0.0/0"
}

# Virtuelle Maschine erstellen
resource "exoscale_compute_instance" "vm" {

  zone = "at-vie-1"

  name = "erik-hammermueller-vm"

  template_id = data.exoscale_template.ubuntu.id

  type = "standard.micro"

  disk_size = 10

  ssh_keys = [
    exoscale_ssh_key.erik.name
  ]

  security_group_ids = [
    exoscale_security_group.web.id
  ]

  user_data = file("${path.module}/cloud-init.yaml")
}