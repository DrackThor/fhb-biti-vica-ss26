# Abgabe 2 – Automatisierte Exoscale VM mit System-Info Webseite

**Kurs:** BITI VICA SS26  
**Abgabe:** Thomas Hoppe  
**Ordner:** `Hoppe_Thomas/Abgabe_2_260604/`

---

## Übersicht

Diese Lösung erstellt automatisiert eine virtuelle Maschine in der Exoscale Cloud (Wien, at-vie-1), die über eine öffentliche HTTPS-URL erreichbar ist und technische Details über sich selbst anzeigt.

Die gesamte Infrastruktur wird mit **OpenTofu** (Terraform-kompatibel) verwaltet und über zwei **GitHub Actions Workflows** gesteuert. Die VM-Konfiguration erfolgt vollständig über **CloudInit** – ohne manuelle SSH-Eingriffe.

---

## Architektur

```
GitHub Actions
  │
  ├── deploy.yml ──────────────► OpenTofu/Terraform
  │                                     │
  │                                     ▼
  │                            Exoscale API (at-vie-1)
  │                                     │
  │                         ┌───────────┼───────────┐
  │                         ▼           ▼           ▼
  │                    SSH Key    Security     Elastic IP
  │                              Group        (statische IP)
  │                         │           │           │
  │                         └───────────┼───────────┘
  │                                     ▼
  │                             Ubuntu 24.04 VM
  │                             (CloudInit konfiguriert:
  │                              nginx, Python API,
  │                              Let's Encrypt TLS)
  │
  └── destroy.yml ─────────────► OpenTofu destroy
```

### Komponenten

| Komponente | Technologie | Zweck |
|---|---|---|
| Infrastruktur-Code | OpenTofu / Terraform | VM, EIP, Security Group, SSH Key |
| CI/CD | GitHub Actions | Automatisches Deploy & Destroy |
| Betriebssystem | Ubuntu 24.04 LTS | Long Term Support, 5 Jahre Updates |
| OS-Konfiguration | CloudInit | Vollautomatische Erstkonfiguration |
| Webserver | nginx | Reverse Proxy, TLS-Terminierung |
| Backend API | Python (stdlib) | Systeminformationen sammeln |
| TLS-Zertifikat | Let's Encrypt / Certbot | Kostenlose HTTPS-Zertifikate |

---

## Dateistruktur

```
Hoppe_Thomas/Abgabe_2_260604/
├── .github/
│   └── workflows/
│       ├── deploy.yml        # Workflow: Infrastruktur erstellen
│       └── destroy.yml       # Workflow: Infrastruktur löschen
├── terraform/
│   ├── main.tf               # Exoscale Ressourcen (VM, EIP, SG, SSH)
│   ├── variables.tf          # Eingabevariablen
│   └── outputs.tf            # Ausgabewerte (IP, URLs)
├── cloud-init/
│   └── cloud-init.yaml       # Vollständige VM-Konfiguration
└── README.md                 # Diese Datei
```

---

## Voraussetzungen & Setup

### 1. Exoscale API Key erstellen

1. Im [Exoscale Console](https://portal.exoscale.com/) einloggen
2. **IAM → API Keys → Create API Key**
3. Berechtigungen: `unrestricted` oder mindestens: Compute, Networking
4. `API Key` und `API Secret` notieren

### 2. SSH-Schlüsselpaar generieren (lokal)

```bash
ssh-keygen -t ed25519 -C "biti-vica-abgabe2" -f ~/.ssh/biti_vica
# Öffentlichen Schlüssel anzeigen:
cat ~/.ssh/biti_vica.pub
```

### 3. Domain konfigurieren

Eine Domain oder Subdomain wird benötigt (für HTTPS mit Let's Encrypt).

**Option A: Eigene Domain** (z.B. `hoppe-thomas.biti-fhb.org`)
- Nach dem ersten Deploy: DNS A-Record auf die Elastic IP setzen
- **Problem:** IP ist erst nach dem Deploy bekannt → zwei Durchläufe nötig

**Option B: Empfohlen – zuerst IP holen, dann DNS setzen**
1. `deploy.yml` ausführen → Elastic IP wird in den Outputs angezeigt
2. DNS A-Record setzen: `hoppe-thomas.biti-fhb.org → <Elastic IP>`
3. Nochmals `deploy.yml` ausführen (oder manuell `certbot` auf der VM)

**Option C: Kein eigener DNS** – dann nur HTTP über IP (certbot überspringen, Variable `domain` = IP-Adresse)

### 4. GitHub Secrets konfigurieren

Im Repository: **Settings → Secrets and variables → Actions → New repository secret**

| Secret Name | Wert | Beispiel |
|---|---|---|
| `EXOSCALE_API_KEY` | Exoscale API Key | `EXO...` |
| `EXOSCALE_API_SECRET` | Exoscale API Secret | `abc123...` |
| `SSH_PUBLIC_KEY` | Inhalt von `~/.ssh/biti_vica.pub` | `ssh-ed25519 AAAA...` |
| `DOMAIN` | FQDN der VM | `hoppe-thomas.biti-fhb.org` |
| `LETSENCRYPT_EMAIL` | E-Mail für Zertifikate | `name@example.com` |

---

## Verwendung

### Infrastruktur erstellen (Deploy)

1. GitHub Repository öffnen
2. **Actions → 🚀 Deploy Infrastruktur → Run workflow**
3. Optionale Parameter:
   - `zone`: Exoscale-Zone (Standard: `at-vie-1` = Wien)
   - `instance_type`: VM-Größe (Standard: `standard.small` = 2 vCPU, 2 GB RAM)
4. **Run workflow** klicken

Der Workflow:
- Lädt OpenTofu herunter
- Führt `tofu init` aus (Exoscale-Provider wird heruntergeladen)
- Zeigt mit `tofu plan` was erstellt wird
- Erstellt mit `tofu apply` alle Ressourcen
- Wartet bis CloudInit abgeschlossen ist (~3-5 Minuten)
- Testet die Endpunkte

**Nach ~5-10 Minuten sind die Endpunkte erreichbar:**

| Endpunkt | Beschreibung |
|---|---|
| `https://<domain>/` | HTML-Webseite mit visuell aufbereiteten VM-Informationen |
| `https://<domain>/api` | JSON-API mit vollständigen Systeminformationen |
| `https://<domain>/api/health` | Health-Check Endpunkt |

### Infrastruktur löschen (Destroy)

1. **Actions → 🗑️ Destroy Infrastruktur → Run workflow**
2. Im Feld `confirm` das Wort `destroy` eingeben (Schutz vor versehentlichem Löschen)
3. **Run workflow** klicken

⚠️ **Achtung:** Alle Exoscale-Ressourcen werden unwiderruflich gelöscht.

### SSH-Zugriff (für Wartung/Debugging)

```bash
ssh -i ~/.ssh/biti_vica ubuntu@<elastic-ip>
```

---

## Dargestellte VM-Informationen

### HTML-Endpunkt (`/`)

Zeigt eine moderne, automatisch aktualisierende Webseite (alle 30 Sekunden) mit:

- **System:** Hostname, Distribution, Uptime, Load Average
- **Kernel:** Kernel-Version, Architektur, `uname -a`
- **Hypervisor/Virtualisierung:** Typ (KVM, Xen, ...), Produkt, Hersteller
- **CPU:** Modell, Anzahl vCPUs, Architektur
- **Arbeitsspeicher:** Gesamt, verwendet, verfügbar, Swap (mit Fortschrittsbalken)
- **Netzwerk:** Alle Interfaces, IP-Adressen, MAC-Adressen, Status
- **Dateisysteme:** Alle Mounts, Typ, Größe, Auslastung (mit Fortschrittsbalken, Farbcodierung)

### JSON-API-Endpunkt (`/api`)

Liefert dieselben Informationen maschinenlesbar:

```json
{
  "timestamp": "2024-06-04T12:00:00+00:00",
  "hostname": "biti-vica-abgabe2",
  "kernel": {
    "version": "6.8.0-45-generic",
    "distribution": "Ubuntu 24.04.1 LTS",
    ...
  },
  "hypervisor": {
    "type": "kvm",
    "product": "Standard PC (Q35 + ICH9, 2009)",
    ...
  },
  "cpu": { "model": "Intel Xeon...", "cores": 2 },
  "memory": { "total_mb": 2048, "used_mb": 512, ... },
  "disks": [...],
  "network": [...],
  "uptime": { "seconds": 3600, "human": "up 1 hour" },
  "load_average": { "1min": 0.05, "5min": 0.03, "15min": 0.01 }
}
```

---

## Technische Details

### CloudInit-Ablauf

CloudInit führt beim ersten VM-Start folgende Schritte aus:

1. **package_update/upgrade:** System aktualisieren
2. **packages:** nginx, python3, certbot, lm-sensors, dmidecode, etc. installieren
3. **write_files:** Python-Backend, systemd-Service, nginx-Config, HTML-Seite schreiben
4. **runcmd** (sequenziell):
   - vminfo systemd-Service aktivieren und starten
   - nginx konfigurieren und starten
   - `certbot` TLS-Zertifikat von Let's Encrypt ausstellen
   - nginx neu starten mit TLS-Konfiguration
   - Automatische Zertifikat-Erneuerung via Cron einrichten

### nginx als Reverse Proxy

nginx übernimmt:
- TLS-Terminierung (HTTPS → HTTP intern)
- HTTP→HTTPS Redirect
- `/api*` → Weiterleitung an Python-Backend (Port 8080)
- `/` → Statische HTML-Datei aus `/var/www/vminfo/`

### Python-Backend (Port 8080)

Das Backend liest Systeminformationen aus Standard-Linux-Quellen:
- `/proc/cpuinfo` – CPU-Details
- `/proc/meminfo` – Speicher-Details
- `/proc/uptime` – Uptime
- `ip -j addr` – Netzwerk-Interfaces (JSON-Output)
- `df -T` – Dateisystem-Details
- `systemd-detect-virt` – Hypervisor-Typ
- `dmidecode` – Hardware-Details (Hersteller, Produkt)

### Terraform State Management

Der Terraform State (welche Ressourcen existieren) wird als GitHub Actions Artifact gespeichert. Der destroy-Workflow lädt diesen State herunter, um die richtigen Ressourcen zu löschen.

**Für Produktionsumgebungen:** Remote Backend empfohlen (z.B. Exoscale Object Storage als S3-kompatibles Backend).

---

## Troubleshooting

### Certbot schlägt fehl

Mögliche Ursachen:
- DNS A-Record zeigt noch nicht auf die Elastic IP (DNS-Propagation dauert bis zu 48h)
- Port 80 ist blockiert

Lösung: Nach DNS-Propagation manuell auf der VM ausführen:
```bash
certbot --nginx -d <domain> -m <email> --agree-tos --non-interactive --redirect
```

### VM nicht erreichbar nach Deploy

CloudInit benötigt 3-10 Minuten. Status prüfen:
```bash
ssh ubuntu@<ip> "cloud-init status --wait"
ssh ubuntu@<ip> "journalctl -u vminfo"
ssh ubuntu@<ip> "systemctl status nginx"
```

### API liefert Fehler

```bash
ssh ubuntu@<ip> "journalctl -u vminfo -n 50"
ssh ubuntu@<ip> "systemctl restart vminfo"
```
