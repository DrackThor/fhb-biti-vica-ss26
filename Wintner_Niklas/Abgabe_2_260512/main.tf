# Definiert die benötigten Provider. Hier wird der offizielle Exoscale Provider geladen.
terraform {
  required_providers {
    exoscale = {
      source = "exoscale/exoscale"
    }
  }
}

# Konfiguriert den Exoscale Provider mit den Zugangsdaten (API-Key und Secret).
# Die Werte werden zur Laufzeit über Variablen aus den GitHub Secrets übergeben.
provider "exoscale" {
  key    = var.exoscale_key
  secret = var.exoscale_secret
}

# Definition der Eingabevariablen für die Authentifizierung.
variable "exoscale_key" {}
variable "exoscale_secret" {}

# DYNAMISCHE SUCHE: Statt einer statischen ID sucht Terraform hier nach dem 
# aktuellsten Ubuntu 24.04 Image in der Zone Wien (at-vie-1). 
# Das erhöht die Stabilität, da sich Image-IDs bei Cloud-Anbietern häufig ändern.
data "exoscale_template" "ubuntu" {
  zone = "at-vie-1"
  name = "Linux Ubuntu 24.04 LTS 64-bit"
}

# Erstellung der Sicherheitsgruppe: Fungiert als virtuelle Firewall für die VM.
resource "exoscale_security_group" "vica_sg" {
  name = "vica-sg-wintner"
}

# Firewall Regel: Erlaubt eingehenden (INGRESS) TCP-Traffic auf Port 80 (HTTP).
# cidr = "0.0.0.0/0" bedeutet, dass der Zugriff von überall im Internet möglich ist.
resource "exoscale_security_group_rule" "http" {
  security_group_id = exoscale_security_group.vica_sg.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 80
  end_port          = 80
}

# Erstellung der Compute Instanz (VM):
# Hier werden die Hardware-Parameter (Typ, Disk) und die Zuweisung zur Zone definiert.
resource "exoscale_compute_instance" "my_vm" {
  name               = "vica-vm-wintner"
  zone               = "at-vie-1"
  type               = "standard.micro"
  
  # Verweist auf die dynamisch gefundene Template-ID aus dem data-Block oben.
  template_id        = data.exoscale_template.ubuntu.id
  disk_size          = 10
  
  # Verknüpft die VM mit der oben erstellten Sicherheitsgruppe.
  security_group_ids = [exoscale_security_group.vica_sg.id]
  
  # Übergibt das Cloud-Init Skript zur automatisierten Betriebssystem-Konfiguration.
  user_data          = file("cloud-init.yaml")
}

# OUTPUT: Gibt nach erfolgreichem Deployment die öffentliche IP-Adresse in der Konsole aus.
output "vm_public_ip" {
  value = exoscale_compute_instance.my_vm.public_ip_address
}
