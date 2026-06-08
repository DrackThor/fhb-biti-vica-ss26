data "exoscale_template" "ubuntu" {
  # Zone, in der nach dem Ubuntu Image gesucht wird
  zone = var.zone

  # Name des gewünschten Ubuntu Images
  name = var.ubuntu_template
}

locals {
  fqdn = "${var.dns_name}.${var.domain_name}"
}

resource "exoscale_compute_instance" "vm" {
  # Name der VM in Exoscale
  name = var.instance_name

  # Exoscale Zone
  zone = var.zone

  # VM-Größe
  type = var.instance_type

  # Größe der Systemdisk in GB
  disk_size = var.disk_size

  # Verwendetes Ubuntu Image
  template_id = data.exoscale_template.ubuntu.id

  # Security Group mit HTTP, HTTPS und SSH Regeln
  security_group_ids = [
    exoscale_security_group.web.id
  ]

  # Cloud-Init Datei für automatische Betriebssystem-Konfiguration, Python File und systemd service für Webserver
  user_data = templatefile("${path.module}/cloud-init.yaml", {
    server_py        = file("${path.module}/vm-info-server.py")
    systemd_service = file("${path.module}/vm-info-server.service")
    nginx_config = templatefile("${path.module}/vm-info-server-nginx.conf", {
    fqdn = local.fqdn
    })
    fqdn            = local.fqdn
    certbot_email   = var.certbot_email
  })
}