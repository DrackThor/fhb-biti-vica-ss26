variable "exoscale_key" {
  type      = string
  sensitive = true
}

variable "exoscale_secret" {
  type      = string
  sensitive = true
}

variable "zone" {
  type    = string
  default = "at-vie-1" # Da FH Burgenland/Wien-Bezug, bietet sich die Wien-Zone an
}

variable "domain_name" {
  type        = string
  default     = "deine-domain.com" # Für HTTPS-Zusatzpunkte (optional, sonst IP nutzen)
  description = "Falls vorhanden, für DNS-Eintrag"
}