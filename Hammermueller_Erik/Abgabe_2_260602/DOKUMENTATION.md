# Dokumentation – Abgabe 2

## Autor

Erik Hammermüller

---

# Aufgabenstellung

Ziel dieser Aufgabe war die automatisierte Bereitstellung einer virtuellen Maschine in Exoscale.

Die VM soll über eine öffentliche URL erreichbar sein und technische Informationen über das System bereitstellen. Die Erstellung und Konfiguration der Infrastruktur erfolgt vollständig automatisiert mittels OpenTofu, GitHub Actions und CloudInit.

---

# Verwendete Technologien

* OpenTofu
* Exoscale
* GitHub Actions
* CloudInit
* Ubuntu 24.04 LTS
* Nginx

---

# Projektstruktur

```text
.github/
└── workflows/
    ├── deploy.yml
    └── destroy.yml

Abgabe_2_ErikHammermueller_260602/
├── infra/
│   ├── main.tf
│   ├── provider.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── cloud-init.yaml
│
├── README.md
│
└── DOKUMENTATION.md
```

---

# Infrastruktur

Die Infrastruktur wird mittels OpenTofu erstellt und besteht aus folgenden Komponenten:

## SSH-Key

Ein SSH-Key wird automatisch bei Exoscale registriert und der VM zugewiesen.

## Security Group

Für die VM wird eine Security Group erstellt.

Freigegebene Ports:

| Port | Protokoll | Verwendung |
| ---- | --------- | ---------- |
| 22   | TCP       | SSH        |
| 80   | TCP       | HTTP       |

## Virtuelle Maschine

Eigenschaften der VM:

* Betriebssystem: Ubuntu 24.04 LTS
* Typ: standard.micro
* Speicherplatz: 10 GB
* Standort: at-vie-1

---

# CloudInit-Konfiguration

Nach dem Start der VM wird CloudInit automatisch ausgeführt.

Dabei werden folgende Schritte durchgeführt:

1. Aktualisierung des Systems
2. Installation von nginx
3. Erstellung einer HTML-Webseite
4. Erstellung eines JSON-Endpunkts
5. Start des nginx-Webservers

Dadurch ist keine manuelle Konfiguration der VM notwendig.

---

# Webseite

Nach erfolgreichem Deployment ist die Webseite über die öffentliche IP-Adresse der VM erreichbar.

Beispiel:

```text
http://<VM-IP>
```

Auf der Webseite werden verschiedene technische Informationen der VM dargestellt:

* Hostname
* IP-Adresse
* Kernel-Version
* Betriebssystem
* CPU-Kerne
* Arbeitsspeicher
* Festplattengröße
* Freier Speicherplatz
* Uptime

---

# JSON-API

Zusätzlich wird ein API-Endpunkt bereitgestellt:

```text
http://<VM-IP>/api.json
```

Beispielausgabe:

```json
{
  "hostname": "vm-example",
  "ip": "123.123.123.123",
  "kernel": "6.x.x",
  "os": "Ubuntu 24.04 LTS"
}
```

Die API liefert dieselben technischen Informationen in maschinenlesbarer Form.

---

# GitHub Actions

Für die Automatisierung wurden zwei Workflows erstellt.

## Deploy Infrastructure

Der Deploy-Workflow erstellt die komplette Infrastruktur automatisch.

Ablauf:

1. Repository auschecken
2. OpenTofu installieren
3. OpenTofu initialisieren
4. Infrastruktur erstellen

Verwendete Secrets:

* EXOSCALE_API_KEY
* EXOSCALE_API_SECRET
* SSH_PUBLIC_KEY

---

## Destroy Infrastructure

Der Destroy-Workflow dient zum Entfernen der Infrastruktur.

Ablauf:

1. Repository auschecken
2. OpenTofu installieren
3. OpenTofu initialisieren
4. OpenTofu Destroy ausführen

---

# Verwendung

## Infrastruktur erstellen

1. GitHub öffnen
2. Actions auswählen
3. Deploy Infrastructure starten
4. Nach erfolgreichem Lauf die ausgegebene IP-Adresse aufrufen

## Infrastruktur entfernen

1. GitHub öffnen
2. Actions auswählen
3. Destroy Infrastructure starten

---

# Hinweise zur Infrastruktur

Die Infrastruktur wird automatisiert mittels OpenTofu über GitHub Actions erstellt.

Der Deploy-Workflow erstellt die benötigten Exoscale-Ressourcen, darunter die virtuelle Maschine, die Security Group sowie den SSH-Key.

Bei der Umsetzung wurde auf eine einfache und nachvollziehbare Lösung für den Übungszweck geachtet. Der OpenTofu-State wird daher nicht in einem Remote Backend gespeichert, sondern nur während der Ausführung des jeweiligen GitHub-Action-Workflows verwendet.

In einer produktiven Umgebung wäre die Verwendung eines persistenten Remote Backends empfehlenswert. Dadurch könnten Deploy- und Destroy-Vorgänge jederzeit auf denselben Infrastrukturzustand zugreifen und Ressourcen zuverlässig verwalten oder entfernen.

Da im Rahmen dieser Übung kein persistenter State verwendet wird, können bereits erstellte Ressourcen von einem späteren Destroy-Lauf nicht automatisch erkannt werden. Die Erstellung der Infrastruktur funktioniert jedoch vollständig automatisiert über den Deploy-Workflow.

---

# Besonderheiten

Die gesamte Infrastruktur wird automatisiert bereitgestellt.

Die Konfiguration des Betriebssystems erfolgt ausschließlich über CloudInit.

Die Informationen werden sowohl als HTML-Webseite als auch als JSON-API bereitgestellt.

---

# Fazit

Die Aufgabe wurde mithilfe von OpenTofu, GitHub Actions, Exoscale und CloudInit umgesetzt.

Durch die Automatisierung kann die komplette Infrastruktur reproduzierbar erstellt werden. Nach dem Deployment steht eine Ubuntu-VM mit nginx-Webserver zur Verfügung, welche technische Informationen über das System sowohl als Webseite als auch über einen JSON-Endpunkt bereitstellt.
