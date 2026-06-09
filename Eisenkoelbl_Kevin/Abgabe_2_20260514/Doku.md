# Abgabe 2 – VM Info Dashboard
**FH Burgenland – BITI VICA SS26**  
**Autor:** Kevin Eisenkölbl  
**Datum:** Mai 2026

---

## Was wurde gebaut?

Eine Ubuntu-VM auf Exoscale, die unter einer fixen IP-Adresse zwei Endpunkte bereitstellt:

| URL | Beschreibung |
|-----|-------------|
| `http://<IP>/` | HTML-Dashboard mit Systeminformationen |
| `http://<IP>/api` | Dieselben Informationen als JSON |

Die gesamte Infrastruktur wird **vollautomatisch** erstellt — kein manueller Eingriff auf der VM nötig.

---

## Herangehensweise

Die Aufgabe wurde in drei Teile aufgeteilt:

1. **Infrastruktur** → Terraform/OpenTofu erstellt die VM in Exoscale
2. **Konfiguration** → CloudInit richtet die VM beim ersten Boot automatisch ein
3. **Anwendung** → Ein Python-Server liefert die Systeminformationen als HTML und JSON

### Warum Python als Server?
nginx alleine kann keine dynamischen Daten liefern. Ein kleiner Python-Server liest die Systeminformationen direkt vom Betriebssystem aus und gibt sie als JSON zurück. nginx leitet die Anfragen nur weiter (Reverse Proxy).

### Warum Elastic IP?
Eine normale VM-IP ändert sich bei jedem Neustart. Die Elastic IP (EIP) ist eine feste öffentliche IP-Adresse, die auch nach einem Neustart gleich bleibt.

---

## Architektur

```
GitHub Actions
      │
      │ startet OpenTofu
      ▼
Exoscale Cloud (AT-VIE-1)
      │
      ├── Elastic IP (feste öffentliche IP)
      ├── Security Group (Firewall: Port 22, 80)
      ├── SSH Key
      └── Ubuntu 24.04 VM (2 vCPU, 4GB RAM, 50GB)
              │
              ├── nginx (Port 80) – Reverse Proxy
              └── Python Server (Port 8080, nur intern)
                      ├── GET /     → HTML Dashboard
                      └── GET /api  → JSON API
```

---

## Funktionsweise

### 1. GitHub Actions Workflows

Es gibt zwei Workflows die manuell gestartet werden:

- **deploy.yml** – erstellt die gesamte Infrastruktur
- **destroy.yml** – löscht alles wieder (erfordert Bestätigung `LOESCHEN`)

Der Deploy-Workflow führt folgende Schritte aus:
1. OpenTofu installieren
2. Terraform State aus Cache laden
3. `tofu init` → Provider laden
4. `tofu plan` → Änderungen planen
5. `tofu apply` → Infrastruktur erstellen
6. IP-Adresse in der Job-Summary ausgeben

### 2. Terraform

Terraform erstellt in Exoscale:

| Ressource | Details |
|-----------|---------|
| VM | Ubuntu 24.04, standard.medium, 50GB Disk |
| Elastic IP | Feste IP mit HTTP-Healthcheck auf `/api` |
| Security Group | Erlaubt Port 22 (SSH), 80 (HTTP), ICMP |
| SSH Key | Für Zugang zur VM |

### 3. CloudInit

CloudInit konfiguriert die VM beim **ersten Boot** vollautomatisch:

1. System aktualisieren
2. Pakete installieren (nginx, python3, curl, dmidecode, ...)
3. Python-Server schreiben (`/opt/vminfo/server.py`)
4. HTML-Dashboard schreiben (`/opt/vminfo/dashboard.html`)
5. systemd-Service für den Python-Server einrichten
6. nginx als Reverse Proxy konfigurieren
7. Alle Services starten

### 4. Python HTTP-Server

Der Server läuft intern auf Port 8080 und sammelt Systeminformationen über Standard-Linux-Befehle:

| Befehl | Information |
|--------|-------------|
| `lscpu` | CPU-Modell, Anzahl Kerne |
| `free -h` | Arbeitsspeicher |
| `df -h` | Dateisystem-Auslastung |
| `lsblk` | Block-Devices |
| `ip -j addr` | Netzwerk-Interfaces |
| `systemd-detect-virt` | Hypervisor-Typ (z.B. kvm) |
| `/proc/loadavg` | Load Average |
| `/proc/uptime` | Uptime |
| `/etc/os-release` | OS-Name, Version |

---

## Verwendung

### Voraussetzungen

- GitHub Account mit diesem Repository
- Exoscale Account
- SSH-Schlüsselpaar (einmalig erstellen)

### Schritt 1: SSH-Key erstellen

```powershell
# Windows PowerShell
ssh-keygen -t ed25519 -C "vica-ss26" -f "$env:USERPROFILE\.ssh\vica_key"
cat "$env:USERPROFILE\.ssh\vica_key.pub"
```

Die Ausgabe (beginnt mit `ssh-ed25519 ...`) für Schritt 3 merken.

### Schritt 2: Exoscale API-Key erstellen

1. [console.exoscale.com](https://console.exoscale.com) → **IAM** → **API Keys** → **+ Add**
2. Name: `github-vica`, Role: `Owner`
3. Key und Secret sofort kopieren — das Secret wird nur einmal angezeigt!

### Schritt 3: GitHub Secrets setzen

Im Repository: **Settings → Secrets and variables → Actions → New repository secret**

| Secret | Inhalt |
|--------|--------|
| `EXOSCALE_API_KEY` | API Key aus Schritt 2 |
| `EXOSCALE_API_SECRET` | API Secret aus Schritt 2 |
| `SSH_PUBLIC_KEY` | Ausgabe von `cat vica_key.pub` |

### Schritt 4: Infrastruktur erstellen

1. GitHub → **Actions** → **"Infrastruktur erstellen"**
2. **Run workflow** → ausfüllen:
   - Domain: `test.local`
   - E-Mail: eigene E-Mail-Adresse
3. **Run workflow** klicken

Nach ca. 2 Minuten zeigt die **Job-Summary** die VM-IP.

### Schritt 5: Dashboard aufrufen

```
http://<VM-IP>/      → HTML Dashboard
http://<VM-IP>/api   → JSON API
```

### Schritt 6: Infrastruktur löschen

1. GitHub → **Actions** → **"Infrastruktur löschen"**
2. **Run workflow** → Bestätigung: `LOESCHEN`

---

## Dargestellte Informationen

### HTML Dashboard

Das Dashboard zeigt Echtzeit-Daten in übersichtlichen Karten und **aktualisiert sich automatisch alle 30 Sekunden**:

- **Allgemein:** Hostname, IP-Adresse, Hypervisor-Typ, Uptime
- **Betriebssystem:** OS-Name, Kernel-Version, Architektur
- **CPU:** Modell, Anzahl Kerne, Load Average
- **Arbeitsspeicher:** Gesamt, verwendet, frei
- **Dateisysteme:** Alle Partitionen mit Auslastungsbalken
- **Netzwerk:** Alle Interfaces mit IP-Adressen und Status

### JSON API (/api)

Beispiel-Ausgabe:
```json
{
  "timestamp": "2026-05-14T08:41:07+00:00",
  "hostname": "vica-ss26-vm",
  "network": { "primary_ip": "194.182.174.58" },
  "os": {
    "name": "Ubuntu 24.04.4 LTS",
    "kernel": "6.8.0-110-generic",
    "uptime": "0d 2h 15m"
  },
  "cpu": { "model": "Intel Core @ 2.0GHz", "cores": "2" },
  "memory": { "total": "3.8Gi", "used": "470Mi", "free": "2.0Gi" },
  "hypervisor": "kvm"
}
```
