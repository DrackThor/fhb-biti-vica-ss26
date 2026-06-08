terraform {
    required_providers {
        exoscale = {
            source = "exoscale/exoscale"
            version = "~> 0.64"
        }
    }
}

provider "exoscale" {
    key = var.exoscale_api_key
    secret = var.exoscale_api_secret
}

data "exoscale_template" "ubuntu" {
    zone = var.zone
    name = "Linux Ubuntu 22.04 LTS 64-bit"
}

resource "exoscale_security_group" "vm_sg"{
    name = "${var.instance_name}-sg"
}

resource "exoscale_security_group_rule" "http" {
    security_group_id = "exoscale_security_group.vm_sg.id"
    type = "INGRESS"
    protocol = "tcp"
    start_port = 80
    end_port = 80
    cidr = "0.0.0.0/0"
}

resource "exoscale_compute_instance" "vm" {
    zone = var.zone
    name = var.instance_name
    type = "standard.medium"
    template_id = data.exoscale_template.ubuntu.id
    disk_size = 20
    security_group_ids = [exoscale_security_group.vm_sg.id]
    user_data = file("${path.module}/cloud-init.yaml")
}

