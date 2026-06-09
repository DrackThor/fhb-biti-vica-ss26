# Setzt voraus, dass eine DNS-Domain in Exoscale bereits subscribed ist
# und die Domain-Variable gesetzt wurde. Ohne DNS wird die reine IP-Adresse verwendet.

# DNS-Domain in Exoscale erstellen (muss vorab gebucht sein)
# resource "exoscale_domain" "vica" {
#   name = "vica.example.com"
# }
#
# # A-Record: Domain zeigt auf die öffentliche IP der VM
# resource "exoscale_domain_record" "vm_a" {
#   domain      = exoscale_domain.vica.id
#   name        = "vm"                  # → vm.vica.example.com
#   record_type = "A"
#   content     = exoscale_compute_instance.vm.public_ip_address
#   ttl         = 300
# }

# Hinweis: Für echtes HTTPS (Bonus) wird Certbot/Let's Encrypt in cloud-init.yaml
# verwendet. Der DNS-Record muss vor dem Certbot-Aufruf auflösbar sein.
# In diesem Setup holt Certbot das Zertifikat automatisch beim ersten Boot.