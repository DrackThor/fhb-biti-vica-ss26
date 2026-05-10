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

# --- DNS Automation ---

# Look up the zone dynamically using the root variable
data "exoscale_domain" "university_zone" {
  name = var.root_domain
}

# Create the Stats Subdomain
resource "exoscale_domain_record" "stats_subdomain" {
  domain      = data.exoscale_domain.university_zone.id
  
  # Strips the root domain out (e.g., leaves "stats.ggruenwald")
  name        = replace(var.stats_domain, ".${var.root_domain}", "")
  record_type = "A"
  content     = exoscale_compute_instance.vm.public_ip_address
  ttl         = 3600
}

# Create the API Subdomain
resource "exoscale_domain_record" "api_subdomain" {
  domain      = data.exoscale_domain.university_zone.id
  
  # Strips the root domain out (e.g., leaves "api.ggruenwald")
  name        = replace(var.api_domain, ".${var.root_domain}", "")
  record_type = "A"
  content     = exoscale_compute_instance.vm.public_ip_address
  ttl         = 3600
}
