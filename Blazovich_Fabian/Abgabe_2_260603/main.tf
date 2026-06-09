# Verwendet das Ubuntu Template aus Exoscale
data "exoscale_template" "ubuntu" {

  # Exoscale Zone
  zone = var.zone

  #Name des Ubuntu Imanges (in variables.tf definiert)
  name = var.ubuntu_template
}

#Erstellt die virtuelle Maschine
resource "exoscale_compute_instance" "vm" {

  # Zone der VM
  zone = var.zone

  # Name der VM
  name = var.vm_name

  # Verwendetes Ubuntu Template
  template_id = data.exoscale_template.ubuntu.id

  # VM Größe
  type        = var.instance_type

  # Größe der Disk
  disk_size   = var.disk_size

  # Verknüpft die Security Group mit der VM
  security_group_ids = [exoscale_security_group.fblazovich_sec_group.id]

  # Führt CloudInit beim ersten Start der VM aus
  user_data = file("${path.module}/cloud-init.yml")
}
