# =====================================================================
# outputs.tf  -  Werte, die nach dem Erstellen ausgegeben werden
# =====================================================================

output "public_ip" {
  description = "Oeffentliche IP-Adresse der VM"
  value       = exoscale_compute_instance.vm.public_ip_address
}

output "website_url" {
  description = "URL der Info-Website (HTML)"
  value       = "http://${exoscale_compute_instance.vm.public_ip_address}/"
}

output "api_url" {
  description = "URL des JSON-API-Endpunkts"
  value       = "http://${exoscale_compute_instance.vm.public_ip_address}/api"
}
