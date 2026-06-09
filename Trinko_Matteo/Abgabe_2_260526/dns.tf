# Liest die bestehende Exoscale-DNS-Zone aus.
# Die Domain muss bereits in Exoscale DNS vorhanden sein.
data "exoscale_domain" "main" {
  name = var.domain_name
}

# Erstellt einen A-Record, der die Subdomain auf die öffentliche IP der VM zeigt.
resource "exoscale_domain_record" "vm" {
  domain      = data.exoscale_domain.main.id
  name        = var.dns_name
  record_type = "A"
  content     = exoscale_compute_instance.vm.public_ip_address
  ttl         = 300
}