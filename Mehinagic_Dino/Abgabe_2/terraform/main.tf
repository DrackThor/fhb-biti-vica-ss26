# 1. Security Group für HTTP/HTTPS erstellen
resource "exoscale_security_group" "web_sg" {
  name        = "web-server-sg"
  description = "Erlaubt HTTP und HTTPS Traffic"
}

resource "exoscale_security_group_rule" "http" {
  security_group_id = exoscale_security_group.web_sg.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 80
  end_port          = 80
}

resource "exoscale_security_group_rule" "https" {
  security_group_id = exoscale_security_group.web_sg.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 443
  end_port          = 443
}

# 2. Ubuntu Template suchen
data "exoscale_template" "ubuntu" {
  zone = var.zone
  name = "Linux Ubuntu 24.04 LTS 64-bit" # Oder 22.04 LTS
}

# 3. Compute Instanz mit Cloud-Init Verknüpfung
resource "exoscale_compute_instance" "web_vm" {
  name               = "fhb-sysinfo-vm"
  zone               = var.zone
  type               = "standard.micro" # Kostengünstig für die Übung
  template_id        = data.exoscale_template.ubuntu.id
  security_group_ids = [exoscale_security_group.web_sg.id]

  # Hier übergeben wir das Cloud-Init Skript
  user_data = file("${path.module}/../cloudinit/cloud-config.yaml")
}

# OPTIONAL: DNS Eintrag falls Domain vorhanden (für HTTPS Zusatzpunkte)
# resource "exoscale_domain_record" "web_dns" {
#   domain      = var.domain_name
#   name        = "sysinfo"
#   record_type = "A"
#   content     = exoscale_compute_instance.web_vm.public_ip_address
#   ttl         = 300
# }

output "vm_public_ip" {
  value       = exoscale_compute_instance.web_vm.public_ip_address
  description = "Die öffentliche IP der VM"
}