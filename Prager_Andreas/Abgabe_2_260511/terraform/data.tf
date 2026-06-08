# Finde die Template-ID für die gewünschte Ubuntu-Version
# Wird in der Datei vm.tf verwendet, um eine Ubuntu VM zu erstellen
data "exoscale_template" "ubuntu_template" {
  zone = var.zone
  name = "Linux Ubuntu 26.04 LTS 64-bit"
}

# Finde die vorgegebene Domain biti-fhb.org
# Auf diese Weise kann von überall dynamisch auf den Domainnamen zugegriffen werden
# Praktisch sollte man einmal einen anderen Namen verwenden wollen, muss er nur an dieser Stelle geändert werden
data "exoscale_domain" "my_domain" {
  name = "biti-fhb.org"
}
