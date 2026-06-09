# Abgabe 2


## Überblick


| Endpunkt | Inhalt |
|----------|--------|
| `http://185.150.11.9/`   | **HTML-Website** mit Systeminformationen (visuell aufbereitet) |
| `http://185.150.11.9/api` | **JSON-API** mit denselben Daten als maschinenlesbare Rohdaten |

Beide Endpunkte werden alle 30 Sekunden automatisch aktualisiert.

---

## Architektur

```
GitHub Actions
     │
     ▼
Terraform / OpenTofu
     │
     ├─ Exoscale Security Group (Firewall: SSH 22, HTTP 80, HTTPS 443)
     ├─ SSH Key Pair
     └─ Compute Instance (Ubuntu 22.04 LTS, Standard Small, 50 GB)
              │
              ▼ (beim ersten Boot)
         CloudInit
              │
              ├─ Pakete installieren (nginx, jq, sysstat, lshw, …)
              ├─ nginx konfigurieren (/ → HTML, /api → JSON)
              ├─ generate-sysinfo.sh schreiben
              └─ systemd Timer aktivieren (alle 30 Sekunden)
```

---

## Voraussetzungen

### 1. GitHub Secrets anlegen

Im GitHub Repository unter **Settings → Secrets and variables → Actions** folgende Secrets anlegen:

| Secret | Inhalt |
|--------|--------|
| `EXOSCALE_API_KEY` | Exoscale API Key (aus Exoscale Portal → IAM → API Keys) |
| `EXOSCALE_API_SECRET` | Exoscale API Secret (nur beim Erstellen sichtbar!) |
| `SSH_PUBLIC_KEY` | Inhalt der `~/.ssh/id_rsa.pub` (oder ed25519) Datei |

### 2. SSH-Schlüssel erstellen

```bash
ssh-keygen -t ed25519 -C "vica-deploy"
cat ~/.ssh/id_ed25519.pub   # diesen Wert als SSH_PUBLIC_KEY Secret speichern
```

### 3. Exoscale API Key erstellen

1. [portal.exoscale.com](https://portal.exoscale.com) → **IAM** → **API Keys** → **ADD**
2. Name: `JH-VICA-terraform`
3. Role: `Owner` (für Terraform nötig)
4. Key und Secret sofort kopieren und als GitHub Secrets speichern

---

## Verwendung

### Infrastruktur erstellen

1. GitHub Repository → **Actions** → ** Infrastruktur erstellen**
2. **Run workflow** klicken
3. Im Feld `confirm` den Text `yes` eingeben
4. **Run workflow** bestätigen

Der Workflow läuft ca. 2–3 Minuten. Im **Job Summary** erscheint danach die URL.

### Infrastruktur löschen

1. GitHub Repository → **Actions** → ** Infrastruktur löschen**
2. **Run workflow** klicken
3. Im Feld `confirm` exakt `destroy` eingeben (Sicherheitsabfrage)
4. **Run workflow** bestätigen

---

## Technische Details

### Terraform (`terraform/`)

| Datei | Beschreibung |
|-------|-------------|
| `main.tf` | Exoscale-Ressourcen: Security Group, SSH Key, Compute Instance |
| `variables.tf` | Eingabevariablen (API-Credentials, SSH Key) |
| `outputs.tf` | Ausgabe von IP-Adresse und URLs nach dem Deployment |
| `cloud-init.yaml` | CloudInit-Konfiguration für die automatische VM-Einrichtung |

### CloudInit (`terraform/cloud-init.yaml`)

1. **Pakete installieren:** nginx, jq, sysstat, lshw, net-tools, bc
2. **nginx konfigurieren:** Zwei Locations (`/` für HTML, `/api` für JSON)
3. **Skript `generate-sysinfo.sh` anlegen:** Sammelt Systemdaten aus `/proc`, `df`, `ip`, `hostname`, Exoscale Metadata-API
4. **systemd Timer aktivieren:** Führt das Skript alle 30 Sekunden aus
5. **nginx starten**

### Gesammelte Systeminformationen

- **Host:** Hostname, OS, Kernel-Version, Kernel-Typ, Architektur, Uptime
- **Hypervisor:** Typ (KVM bei Exoscale) via `systemd-detect-virt`
- **Netzwerk:** Öffentliche und private IP, alle Interfaces
- **CPU:** Modell, Anzahl Kerne, Load Average
- **Speicher:** RAM gesamt/genutzt/frei
- **Dateisysteme:** Alle gemounteten Filesysteme mit Größe, Nutzung, Typ, Mountpoint
- **Prozesse:** Anzahl laufender Prozesse

---

## Terraform State

Der State verbindet Terraform mit den tatsächlich erstellten Ressourcen. Ohne ihn weiß Terraform nicht, was es erstellt hat und kann nichts löschen.

## Projektstruktur

```
Abgabe_2_260607/
├── .github/
│   └── workflows/
│       ├── hollerer_deploy.yml      # Workflow: Infrastruktur erstellen
│       └── hollerer_destroy.yml     # Workflow: Infrastruktur löschen
├── terraform/
│   ├── main.tf             # Exoscale Ressourcen
│   ├── variables.tf        # Eingabevariablen
│   ├── outputs.tf          # Ausgabewerte (IP, URLs)
│   └── cloud-init.yaml     # Automatische VM-Konfiguration
└── README.md               # Diese Datei
```
