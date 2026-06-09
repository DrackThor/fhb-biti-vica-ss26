# Funktionsweise der Lösung
## Erstellung der Infrastruktur mit OpenTofu
Die Infrastruktur wird vollständig automatisiert mit OpenTofu bereitgestellt. Sämtliche Infrastrukturkomponenten werden deklarativ über Terraform-Dateien beschrieben und anschließend über die Exoscale API erstellt. Dadurch kann die Infrastruktur reproduzierbar erstellt, geändert und gelöscht werden. Für die Authentifizierung am Exoscale-Provider werden keine Zugangsdaten direkt im Quellcode gespeichert. Stattdessen werden Environment Variables verwendet, die automatisch über das Präfix TF_VAR_* an OpenTofu übergeben werden.

Verwendete Variablen:
```text
TF_VAR_exoscale_api_key 
TF_VAR_exoscale_api_secret
```
Zusätzlich werden die Variablen mit sensitive = true gekennzeichnet. Dadurch werden sensible Informationen weder in Outputs noch in Logs angezeigt.

Die Security Group öffnet den notwendigen Port:
| Port | Zweck | 
|---|---| 
| 80 | HTTP-Zugriff | 
| 443 | HTTPS-Zugriff |

Für die Bereitstellung der Infrastruktur werden folgende OpenTofu-Befehle verwendet:

- tofu init
- tofu plan
- tofu apply

### tofu init

Mit tofu init wird das Projekt initialisiert. Dabei werden:

- der Exoscale Provider heruntergeladen
- benötigte Abhängigkeiten installiert
- das Terraform Arbeitsverzeichnis vorbereitet

Zusätzlich wird automatisch ein .terraform Ordner erstellt.

### tofu plan

Mit tofu plan wird geprüft, welche Infrastruktur erstellt werden würde. Dabei zeigt OpenTofu:

- welche Ressourcen erstellt werden
- welche Änderungen durchgeführt werden
- ob die Konfiguration gültig ist

Dadurch kann die Infrastruktur vor der eigentlichen Erstellung überprüft werden.

### tofu apply

Mit tofu apply wird die Infrastruktur tatsächlich erstellt. OpenTofu erstellt dabei automatisch:

- die Ubuntu VM
- die Security Group
- die Firewall Regel
- die Netzwerkkonfiguration

Zusätzlich wird die Cloud-Init Datei automatisch an die VM übergeben. Nach erfolgreicher Erstellung startet Exoscale die VM automatisch.

## Automatische Betriebssystemkonfiguration mit Cloud-Init

Cloud-Init übernimmt die automatische Initialisierung und Konfiguration des Betriebssystems beim ersten Start der VM. Dabei werden automatisch folgende Schritte durchgeführt:

- Aktualisierung der Paketlisten
- Installation des nginx Webservers
- Aktivierung des nginx Dienstes
- Start des nginx Dienstes
- Erstellung der HTML-Webseite
- Erstellung des JSON API-Endpunkts
- Generierung technischer Systeminformationen
- Installation von Certbot
- Erstellung des Let's-Encrypt-Zertifikats
- automatische nginx HTTPS-Konfiguration
- Weiterleitung von HTTP auf HTTPS

Die erzeugten Dateien werden automatisch im nginx Webverzeichnis gespeichert:
```text
/var/www/html
```

Dadurch ist keine manuelle Serverkonfiguration notwendig.

## DNS-Konfiguration


Zusätzlich zur VM wird automatisch ein DNS A-Record erstellt. Der DNS-Eintrag verweist die Subdomain:
```text
blazovich-tobias.biti-fhb.org
```

automatisch auf die öffentliche IP-Adresse der VM. Dadurch kann die Infrastruktur über einen festen Domainnamen erreicht werden.

## HTTPS und Zertifikate
Für die Absicherung der HTTP-Endpunkte wird Let's Encrypt verwendet.

Die Zertifikatserstellung erfolgt automatisiert über Certbot während der Cloud-Init-Ausführung.

Dabei werden automatisch:

- Certbot installiert
- ein TLS-Zertifikat erstellt
- nginx für HTTPS konfiguriert
- HTTP auf HTTPS umgeleitet

Dadurch sind Webseite und API verschlüsselt erreichbar.
## Zugriff auf die Webseite und API

Nach erfolgreichem Apply wird die öffentliche IP-Adresse der VM ausgegeben. Dabei entstehen zwei unterschiedliche HTTP-Endpunkte:

```text
http://PUBLIC-IP
http://PUBLIC-IP/api.json

https://blazovich-tobias.biti-fhb.org
https://blazovich-tobias.biti-fhb.org/api.json
```
Der Endpunkt / stellt die technischen Systeminformationen als HTML-Webseite für die Darstellung im Browser bereit. 

Der Endpunkt /api.json liefert dieselben Informationen strukturiert im JSON-Format und dient als maschinenlesbare API.

Die öffentliche Erreichbarkeit wird über die Security Group und die freigegebenen Ports 80 und 443 ermöglicht.

## Erfassung der Systeminformationen

Die Webseite zeigt technische Informationen über die VM an. Dazu gehören unter anderem:

| Befehl | Zweck | 
|---|---| 
| hostname | Liefert den Hostnamen der virtuellen Maschine | 
| hostname -I | Gibt die öffentliche beziehungsweise lokale IP-Adresse der VM aus | 
| uname -r | Zeigt die verwendete Linux-Kernel-Version an | 
| free -h | Liefert Informationen über den verfügbaren und verwendeten Arbeitsspeicher | 
| df -h | Zeigt Informationen über die eingebundenen Dateisysteme und den verfügbaren Speicherplatz an | 
| lsblk | Listet vorhandene Blockgeräte und Storage-Informationen der VM auf | 
| lscpu | Liefert technische Informationen über die CPU und Prozessorarchitektur | 
| systemd-detect-virt | Erkennt den verwendeten Hypervisor beziehungsweise die Virtualisierungstechnologie | 

## GitHub Actions

Zusätzlich zur lokalen Ausführung wurde die Infrastrukturautomatisierung mit GitHub Actions umgesetzt. Dafür wurden zwei separate Workflows erstellt:

### create-infrastructure.yml

Dieser Workflow erstellt die Infrastruktur automatisch. Dabei werden folgende Schritte durchgeführt:

1. Repository auschecken
2. OpenTofu installieren
3. OpenTofu initialisieren
4. Infrastruktur mit tofu apply erstellen

Während der Workflow-Ausführung werden die Exoscale-Zugangsdaten automatisch über GitHub Secrets bereitgestellt. Verwendete Secrets:
```text
EXOSCALE_API_KEY
EXOSCALE_API_SECRET
````

### destroy-infrastructure.yml

Dieser Workflow löscht die Infrastruktur automatisiert. Dabei werden folgende Schritte durchgeführt:

1. Repository auschecken
2. OpenTofu installieren
3. OpenTofu initialisieren
4. Infrastruktur mit tofu destroy entfernen

Dadurch können alle erstellten Ressourcen automatisiert wieder gelöscht werden.

## Löschen der Infrastruktur

Die Infrastruktur kann mit folgendem Befehl gelöscht werden:

- tofu destroy

Dabei werden automatisch alle erstellten Ressourcen gelöscht. Dazu gehören:

- die VM
- die Security Group
- die Firewall Regeln

## Verwendung der Lösung

Vor der Verwendung müssen im GitHub Repository die Exoscale-Zugangsdaten als GitHub Secrets hinterlegt werden. Verwendete Secrets:`

```text
EXOSCALE_API_KEY
EXOSCALE_API_SECRET
```

Die Secrets werden während der Workflow-Ausführung automatisch als Environment Variables an OpenTofu übergeben.

### Erstellung der Infrastruktur über GitHub Actions

Die Infrastruktur kann automatisiert über GitHub Actions erstellt werden. Dafür muss im GitHub Repository der folgende Workflow gestartet werden:

- create-infrastructure.yml

Der Ablauf erfolgt dabei wie folgt:
```text
- GitHub Actions öffnen
- Den Workflow create-infrastructure.yml auswählen
- Run workflow ausführen
- Warten bis der Workflow erfolgreich abgeschlossen ist
```

Während der Workflow-Ausführung werden automatisch:

- das Repository ausgecheckt
- OpenTofu installiert
- die Infrastruktur initialisiert
- die Infrastruktur in Exoscale erstellt

Nach erfolgreichem Abschluss startet Exoscale die VM automatisch.

### Zugriff auf die Webseite und API

Nach erfolgreichem tofu apply wird die öffentliche IP-Adresse der VM automatisch ausgegeben. Die HTML-Webseite ist anschließend erreichbar unter:
```text
http://PUBLIC-IP
https://blazovich-tobias.biti-fhb.org
```
Zusätzlich steht ein JSON API-Endpunkt zur Verfügung:
```text
http://PUBLIC-IP/api.json
https://blazovich-tobias.biti-fhb.org/api.json
```
Die HTML-Webseite dient der visuellen Darstellung der technischen Systeminformationen. Der JSON-Endpunkt liefert dieselben Informationen strukturiert im JSON-Format und kann automatisiert abgefragt werden.
Da die DNS-Propagation sowie die Installation und Konfiguration der benötigten Pakete einige Minuten dauern können, ist die HTTPS-Konfiguration nicht sofort nach dem Start der VM verfügbar.

Die vollständige Bereitstellung von HTTPS und der TLS-Zertifikate kann daher mehrere Minuten in Anspruch nehmen.

### Löschen der Infrastruktur

Zum automatisierten Löschen der Infrastruktur kann der folgende GitHub Workflow verwendet werden:

- destroy-infrastructure.yml

Der Ablauf erfolgt dabei wie folgt:
```text
- GitHub Actions öffnen
- Den Workflow destroy-infrastructure.yml auswählen
- Run workflow ausführen
- Warten bis der Workflow erfolgreich abgeschlossen ist
```
Während der Workflow-Ausführung werden automatisch:

- das Repository ausgecheckt
- OpenTofu installiert
- die Infrastruktur initialisiert
- sämtliche Ressourcen gelöscht

Dabei werden unter anderem entfernt:

- die virtuelle Maschine
- die Security Group
- die Firewall-Regeln
- die Netzwerkkonfiguration

Zusätzlich kann die Infrastruktur lokal mit folgendem Befehl gelöscht werden:

- tofu destroy

Dadurch kann die Infrastruktur jederzeit reproduzierbar erstellt und wieder entfernt werden.