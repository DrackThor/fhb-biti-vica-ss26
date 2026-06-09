# Dokumentation – Abgabe 2

## Beschreibung

Diese Lösung erstellt automatisiert eine virtuelle Maschine in Exoscale.

Die Infrastruktur wird mit OpenTofu/Terraform erstellt und gelöscht.

Die VM verwendet Ubuntu 22.04 und wird automatisch über CloudInit konfiguriert.

Auf der VM läuft ein nginx Webserver, der technische Informationen über die VM bereitstellt.

Zusätzlich wird ein JSON API Endpoint angeboten.

---

# Verwendete Technologien

- Exoscale
- OpenTofu / Terraform
- GitHub Actions
- CloudInit
- Ubuntu 22.04
- nginx

---

# Infrastruktur

Die Infrastruktur besteht aus:

- einer Ubuntu VM
- einer Security Group
- HTTP Zugriff auf Port 80
- SSH Zugriff auf Port 22

---

# Workflow – Infrastruktur erstellen

Die Infrastruktur wird über GitHub Actions erstellt.

Vorgehensweise:

1. GitHub Repository öffnen
2. Actions öffnen
3. Workflow „Create Exoscale Infrastructure“ starten
4. OpenTofu erstellt automatisch die Infrastruktur

---

# Workflow – Infrastruktur löschen

Zum Löschen der Infrastruktur:

1. GitHub öffnen
2. Actions öffnen
3. Workflow „Destroy Exoscale Infrastructure“ starten
4. OpenTofu löscht automatisch alle Ressourcen

---

# CloudInit

CloudInit installiert automatisch:

- nginx
- jq

Zusätzlich wird automatisch:

- eine HTML Website erstellt
- ein JSON API Endpoint erstellt

---

# Website

Die Website zeigt technische Informationen der VM:

- Hostname
- Public IP
- Betriebssystem
- Kernel
- Speicher
- Storage
- Filesystem
- Hypervisor

---

# API

Die API liefert dieselben Informationen im JSON Format.

Endpoint:

```text
/api/
