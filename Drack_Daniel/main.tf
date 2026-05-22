data "exoscale_template" "ubuntu" {
  zone = var.exoscale_zone
  name = "Linux Ubuntu 22.04 LTS 64-bit"
}

resource "exoscale_security_group" "sg" {
  zone = var.exoscale_zone
  name = "${var.instance_name}-sg"
  description = "Allow HTTP and SSH"
}

resource "exoscale_security_group_rule" "ssh" {
  security_group_id = exoscale_security_group.sg.id
  direction         = "ingress"
  ip_protocol       = "tcp"
  port              = "22"
  cidr_list         = ["0.0.0.0/0"]
}

resource "exoscale_security_group_rule" "http" {
  security_group_id = exoscale_security_group.sg.id
  direction         = "ingress"
  ip_protocol       = "tcp"
  port              = "80"
  cidr_list         = ["0.0.0.0/0"]
}

resource "exoscale_compute_instance" "vm" {
  zone        = var.exoscale_zone
  name        = var.instance_name
  template_id = data.exoscale_template.ubuntu.id
  type        = var.instance_type
  disk_size   = var.disk_size_gb
  user_data   = file(var.cloudinit_file)
  security_group_ids = [exoscale_security_group.sg.id]
  # optional: keypair_name = var.ssh_key_name
}

resource "exoscale_floating_ip" "fip" {
  zone = var.exoscale_zone
}

resource "exoscale_floating_ip_association" "assoc" {
  instance_id     = exoscale_compute_instance.vm.id
  floating_ip_id  = exoscale_floating_ip.fip.id
}

output "endpoint_ip" {
  description = "IP-Adresse des HTTP Endpoints (Floating IP)"
  value       = exoscale_floating_ip.fip.ip_address
}

output "instance_id" {
  value = exoscale_compute_instance.vm.id
}
