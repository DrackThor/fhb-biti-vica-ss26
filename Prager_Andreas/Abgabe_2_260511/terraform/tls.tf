resource "tls_private_key" "account_key" {
  algorithm = "RSA"
}

# Registrierung bei der CA
# In diesem Fall Let's Encrypt - wird in provider.tf festgelegt
resource "acme_registration" "reg" {
  account_key_pem = tls_private_key.account_key.private_key_pem
  email_address   = var.owner_mail
}


resource "tls_private_key" "cert_key" {
  algorithm = "RSA"
}

# Frage bei der CA nach dem benötigtem Zertifikat an
resource "acme_certificate" "cert" {
  account_key_pem = acme_registration.reg.account_key_pem
  common_name     = "${var.namespace}.${data.exoscale_domain.my_domain.name}"

  # DNS Challenge, automatisch über Exoscale
  dns_challenge {
    provider = "exoscale"
    config = {
      EXOSCALE_API_KEY    = var.exoscale_api_key
      EXOSCALE_API_SECRET = var.exoscale_api_secret
    }
  }
}
