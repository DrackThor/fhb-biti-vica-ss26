# =====================================================================
# main.tf
# ---------------------------------------------------------------------
# Beschreibt die GESAMTE Exoscale-Infrastruktur als Code:
#   - den Provider (Verbindung zu Exoscale)
#   - eine Firewall (Security Group + Regeln)
#   - optional einen SSH-Key
#   - die eigentliche Ubuntu-VM mit CloudInit
# =====================================================================

terraform {
  required_version = ">= 1.6"

  required_providers {
    exoscale = {
      source  = "exoscale/exoscale"
      version = ">= 0.62"
    }
  }
}

# Exoscale-Provider mit den API-Zugangsdaten konfigurieren.
# Die Werte kommen aus Variablen (niemals im Code hartkodieren!).
provider "exoscale" {
  key    = var.exoscale_api_key
  secret = var.exoscale_api_secret
}

# Passendes Ubuntu-Image in der gewaehlten Zone nachschlagen.
# Wir holen uns nur die ID des fertigen Templates.
data "exoscale_template" "ubuntu" {
  zone = var.zone
  name = var.template_name
}

# ---------------------------------------------------------------------
# Firewall: eine Security Group mit drei eingehenden Regeln
# ---------------------------------------------------------------------
resource "exoscale_security_group" "web" {
  name = "vminfo-sg"
}

# HTTP (Port 80) von ueberall erlauben -> fuer die Website
resource "exoscale_security_group_rule" "http" {
  security_group_id = exoscale_security_group.web.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 80
  end_port          = 80
}

# HTTPS (Port 443) von ueberall erlauben -> fuer den HTTPS-Bonus
resource "exoscale_security_group_rule" "https" {
  security_group_id = exoscale_security_group.web.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 443
  end_port          = 443
}

# SSH (Port 22) von ueberall erlauben -> optional, zum Debuggen
resource "exoscale_security_group_rule" "ssh" {
  security_group_id = exoscale_security_group.web.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 22
  end_port          = 22
}

# ---------------------------------------------------------------------
# SSH-Key (optional): wird nur angelegt, wenn ein Public Key gesetzt ist.
# count = 0 bedeutet "Ressource nicht erstellen".
# ---------------------------------------------------------------------
resource "exoscale_ssh_key" "this" {
  count      = var.ssh_public_key == "" ? 0 : 1
  name       = "vminfo-key"
  public_key = var.ssh_public_key
}

# ---------------------------------------------------------------------
# Die eigentliche VM
# ---------------------------------------------------------------------
resource "exoscale_compute_instance" "vm" {
  zone        = var.zone
  name        = "vm-Dirry"
  template_id = data.exoscale_template.ubuntu.id
  type        = var.instance_type
  disk_size   = 10

  # unsere Firewall-Regeln zuweisen
  security_group_ids = [exoscale_security_group.web.id]

  # SSH-Key zuweisen, falls vorhanden (sonst null = keiner)
  ssh_key = var.ssh_public_key == "" ? null : exoscale_ssh_key.this[0].name

  # CloudInit: Die Vorlage wird gerendert; dabei wird der Inhalt von
  # generate.py in das YAML hineinkopiert.
  user_data = templatefile("${path.module}/cloud-init.yaml.tftpl", {
    generate_py_b64 = base64encode(file("${path.module}/generate.py"))
  })
}
