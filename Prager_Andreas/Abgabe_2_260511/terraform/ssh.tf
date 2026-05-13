resource "exoscale_ssh_key" "main" {
  name       = "prager-vica-ssh-key"
  public_key = var.ssh_public_key
}