# Oeffentliche IP-Adresse der VM
output "public_ip" {
  description = "Oeffentliche IP-Adresse der VM"
  value       = exoscale_compute_instance.vm.public_ip_address
}

# HTTP URL zur Website
output "website_url" {
  description = "HTTP URL zur VM-Info Website"
  value       = "http://${exoscale_compute_instance.vm.public_ip_address}"
}

# JSON API Endpunkt
output "api_url" {
  description = "HTTP URL zum JSON API Endpunkt"
  value       = "http://${exoscale_compute_instance.vm.public_ip_address}/api/info"
}