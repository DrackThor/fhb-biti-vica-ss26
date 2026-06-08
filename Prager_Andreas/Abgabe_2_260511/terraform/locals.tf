locals {
  # NGINX-Konfiguration wird mit der templatefile Funktion erstellt
  # Wird in User Data an CloudInit weitergegeben - in der Datei vm.tf
  nginx_conf = templatefile("${path.module}/files/nginx.conf.tftpl", {
    namespace   = var.namespace
    domain_name = data.exoscale_domain.my_domain.name
  })
}
