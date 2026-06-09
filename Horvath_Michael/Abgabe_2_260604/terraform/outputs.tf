# Die öffentliche IP-Adresse der VM
output "vm_ip" {
  description = "Öffentliche IP-Adresse der VM"
  value       = exoscale_compute_instance.vm.public_ip_address
}

# Der Name der VM – zur Kontrolle
output "vm_name" {
  description = "Name der VM"
  value       = exoscale_compute_instance.vm.name
}

# Fertige URL zum direkten Aufrufen
output "vm_url" {
  description = "URL der VM"
  value       = "http://${exoscale_compute_instance.vm.public_ip_address}"
}