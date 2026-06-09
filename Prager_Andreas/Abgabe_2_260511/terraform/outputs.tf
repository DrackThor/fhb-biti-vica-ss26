output "vm_public_ip" {
  description = "Public IP address of the Exoscale VM"
  value       = exoscale_compute_instance.vm.public_ip_address
}

output "web_url" {
  description = "URL to the HTML interface of the VM info service"
  value       = "https://${exoscale_domain_record.my_host.hostname}/"
}

output "api_url" {
  description = "URL to the JSON API endpoint of the VM info service"
  value       = "https://${exoscale_domain_record.my_host.hostname}/api"
}

output "ssh_command" {
  description = "Command to SSH into the VM (for debugging)"
  value       = "ssh ubuntu@${exoscale_compute_instance.vm.public_ip_address}"
}
