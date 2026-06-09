# 1. Datenquelle für das Ubuntu 22.04 LTS Template
data "exoscale_template" "ubuntu" {
  zone = var.zone
  name = "Linux Ubuntu 22.04 LTS 64-bit"
}

# 2. Sicherheitsgruppe (Firewall) definieren mit BRANDNEUEM Namen
resource "exoscale_security_group" "web_sg" {
  name = "vica-web-sg-v5"
  description = "Security Group fuer SSH und HTTP Webserver"
}

# 3. Firewall-Regel: Port 22 für SSH erlauben
resource "exoscale_security_group_rule" "ssh" {
  security_group_id = exoscale_security_group.web_sg.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 22
  end_port          = 22
}

# 4. Firewall-Regel: Port 80 für den Python-Webserver erlauben
resource "exoscale_security_group_rule" "http" {
  security_group_id = exoscale_security_group.web_sg.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 80
  end_port          = 80
}

# 5. Die virtuelle Compute-Instanz erstellen mit BRANDNEUEM Namen
resource "exoscale_compute_instance" "web_server" {
  zone = var.zone
  name = "vica-server-v5"
  type = "standard.medium"

  # Festplattengroeße in GB
  disk_size = 10

  # Nutzt die ID aus der Datenquelle
  template_id = data.exoscale_template.ubuntu.id

  # Zuweisung der Firewall
  security_group_ids = [exoscale_security_group.web_sg.id]

  # Übergabe der Cloud-Init-Konfigurationsdatei
  user_data = file("${path.module}/cloud-init.yaml")
}

# 6. Ausgabe der öffentlichen IP nach dem Deployment
output "vm_public_ip" {
  value       = exoscale_compute_instance.web_server.public_ip_address
  description = "Die oeffentliche IP-Adresse des Webservers"
}
