# locals.tf
# -----------------------------------------------------------------------------
# Zentrale, abgeleitete Werte (Single Source of Truth fuer die FQDNs).
# -----------------------------------------------------------------------------

locals {
  # Offizielle Let's-Encrypt-Endpunkte.
  acme_production = "https://acme-v02.api.letsencrypt.org/directory"
  acme_staging    = "https://acme-staging-v02.api.letsencrypt.org/directory"

  # E-Mail fuer ACME-Benachrichtigungen.
  admin_email = "${var.second_level_domain}@${var.root_domain}"

  # Vollstaendige Domainnamen:
  #   Website (HTML): ilic.biti-fhb.org
  #   API (JSON):     api.ilic.biti-fhb.org
  website_fqdn = "${var.second_level_domain}.${var.root_domain}"
  api_fqdn     = "${var.api_prefix}.${var.second_level_domain}.${var.root_domain}"

  # A-Records, die in der DNS-Zone angelegt werden (Name relativ zur Zone).
  dns_records = {
    "website" = var.second_level_domain                              # -> ilic
    "api"     = "${var.api_prefix}.${var.second_level_domain}"        # -> api.ilic
  }
}
