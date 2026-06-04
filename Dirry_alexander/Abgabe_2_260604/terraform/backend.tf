# =====================================================================
# backend.tf  -  Speichert den Terraform-State in einem Exoscale-SOS-Bucket
# ---------------------------------------------------------------------
# WARUM? Jeder GitHub-Actions-Lauf startet auf einem frischen Rechner.
# Ohne gemeinsam genutzten ("remote") State wuesste der "Loeschen"-Workflow
# nicht, welche Ressourcen er abbauen soll. Deshalb legen wir den State in
# einem Object-Storage-Bucket ab, auf den beide Workflows zugreifen.
#
# WICHTIG (einmalig vorab):
#   1) Den Bucket manuell anlegen (Exoscale-Console oder CLI), Zone at-vie-1.
#   2) Den Bucketnamen unten eintragen (muss eindeutig sein).
#
# Die Zugangsdaten fuer den Bucket kommen aus den Umgebungsvariablen
# AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY (= Exoscale Key/Secret),
# die in den Workflows gesetzt werden.
# =====================================================================
terraform {
  backend "s3" {
    bucket = "dirry-abgabe2-tfstate" # dein SOS-Bucket in AT-VIE-1
    key    = "abgabe2/terraform.tfstate"
    region = "at-vie-1"

    endpoints = {
      s3 = "https://sos-at-vie-1.exo.io"
    }

    # SOS ist S3-kompatibel, aber kein echtes AWS.
    # Daher diese AWS-spezifischen Pruefungen abschalten:
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_s3_checksum            = true
  }
}
