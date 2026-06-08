# Abgabe 2 – VM-Info Webserver auf Exoscale

VICA SS26 | FH Burgenland | Edison Blakaj

## Projektbeschreibung

In diesem Projekt erstellen wir automatisiert eine Ubunut-VM in Exoscale, die technische Information über die Maschine als Website und JSON API bereitstellt. Alles geschieht über Terraform und OpenTofu via GitHub Actions, hier kann die VM deployed und destroyed werden. Die Konfiguration der VM erfolgt vollkommen autimatisch durch eine cloud-init Datei.

## Architektur

```
GitHub Actions
    |
    | tofu apply          (Deploy Workflow)
    | exo instance delete (Destroy Workflow)
    v
Exoscale AT-VIE-1
    |- Security Group (Port 80, 443, 22)
    +- Ubuntu 24.04 VM
           |
           | Cloud-Init (erster Boot)
           v
       nginx Webserver
           |- GET /       -> HTML Dashboard
           +- GET /api    -> JSON API
```

## Verzeichnisstruktur

```
fhb-biti-vica-ss26/
├── .github/
│   └── workflows/
│       ├── blakaj_deploy.yml
│       └── blakaj_destroy.yml
└── Edison_Blakaj/
    └── Abgabe_2_260517/
        ├── terraform/
        │   ├── main.tf            Exoscale Ressourcen (VM, Security Group)
        │   ├── variables.tf       Eingabevariablen
        │   ├── outputs.tf         IP-Adresse und URLs nach dem Deploy
        │   └── cloud-init.yaml    Automatische VM-Konfiguration beim ersten Boot
        └── README.md
```

## Voraussetzungen

- Exoscale Account mit API Key (Rolle: User)
- GitHub Repository mit folgenden Secrets:

| Secret | Beschreibung |
|---|---|
| `EXOSCALE_API_KEY` | Exoscale API Key |
| `EXOSCALE_API_SECRET` | Exoscale API Secret |

## Verwendung

### Infrastruktur erstellen

1. GitHub Repository → Tab **Actions**
2. Workflow **"Deploy Infrastructure"** auswählen
3. **"Run workflow"** klicken und bestätigen
4. Nach ca. 3–5 Minuten zeigt der Schritt **"Show outputs"** die fertige IP-Adresse

Hinweis: Cloud-Init benötigt nach dem ersten VM-Start ca. 2 Minuten um nginx zu installieren und das Info-Skript auszuführen. Danach sind alle Informationen aufrufbereit über die IP Adresse die man in Exoscale finden kann.

### Infrastruktur löschen

1. Workflow **"Destroy Infrastructure"** auswählen
2. **"Run workflow"** klicken und bestätigen
3. Der Workflow löscht VM und Security Group direkt über die Exoscale CLI

## Endpunkte

| Endpunkt | Beschreibung |
|---|---|
| `http://<IP>/` | HTML Dashboard mit allen VM-Informationen |
| `http://<IP>/api` | Dieselben Daten als JSON |

Das Dashboard aktualisiert sich automatisch alle 30 Sekunden. Die Systemdaten werden alle 5 Minuten durch einen systemd Timer neu eingelesen.

## Dargestellte VM-Informationen

- Betriebssystem: Distribution, Kernel-Version, Kernel-Typ, Architektur
- CPU: Modell, Kerne, Hypervisor-Vendor, Virtualisierungstyp
- Arbeitsspeicher: Gesamt, verwendet, frei, verfügbar
- Storage: Block Devices, Dateisysteme mit Größe und Auslastung
- Netzwerk: Öffentliche IP, Interfaces mit Adressen, Default Route
- System: Uptime, Load Average, Prozessanzahl
- Cloud-Metadaten: Provider, Instance-ID, Zone

## Technologien

| Tool | Zweck |
|---|---|
| OpenTofu 1.8 | Infrastructure as Code |
| Exoscale Provider ~0.59 | Terraform Provider für Exoscale |
| Exoscale CLI | Direktes Löschen der VM beim Destroy |
| GitHub Actions | CI/CD Workflows für Deploy und Destroy |
| Ubuntu 24.04 LTS | Betriebssystem der VM |
| Cloud-Init | Automatische Erstkonfiguration beim ersten Boot |
| nginx | Webserver |
| Python 3 | Systemdaten sammeln, HTML und JSON generieren |
| systemd | Service- und Timer-Management |

## Aufgetretene Probleme

Im laufe der Konzeption und Entwicklung dieser Projektaufgabe sind diverse Probleme aufgetreten. Als Hilfe um die Probleme zu lösen wurden Internetrecherchen genutzt aber auch die KI, alles in der Trial and Error Methodik. Nach mehreren Versuchen hat jedoch die Ausführung funktioniert.

**Terraform Provider API**
Der Exoscale Provider `~0.59` unterstützt `exoscale_compute_template` nicht mehr als Data Source – der korrekte Name ist `exoscale_template`. Zusätzlich wird das `family` Argument nicht unterstützt und musste entfernt werden.

**nginx /api Endpunkt**
Der `/api` Endpunkt lieferte anfangs einen 404-Fehler. Das Problem lag darin dass nginx nach einer Datei namens `api` sucht, das Python-Skript aber nur `api.json` schrieb. Die Lösung war, das Skript beide Dateien schreiben zu lassen – `api.json` und `api` – sodass nginx die Datei ohne spezielle Location-Konfiguration findet.

**Terraform Destroy ohne State**
Terraform benötigt den State um zu wissen welche Ressourcen gelöscht werden sollen. Da der State nach dem Deploy nicht persistiert wurde, schlug der Destroy-Workflow wiederholt fehl. Die finale Lösung war der Wechsel von Terraform zu einem direkten CLI-basierten Ansatz im Destroy-Workflow: die Exoscale CLI löscht VM und Security Group direkt über ihren Namen – ohne State.

**Exoscale CLI Installation**
Der ursprüngliche Download-Pfad `exo_linux_amd64.tar.gz` existiert in neueren Versionen nicht mehr. Der Dateiname hat sich zu `exoscale-cli_*_linux_amd64.tar.gz` geändert. Die sauberste Lösung war das offizielle Install-Script von Exoscale zu verwenden.

**GitHub Actions Workflow-Pfad**
GitHub Actions erkennt Workflows nur unter `.github/workflows/` im Repository-Root, nicht in Unterordnern. Die Workflows mussten daher im Root abgelegt werden, nicht im Abgabe-Unterordner.

## Persönliche Anmerkung

Diese Übung hat mir ungemein viel Spaß gemacht. Ich liebe es wenn Aufgaben, selbst mit KI-Unterstützung (Danke Anthropic an dieser, komplex bleiben und viel Zeit sowie Denkarbeit erfordern. 
Genau das hatte ich hier mit dieser Aufgabe, ich habe mir das Programmieren mit KI immer recht simple vorgestellt (und bei sehr simplen Scripts kann ich mir vorstellen, dass das auch so ist), aber das war hier nicht ganz der Fall.
Die Maschine wollte nicht starten, die API Abfrage hat nicht funktioniert, dann hat "Destroy" mal funktioniert, gegen Ende aber garnicht mehr. Viele Versuche die Probleme zu Lösen aber im ganzen haben mir auch diese Probleme geholfen ein Verständnis über A) die Nutzung von KI im Kontext zu Programmieren und B) wie IaC weiters funktioniert und wie cool das ist eigentlich auf Knopfdruck Maschinen zu erstellen und zu löschen, zu bekommen.
Ist eine erfrischende Abwechslung und auch wenn ich mich in der Arbeit wohl kaum mit diesem Thema auseinander setzen werde, werde ich das Wissen dennoch fest beibehalten.
