output "public_ip" {
  value = exoscale_compute_instance.vm.public_ip_address
}

output "html_url" {
  value = "http://${exoscale_compute_instance.vm.public_ip_address}/"
}

output "api_url" {
  value = "http://${exoscale_compute_instance.vm.public_ip_address}/api"
}