# Öffentliche IP-Adresse der erstellten VM
# Diese IP wird nach dem Workflow angezeigt und dient als URL für die Abgabe
output "public_ip" {
  description = "Öffentliche IP-Adresse der Exoscale VM"
  value       = exoscale_compute_instance.vm.public_ip_address
}

# HTML Endpunkt der Webseite
output "html_endpoint" {
  description = "HTTP Endpunkt für die HTML Webseite"
  value       = "http://${exoscale_compute_instance.vm.public_ip_address}/"
}

# JSON API Endpunkt
output "json_endpoint" {
  description = "HTTP Endpunkt für die JSON API"
  value       = "http://${exoscale_compute_instance.vm.public_ip_address}/api"
}