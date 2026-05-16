# ==========================================
# LET'S ENCRYPT / ACME
# ==========================================
# These constants define the official ACME CA endpoints for Let's Encrypt.
# Stored as locals instead of variables to prevent accidental overrides via
# CLI flags or CI environment variables, which could silently break SSL.

locals {
  acme_production = "https://acme-v02.api.letsencrypt.org/directory"
  acme_staging    = "https://acme-staging-v02.api.letsencrypt.org/directory"
}
