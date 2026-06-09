output "vm_name" {
  description = "Name der erstellten VM"
  value       = exoscale_compute_instance.vm.name
}

output "vm_public_ip" {
  description = "Öffentliche IP-Adresse der VM"
  value       = exoscale_compute_instance.vm.public_ip_address
}

output "fqdn" {
  description = "Vollständiger DNS-Name der VM"
  value       = local.fqdn
}

output "http_url" {
  description = "HTTP URL der VM"
  value       = "http://${local.fqdn}"
}

output "https_url" {
  description = "HTTPS URL der VM"
  value       = "https://${local.fqdn}"
}

output "api_url" {
  description = "JSON API URL der VM"
  value       = "https://${local.fqdn}/api"
}