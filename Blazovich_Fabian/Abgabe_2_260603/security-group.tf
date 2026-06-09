# Erstellt eine Security Group für die VM
resource "exoscale_security_group" "fblazovich_sec_group" {

  # Name der Security Group
  name = "fblazovich_sec_group"
}

# Firewall Regeln für SSH Zugriff
resource "exoscale_security_group_rule" "ssh" {

  # Verknüpft die Regeln mit der Security Group
  security_group_id = exoscale_security_group.fblazovich_sec_group.id

  # Eingehender Netzwerkverkehr
  type              = "INGRESS"

  # Verwendetes Protokoll
  protocol          = "TCP"

  # Erlaubt Zugriff von allen IP-Adressen
  cidr              = "0.0.0.0/0"

  # HTTP Port
  start_port        = 22
  end_port          = 22
}

# Firewall Regel für HTTP Zugriff
resource "exoscale_security_group_rule" "http" {

  # Verknüpft die Regel mit der Security Group
  security_group_id = exoscale_security_group.fblazovich_sec_group.id

  #Eingehender Netzwerkverkehr
  type              = "INGRESS"
  
  # Verwendetes Protokoll
  protocol          = "TCP"

  # Erlaubt Zugriff von allen IP-Adressen
  cidr              = "0.0.0.0/0"

  # HTTP Port
  start_port        = 80
  end_port          = 80
}