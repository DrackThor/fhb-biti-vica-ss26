variable "exoscale_api_key" {
    type = string
    sensitive = true
}

variable "exoscale_api_secret" {
    type = string
    sensitive = true
}

variable "zone" {
    type = string
    default = "at-vie-1"
}

variable "instance_name" {
    type = string
    default = "vm-endpoint"
}