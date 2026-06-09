# outputs.tf
# -----------------------------------------------------------------------------
# Ausgaben nach dem Apply.
# -----------------------------------------------------------------------------

output "public_ip" {
  description = "Oeffentliche IPv4 der VM."
  value       = exoscale_compute_instance.vm.public_ip_address
}

output "website_url" {
  description = "HTTPS-URL der Website (HTML)."
  value       = "https://${local.website_fqdn}/"
}

output "api_url" {
  description = "HTTPS-URL der API (JSON)."
  value       = "https://${local.api_fqdn}/"
}
