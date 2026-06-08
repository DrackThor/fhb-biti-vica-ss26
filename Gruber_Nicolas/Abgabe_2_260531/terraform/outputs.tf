# Ausgabe-Werte nach erfolgreichem Deployment
# Diese Werte werden im GitHub Actions Log angezeigt

# IP-Adresse der VM
output "vm_ip_address" {
  description = "Oeffentliche IPv4 Adresse der VM"
  value       = exoscale_compute_instance.webserver.public_ip_address
}

# Website URL (HTTP oder HTTPS je nach Konfiguration)
output "website_url" {
  description = "URL zur VM-Info Website"
  value       = var.domain_name != "" ? "https://${var.domain_name}" : "http://${exoscale_compute_instance.webserver.public_ip_address}"
}

# JSON API Endpoint
output "api_endpoint" {
  description = "URL zum JSON API Endpoint"
  value       = var.domain_name != "" ? "https://${var.domain_name}/api/info.json" : "http://${exoscale_compute_instance.webserver.public_ip_address}/api/info.json"
}

# SSH Verbindungsbefehl
output "ssh_connection" {
  description = "Befehl fuer SSH-Verbindung zur VM"
  value       = "ssh ubuntu@${exoscale_compute_instance.webserver.public_ip_address}"
}

# Konfigurierte Domain (oder Hinweis)
output "configured_domain" {
  description = "Verwendete Domain fuer HTTPS"
  value       = var.domain_name != "" ? var.domain_name : "(keine Domain - nur HTTP)"
}
