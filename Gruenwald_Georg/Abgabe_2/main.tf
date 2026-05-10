# --- Infrastructure Configuration ---

terraform {
  required_providers {
    exoscale = {
      source  = "exoscale/exoscale"
      version = "~> 0.69.0"
    }
  }
}

provider "exoscale" {
  key    = var.exoscale_api_key
  secret = var.exoscale_api_secret
}

# Find the latest Ubuntu 24.04 image
data "exoscale_template" "ubuntu" {
  zone = var.zone
  name = "Linux Ubuntu 24.04 LTS 64-bit"
}

# Firewall Rules
resource "exoscale_security_group" "sg" {
  name        = "monitoring-sg"
  description = "Allows HTTP, HTTPS, and SSH"
}

resource "exoscale_security_group_rule" "web" {
  for_each          = toset(["80", "443", "22"])
  security_group_id = exoscale_security_group.sg.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = each.key
  end_port          = each.key
}

# Compute Instance
resource "exoscale_compute_instance" "vm" {
  name               = "monitoring-node"
  zone               = var.zone
  template_id        = data.exoscale_template.ubuntu.id
  type               = "standard.micro"
  disk_size          = 20
  security_group_ids = [exoscale_security_group.sg.id]
  
  # Inject variables into cloud-init
  user_data = templatefile("${path.module}/cloud-init.yaml", {
    stats_domain = var.stats_domain
    api_domain   = var.api_domain
    admin_email  = var.admin_email
  })
}

# --- DNS Automation (TODO) ---

# This assumes the domain is already managed in Exoscale DNS
resource "exoscale_domain_record" "stats" {
  domain      = var.root_domain
  name        = split(".", var.stats_domain)[0]
  record_type = "A"
  content     = exoscale_compute_instance.vm.public_ip_address
}

resource "exoscale_domain_record" "api_docs" {
  domain      = var.root_domain
  name        = split(".", var.api_domain)[0]
  record_type = "A"
  content     = exoscale_compute_instance.vm.public_ip_address
}
