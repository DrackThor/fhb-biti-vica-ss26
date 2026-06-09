# Ausgaben nach dem Deployment
output "public_ip" {
  value = exoscale_compute_instance.vm.public_ip_address
}

output "website_url" {
  value = "https://${exoscale_compute_instance.vm.public_ip_address}"
}

output "api_url" {
  value = "https://${exoscale_compute_instance.vm.public_ip_address}/api/vm-info"
}
