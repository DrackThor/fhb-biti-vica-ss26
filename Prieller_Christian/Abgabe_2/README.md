# Abgabe 2 – Christian Prieller

## Projektziel

Eine VM in Exoscale automatisiert erstellen, die unter einer HTTPS-URL ein Dashboard
mit technischen Systeminformationen anzeigt. Alles wird über Terraform und CloudInit
automatisiert.

## Verwendete Technologien

| Technologie | Zweck |
|---|---|
| OpenTofu (Terraform) | Erstellt die Cloud-Infrastruktur |
| Exoscale | Cloud Provider |
| Ubuntu 26.04 LTS | Betriebssystem der VM |
| CloudInit | Konfiguriert die VM beim ersten Start |
| nginx | Webserver|
| GitHub Actions | CI/CD Workflows |

## Projektstruktur

    Prieller_Christian/
    Abgabe_2/
        README.md
        .gitignore
        terraform/
            versions.tf         # Provider Version
            providers.tf        # Exoscale Login
            variables.tf        # Konfiguration
            main.tf             # VM + Security Groups
            outputs.tf          # IP und URL Ausgabe
            cloud-init.yaml     # VM Konfiguration

    .github/workflows/
        deploy.yml              # VM erstellen
        destroy.yml             # VM loeschen


### Terraform

Die Infrastruktur wird deklarativ in .tf-Dateien beschrieben:

- **versions.tf** definiert den Exoscale Provider
- **providers.tf** konfiguriert die Authentifizierung mit API Key und Secret
- **variables.tf** macht die Konfiguration flexibel (Zone, VM-Größe, Name)
- **main.tf** erstellt die Ressourcen:
  ** Ubuntu 26.04 VM und Security Group mit Regeln für HTTP, HTTPS und SSH
- **outputs.tf** gibt nach dem Deploy die IP und URLs aus

### CloudInit

CloudInit konfiguriert die VM beim ersten Boot:

1. Installiert nginx, openssl, curl und dmidecode
2. Erstellt ein SSL Zertifikat für HTTPS
3. Konfiguriert nginx mit HTTPS und HTTP-Redirect
4. Führt ein Script aus, dass alle VM-Informationen sammelt
5. Generiert ein HTML Dashboard und eine JSON API

### Dashboard

Die Webseite zeigt folgende technische VM-Details:
- Hostname, Public IP, Private IP
- Betriebssystem, Kernel, Architektur
- CPU Modell und Kerne
- RAM und Festplatten-Nutzung
- Dateisystem-Typ
- Hypervisor und Virtualisierungs-Typ
- BIOS Vendor und Hersteller
- Uptime

### GitHub Actions

Zwei Workflows steuern den Lebenszyklus:
- **deploy.yml** erstellt die VM via tofu apply
- **destroy.yml** loescht alle Ressourcen via tofu destroy

Der Terraform State wird als GitHub Artifact zwischen den Workflows geteilt.

## Anleitung

### Voraussetzungen

GitHub Secrets im Repository einrichten:
- EXOSCALE_API_KEY mit dem Exoscale API Key
- EXOSCALE_API_SECRET mit dem Exoscale API Secret

### VM erstellen

1. Actions Tab im GitHub Repository öffnen
2. Workflow "Deploy Infrastruktur" auswählen
3. "Run workflow" klicken und bestätigen
4. Warten bis der Workflow fertig ist (ca. 5 Minuten)
5. In den Outputs die URL kopieren und im Browser öffnen
6. Bei der Browser-Warnung (self-signed Zertifikat): "Erweitert" und dann "Weiter"

### VM löschen

1. Actions Tab dann "Destroy Infrastruktur" und "Run workflow"

### Lokale Ausführung möglich

    cd Prieller_Christian/Abgabe_2/terraform
    export TF_VAR_exoscale_api_key="MEIN_KEY"
    export TF_VAR_exoscale_api_secret="MEIN_SECRET"
    tofu init
    tofu plan
    tofu apply
    
    # Zum Löchen:
    tofu destroy

## HTTPS

Es wird ein self-signed Zertifikat verwendet. Der Browser zeigt eine Warnung weil
es nicht von einer offiziellen CA signiert ist. Die Verbindung wird trotzdem verschlüsselt.
