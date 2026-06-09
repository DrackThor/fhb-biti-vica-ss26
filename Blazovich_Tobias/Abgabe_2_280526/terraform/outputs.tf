# Ausgabe der HTTPS URL der Webseite 
output "website_url" { 
   # Vollständige HTTPS Adresse der Webseite
   value = "https://blazovich-tobias.biti-fhb.org" 
  } 
  
# Ausgabe der HTTPS URL des JSON API Endpunkts 
output "api_url" { 
   # Vollständige HTTPS Adresse der JSON API
   value = "https://blazovich-tobias.biti-fhb.org/api.json"
  } 
  
# Ausgabe der öffentlichen IP-Adresse der VM 
output "public_ip" { 
     # Öffentliche IP-Adresse der Exoscale VM 
    value = exoscale_compute_instance.web.public_ip_address 
  } 

# Ausgabe der HTTP URL über die öffentliche IP-Adresse 
output "http_ip_url" { 
   # Direkter HTTP Zugriff über die Public IP der VM 
   value = "http://${exoscale_compute_instance.web.public_ip_address}" 
  }

# Ausgabe der HTTP URL des JSON API-Endpunkts über die Public IP-Adresse
  output "http_api_url" { 
  # Vollständige HTTP Adresse des JSON API-Endpunkts über die Public IP-Adresse
   value = "http://${exoscale_compute_instance.web.public_ip_address}/api.json" 
  }