# Security Group für Firewall-Regeln
resource "exoscale_security_group" "just_web_sg" {
  name        = "web-sg"
  description = "Erlaubt SSH, HTTP und HTTPS"
}

# Regel für SSH (Port 22)
resource "exoscale_security_group_rule" "ssh" {
  security_group_id = exoscale_security_group.just_web_sg.id
  type              = "INGRESS"      # Eingehender Traffic
  protocol          = "TCP"
  start_port        = 22
  end_port          = 22
  cidr              = "0.0.0.0/0"    # Von überall erreichbar
}

# Regel für HTTP (Port 80)
resource "exoscale_security_group_rule" "http" {
  security_group_id = exoscale_security_group.just_web_sg.id
  type              = "INGRESS"
  protocol          = "TCP"
  start_port        = 80
  end_port          = 80
  cidr              = "0.0.0.0/0"
}

# Regel für HTTPS (Port 443)
resource "exoscale_security_group_rule" "https" {
  security_group_id = exoscale_security_group.just_web_sg.id
  type              = "INGRESS"
  protocol          = "TCP"
  start_port        = 443
  end_port          = 443
  cidr              = "0.0.0.0/0"
}

# Das Ubuntu Template
data "exoscale_template" "ubuntu" {
  zone = var.zone
  name = "Linux Ubuntu 26.04 LTS 64-bit"
}

# Die VM
resource "exoscale_compute_instance" "just_web_vm" {
  zone        = var.zone
  name        = "just_info-vm"
  template_id = data.exoscale_template.ubuntu.id
  type        = "standard.micro"
  disk_size   = 10

  # SSH Key aus variables
  ssh_keys = [var.vica-ss26-key]

  # Security Group zuweisen
  security_group_ids = [exoscale_security_group.just_web_sg.id]

  # CloudInit Script
  user_data = templatefile("${path.module}/cloud-init.yaml", {
    fqdn  = "just.biti-fhb.org"
    email = "2410640012@hochschule-burgenland.at"
  })
}

# Bestehende Domain verwenden
data "exoscale_domain" "biti_fhb" {
  name = "biti-fhb.org"
}

# A-Record für DNS
resource "exoscale_domain_record" "dns_record" {
  domain      = data.exoscale_domain.biti_fhb.id
  name        = "just"
  record_type = "A"
  content     = exoscale_compute_instance.just_web_vm.public_ip_address
  ttl         = 300
}