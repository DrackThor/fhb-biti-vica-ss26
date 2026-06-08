# Virtualisierung Abgabe 2 - Exoscale VM Automation

## Autor

Ebin Brica

---

## Ziel der Aufgabe

Ziel dieser Aufgabe war es, eine vollständig automatisierte Infrastruktur in Exoscale bereitzustellen.

Dabei wird eine virtuelle Maschine erstellt, welche über einen HTTP Endpunkt erreichbar ist und technische Informationen über das System bereitstellt.

Die komplette Erstellung und Löschung der Infrastruktur erfolgt automatisiert über GitHub Actions mit OpenTofu/Terraform.

---

## Verwendete Technologien

- Exoscale Cloud Plattform
- OpenTofu / Terraform
- GitHub Actions
- Ubuntu 24.04 LTS
- CloudInit
- Apache Webserver

---

## Aufbau der Lösung

Die Infrastruktur besteht aus folgenden Komponenten:

- einer Ubuntu VM in Exoscale
- einer Security Group für den Netzwerkzugriff
- HTTP Zugriff über Port 80
- automatischer Betriebssystemkonfiguration über CloudInit
- Apache Webserver für die Ausgabe der Informationen

---

## Terraform / OpenTofu

Die komplette Infrastruktur wird über OpenTofu erstellt.

Terraform erstellt automatisch:

- Exoscale Compute Instance
- Security Group
- Firewall Regeln
- Ubuntu Template Auswahl
- CloudInit Übergabe

Die Zugangsdaten werden nicht direkt im Code gespeichert, sondern über GitHub Secrets verwendet.

Benötigte Secrets:

```
EXOSCALE_API_KEY
EXOSCALE_API_SECRET
```

---

## GitHub Actions Workflows

Es existieren zwei Workflows.

### Create Infrastructure

Dieser Workflow erstellt die komplette Umgebung:

Ablauf:

1. Repository wird geladen
2. OpenTofu wird installiert
3. Terraform Initialisierung wird durchgeführt
4. Infrastruktur wird in Exoscale erstellt
5. Terraform State wird gespeichert

Start:

```
Actions
→ Create Infrastructure
→ Run workflow
```

---

### Destroy Infrastructure

Dieser Workflow entfernt die erstellte Infrastruktur wieder.

Dabei werden gelöscht:

- virtuelle Maschine
- Security Group
- zugehörige Ressourcen

Start:

```
Actions
→ Destroy Infrastructure
→ Run workflow
```

---

## CloudInit

Die komplette Konfiguration des Betriebssystems erfolgt automatisch über CloudInit.

CloudInit führt folgende Schritte aus:

1. Aktualisieren der Paketquellen
2. Installation von Apache
3. Installation benötigter Tools
4. Starten des Webservers
5. Erstellen der HTML Webseite
6. Erstellen des JSON API Endpunktes

Es ist kein manueller Zugriff auf die VM notwendig.

---

## Bereitgestellte Endpunkte

Nach erfolgreicher Erstellung gibt es zwei HTTP Endpunkte.

### HTML Webseite

```
http://<PUBLIC-IP>/
```

Die Webseite zeigt technische Informationen der VM:

- Public IP Adresse
- Kernel Version
- Arbeitsspeicher
- Speicherplatz
- Dateisystem
- Hypervisor

---

### JSON API

```
http://<PUBLIC-IP>/api
```

Beispiel:

```json
{
  "public_ip": "194.182.172.179",
  "kernel": "6.8.0-117-generic",
  "memory": "454Mi",
  "storage": "8.7G",
  "filesystem": "ext4",
  "hypervisor": "kvm"
}
```

---

## Test der Lösung

Die Lösung wurde erfolgreich getestet.

Erfolgreich durchgeführt:

- Erstellung über GitHub Actions
- automatische VM Erstellung
- automatische CloudInit Konfiguration
- HTML Endpoint erreichbar
- JSON API Endpoint erreichbar
- Löschen über Destroy Workflow

---

## Ergebnis

Die komplette Infrastruktur kann automatisiert erstellt und gelöscht werden.

Die VM stellt ihre technischen Informationen automatisch über eine Webseite und eine JSON API bereit.