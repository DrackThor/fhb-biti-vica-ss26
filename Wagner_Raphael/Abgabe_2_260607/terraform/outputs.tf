# Die IP ist der wichtigste Fallback, falls keine DNS-Zone angegeben wurde.
output "instance_ip" {
  description = "Oeffentliche IPv4-Adresse der Exoscale-VM."
  value       = exoscale_compute_instance.vm.public_ip_address
}

# HTML-URL fuer die Bewertung. Mit DNS ist sie HTTPS, sonst HTTP per IP.
output "website_url" {
  description = "URL der HTML-Website mit VM-Details."
  value = (
    local.dns_enabled
    ? "https://${local.fqdn}/"
    : "http://${exoscale_compute_instance.vm.public_ip_address}/"
  )
}

# Separater JSON-Endpunkt fuer die API-Zusatzanforderung.
output "api_url" {
  description = "URL des JSON-API-Endpunkts."
  value = (
    local.dns_enabled
    ? "https://${local.fqdn}/api/v1/system"
    : "http://${exoscale_compute_instance.vm.public_ip_address}/api/v1/system"
  )
}

# Der FQDN bleibt null, wenn DNS nicht aktiviert wurde.
output "fqdn" {
  description = "Optionaler DNS-Name, falls dns_zone gesetzt wurde."
  value       = local.dns_enabled ? local.fqdn : null
}
