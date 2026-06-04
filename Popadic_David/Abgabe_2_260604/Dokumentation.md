# Abgabe 2 – Exoscale VM mit OpenTofu und CloudInit

## Ziel der Aufgabe

Ziel dieser Aufgabe war die automatisierte Bereitstellung einer virtuellen Maschine in Exoscale mittels OpenTofu. Die VM sollte über einen HTTP-Endpunkt erreichbar sein und technische Informationen über das System bereitstellen. Die Betriebssystemkonfiguration sollte vollständig automatisiert über CloudInit erfolgen.

## Verwendete Technologien

* OpenTofu
* Exoscale
* Ubuntu 24.04 LTS
* CloudInit
* Nginx
* GitHub Actions

## Herangehensweise

Zu Beginn wurde die Aufgabenstellung analysiert und in einzelne technische Anforderungen unterteilt.

Die Aufgabenstellung verlangte die automatisierte Erstellung einer virtuellen Maschine in Exoscale, die Bereitstellung eines HTTP-Endpunkts sowie die automatische Konfiguration des Betriebssystems mittels CloudInit.

Für die Umsetzung wurden OpenTofu, Exoscale, CloudInit und nginx verwendet. Die Infrastruktur wurde zunächst lokal mit OpenTofu entwickelt und getestet. Anschließend wurde eine Ubuntu 24.04 LTS VM in Exoscale erstellt.

Um den Zugriff auf die VM zu ermöglichen, wurde eine Security Group eingerichtet. Dabei wurden die benötigten Ports für SSH (22) und HTTP (80) freigegeben.

Die Betriebssystemkonfiguration erfolgt vollständig automatisiert über CloudInit. Beim ersten Start der VM werden die Paketlisten aktualisiert, nginx installiert und eine HTML-Webseite mit technischen Informationen zur VM erstellt.

Für die Automatisierung der Infrastruktur wurden zusätzlich GitHub Actions Workflows erstellt. Ein Workflow dient zum Erstellen der Infrastruktur und ein weiterer Workflow zum Löschen der Infrastruktur. Dadurch kann die gesamte Umgebung automatisiert bereitgestellt oder entfernt werden.

Die Lösung wurde mehrfach mit den Befehlen `tofu validate`, `tofu plan` und `tofu apply` überprüft und getestet. Anschließend wurde die Erreichbarkeit der Webseite über die öffentliche IP-Adresse der VM kontrolliert.

## Erstellung der Infrastruktur

Die Infrastruktur wird mit OpenTofu erstellt. Über die Exoscale API wird automatisch eine Ubuntu-VM in der Zone AT-VIE-1 bereitgestellt.

Für die Erstellung werden folgende Befehle verwendet:

* tofu init
* tofu validate
* tofu plan
* tofu apply

Nach erfolgreichem Apply wird die VM automatisch in Exoscale erstellt und gestartet.

## Security Group

Zusätzlich wird eine Security Group erstellt.

Folgende Ports werden freigegeben:

| Port | Zweck        |
| ---- | ------------ |
| 22   | SSH-Zugriff  |
| 80   | HTTP-Zugriff |

Dadurch kann auf die VM per SSH zugegriffen und die Webseite im Browser aufgerufen werden.

## CloudInit

Für die automatische Konfiguration des Betriebssystems wird CloudInit verwendet.

CloudInit übernimmt folgende Aufgaben:

* Aktualisierung der Paketlisten
* Installation von nginx
* Erstellung der HTML-Webseite
* Aktivierung des nginx-Dienstes
* Start des nginx-Webservers

Dadurch ist keine manuelle Installation oder Konfiguration des Webservers erforderlich.

## Bereitstellung der Webseite

Die Webseite wird automatisch durch CloudInit erstellt und im nginx-Webverzeichnis gespeichert.

Über die öffentliche IP-Adresse der VM kann die Webseite aufgerufen werden.

Die Webseite stellt folgende technische Informationen bereit:

* Hostname
* IP-Adresse
* Betriebssystem
* RAM
* CPU
* Storage
* Zone
* Hypervisor

## Automatisierung mit GitHub Actions

Für die Automatisierung der Infrastruktur wurden zwei GitHub Actions Workflows erstellt:

* create.yml
* destroy.yml

Der Workflow `create.yml` erstellt die Infrastruktur automatisch.

Der Workflow `destroy.yml` löscht die Infrastruktur automatisch.

Die Authentifizierung erfolgt über folgende GitHub Secrets:

* EXOSCALE_API_KEY
* EXOSCALE_API_SECRET

Dadurch müssen keine Zugangsdaten direkt im Quellcode gespeichert werden.

## Funktionsweise der Lösung

Die Infrastruktur wird mit OpenTofu beschrieben und automatisiert erstellt.

Während der Erstellung der VM wird die CloudInit-Datei an die Instanz übergeben. Beim ersten Start führt CloudInit automatisch die definierten Konfigurationsschritte aus.

Anschließend wird nginx gestartet und die vorbereitete Webseite mit den technischen Informationen der VM bereitgestellt.

Die Webseite kann über die öffentliche IP-Adresse der VM im Browser aufgerufen werden.

## Verwendung

### Infrastruktur über GitHub Actions erstellen

1. GitHub Repository öffnen
2. Actions auswählen
3. Workflow "create.yml" starten
4. Warten bis der Workflow erfolgreich abgeschlossen wurde

### Infrastruktur über GitHub Actions löschen

1. GitHub Repository öffnen
2. Actions auswählen
3. Workflow "destroy.yml" starten
4. Warten bis der Workflow erfolgreich abgeschlossen wurde

### Alternative lokale Ausführung

## Erstellen

```bash
tofu init
tofu apply
```

## Löschen

```bash
tofu destroy
```

## Ergebnis

Die virtuelle Maschine wird vollständig automatisiert mit OpenTofu erstellt. Die Betriebssystemkonfiguration erfolgt automatisch über CloudInit.

Nach erfolgreicher Erstellung ist die VM über ihre öffentliche IP-Adresse erreichbar. Über den HTTP-Endpunkt kann die automatisch erzeugte Webseite aufgerufen werden.

Die Webseite stellt technische Informationen über die virtuelle Maschine bereit, darunter Hostname, Betriebssystem, RAM, CPU, Storage, Zone und Hypervisor.

Durch die Kombination aus OpenTofu, CloudInit und GitHub Actions kann die Infrastruktur reproduzierbar erstellt, verwaltet und gelöscht werden.

## Vorteile der Lösung

Die gewählte Lösung bietet folgende Vorteile:

* Vollständige Automatisierung der Infrastruktur
* Reproduzierbare Bereitstellung der Umgebung
* Automatische Betriebssystemkonfiguration
* Keine manuelle Serverkonfiguration erforderlich
* Einfache Wartung und Erweiterbarkeit
* Sichere Verwendung von API-Zugangsdaten über Variablen und GitHub Secrets

## Verwendete Dateien

| Datei                     | Aufgabe                                                      |
| ------------------------- | ------------------------------------------------------------ |
| main.tf                   | Erstellt die Exoscale VM, Security Group und Firewall-Regeln |
| variables.tf              | Enthält die benötigten Variablen                             |
| outputs.tf                | Enthält Ausgaben der Infrastruktur                           |
| cloud-init.yaml           | Automatische Konfiguration der VM                            |
| create.yml                | GitHub Workflow zum Erstellen der Infrastruktur              |
| destroy.yml               | GitHub Workflow zum Löschen der Infrastruktur                |
| .gitignore                | Verhindert das Hochladen lokaler Terraform-Dateien           |
| Dokumentation.md          | Dokumentation der Lösung                                     |