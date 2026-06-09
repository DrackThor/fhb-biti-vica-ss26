output "vm_public_ip" {
    value = exoscale_compute_instance.vm.public_ip_address
}

output "vm_http_url" {
    value = "http://${exoscale_compute_instance.vm.public_ip_address}"
}