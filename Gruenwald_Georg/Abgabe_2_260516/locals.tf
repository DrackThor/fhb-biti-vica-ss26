locals {
  # ==========================================
  # LET'S ENCRYPT / ACME
  # ==========================================
  # These constants define the official ACME CA endpoints for Let's Encrypt.
  # Stored as locals instead of variables to prevent accidental overrides via
  # CLI flags or CI environment variables, which could silently break SSL.

  acme_production = "https://acme-v02.api.letsencrypt.org/directory"
  acme_staging    = "https://acme-staging-v02.api.letsencrypt.org/directory"

  # ==========================================
  # CENTRALIZED DOMAIN STRINGS
  # ==========================================
  # These constants dynamically assemble the FQDNs for the application endpoints.
  # Maintained here to enforce a single source of truth and eliminate redundant
  # string interpolation across templates, outputs, and DNS records.

  admin_email = "${var.second_level_domain}@${var.root_domain}"
  stats_fqdn  = "${var.stats_prefix}.${var.second_level_domain}.${var.root_domain}"
  api_fqdn    = "${var.api_prefix}.${var.second_level_domain}.${var.root_domain}"

  # Set of subdomains for dynamic DNS record creation
  subdomains = toset([
    "${var.stats_prefix}.${var.second_level_domain}",
    "${var.api_prefix}.${var.second_level_domain}"
  ])
}
