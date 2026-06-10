# Sucht die Image-ID zum Namen. data = nur lesen, legt nichts an.
data "exoscale_template" "ubuntu" {
  zone = var.zone
  name = "Linux Ubuntu 24.04 LTS 64-bit"
}

resource "exoscale_security_group" "web" {
  name        = "${var.instance_name}-sg"
  description = "Security Group fuer die Sysinfo-VM"
}

# Nur HTTP von ueberall rein - mehr braucht die Seite nicht.
resource "exoscale_security_group_rule" "http" {
  security_group_id = exoscale_security_group.web.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 80
  end_port          = 80
}

resource "exoscale_compute_instance" "vm" {
  zone        = var.zone
  name        = var.instance_name
  type        = "standard.small"
  disk_size   = 10
  template_id = data.exoscale_template.ubuntu.id

  security_group_ids = [exoscale_security_group.web.id]

  # Die gesamte OS-Konfiguration laeuft beim ersten Boot ueber cloud-init.yaml.
  user_data = file("${path.module}/cloud-init.yaml")
}