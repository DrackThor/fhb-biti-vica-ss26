# Herangehensweise
## Analyse der Aufgabenstellung

Zu Beginn wurde die Aufgabenstellung analysiert und in einzelne technische Anforderungen unterteilt.

Die Aufgabenstellung verlangt:

- die automatisierte Erstellung einer VM in Exoscale
- die Bereitstellung eines HTTP-Endpunkts
- die automatische Betriebssystemkonfiguration
- die Verwendung von OpenTofu
- die Verwendung von GitHub Actions
- die Bereitstellung einer HTML-Webseite und einer JSON API über unterschiedliche Endpunkte
- die Verwendung von DNS und HTTPS
- die automatische Erstellung eines TLS-Zertifikat

Zusätzlich sollten sensible Zugangsdaten nicht direkt im Quellcode gespeichert werden.

## Auswahl der Technologien
Für die Umsetzung wurden folgende Technologien ausgewählt:
| Datei | Zweck | 
|---|---| 
| OpenTofu | Automatisierte Erstellung der Infrastruktur | 
| Exoscale | Bereitstellung der Cloud-Infrastruktur | 
| Cloud-Init | Automatische Konfiguration der VM |
| nginx | Bereitstellung der HTTP-Endpunkte | 
| GitHub Actions | Automatisierung der Infrastrukturverwaltung |
| Certbot | Automatische Erstellung von HTTPS-Zertifikaten |
| Let's Encrypt | Bereitstellung kostenloser TLS-Zertifikate |
| Exoscale DNS | Verwaltung der DNS-Einträge |

## Planung der Infrastruktur

Die Infrastruktur wurde bewusst einfach und übersichtlich gehalten.

Geplant wurden folgende Komponenten:

- Ubuntu 22.04 LTS VM
- Exoscale Security Group
- HTTP Firewall-Regel
- Cloud-Init-Konfiguration
- nginx Webserver
- HTML-Webseite
- JSON API-Endpunkt
- DNS A-Record
- HTTPS Firewall-Regel
- Certbot für Let's-Encrypt-Zertifikate

Die VM sollte automatisch eine öffentliche IP-Adresse erhalten und anschließend direkt erreichbar sein.
Zusätzlich wurde geplant, die Konfiguration auf mehrere Terraform-Dateien aufzuteilen, damit die einzelnen Aufgabenbereiche logisch getrennt bleiben.

## Repository-Struktur
```text
fhb-biti-vica-ss26
│
├── .github
│   └── workflows
│       ├── blazovich-tobias_create-infrastructure.yml
│       └── blazovich-tobias_destroy-infrastructure.yml
├── Blazovich_Tobias
    └── Abgabe_2_280526 
        ├── terraform/ 
        │   ├── cloud-init.yaml 
        │   ├── main.tf 
        │   ├── dns.tf
        │   ├── outputs.tf
        │   ├── variables.tf 
        │   └── versions.tf 
        ├── .gitignore 
        ├── FUNKTIONSWEISE.md 
        ├── HERANGEHENSWEISE.md
        └── README.md
```
Die Dateien im Abgabeordner ABGABE_2_280526 haben folgenden Zweck:

| Datei | Aufgabe |
|---|---|
| `.gitignore` | Verhindert, dass lokale OpenTofu-Dateien wie `.terraform/` und `terraform.tfstate` committed werden. |
| `create-infrastructure.yml` | GitHub Actions Workflow zum automatisierten Erstellen der Infrastruktur. |
| `destroy-infrastructure.yml` | GitHub Actions Workflow zum automatisierten Löschen der Infrastruktur. |
| `versions.tf` | Definiert die benötigte OpenTofu/Terraform-Version und den Exoscale Provider. |
| `main.tf` | Erstellt die Exoscale-VM, Security Group und Firewall-Regeln. |
| `dns.tf` | Erstellt den DNS-A-Record, der die Subdomain auf die öffentliche IP-Adresse der VM zeigt. |
| `variables.tf` | Enthält zentrale Variablen wie Exoscale API Key, API Secret und Zone. |
| `outputs.tf` | Gibt nach dem Erstellen die Website-URL und API-URL aus. |
| `cloud-init.yaml` | Installiert nginx und erstellt automatisch die HTML-Webseite sowie den JSON-Endpunkt und konfiguriert HTTPS mit Certbot`/api.json`. |
| `FUNKTIONSWEISE.md` | Beschreibt die technische Funktionsweise der Lösung. |
| `HERANGEHENSWEISE.md` | Beschreibt Planung, Aufbau und Vorgehensweise bei der Umsetzung. |


## Verwendung von OpenTofu
Für die Automatisierung der Infrastruktur wurde OpenTofu verwendet. 

Die OpenTofu Konfiguration übernimmt dabei:

- die Verbindung zum Exoscale Provider
- die Erstellung der VM
- die Erstellung der Security Group
- die Firewall Konfiguration
- die Übergabe der Cloud-Init Datei an die VM

Die Infrastruktur wurde deklarativ beschrieben, damit sie jederzeit reproduzierbar erstellt oder gelöscht werden kann.
Für sensible Zugangsdaten wurden Environment Variables verwendet. Dadurch befinden sich keine API-Zugangsdaten direkt im Git-Repository.

## Verwendung von Cloud-Init

Für die automatische Konfiguration der VM wurde Cloud-Init verwendet. Cloud-Init führt beim ersten Start der VM automatisch Konfigurationsschritte aus.Dadurch musste keine manuelle Konfiguration durchgeführt werden.

Cloud-Init übernimmt in der Lösung:

- Aktualisierung der Paketquellen
- Installation des nginx Webservers
- Aktivierung und Start des nginx Dienstes
- Erstellung der HTML-Webseite
- Erstellung des JSON API-Endpunkts
- Generierung technischer Systeminformationen
- Installation von Certbot
- automatische Erstellung des HTTPS-Zertifikats
- automatische nginx HTTPS-Konfiguration

Dadurch werden sowohl die Webseite als auch die API vollständig automatisiert erstellt.

## Umsetzung der HTTP-Endpunkte

Als HTTP Dienst wurde nginx verwendet. Nach dem Start der VM stellt nginx automatisch eine Webseite bereit.
Die HTML Webseite ist über folgenden Endpunkt erreichbar:
```text
https://blazovich-tobias.biti-fhb.org
http://PUBLIC-IP
```
Zusätzlich wird ein JSON API Endpunkt bereitgestellt:
```text
https://blazovich-tobias.biti-fhb.org/api.json
http://PUBLIC-IP/api.json
```
Die Informationen werden automatisiert während der Cloud-Init-Ausführung erzeugt und anschließend über nginx öffentlich bereitgestellt. Für die sichere Bereitstellung der Endpunkte wird automatisch ein Let's-Encrypt-Zertifikat erstellt. Die HTTPS-Konfiguration erfolgt automatisiert über Certbot während der Cloud-Init-Ausführung.

Dabei werden automatisch:

- Certbot installiert
- das TLS-Zertifikat erstellt
- nginx für HTTPS konfiguriert
- HTTP automatisch auf HTTPS umgeleitet

## Automatisierung mit GitHub Actions

Für die Automatisierung wurden GitHub Actions verwendet.

Es wurden zwei Workflows erstellt:

- create-infrastructure.yml
- destroy-infrastructure.yml

Die Workflows übernehmen automatisch:

- das Herunterladen des Repositories
- die Installation von OpenTofu
- die Initialisierung der Infrastruktur
- das Erstellen oder Löschen der Ressourcen

Die Exoscale-Zugangsdaten werden dabei sicher über GitHub Secrets bereitgestellt.

Verwendete Secrets:
```text
EXOSCALE_API_KEY
EXOSCALE_API_SECRET
```

## Vorteile der gewählten Lösung

Die gewählte Lösung bietet mehrere Vorteile:

- vollständige Automatisierung der Infrastruktur
- reproduzierbare Erstellung der Umgebung
- einfache Wartung durch strukturierte Dateien
- automatische Betriebssystemkonfiguration
- keine manuelle Serverkonfiguration notwendig
- schnelle Bereitstellung der Infrastruktur
- einfache Erweiterbarkeit der Lösung

Durch die Kombination aus OpenTofu, CloudInit und GitHub Actions konnte eine vollständig automatisierte und reproduzierbare Infrastruktur umgesetzt werden.