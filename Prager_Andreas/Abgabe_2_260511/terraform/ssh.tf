# SSH-Schlüsselpaar muss vor Ausführung generiert werden
# Hier wird der öffentliche Schlüssel auf Exoscale hinterlegt
resource "exoscale_ssh_key" "main" {
  name       = "${var.namespace}-ssh-key"
  public_key = var.ssh_public_key
}
