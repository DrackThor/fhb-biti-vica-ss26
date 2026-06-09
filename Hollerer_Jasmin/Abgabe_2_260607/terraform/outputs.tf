output "vm_public_ip" {
  description = "Öffentliche IP-Adresse der erstellten VM"
  value       = exoscale_compute_instance.web.public_ip_address
}

output "html_endpoint" {
  description = "URL des HTML-Endpunkts (Systeminformationen als Website)"
  value       = "http://${exoscale_compute_instance.web.public_ip_address}/"
}

output "json_endpoint" {
  description = "URL des JSON API-Endpunkts (Systeminformationen als API)"
  value       = "http://${exoscale_compute_instance.web.public_ip_address}/api"
}
