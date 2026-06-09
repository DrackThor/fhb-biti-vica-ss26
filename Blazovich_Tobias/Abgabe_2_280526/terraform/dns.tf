#Exoscale DNS Domain laden
 data "exoscale_domain" "website" { 
    # Verwendete Domain
    name = "biti-fhb.org" 
    } 
# DNS A-Record erstellen
 resource "exoscale_domain_record" "webserver" {
    # Zugehörige Domain-ID 
    domain = data.exoscale_domain.website.id 
    # Verwendete Subdomain
    name = "blazovich-tobias" 
    # DNS Record Typ
    record_type = "A" 
    # Öffentliche IP-Adresse der VM
    content = exoscale_compute_instance.web.public_ip_address 
    # DNS Cache-Zeit in Sekunden
    ttl = 3600 
    }