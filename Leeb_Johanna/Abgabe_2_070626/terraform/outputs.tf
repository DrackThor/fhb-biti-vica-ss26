# Gibt nach dem erfolgreichen Setup die IP-Adresse der VM aus
output "vm_url" {
  value       = "http://${exoscale_compute_instance.sysinfo_vm.public_ip_address}"
  description = "Die fertige URL zum HTTP-Endpunkt mit den Systemdetails"
}
