# main.tf
# Die eigentliche Infrastruktur: Ubuntu-VM + Firewall (Security Group) in Exoscale.

# ---------------------------------------------------------------------------
# Template-ID des gewuenschten Ubuntu-Images in der Zielzone ermitteln.
# (Template-IDs unterscheiden sich je Zone, daher dynamisch nachschlagen.)
# ---------------------------------------------------------------------------
data "exoscale_template" "ubuntu" {
  zone = var.zone
  name = var.template_name
}

# ---------------------------------------------------------------------------
# Optionaler SSH-Key: nur anlegen, wenn ein Public-Key uebergeben wurde.
# ---------------------------------------------------------------------------
resource "exoscale_ssh_key" "this" {
  count      = var.ssh_public_key == "" ? 0 : 1
  name       = "${var.instance_name}-key"
  public_key = var.ssh_public_key
}

# ---------------------------------------------------------------------------
# Security Group = Firewall der Instanz.
# ---------------------------------------------------------------------------
resource "exoscale_security_group" "web" {
  name        = "${var.instance_name}-sg"
  description = "Erlaubt SSH (22), HTTP (80) und HTTPS (443)."
}

locals {
  # Eingehende erlaubte Ports als Map (Name -> Port), kompakt per for_each.
  ingress_ports = {
    ssh   = 22
    http  = 80
    https = 443
  }
}

# Eine INGRESS-Regel je Port. Egress ist standardmaessig erlaubt.
resource "exoscale_security_group_rule" "ingress" {
  for_each          = local.ingress_ports
  security_group_id = exoscale_security_group.web.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0" # von ueberall erreichbar (oeffentlicher Endpunkt)
  start_port        = each.value
  end_port          = each.value
  description       = "Eingehend TCP/${each.value} (${each.key})"
}

# ---------------------------------------------------------------------------
# Die Compute-Instanz (VM).
# ---------------------------------------------------------------------------
resource "exoscale_compute_instance" "vm" {
  zone        = var.zone
  name        = var.instance_name
  type        = var.instance_type
  disk_size   = var.disk_size
  template_id = data.exoscale_template.ubuntu.id

  # SSH-Key nur referenzieren, wenn einer angelegt wurde.
  ssh_key = var.ssh_public_key == "" ? null : exoscale_ssh_key.this[0].name

  # Security Group zuordnen.
  security_group_ids = [exoscale_security_group.web.id]

  # CloudInit: gesamte OS-Konfiguration. Der Python-Dienst wird aus
  # files/server.py eingebettet und vom Template korrekt eingerueckt.
  user_data = templatefile("${path.module}/cloud-init.yaml.tftpl", {
    server_py = file("${path.module}/files/server.py")
  })
}
