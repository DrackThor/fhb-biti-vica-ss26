# Öffentliche IPv4-Adresse der VM - direkt erreichbar auch ohne DNS
output "vm_public_ip" {
  description = "Öffentliche IP-Adresse der VM"
  value       = exoscale_compute_instance.vm.public_ip_address
}

# HTTP-URL für direkten Zugriff über IP
output "vm_url_http" {
  description = "HTTP-Endpunkt (HTML-Ansicht)"
  value       = "http://${exoscale_compute_instance.vm.public_ip_address}/"
}

# API-Endpunkt für JSON-Ausgabe
output "vm_url_api" {
  description = "JSON API-Endpunkt"
  value       = "http://${exoscale_compute_instance.vm.public_ip_address}/api"
}

# Instanz-Name zur Referenz
output "vm_name" {
  description = "Name der Compute-Instanz"
  value       = exoscale_compute_instance.vm.name
}