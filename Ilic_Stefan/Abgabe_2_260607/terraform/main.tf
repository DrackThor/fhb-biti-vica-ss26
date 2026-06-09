# main.tf
# -----------------------------------------------------------------------------
# Kern: Ubuntu-Template, Security Group, DNS-Records, Compute-Instanz.
# Die Domains stehen schon beim Apply fest (aus Variablen) -> sie werden via
# templatefile direkt in cloud-init eingesetzt. Die VM muss ihre IP daher NICHT
# selbst ermitteln (anders als bei der sslip.io-Variante).
# -----------------------------------------------------------------------------

# Ubuntu-Template per Name nachschlagen.
data "exoscale_template" "ubuntu" {
  zone = var.zone
  name = var.template_name
}

# Vom Kurs bereitgestellte DNS-Zone abfragen.
data "exoscale_domain" "zone" {
  name = var.root_domain
}

# --- Security Group + Firewall-Regeln ---
resource "exoscale_security_group" "sg" {
  name        = "sg-${var.vm_name}"
  description = "Abgabe 2: SSH, HTTP, HTTPS"
}

# TCP-Regeln dynamisch aus einer Map (kein duplizierter Code).
locals {
  tcp_rules = {
    "ssh"   = { port = 22, cidr = var.ssh_allowed_cidr }
    "http"  = { port = 80, cidr = "0.0.0.0/0" }
    "https" = { port = 443, cidr = "0.0.0.0/0" }
  }
}

resource "exoscale_security_group_rule" "tcp" {
  for_each          = local.tcp_rules
  security_group_id = exoscale_security_group.sg.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = each.value.cidr
  start_port        = each.value.port
  end_port          = each.value.port
}

# Ping erlauben (nützlich zum Debuggen).
resource "exoscale_security_group_rule" "icmp" {
  security_group_id = exoscale_security_group.sg.id
  type              = "INGRESS"
  protocol          = "ICMP"
  cidr              = "0.0.0.0/0"
  icmp_type         = 8
  icmp_code         = 0
}

# Optionaler SSH-Key (nur wenn uebergeben).
resource "exoscale_ssh_key" "debug" {
  count      = var.ssh_public_key == "" ? 0 : 1
  name       = "${var.vm_name}-key"
  public_key = var.ssh_public_key
}

# --- Compute-Instanz ---
resource "exoscale_compute_instance" "vm" {
  zone               = var.zone
  name               = "vm-${var.vm_name}"
  template_id        = data.exoscale_template.ubuntu.id
  type               = var.instance_type
  disk_size          = var.disk_size
  security_group_ids = [exoscale_security_group.sg.id]
  ssh_key            = var.ssh_public_key == "" ? null : exoscale_ssh_key.debug[0].name

  # cloud-init mit den fertigen Domains rendern.
  user_data = templatefile("${path.module}/cloud-init.yaml", {
    website_domain = local.website_fqdn
    api_domain     = local.api_fqdn
    admin_email    = local.admin_email
    acme_ca        = var.acme_staging ? local.acme_staging : local.acme_production
  })
}

# --- DNS: A-Records fuer beide Subdomains auf die VM-IP zeigen lassen ---
resource "exoscale_domain_record" "records" {
  for_each    = local.dns_records
  domain      = data.exoscale_domain.zone.id
  name        = each.value
  record_type = "A"
  content     = exoscale_compute_instance.vm.public_ip_address
  ttl         = 60
}
