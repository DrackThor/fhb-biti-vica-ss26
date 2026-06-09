output "vm_ip_address" {
  description = "Public IP address of the Exoscale VM"
  value       = exoscale_compute_instance.vm.public_ip_address
}

output "vm_website_url" {
  description = "HTTP URL of the VM information website"
  value       = "http://${exoscale_compute_instance.vm.public_ip_address}"
}

output "vm_api_url" {
  description = "JSON API endpoint of the VM"
  value       = "http://${exoscale_compute_instance.vm.public_ip_address}/api/"
}
