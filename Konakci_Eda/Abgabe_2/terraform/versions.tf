# Definiert die benötigten OpenTofu/Terraform- und Provider-Versionen.
# OpenTofu kann Terraform-Provider aus der Registry verwenden.
terraform {
  required_version = ">= 1.8.0"

  required_providers {
    # Offizieller Exoscale Provider für Compute, Security Groups und DNS.
    exoscale = {
      source  = "exoscale/exoscale"
      version = "~> 0.69"
    }
  }
}
