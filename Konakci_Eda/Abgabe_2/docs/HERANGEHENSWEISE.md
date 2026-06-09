# Herangehensweise und Funktionsweise

## Ziel

Ziel der Aufgabe ist es, automatisiert eine VM in Exoscale zu erstellen.
Diese VM ist über eine öffentliche URL erreichbar und zeigt technische Informationen über sich selbst an.

Es gibt zwei Endpunkte:

- HTML Website: http://<PUBLIC_IP>/
- JSON API: http://<PUBLIC_IP>/api/v1/vm-details.json

## Verwendete Technologien
   
   - OpenTofu/Terraform für die Infrastruktur
   - GitHub Actions für Erstellung und Löschung
   - Exoscale als Cloud Provider
   - Ubuntu als Betriebssystem
   - Cloud-Init für die automatische VM-Konfiguration
   - Nginx als Webserver

## Aufbau

Die Abgabe liegt im Ordner:

Abgabe_2_eda_konakci

Wichtige Bestandteile:

    - terraform/ enthält den OpenTofu-Code
    - cloud-init.yaml.tftpl konfiguriert die VM automatisch
    - create-infrastructure.yml erstellt die Infrastruktur
    - delete-infrastructure.yml löscht die Infrastruktur
    - README.md beschreibt die Verwendung


## Funktionsweise

OpenTofu erstellt in Exoscale eine Ubuntu VM, eine Security Group und die nötigen Firewall-Regeln für HTTP und HTTPS.

Die VM erhält beim Erstellen eine Cloud-Init Konfiguration. Dadurch werden automatisch Nginx und alle benötigten Hilfsprogramme installiert. Außerdem werden eine HTML-Seite und eine JSON-Datei erzeugt.

Die angezeigten Informationen werden direkt auf der VM ermittelt.

## Angezeigte Informationen

Die Website und die JSON API zeigen unter anderem:

   - Hostname
   - öffentliche IP-Adresse
   - private IP-Adresse
   - Betriebssystem
   - Kernel-Version
   - CPU-Informationen
   - Arbeitsspeicher
   - Hypervisor bzw. Virtualisierung
   - Filesysteme
   - Uptime
   - Zeitpunkt der letzten Aktualisierung

## Verwendung

Vor der Ausführung müssen in GitHub folgende Secrets gesetzt werden:

EXOSCALE_API_KEY
EXOSCALE_API_SECRET

Diese Werte stammen aus Exoscale und werden nicht im Code gespeichert.

## Infrastruktur erstellen

   1. GitHub Repository öffnen
   2. Tab Actions öffnen
   3. Workflow Create Exoscale Infrastructure auswählen
   4. Auf Run workflow klicken
   5. Zone auswählen, z.B. at-vie-1
   6. Workflow starten

Nach erfolgreichem Lauf werden die Public IP und die URLs als Output angezeigt.

## Infrastruktur löschen

   1. Tab Actions öffnen
   2. Workflow Delete Exoscale Infrastructure auswählen
   3. Auf Run workflow klicken
   4. Gleiche Zone wie beim Erstellen verwenden
   5. Workflow starten

Dadurch wird die erstellte Infrastruktur wieder gelöscht.

## Hinweis zu DNS und HTTPS

Die Lösung ist für den Aufruf über die öffentliche IP-Adresse vorbereitet.
DNS und HTTPS sind optional vorgesehen, benötigen aber einen gültigen FQDN.

## Teststatus / Hinweis

Die Infrastruktur konnte über den GitHub Actions Workflow erstellt werden.  
OpenTofu hat eine Public IP und die vorgesehenen Endpunkte als Output ausgegeben.

Beim manuellen Test war der HTTP-Endpunkt über die Public IP in meinem Testlauf jedoch nicht erreichbar.  
Die wahrscheinlichsten Ursachen sind eine noch nicht vollständig abgeschlossene Cloud-Init Konfiguration oder ein Problem beim Start des Webservers auf der VM.

Die Lösung enthält die vorgesehenen Komponenten für die automatische Bereitstellung:

   - OpenTofu Infrastruktur
   - GitHub Actions Workflows
   - Ubuntu VM
   - Security Group für HTTP und HTTPS
   - Cloud-Init Konfiguration
   - HTML Website
   - JSON API

## Zusammenfassung

Die Lösung erstellt und löscht eine Exoscale VM automatisiert über GitHub Actions und OpenTofu.
Die VM wird vollständig über Cloud-Init konfiguriert und stellt technische Informationen als HTML Website und JSON API bereit.
