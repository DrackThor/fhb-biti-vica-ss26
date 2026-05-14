# Öffentliche IPv4-Adresse der VM.
output "public_ip" {
  description = "Public IPv4 address of the VM"
  value       = exoscale_compute_instance.vm.public_ip_address
}

# HTTP-Endpunkt der Website.
output "html_endpoint" {
  description = "HTML website endpoint"
  value       = "http://${exoscale_compute_instance.vm.public_ip_address}/"
}

# JSON-Endpunkt der API.
output "json_endpoint" {
  description = "JSON API endpoint"
  value       = "http://${exoscale_compute_instance.vm.public_ip_address}/api/vm"
}
