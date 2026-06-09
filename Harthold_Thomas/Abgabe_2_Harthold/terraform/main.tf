# Sucht das gewünschte Ubuntu-Template in der angegebenen Zone.
data "exoscale_template" "ubuntu" {
  zone = var.zone
  name = var.ubuntu_template_name
}

# Security Group für die VM.
resource "exoscale_security_group" "web" {
  # Eindeutiger Name verhindert Kollisionen mit anderen Abgaben.
  name = "${var.project_name}-web-sg"
}

# Erlaubt HTTP-Zugriffe von überall, damit die URL erreichbar ist.
resource "exoscale_security_group_rule" "http_in" {
  security_group_id = exoscale_security_group.web.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 80
  end_port          = 80
  description       = "Erlaubt HTTP Zugriffe"
}


# Erstellt die eigentliche VM und übergibt sämtliche OS-Konfiguration per Cloud-Init.
resource "exoscale_compute_instance" "vm" {
  zone        = var.zone
  name        = "${var.project_name}-vm"
  template_id = data.exoscale_template.ubuntu.id
  type        = var.instance_type
  disk_size   = var.disk_size

  # Die VM erhält eine öffentliche IPv4-Adresse; private=false ist der Default, hier explizit gesetzt.
  private = false

  # Nur die definierte Security Group wird an die VM gehängt.
  security_group_ids = [exoscale_security_group.web.id]

  # Alle Betriebssystemänderungen passieren über diese Cloud-Init-Datei.
  user_data = file("${path.module}/cloud-init.yaml")

  # Labels erleichtern das Auffinden und Aufräumen im Exoscale Portal.
  labels = {
    project = var.project_harthold
    owner   = "harthold"
    purpose = "fhb-biti-vica-ss26-abgabe-2"
  }
}
