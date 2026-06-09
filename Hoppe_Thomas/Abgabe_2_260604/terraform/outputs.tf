# =============================================================================
# outputs.tf – Terraform Outputs
# Diese Werte werden nach dem Apply ausgegeben und in GitHub Actions geloggt
# =============================================================================

# Öffentliche IP-Adresse der VM (Elastic IP)
output "vm_ip" {
  description = "Öffentliche Elastic IP-Adresse der VM"
  value       = exoscale_elastic_ip.vm_eip.ip_address
}

# Vollständiger Domainname
output "domain" {
  description = "FQDN der VM"
  value       = var.domain
}

# HTTPS-URL für den HTML-Endpunkt
output "url_html" {
  description = "URL der HTML-Webseite mit VM-Informationen"
  value       = "https://${var.domain}/"
}

# HTTPS-URL für den JSON-API-Endpunkt
output "url_api" {
  description = "URL des JSON-API-Endpunkts mit VM-Informationen"
  value       = "https://${var.domain}/api"
}

# Health-Check Endpunkt
output "url_health" {
  description = "Health-Check URL"
  value       = "https://${var.domain}/api/health"
}

# VM Instanz-ID (für Debugging)
output "vm_id" {
  description = "Exoscale VM Instanz-ID"
  value       = exoscale_compute_instance.vm.id
}
