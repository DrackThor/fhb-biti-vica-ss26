# Aktuellstes passendes offizielles Ubuntu Image in der gewählten Zone suchen.
data "exoscale_template" "ubuntu" {
  zone = var.zone
  name = var.template_name
}

# Optionaler SSH Key: wird nur angelegt, wenn ssh_public_key nicht leer ist.
resource "exoscale_ssh_key" "admin" {
  count      = trimspace(var.ssh_public_key) != "" ? 1 : 0
  name       = "${var.instance_name}-admin-key"
  public_key = var.ssh_public_key
}

# Eigene Security Group für die Web-VM.
resource "exoscale_security_group" "web" {
  name        = "${var.instance_name}-sg"
  description = "Security Group für VM Details Website und API"
}

# HTTP öffentlich erlauben, damit die Seite unter IP/FQDN erreichbar ist.
resource "exoscale_security_group_rule" "http" {
  security_group_id = exoscale_security_group.web.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 80
  end_port          = 80
  description       = "Öffentlicher HTTP Zugriff"
}

# HTTPS öffentlich erlauben. Wird für den Bonus mit FQDN und Zertifikat benötigt.
resource "exoscale_security_group_rule" "https" {
  security_group_id = exoscale_security_group.web.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 443
  end_port          = 443
  description       = "Öffentlicher HTTPS Zugriff"
}

# SSH nur optional und nur aus einem explizit gesetzten CIDR erlauben.
resource "exoscale_security_group_rule" "ssh" {
  count             = trimspace(var.ssh_allowed_cidr) != "" ? 1 : 0
  security_group_id = exoscale_security_group.web.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = var.ssh_allowed_cidr
  start_port        = 22
  end_port          = 22
  description       = "Optionaler SSH Zugriff für Debugging"
}

# Die eigentliche Exoscale VM. Sämtliche OS-Konfiguration kommt aus Cloud-Init.
resource "exoscale_compute_instance" "vm_details" {
  zone     = var.zone
  name     = var.instance_name
  type     = var.instance_type
  disk_size = var.disk_size

  # Ubuntu Image aus der Data Source.
  template_id = data.exoscale_template.ubuntu.id

  # Security Group hängt die Firewall-Regeln an die VM.
  security_group_ids = [exoscale_security_group.web.id]

  # Optionaler SSH Key, wenn angegeben.
  ssh_keys = trimspace(var.ssh_public_key) != "" ? [exoscale_ssh_key.admin[0].name] : []

  # Cloud-Init installiert Nginx, generiert HTML/JSON und richtet HTTPS ein.
  user_data = local.cloud_init

  labels = {
    managed-by = "opentofu"
    project    = "fhb-biti-vica-ss26"
  }
}

# Optional vorhandene DNS Zone aus Exoscale DNS laden.
data "exoscale_domain" "selected" {
  count = local.dns_enabled ? 1 : 0
  name  = var.dns_domain
}

# Optionalen A-Record auf die öffentliche IPv4 der VM setzen.
resource "exoscale_domain_record" "vm" {
  count       = local.dns_enabled ? 1 : 0
  domain      = data.exoscale_domain.selected[0].id
  name        = var.dns_record_name
  record_type = "A"
  content     = exoscale_compute_instance.vm_details.public_ip_address
  ttl         = 300
}
