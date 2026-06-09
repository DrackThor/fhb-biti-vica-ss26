# Das Ubuntu-Image wird dynamisch gesucht, weil Template-IDs je Zone wechseln koennen.
data "exoscale_template" "ubuntu" {
  zone = var.zone
  name = var.template_name
}

locals {
  # DNS ist optional. Ohne Zone wird die IP-Adresse als URL verwendet.
  dns_enabled = trimspace(var.dns_zone) != ""

  # Vollstaendiger Hostname fuer die optionale DNS-Variante.
  fqdn = local.dns_enabled ? "${var.dns_record_name}.${var.dns_zone}" : ""

  # Caddy nutzt bei DNS den Hostnamen und holt automatisch ein Let's-Encrypt-Zertifikat.
  # Ohne DNS bindet Caddy nur plain HTTP auf Port 80.
  caddy_site_address = local.dns_enabled ? local.fqdn : ":80"

  # Ports fuer den oeffentlichen Web-Endpunkt und optionalen SSH-Zugang.
  ingress_rules = {
    http  = { port = 80, cidr = "0.0.0.0/0" }
    https = { port = 443, cidr = "0.0.0.0/0" }
    ssh   = { port = 22, cidr = var.ssh_cidr }
  }
}

# Optionaler SSH-Key fuer Debugging. Ohne Secret bleibt diese Ressource weg.
resource "exoscale_ssh_key" "student" {
  count      = trimspace(var.ssh_public_key) == "" ? 0 : 1
  name       = "${var.instance_name}-ssh"
  public_key = var.ssh_public_key
}

# Firewall/Security Group fuer Webzugriff und optionalen SSH-Zugriff.
resource "exoscale_security_group" "web" {
  name        = "${var.instance_name}-sg"
  description = "Abgabe 2: erlaubt HTTP, HTTPS und optional SSH zur VM-Info-Seite."
}

# Eine Regel pro Port haelt die Firewall nachvollziehbar und gut kommentierbar.
resource "exoscale_security_group_rule" "ingress" {
  for_each          = local.ingress_rules
  security_group_id = exoscale_security_group.web.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = each.value.cidr
  start_port        = each.value.port
  end_port          = each.value.port
  description       = "Erlaubt ${each.key} auf TCP/${each.value.port}."
}

# DNS-Zone nur lesen, wenn der Bonus mit FQDN aktiviert wurde.
data "exoscale_domain" "selected" {
  count = local.dns_enabled ? 1 : 0
  name  = var.dns_zone
}

# Die VM ist die zentrale Ressource: Ubuntu, kleine Disk, Security Group und CloudInit.
resource "exoscale_compute_instance" "vm" {
  zone        = var.zone
  name        = var.instance_name
  type        = var.instance_type
  disk_size   = var.disk_size
  template_id = data.exoscale_template.ubuntu.id

  # Der Key wird nur gesetzt, wenn auch wirklich einer erstellt wurde.
  ssh_key = trimspace(var.ssh_public_key) == "" ? null : exoscale_ssh_key.student[0].name

  # Die Security Group macht Port 80/443 von aussen erreichbar.
  security_group_ids = [exoscale_security_group.web.id]

  # CloudInit ist laut Aufgabenstellung fuer die gesamte OS-Konfiguration zustaendig.
  user_data = templatefile("${path.module}/cloud-init.yaml.tftpl", {
    app_py             = file("${path.module}/files/app.py")
    caddy_site_address = local.caddy_site_address
  })

  labels = {
    course = "fhb-biti-vica-ss26"
    task   = "abgabe-2"
    owner  = "raphael-wagner"
  }
}

# Optionaler A-Record. Er zeigt direkt auf die von Exoscale vergebene Public IP.
resource "exoscale_domain_record" "vminfo" {
  count       = local.dns_enabled ? 1 : 0
  domain      = data.exoscale_domain.selected[0].id
  name        = var.dns_record_name
  record_type = "A"
  content     = exoscale_compute_instance.vm.public_ip_address
  ttl         = 300
}
