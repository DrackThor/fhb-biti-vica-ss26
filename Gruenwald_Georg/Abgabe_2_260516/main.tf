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
data "exoscale_template" "ubuntu" {
  zone = var.zone
  name = "Linux Ubuntu 26.04 LTS 64-bit"
}

data "exoscale_domain" "university_zone" {
  name = var.root_domain
}

# --- Security & Network ---
# Resource-specific locals defined right where they are used for maximum readability
locals {
  # TCP Rules (Requires Ports)
  sg_rules = {
    "http-v4"  = { port = 80,  cidr = "0.0.0.0/0" }
    "https-v4" = { port = 443, cidr = "0.0.0.0/0" }
    "http-v6"  = { port = 80,  cidr = "::/0" }
    "https-v6" = { port = 443, cidr = "::/0" }
    "ssh-v4"   = { port = 22,  cidr = var.ssh_allowed_cidr }
  }

  # ICMP Rules (No Ports)
  icmp_rules = {
    "ping-v4" = { protocol = "ICMP",   cidr = "0.0.0.0/0", type = 8,   code = 0 }
    "ping-v6" = { protocol = "ICMPv6", cidr = "::/0",      type = 128, code = 0 }
  }
}

resource "exoscale_security_group" "sg" {
  name        = "sg-${var.vm_name}"
  description = "Allows HTTP, HTTPS, and SSH"
}

# Dynamically provisions all ingress rules from the local map 
# to eliminate duplicate resource blocks.
# --- TCP Loop ---
resource "exoscale_security_group_rule" "web" {
  for_each          = local.sg_rules
  security_group_id = exoscale_security_group.sg.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = each.value.cidr
  start_port        = each.value.port
  end_port          = each.value.port
}

# --- ICMP Loop ---
resource "exoscale_security_group_rule" "ping" {
  for_each          = local.icmp_rules
  security_group_id = exoscale_security_group.sg.id
  type              = "INGRESS"
  protocol          = each.value.protocol
  cidr              = each.value.cidr
  icmp_type         = each.value.type
  icmp_code         = each.value.code
}

# --- Compute Instance ---
resource "exoscale_compute_instance" "vm" {
  name               = "vm-${var.vm_name}"
  zone               = var.zone
  template_id        = data.exoscale_template.ubuntu.id
  type               = "standard.small"
  disk_size          = 50
  security_group_ids = [exoscale_security_group.sg.id]

  # Injecting pre-rendered configuration files (Caddy, Docker, OpenAPI) directly 
  # into the cloud-init YAML to avoid writing complex file-creation bash scripts.
  user_data = templatefile("${path.module}/cloud-init.yml", {
    openapi_spec = templatefile("${path.module}/openapi.tftpl", {
      stats_domain = local.stats_fqdn
    })

    compose_config = templatefile("${path.module}/docker-compose.tftpl", {
      stats_domain = local.stats_fqdn
    })
    
    caddy_config = templatefile("${path.module}/caddyfile.tftpl", {
      admin_email  = local.admin_email
      stats_domain = local.stats_fqdn
      api_domain   = local.api_fqdn
      acme_ca      = var.acme_staging ? local.acme_staging : local.acme_production
    })
  })
}

# --- DNS Automation ---
# Dynamically create all required A-Records from the locals.tf subdomains set
resource "exoscale_domain_record" "subdomains" {
  for_each    = local.subdomains
  
  domain      = data.exoscale_domain.university_zone.id
  name        = each.value
  record_type = "A"
  content     = exoscale_compute_instance.vm.public_ip_address
  ttl         = 60
}
