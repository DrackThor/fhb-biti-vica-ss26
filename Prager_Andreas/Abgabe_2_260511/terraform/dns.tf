resource "exoscale_domain_record" "my_host" {
  domain      = data.exoscale_domain.my_domain.id
  name        = "prager-vica"
  record_type = "A"
  content     = exoscale_elastic_ip.my_elastic_ip.ip_address
}