# A Record anlegen mit dem auf die Web-App zugegriffen wird
# Für diesen Namen wird das TLS-Zertifikat ausgestellt in der Datei tls.tf
resource "exoscale_domain_record" "my_host" {
  domain      = data.exoscale_domain.my_domain.id
  name        = var.namespace
  record_type = "A"
  content     = exoscale_compute_instance.vm.public_ip_address
}
