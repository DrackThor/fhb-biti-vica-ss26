resource "exoscale_elastic_ip" "my_elastic_ip" {
  zone        = var.zone
  reverse_dns = "prager-vica.${data.exoscale_domain.my_domain.name}."
  labels = {
    "owner" = "Andreas Prager"
  }
}
