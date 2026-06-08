# Gibt nach dem Erstellen der VM die wichtigsten URLs und die IP-Adresse aus.

output "instance_ip" {
  description = "Public IP Adresse der Exoscale VM"
  value       = exoscale_compute_instance.vm.public_ip_address
}

output "website_url" {
  description = "HTTP URL zur HTML-Webseite"
  value       = "http://${exoscale_compute_instance.vm.public_ip_address}/"
}

output "api_url" {
  description = "HTTP URL zum JSON API Endpunkt"
  value       = "http://${exoscale_compute_instance.vm.public_ip_address}/api/v1/system.json"
}
