output "endpoint" {
  description = "HTTP endpoint (IP) der VM"
  value       = exoscale_floating_ip.fip.ip_address
}
