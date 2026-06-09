# --- Outputs ---
# Gibt nach dem Deployment die IP und URL der VM aus.

output "public_ip" {
  description = "The public IP address of the VM."
  value       = exoscale_compute_instance.vm.public_ip_address
}

output "service_url" {
  description = "The HTTP URL of the VM information page."
  value       = "http://${exoscale_compute_instance.vm.public_ip_address}"
}
