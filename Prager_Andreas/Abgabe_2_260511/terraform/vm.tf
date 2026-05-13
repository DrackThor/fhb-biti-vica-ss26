resource "exoscale_compute_instance" "vm" {
  name        = "prager-vica-vm"
  zone        = var.zone
  template_id = data.exoscale_template.ubuntu_template.id
  type        = var.instance_type
  disk_size   = 10

  ssh_keys       = [exoscale_ssh_key.main.name]
  elastic_ip_ids = [exoscale_elastic_ip.my_elastic_ip.id]

  security_group_ids = [
    exoscale_security_group.web.id,
    exoscale_security_group.ssh.id
  ]

  labels = {
    "owner" = "Andreas Prager"
  }

  # CloudInit bootstrap
  user_data = file("${path.module}/cloudinit.yaml")
}

