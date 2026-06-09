# =============================================================================
# outputs.tf – Ausgabewerte nach dem Terraform Apply
# Diese Werte werden im GitHub Workflow als Job-Summary angezeigt
# =============================================================================

output "vm_public_ip" {
  description = "Öffentliche IP-Adresse der Elastic IP (EIP)"
  value       = exoscale_elastic_ip.vm_eip.ip_address
}

output "vm_name" {
  description = "Name der erstellten Compute Instance"
  value       = exoscale_compute_instance.vm.name
}

output "vm_zone" {
  description = "Exoscale Zone der VM"
  value       = exoscale_compute_instance.vm.zone
}

output "website_url" {
  description = "URL des HTML-Dashboards"
  value       = "https://${var.domain}/"
}

output "api_url" {
  description = "URL des JSON-API-Endpunkts"
  value       = "https://${var.domain}/api"
}

output "security_group_id" {
  description = "ID der Security Group"
  value       = exoscale_security_group.vm_sg.id
}
