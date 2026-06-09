output "http_url" {

  description = "HTTP URL der VM"

  # Öffentliche HTTP URL der VM
  value       = "http://${exoscale_compute_instance.vm.public_ip_address}"
}

output "api_url" {
  
  description = "JSON API URL der VM"

  # Öffentliche URL des API Endpunkts
  value       = "http://${exoscale_compute_instance.vm.public_ip_address}/api"
}