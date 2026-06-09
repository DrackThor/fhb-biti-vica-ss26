# Outputs - Werte nach der Erstellung der Infrastruktur

# Oeffentliche IP-Adresse der VM
output "vm_public_ip" {
  description = "Oeffentliche IP-Adresse der VM"
  value       = exoscale_compute_instance.vm.public_ip_address
}

# URL fuer den HTTP-Zugriff
output "vm_http_url" {
  description = "HTTP-URL zum Zugriff auf die VM-Info Website"
  value       = "http://${exoscale_compute_instance.vm.public_ip_address}"
}

# URL fuer den HTTPS-Zugriff (wenn Domain konfiguriert)
output "vm_https_url" {
  description = "HTTPS-URL zum Zugriff auf die VM-Info Website"
  value       = var.domain_name != "" ? "https://${var.domain_name}" : "http://${exoscale_compute_instance.vm.public_ip_address}"
}

# API-Endpoint (JSON)
output "vm_api_url" {
  description = "API-Endpoint fuer VM-Informationen im JSON-Format"
  value       = var.domain_name != "" ? "https://${var.domain_name}/api/info.json" : "http://${exoscale_compute_instance.vm.public_ip_address}/api/info.json"
}

# SSH-Befehl fuer den Zugriff
output "ssh_command" {
  description = "SSH-Befehl fuer den Zugriff auf die VM"
  value       = "ssh ubuntu@${exoscale_compute_instance.vm.public_ip_address}"
}

# Domain (wenn konfiguriert)
output "domain" {
  description = "Konfigurierte Domain (falls vorhanden)"
  value       = var.domain_name != "" ? var.domain_name : "keine Domain konfiguriert"
}
