output "public_ip" {
  description = "Public IP address of the VM"
  value       = exoscale_compute_instance.vm.public_ip_address
}

output "url_html" {
  description = "HTML dashboard"
  value       = "http://${exoscale_compute_instance.vm.public_ip_address}/"
}

output "url_api" {
  description = "JSON API endpoint"
  value       = "http://${exoscale_compute_instance.vm.public_ip_address}/api"
}
