output "vm_public_ip" {
  description = "Die oeffentliche IP-Adresse der VM fuer den Zugriff auf das Dashboard und die API"
  value       = exoscale_compute_instance.ubuntu_vm.public_ip_address
}

output "dashboard_url" {
  description = "Direktlink zum HTML-Dashboard"
  value       = "http://${exoscale_compute_instance.ubuntu_vm.public_ip_address}"
}

output "api_url" {
  description = "Direktlink zur JSON-API"
  value       = "http://${exoscale_compute_instance.ubuntu_vm.public_ip_address}/api.json"
}