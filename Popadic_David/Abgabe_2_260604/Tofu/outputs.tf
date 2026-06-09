# Ausgabe der öffentlichen IP-Adresse der VM
output "public_ip" {
  value = exoscale_compute_instance.vm.public_ip_address
}