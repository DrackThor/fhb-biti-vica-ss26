# Öffentliche IPv4 der VM.
output "public_ip" {
  description = "Public IPv4 address of the VM."
  value       = exoscale_compute_instance.vm.public_ip_address
}

# URL für den HTTP-Endpunkt.
output "http_url" {
  description = "HTTP URL that returns technical VM details."
  value       = "http://${exoscale_compute_instance.vm.public_ip_address}/"
}

# Kleiner Healthcheck-Endpunkt für Tests.
output "health_url" {
  description = "Healthcheck URL."
  value       = "http://${exoscale_compute_instance.vm.public_ip_address}/health"
}
