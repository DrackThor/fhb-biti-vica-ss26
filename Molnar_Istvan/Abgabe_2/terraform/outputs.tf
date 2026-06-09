# =============================================================================
# outputs.tf – Terraform Outputs nach erfolgreichem Apply
# =============================================================================
# Diese Werte werden nach dem Deployment ausgegeben und im GitHub-Workflow
# als Job-Summary sowie als Environment-Variable weiterverwendet.
# =============================================================================

output "vm_public_ip" {
  description = "Oeffentliche IPv4-Adresse der VM"
  value       = exoscale_compute_instance.vm_info.public_ip_address
}

output "vm_name" {
  description = "Name der erstellten Compute Instance"
  value       = exoscale_compute_instance.vm_info.name
}

output "vm_zone" {
  description = "Exoscale Zone der VM"
  value       = exoscale_compute_instance.vm_info.zone
}

output "http_url" {
  description = "HTTP-URL des VM-Info-Endpunkts (HTML-Ansicht)"
  value       = "http://${exoscale_compute_instance.vm_info.public_ip_address}/"
}

output "api_url" {
  description = "HTTP-URL des JSON-API-Endpunkts"
  value       = "http://${exoscale_compute_instance.vm_info.public_ip_address}/api"
}

output "https_url" {
  description = "HTTPS-URL (nur verfuegbar wenn domain_name gesetzt)"
  value       = var.domain_name != "" ? "https://${var.domain_name}/" : "HTTPS nicht konfiguriert (kein domain_name gesetzt)"
}

output "security_group_id" {
  description = "ID der erstellten Security Group"
  value       = exoscale_security_group.vm_info_sg.id
}
