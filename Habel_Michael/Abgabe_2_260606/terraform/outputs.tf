# outputs.tf
# Nach dem Apply ausgegebene Werte. Der Workflow schreibt diese in die
# Job-Zusammenfassung, sodass die Ziel-URL sofort sichtbar ist.

output "instance_ip" {
  description = "Oeffentliche IPv4-Adresse der VM."
  value       = exoscale_compute_instance.vm.public_ip_address
}

output "url_http" {
  description = "HTTP-URL des Info-Endpunkts."
  value       = "http://${exoscale_compute_instance.vm.public_ip_address}/"
}

output "url_https" {
  description = "HTTPS-URL (self-signed Zertifikat -> Browser-Warnung ist zu erwarten)."
  value       = "https://${exoscale_compute_instance.vm.public_ip_address}/"
}

output "api_json" {
  description = "JSON-Endpunkt mit denselben Daten."
  value       = "http://${exoscale_compute_instance.vm.public_ip_address}/api/info"
}
