# Lokale Werte halten wiederverwendete Bedingungen und Strings zentral.
locals {
  # DNS ist aktiv, sobald eine Domain gesetzt ist.
  dns_enabled = trimspace(var.dns_domain) != ""

  # FQDN wird nur gebildet, wenn DNS aktiv ist.
  fqdn = local.dns_enabled ? "${var.dns_record_name}.${var.dns_domain}" : ""

  # Cloud-Init bekommt die Runtime-Parameter als Template-Variablen.
  cloud_init = templatefile("${path.module}/cloud-init.yaml.tftpl", {
    fqdn              = local.fqdn
    letsencrypt_email = var.letsencrypt_email
  })
}
