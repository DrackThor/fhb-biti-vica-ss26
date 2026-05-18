
# Outputs for the web server instance
# public_ip is an official (read-only) attribute of the exoscale_compute_instance resource
output "public_ip" {
  value = exoscale_compute_instance.web.public_ip_address
}

output "website_url" {
  value = "http://${exoscale_compute_instance.web.public_ip_address}"
}

output "api_url" {
  value = "http://${exoscale_compute_instance.web.public_ip_address}/api"
}