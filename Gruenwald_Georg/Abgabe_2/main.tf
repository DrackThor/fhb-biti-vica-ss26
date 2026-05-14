# --- Provider & Authentication ---
terraform {
  required_version = ">= 1.6.0"

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

# --- Data Sources ---
# Find the latest Ubuntu 26.04 image
data "exoscale_template" "ubuntu" {
  zone = var.zone
  name = "Linux Ubuntu 26.04 LTS 64-bit"
}

# Look up the existing university DNS zone (e.g., biti-fhb.org)
data "exoscale_domain" "university_zone" {
  name = var.root_domain
}

# --- Security & Network ---
resource "exoscale_security_group" "sg" {
  name        = "sg-${var.vm_name}"
  description = "Allows HTTP, HTTPS, and SSH"
}

# Defines one ingress rule per entry: HTTP/HTTPS for both IPv4 and IPv6, SSH restricted to var.ssh_allowed_cidr.
locals {
  sg_rules = {
    "http-v4"  = { port = 80,  cidr = "0.0.0.0/0" }
    "https-v4" = { port = 443, cidr = "0.0.0.0/0" }
    "http-v6"  = { port = 80,  cidr = "::/0" }
    "https-v6" = { port = 443, cidr = "::/0" }
    "ssh-v4"   = { port = 22,  cidr = var.ssh_allowed_cidr }
  }
}

# Iterates over sg_rules to create one security group rule per entry.
resource "exoscale_security_group_rule" "web" {
  for_each          = local.sg_rules
  security_group_id = exoscale_security_group.sg.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = each.value.cidr
  start_port        = each.value.port
  end_port          = each.value.port
}

# --- Compute Instance ---
resource "exoscale_compute_instance" "vm" {
  name               = "vm-${var.vm_name}"
  zone               = var.zone
  template_id        = data.exoscale_template.ubuntu.id
  type               = "standard.small"
  disk_size          = 50
  security_group_ids = [exoscale_security_group.sg.id]

  # Dynamically build the full domains and inject them into cloud-init
  user_data = templatefile("${path.module}/cloud-init.yml", {
    stats_domain = "${var.stats_prefix}.${var.second_level_domain}.${var.root_domain}"

    # Inject the OpenAPI spec dynamically
    openapi_spec = templatefile("${path.module}/openapi.yml", {
      stats_domain = "${var.stats_prefix}.${var.second_level_domain}.${var.root_domain}"
    })

    # Inject the Docker Compose file as a single string variable
    compose_config = templatefile("${path.module}/docker-compose.tftpl", {
      stats_domain = "${var.stats_prefix}.${var.second_level_domain}.${var.root_domain}"
    })
    
    # Inject the entire Caddyfile as a single string variable
    caddy_config = templatefile("${path.module}/caddyfile.tftpl", {
      admin_email  = "${var.second_level_domain}@${var.root_domain}"
      stats_domain = "${var.stats_prefix}.${var.second_level_domain}.${var.root_domain}"
      api_domain   = "${var.api_prefix}.${var.second_level_domain}.${var.root_domain}"
      acme_ca = var.acme_staging ? local.acme_staging : local.acme_production
    })
  })
}

# --- DNS Automation ---
# Creates the A-Record for stats.ggruenwald.biti-fhb.org
resource "exoscale_domain_record" "stats" {
  domain      = data.exoscale_domain.university_zone.id
  name        = "${var.stats_prefix}.${var.second_level_domain}"
  record_type = "A"
  content     = exoscale_compute_instance.vm.public_ip_address
  ttl         = 60
}

# Creates the A-Record for api.ggruenwald.biti-fhb.org
resource "exoscale_domain_record" "api" {
  domain      = data.exoscale_domain.university_zone.id
  name        = "${var.api_prefix}.${var.second_level_domain}"
  record_type = "A"
  content     = exoscale_compute_instance.vm.public_ip_address
  ttl         = 60
}

# --- Outputs ---
output "public_ip" {
  description = "The public IP of the monitoring server"
  value       = exoscale_compute_instance.vm.public_ip_address
}

output "stats_url" {
  description = "The direct URL for the Netdata Dashboard"
  value       = "https://${var.stats_prefix}.${var.second_level_domain}.${var.root_domain}"
}

output "api_url" {
  description = "The direct URL for the Swagger API UI"
  value       = "https://${var.api_prefix}.${var.second_level_domain}.${var.root_domain}"
}
