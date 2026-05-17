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
  sg_rules = {
    "http-v4"  = { port = 80,  cidr = "0.0.0.0/0" }
    "https-v4" = { port = 443, cidr = "0.0.0.0/0" }
    "http-v6"  = { port = 80,  cidr = "::/0" }
    "https-v6" = { port = 443, cidr = "::/0" }
    "ssh-v4"   = { port = 22,  cidr = var.ssh_allowed_cidr }
  }
}

resource "exoscale_security_group" "sg" {
  name        = "sg-${var.vm_name}"
  description = "Allows HTTP, HTTPS, and SSH"
}

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
