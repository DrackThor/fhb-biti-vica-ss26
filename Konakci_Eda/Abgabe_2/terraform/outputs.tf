# Öffentliche IP der VM als Output für Tests und Bewertung.
output "public_ip" {
  description = "Öffentliche IPv4 Adresse der VM"
  value       = exoscale_compute_instance.vm_details.public_ip_address
}

# HTTP URL funktioniert immer, auch ohne DNS.
output "http_url" {
  description = "HTTP URL der VM Details Website"
  value       = local.dns_enabled ? "http://${local.fqdn}" : "http://${exoscale_compute_instance.vm_details.public_ip_address}"
}

# HTTPS URL ist nur sinnvoll, wenn ein FQDN gesetzt ist.
output "https_url" {
  description = "HTTPS URL der VM Details Website, wenn DNS/FQDN verwendet wird"
  value       = local.dns_enabled ? "https://${local.fqdn}" : "HTTPS benötigt einen FQDN und ist ohne DNS deaktiviert"
}

# JSON API Endpoint für automatisierte Prüfung.
output "json_api_url" {
  description = "JSON API Endpoint mit VM Details"
  value       = local.dns_enabled ? "https://${local.fqdn}/api/v1/vm-details.json" : "http://${exoscale_compute_instance.vm_details.public_ip_address}/api/v1/vm-details.json"
}
