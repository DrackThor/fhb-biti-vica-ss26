
# Install provider exoscale

terraform {
  required_providers {
    exoscale = {
      source  = "exoscale/exoscale"
      version = "0.69.2"
    }
  }
}

provider "exoscale" {
  # Configuration options
  key    = var.exoscale_key
  secret = var.exoscale_secret
}

# Search for template ubuntu 24.04 LTS 64-bit in the specified zone
data "exoscale_template" "ubuntu" {
  zone = var.zone
  name = "Linux Ubuntu 24.04 LTS 64-bit"
}

# Create a compute instance with the specified template and type
resource "exoscale_compute_instance" "web" {
  zone               = var.zone
  name               = "abgabe-2-webserver"
  template_id        = data.exoscale_template.ubuntu.id
  type               = "standard.small"
  disk_size          = 10
  security_group_ids = [exoscale_security_group.web.id]
  ssh_keys           = [exoscale_ssh_key.ssh.id]

  # Provide the cloud-init configuration file to initialize the instance
  user_data = file("${path.module}/cloud-init.yaml")
}

# Create a security group for the web server instance
resource "exoscale_security_group" "web" {
  name = "abgabe-2-web-sg"
}

# Create a security group rule to allow incoming HTTP traffic on port 80
resource "exoscale_security_group_rule" "http" {
  security_group_id = exoscale_security_group.web.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 80
  end_port          = 80
}

# Create a security group rule to allow incoming SSH traffic on port 22
resource "exoscale_security_group_rule" "ssh" {
  security_group_id = exoscale_security_group.web.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 22
  end_port          = 22
}

# Create ssh-key resource to allow SSH access to the instance
resource "exoscale_ssh_key" "ssh" {
  name       = "ssh-key"
  public_key = var.ssh_public_key
}







