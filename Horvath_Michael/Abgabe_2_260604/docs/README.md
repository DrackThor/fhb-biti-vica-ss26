# Abgabe 2 – Automatisierte VM-Infrastruktur auf Exoscale

**Autor:** Michael Horvath  
**Kurs:** BITI VICA SS26  
**Datum:** Juni 2026

---

## Überblick

Diese Lösung erstellt automatisiert eine virtuelle Maschine auf Exoscale, die über eine öffentliche IP-Adresse erreichbar ist und technische Details über sich selbst als Website und JSON-API bereitstellt.

### Erreichbare Endpunkte

| Endpunkt | Beschreibung |
|----------|-------------|
| `http://<IP>/` | HTML-Website mit VM-Informationen |
| `http://<IP>/api/info.json` | JSON-API mit VM-Informationen |

---

## Technologien

| Technologie | Zweck |
|-------------|-------|
| Terraform | Erstellung und Löschung der Exoscale Infrastruktur |
| Exoscale | Cloud-Anbieter für die VM (Zone: at-vie-1, Wien) |
| Exoscale SOS | S3-kompatibler Object Storage für den Terraform Remote State |
| CloudInit | Automatische Konfiguration der VM beim ersten Boot |
| GitHub Actions | Automatisierung der Create/Destroy Workflows |
| nginx | Webserver auf der VM |
| Bash | Script zur Sammlung und Darstellung der VM-Informationen |

---

## Projektstruktur

```
Horvath_Michael/
├── Abgabe_2_260604/
│   ├── terraform/
│   │   ├── main.tf           # Hauptkonfiguration (VM, Firewall-Regeln)
│   │   ├── variables.tf      # Variablen (Zone, VM-Typ, Disk-Größe, API Keys)
│   │   ├── outputs.tf        # Outputs (IP-Adresse, VM-Name, URL)
│   │   ├── cloud-init.yaml   # Automatische VM-Konfiguration beim Boot
│   │   └── .gitignore        # Terraform State und Cache von Git ausschließen
│   └── docs/
│       └── README.md         # Diese Dokumentation
└── .github/
    └── workflows/
        ├── create-infra.yml  # Workflow: Infrastruktur erstellen
        └── destroy-infra.yml # Workflow: Infrastruktur löschen
```

---

## Funktionsweise

### 1. Terraform erstellt die Infrastruktur

Terraform definiert und erstellt folgende Ressourcen auf Exoscale:

- **Security Group** mit Firewall-Regeln für Port 22 (SSH), 80 (HTTP) und 443 (HTTPS)
- **Compute Instance** (Ubuntu 24.04 LTS, standard.medium, 10GB Disk, Zone at-vie-1)

Die API Keys werden nie im Code gespeichert, sondern als GitHub Secrets übergeben und von Terraform über die Umgebungsvariablen `TF_VAR_exoscale_api_key` und `TF_VAR_exoscale_api_secret` eingelesen.

Der Terraform State wird in einem **S3-kompatiblen Remote Backend** auf Exoscale Object Storage (SOS) gespeichert (Bucket: `mhorvath-terraform-state`, Zone: `at-vie-1`). Dadurch teilen sich Create- und Destroy-Workflow denselben State — ohne Remote Backend würde der Destroy-Workflow keine Ressourcen kennen und nichts löschen können.

### 2. CloudInit konfiguriert die VM automatisch

Beim ersten Boot der VM führt CloudInit automatisch folgende Schritte aus:

1. Pakete installieren (`nginx`, `curl`, `jq`, `net-tools`)
2. Bash-Script `/usr/local/bin/collect-vm-info.sh` erstellen
3. Script sofort ausführen (HTML + JSON generieren)
4. Cronjob einrichten (Script alle 5 Minuten ausführen)
5. nginx starten

### 3. Das Info-Script sammelt VM-Daten

Das Script `/usr/local/bin/collect-vm-info.sh` sammelt folgende Informationen:

| Information | Quelle |
|-------------|--------|
| Hostname | `hostname` |
| Betriebssystem | `lsb_release` |
| Kernel | `uname -r` |
| Architektur | `uname -m` |
| Hypervisor | `systemd-detect-virt` |
| CPU Model + Cores | `/proc/cpuinfo`, `nproc` |
| RAM (gesamt/verwendet/frei) | `free -m` |
| Public/Private IP | `curl ifconfig.me`, `hostname -I` |
| Filesysteme | `df -h` |

Die Daten werden als **JSON** unter `/var/www/html/api/info.json` und als **HTML-Website** unter `/var/www/html/index.html` gespeichert. nginx liefert beide Dateien aus.

---

## Verwendung

### Voraussetzungen

- GitHub Account mit Fork des Repos
- Exoscale Account mit API Key und Secret
- GitHub Secrets konfiguriert (siehe unten)

### GitHub Secrets einrichten

Unter `Settings → Secrets and variables → Actions` folgende Secrets anlegen:

| Name | Beschreibung |
|------|-------------|
| `EXOSCALE_API_KEY` | Exoscale API Key |
| `EXOSCALE_API_SECRET` | Exoscale API Secret |

### Infrastruktur erstellen

1. GitHub Repository öffnen
2. **Actions** Tab → **"Horvath Michael – Create Infrastructure"**
3. **"Run workflow"** → **"Run workflow"** klicken
4. Nach ca. 1 Minute ist der Workflow abgeschlossen
5. Im Job-Log unter **"Show VM IP"** die IP-Adresse ablesen
6. Website unter `http://<IP>/` aufrufen
7. JSON-API unter `http://<IP>/api/info.json` aufrufen

> **Hinweis:** CloudInit benötigt nach dem Start der VM noch ca. 2-3 Minuten um nginx zu installieren und die Website zu generieren.

### Infrastruktur löschen

1. **Actions** Tab → **"Horvath Michael – Destroy Infrastructure"**
2. **"Run workflow"** → **"Run workflow"** klicken
3. Nach ca. 1 Minute sind alle Ressourcen gelöscht

---

## Dargestellte VM-Informationen

### HTML-Website (`http://<IP>/`)

Die Website zeigt folgende Informationen übersichtlich in Cards:

- **Übersicht:** Hostname, Uptime, CPU-Cores, RAM-Auslastung
- **System:** Betriebssystem, Kernel, Architektur, Hypervisor
- **Memory:** RAM gesamt/verwendet/frei mit Fortschrittsbalken
- **Netzwerk:** Public IP, Private IP, Zone
- **Filesysteme:** Alle gemounteten Filesysteme mit Typ, Größe, Auslastung

Die Seite aktualisiert sich automatisch alle 30 Sekunden. Die Daten werden alle 5 Minuten via Cronjob neu generiert.

### JSON-API (`http://<IP>/api/info.json`)

```json
{
  "timestamp": "2026-06-04T10:38:17Z",
  "hostname": "mhorvath-vm",
  "os": "Ubuntu 24.04.4 LTS",
  "kernel": "6.8.0-117-generic",
  "architecture": "x86_64",
  "hypervisor": "kvm",
  "uptime": "up 5 minutes",
  "cpu": {
    "model": "Intel Core Processor (Broadwell)",
    "cores": 2
  },
  "memory": {
    "total_mb": 3911,
    "used_mb": 615,
    "free_mb": 3296,
    "used_percent": 15
  },
  "network": {
    "public_ip": "85.217.x.x",
    "private_ip": "85.217.x.x"
  },
  "filesystems": [...]
}
```

---

## Sicherheit

- API Keys werden ausschließlich als GitHub Secrets gespeichert
- Terraform State wird nicht ins Git-Repository committed (`.gitignore`), sondern remote in Exoscale SOS gespeichert
- SSH-Zugang ist in der Security Group offen, kann bei Bedarf eingeschränkt werden
- Sensible Variablen sind in `variables.tf` mit `sensitive = true` markiert
