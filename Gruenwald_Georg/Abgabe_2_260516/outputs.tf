# --- Infrastructure Outputs ---
# Returns operational data like the server IP and application endpoints 
# once the Exoscale provisioning is complete.

output "public_ip" {
  description = "The public IP of the monitoring server"
  value       = exoscale_compute_instance.vm.public_ip_address
}

output "stats_url" {
  description = "The direct URL for the Netdata Dashboard"
  value       = "https://${local.stats_fqdn}"
}

output "api_url" {
  description = "The direct URL for the Swagger API UI"
  value       = "https://${local.api_fqdn}"
}
