resource "exoscale_compute_instance" "vm" {
  # Definition der Virtuellen Maschine
  name        = "${var.namespace}-vm"
  zone        = var.zone
  template_id = data.exoscale_template.ubuntu_template.id
  type        = var.instance_type
  disk_size   = var.vm_disk_size

  # Verknüpfe definierten SSH Key für Anmeldung auf der VM
  ssh_keys = [exoscale_ssh_key.main.name]

  # Verknüpfe definierte Security Groups für Web und SSH
  security_group_ids = [
    exoscale_security_group.web.id,
    exoscale_security_group.ssh.id
  ]

  # Owner wird als Label gesetzt
  labels = {
    "owner" = var.owner_name
  }

  # Übergabe von User Data an CloudInit auf Basis der Datei `cloudinit.yaml.tftpl`
  user_data = templatefile("${path.module}/cloudinit.yaml.tftpl", {
    namespace  = var.namespace
    nginx_conf = local.nginx_conf                    # NGINX Template Konfiguration
    app_py     = file("${path.module}/files/app.py") # Flask Web App

    # TLS Zertifikat
    cert_pem = acme_certificate.cert.certificate_pem
    key_pem  = acme_certificate.cert.private_key_pem
  })

  # Ignoriere Abweichungen zwischen State und Wirklichkeit bei der Definition von `user_data`
  lifecycle {
    ignore_changes = [user_data]
  }
}
