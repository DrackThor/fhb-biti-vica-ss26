# VM-Info Service – Automatisierte Infrastruktur auf Exoscale

## Übersicht

Dieses Projekt automatisiert die Erstellung einer Ubuntu-VM auf der Exoscale-Cloudplattform, die technische Systeminformationen als HTTP-Endpunkt bereitstellt. Die gesamte Infrastruktur wird via **OpenTofu** (Terraform-kompatibler Open-Source-Fork) erstellt und über **GitHub Actions** automatisiert.

### Bereitgestellte Endpunkte

| Endpunkt | Beschreibung |
|----------|--------------|
| `http://<IP>/` | **HTML-Dashboard**: Visuelles Echtzeit-Dashboard mit allen VM-Infos |
| `http://<IP>/api` | **JSON-API**: Maschinenlesbare Rohdaten aller Systemmetriken |
| `http://<IP>/health` | **Health-Check**: Gibt `{"status": "ok"}` zurück wenn der Service läuft |
| `https://<domain>/` | **HTTPS** (optional, wenn `domain_name` gesetzt) |

---

## Architektur

```
GitHub Actions
     │
     ├─ deploy.yml ──► OpenTofu ──► Exoscale API
     │                               │
     └─ destroy.yml                  └─► Ubuntu 24.04 VM
                                          │
                                     CloudInit (erster Boot)
                                          │
                                     ┌────┴────────────────┐
                                     │  systemd Service     │
                                     │  Python Flask App    │
                                     │  (127.0.0.1:5000)    │
                                     └────────┬────────────┘
                                              │ Reverse-Proxy
                                     ┌────────┴────────────┐
                                     │  Nginx               │
                                     │  Port 80 (HTTP)      │
                                     │  Port 443 (HTTPS)    │
                                     └─────────────────────┘
```

---

## Verzeichnisstruktur

```
Abgabe_2_xxx/
├── .github/
│   └── workflows/
│       ├── deploy.yml          # Workflow: Infrastruktur erstellen
│       └── destroy.yml         # Workflow: Infrastruktur löschen
├── terraform/
│   ├── main.tf                 # Hauptkonfiguration (VM, Security Group, SSH Key)
│   ├── variables.tf            # Eingabevariablen mit Beschreibungen
│   ├── outputs.tf              # Ausgaben (IP, URLs)
│   ├── cloudinit.yaml          # CloudInit: vollautomatische OS-Konfiguration
│   └── terraform.tfvars.example # Beispiel-Konfigurationsdatei
├── .gitignore
└── README.md                   # Diese Datei
```

---

## Verwendete Technologien

| Technologie | Zweck |
|-------------|-------|
| **OpenTofu** | Infrastructure as Code – erstellt/löscht Exoscale-Ressourcen |
| **Exoscale** | Cloud-Provider (IaaS), VM läuft in Wien (at-vie-1) |
| **GitHub Actions** | CI/CD-Pipeline für automatisiertes Deploy/Destroy |
| **CloudInit** | Vollautomatische OS-Konfiguration beim ersten VM-Boot |
| **Ubuntu 24.04 LTS** | Betriebssystem der VM |
| **Python/Flask** | Web-App die Systeminformationen bereitstellt |
| **Nginx** | Reverse-Proxy vor der Flask-App |
| **Let's Encrypt / Certbot** | Automatische TLS-Zertifikate (optional) |
| **psutil** | Python-Bibliothek für Systemmetriken |
| **systemd** | Service-Management für die Flask-App |

---

## Voraussetzungen

### 1. Exoscale Account

Registrieren unter [portal.exoscale.com](https://portal.exoscale.com) und einen **API Key** erstellen:  
`Portal → IAM → API Keys → Create API Key`

### 2. SSH-Schlüsselpaar generieren

```bash
# Ed25519-Schlüssel generieren (empfohlen)
ssh-keygen -t ed25519 -C "vminfo-deploy" -f ~/.ssh/vminfo_key

# Public Key anzeigen (wird als GitHub Secret gesetzt)
cat ~/.ssh/vminfo_key.pub
```

### 3. GitHub Secrets konfigurieren

Im GitHub Repository unter `Settings → Secrets and variables → Actions`:

| Secret Name | Beschreibung | Beispielwert |
|-------------|--------------|--------------|
| `EXOSCALE_API_KEY` | Exoscale API Key | `EXOxxxxxxxx` |
| `EXOSCALE_API_SECRET` | Exoscale API Secret | `...` |
| `SSH_PUBLIC_KEY` | SSH Public Key (Inhalt der `.pub`-Datei) | `ssh-ed25519 AAAA...` |
| `TF_HTTP_ADDRESS` | Terraform Backend URL (optional) | `https://...` |
| `TF_HTTP_USERNAME` | Backend Username (optional) | `...` |
| `TF_HTTP_PASSWORD` | Backend Passwort/Token (optional) | `...` |

> **Hinweis zu `TF_HTTP_ADDRESS`**: Wenn kein Remote-Backend konfiguriert ist, wird ein lokaler State verwendet. Für Produktionsumgebungen empfiehlt sich ein Remote-Backend (z.B. GitLab-managed Terraform State, S3-kompatibel).

---

## Verwendung

### Infrastruktur erstellen

1. Im GitHub-Repository auf **Actions** klicken
2. Workflow **"🚀 Deploy Infrastruktur"** auswählen
3. **"Run workflow"** klicken
4. Parameter konfigurieren:
   - **Zone**: `at-vie-1` (Wien) empfohlen
   - **Instance Type**: `standard.small` (2 vCPU, 2 GB RAM)
   - **Domain Name**: leer lassen für IP-only, oder FQDN für HTTPS
   - **Admin Email**: E-Mail für Let's Encrypt (nur bei Domain relevant)
5. **"Run workflow"** bestätigen

Nach ca. 3–5 Minuten ist die VM verfügbar. Die **Job Summary** zeigt die IP-Adresse und die direkten URLs.

### Infrastruktur löschen

1. **Actions → "🗑️ Destroy Infrastruktur"** → **"Run workflow"**
2. Im Feld "Bestätigung" exakt `DESTROY` eingeben
3. Dieselbe Zone wie beim Deploy auswählen
4. **"Run workflow"** bestätigen

> ⚠️ **Achtung**: Alle Ressourcen (VM, Daten, IP) werden unwiderruflich gelöscht!

---

## Dargestellte Systeminformationen

### HTML-Dashboard (`/`)

Das Dashboard zeigt in Echtzeit (Auto-Refresh alle 30 Sekunden):

- **System**: Hostname, FQDN, OS-Version, Kernel, Architektur
- **Hypervisor**: Erkannter Virtualisierungstyp (KVM, Xen, etc.)
- **Uptime**: Laufzeit seit letztem Boot
- **CPU**: Modell, Anzahl Kerne (physisch/logisch), Taktfrequenz, Auslastung
- **Arbeitsspeicher**: Gesamt/Belegt/Verfügbar, Swap
- **Dateisysteme**: Alle gemounteten Filesysteme mit Größe, Typ, Auslastung
- **Netzwerk**: Alle Interfaces mit IPv4/IPv6-Adressen

### JSON-API (`/api`)

Dieselben Daten als strukturiertes JSON, geeignet für programmatische Weiterverarbeitung:

```json
{
  "collected_at": "2026-06-01T10:30:00+00:00",
  "host": {
    "hostname": "vm-info-server",
    "os": "Ubuntu 24.04 LTS",
    "kernel": "6.8.0-45-generic",
    "hypervisor": "kvm",
    "uptime": "2d 4h 15m"
  },
  "cpu": {
    "model": "Intel(R) Xeon(R) ...",
    "logical_cores": 2,
    "usage_percent": 3.2
  },
  "memory": {
    "total_gb": 2.0,
    "used_gb": 0.8,
    "percent": 40.0
  },
  "filesystems": [...],
  "network": [...]
}
```

---

## Funktionsweise im Detail

### 1. GitHub Actions Workflow (deploy.yml)

Der Workflow wird manuell via `workflow_dispatch` ausgelöst. Er:
1. Checkt das Repository aus
2. Installiert OpenTofu in der gewünschten Version (gepinnt für Reproduzierbarkeit)
3. Initialisiert das Terraform-Backend (Remote-State oder lokal)
4. Führt `tofu plan` aus (zeigt geplante Änderungen)
5. Führt `tofu apply` aus (erstellt die Infrastruktur)
6. Extrahiert die IP-Adresse aus den Terraform-Outputs
7. Wartet bis der HTTP-Service erreichbar ist (Health-Check mit Retry)
8. Erstellt eine Job-Summary mit allen URLs

### 2. OpenTofu/Terraform (main.tf)

Terraform verwaltet folgende Exoscale-Ressourcen:
- **`exoscale_compute_instance`**: Die Ubuntu-VM (Template: Ubuntu 24.04 LTS)
- **`exoscale_security_group`**: Firewall-Regeln (Port 22, 80, 443, ICMP)
- **`exoscale_ssh_key`**: SSH-Schlüssel für Admin-Zugang

Die CloudInit-Konfiguration wird via `user_data` an die VM übergeben.

### 3. CloudInit (cloudinit.yaml)

CloudInit wird beim **ersten Boot** der VM ausgeführt und:
1. Setzt Hostname, Locale und Zeitzone
2. Aktualisiert das System (`apt upgrade`)
3. Installiert Nginx, Python3, Flask, psutil, Certbot
4. Erstellt einen System-User `vminfo` (ohne Shell-Zugang)
5. Schreibt die Flask-App nach `/opt/vminfo/app.py`
6. Erstellt einen **systemd-Service** `vminfo.service`
7. Konfiguriert **Nginx** als Reverse-Proxy
8. Richtet (optional) **Let's Encrypt TLS** via Certbot ein
9. Startet und aktiviert alle Services

### 4. Flask-Applikation (app.py)

Die App sammelt via `psutil` und direktem `/proc`-Lesezugriff Systeminfos und stellt sie über drei Endpunkte bereit:
- `/` → HTML mit Jinja2-Template (inline)
- `/api` → `jsonify()` mit CORS-Header
- `/health` → Statuscheck

---

## Lokale Entwicklung

Für lokales Testen ohne GitHub Actions:

```bash
# Voraussetzungen
brew install opentofu  # macOS
# oder: https://opentofu.org/docs/intro/install/

# In das Terraform-Verzeichnis wechseln
cd Abgabe_2_xxx/terraform

# terraform.tfvars anlegen (aus Beispiel kopieren)
cp terraform.tfvars.example terraform.tfvars
# terraform.tfvars mit echten Werten befüllen (nicht committen!)

# Terraform initialisieren (ohne Remote-Backend)
tofu init -backend=false

# Plan anzeigen
tofu plan

# Infrastruktur erstellen
tofu apply

# Infrastruktur löschen
tofu destroy
```

---

## HTTPS / DNS (Zusatzpunkte)

Für HTTPS wird ein FQDN benötigt:

1. DNS-Eintrag erstellen: `vm-info.example.com → <VM-IP>` (A-Record)
2. Workflow mit `domain_name=vm-info.example.com` starten
3. CloudInit holt automatisch ein **Let's Encrypt-Zertifikat** via Certbot
4. Nginx wird automatisch auf HTTPS umgestellt (HTTP → HTTPS Redirect)
5. Automatische Zertifikat-Erneuerung via Cron-Job (alle 90 Tage)

> **Timing**: Der DNS-Eintrag muss vor dem Certbot-Aufruf propagiert sein. Da CloudInit einige Minuten nach dem VM-Start läuft, ist das in der Regel kein Problem.

---

## Sicherheitsaspekte

- **Secrets**: Alle Credentials werden ausschließlich als GitHub Secrets gespeichert, nie im Code
- **Service-User**: Flask läuft unter dem unprivilegierten User `vminfo`
- **systemd Hardening**: `NoNewPrivileges`, `ProtectSystem`, `ProtectHome` aktiviert
- **Nginx**: Security-Header (X-Frame-Options, X-Content-Type-Options, etc.)
- **Keine Passwort-Authentifizierung**: VM-Zugang nur via SSH-Key
- **`.gitignore`**: Terraform State und `terraform.tfvars` werden nie committet

---

## Troubleshooting

| Problem | Lösung |
|---------|--------|
| VM nicht erreichbar | CloudInit braucht 3-5 Minuten – warten und `/health` testen |
| Service läuft nicht | SSH auf VM: `sudo systemctl status vminfo` |
| Nginx-Fehler | `sudo nginx -t` und `sudo journalctl -u nginx` |
| Flask-Fehler | `sudo journalctl -u vminfo -f` |
| CloudInit-Log | `sudo cat /var/log/cloud-init-output.log` |
| TLS-Fehler | DNS-Propagation abwarten, dann `sudo certbot renew` |
