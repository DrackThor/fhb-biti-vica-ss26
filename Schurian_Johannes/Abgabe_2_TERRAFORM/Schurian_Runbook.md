# Runbook – Automatisierte VM-Infrastruktur auf Exoscale

> **Projekt:** BITI VICA SS26 – Abgabe 2  
> **Autor:** Johannes Schurian  
> **Ziel:** Automatisierte Erstellung einer Ubuntu VM auf Exoscale, die per HTTP technische Details über sich selbst ausliefert.

---

## Inhaltsverzeichnis

1. [Architekturüberblick](#1-architekturüberblick)
2. [Voraussetzungen](#2-voraussetzungen)
3. [Datei: `main.tf` – Infrastrukturdefinition](#3-datei-maintf--infrastrukturdefinition)
4. [Datei: `cloud-init.yml` – OS-Konfiguration](#4-datei-cloud-inityml--os-konfiguration)
5. [Datei: `schurian_deploy.yml` – Infrastruktur erstellen](#5-datei-schurian_deployyml--infrastruktur-erstellen)
6. [Datei: `schurian_destroy.yml` – Infrastruktur löschen](#6-datei-schurian_destroyyml--infrastruktur-löschen)
7. [Verwendung – Schritt-für-Schritt](#7-verwendung--schritt-für-schritt)
8. [Troubleshooting](#8-troubleshooting)

---

## 1. Architekturüberblick

```
┌──────────────────────────────────────────────┐
│              GitHub Repository               │
│                                              │
│  schurian_deploy.yml  ──►  Terraform Apply   │
│  schurian_destroy.yml ──►  Terraform Destroy │
│                                              │
│  terraform.tfstate  (im Repo gespeichert)    │
└──────────────────┬───────────────────────────┘
                   │ Exoscale API
                   ▼
┌──────────────────────────────────────────────┐
│              Exoscale (at-vie-1)             │
│                                              │
│  Security Group: HTTP (80) + HTTPS (443)     │
│                                              │
│  VM: Ubuntu 24.04 LTS (standard.micro)       │
│    └─► Cloud-Init konfiguriert beim Boot:    │
│          - nginx installieren & starten      │
│          - index.html mit VM-Details         │
│            generieren                        │
└──────────────────────────────────────────────┘
                   │
            Öffentliche IP
                   │
         http://<IP>/  →  VM-Dashboard
```

**Ablauf zusammengefasst:**
- Terraform erstellt die Exoscale-Infrastruktur (Security Group + VM).
- CloudInit konfiguriert die VM beim ersten Boot vollautomatisch: nginx wird installiert und ein Bash-Skript befüllt `/var/www/html/index.html` mit aktuellen Systemdaten.
- Der Terraform State wird nach jedem Workflow-Lauf direkt ins GitHub Repository committed, damit Deploy- und Destroy-Workflow denselben State verwenden.

---

## 2. Voraussetzungen

### GitHub Secrets

Im Repository unter **Settings → Secrets and variables → Actions** müssen zwei Secrets angelegt sein:

| Secret Name | Inhalt |
|---|---|
| `EXOSCALE_API_KEY` | Exoscale API Key (beginnt mit `EXO...`) |
| `EXOSCALE_API_SECRET` | Zugehöriges API Secret |

**Exoscale API Keys erstellen:**
1. Einloggen auf [portal.exoscale.com](https://portal.exoscale.com)
2. **Account → API Keys → Add**
3. Berechtigungen: *Unrestricted* (oder mindestens Compute + Storage)
4. Key und Secret notieren und als GitHub Secrets eintragen

### Repository-Struktur

Die Dateien müssen im Repository unter folgendem Pfad liegen, da die Workflows mit `working-directory` darauf zeigen:

```
repository-root/
└── Schurian_Johannes/
    └── Abgabe_2_TERRAFORM/
        ├── main.tf
        └── cloud-init.yml
```

Die Workflow-Dateien liegen wie üblich unter:
```
.github/
└── workflows/
    ├── schurian_deploy.yml
    └── schurian_destroy.yml
```

---

## 3. Datei: `main.tf` – Infrastrukturdefinition

Diese Datei beschreibt die gesamte Exoscale-Infrastruktur als Code (Infrastructure as Code). Terraform liest sie und erstellt oder löscht die darin definierten Ressourcen.

### Annotierter Code

```hcl
# Terraform-Block: Definiert welche Provider-Plugins benötigt werden.
# Der Exoscale Provider (Version 0.69.2) wird von der Exoscale-Registry geladen.
terraform {
  required_providers {
    exoscale = {
      source  = "exoscale/exoscale"
      version = "0.69.2"
    }
  }
}

# Provider-Konfiguration: Absichtlich leer gehalten.
# Terraform liest die Zugangsdaten automatisch aus den Umgebungsvariablen
# EXOSCALE_API_KEY und EXOSCALE_API_SECRET – diese werden im GitHub
# Workflow über env: gesetzt (siehe schurian_deploy.yml).
provider "exoscale" {
}

# Lokale Variablen: Zentral definierte Werte, die mehrfach verwendet werden.
# Änderungen hier wirken sich auf alle Ressourcen aus.
locals {
  zone     = "at-vie-1"                      # Exoscale-Zone Wien, Österreich
  template = "Linux Ubuntu 26.04 LTS 64-bit" # Name des VM-Basis-Images
}

# Data Source: Sucht das passende Ubuntu-Template in der angegebenen Zone.
# Gibt die template_id zurück, die bei der VM-Erstellung benötigt wird.
data "exoscale_template" "ubuntu" {
  zone = local.zone
  name = local.template
}

# Ressource: Security Group (entspricht einer Firewall-Regelgruppe).
# Nur explizit erlaubter Traffic kann die VM erreichen.
# SSH (Port 22) ist bewusst nicht konfiguriert – erhöhte Sicherheit,
# da kein direkter Shell-Zugriff von außen möglich ist.
resource "exoscale_security_group" "web" {
  name        = "jschurian-security-policies"
  description = "Erlaubt reinen Web-Traffic (HTTP und HTTPS)"
}

# Firewall-Regel 1: Eingehender HTTP-Traffic auf Port 80
# cidr "0.0.0.0/0" bedeutet: von allen IP-Adressen erlaubt (öffentlich erreichbar)
resource "exoscale_security_group_rule" "http" {
  security_group_id = exoscale_security_group.web.id
  type              = "INGRESS"   # INGRESS = eingehend (zur VM)
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 80
  end_port          = 80
}

# Firewall-Regel 2: Eingehender HTTPS-Traffic auf Port 443
resource "exoscale_security_group_rule" "https" {
  security_group_id = exoscale_security_group.web.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 443
  end_port          = 443
}

# Ressource: Die eigentliche virtuelle Maschine (Compute Instance).
# Alle oben definierten Ressourcen werden hier zusammengeführt.
resource "exoscale_compute_instance" "web_server" {
  zone               = local.zone
  name               = "Johannes-Schurian NGINX-Web-Server"
  template_id        = data.exoscale_template.ubuntu.id  # Ubuntu-Image von oben
  type               = "standard.micro"                  # Kleinste VM-Größe (1 vCPU, 1 GB RAM)
  disk_size          = 10                                # 10 GB Root-Disk
  security_group_ids = [exoscale_security_group.web.id] # Firewall-Gruppe zuweisen

  # Cloud-Init User-Data: Der Inhalt von cloud-init.yml wird beim ersten
  # VM-Start von cloud-init ausgeführt und konfiguriert das OS vollautomatisch.
  user_data = file("${path.module}/cloud-init.yml")
}

# Output: Gibt die öffentliche IP-Adresse der VM nach dem Deployment aus.
# Erscheint im GitHub Actions Log – so erfährt man die URL des Dashboards.
output "server_ip" {
  value       = exoscale_compute_instance.web_server.public_ip_address
  description = "Die oeffentliche IP-Adresse des Webservers"
}
```

### Erstellte Ressourcen im Überblick

| Ressource | Name | Details |
|---|---|---|
| Security Group | `jschurian-security-policies` | Erlaubt Port 80 + 443 von überall |
| Compute Instance | `Johannes-Schurian NGINX-Web-Server` | Ubuntu, `standard.micro`, 10 GB |

---

## 4. Datei: `cloud-init.yml` – OS-Konfiguration

CloudInit ist ein Industrie-Standard-Tool, das beim **ersten Boot** einer VM automatisch ausgeführt wird. Die Konfiguration wird als `user_data` an die VM übergeben (siehe `main.tf`). Es ist keine manuelle SSH-Verbindung nötig.

Die Datei ist in vier Abschnitte gegliedert:

### Annotierter Code

```yaml
#cloud-config
# Die erste Zeile "#cloud-config" ist obligatorisch – sie teilt cloud-init mit,
# dass diese Datei im YAML-Format interpretiert werden soll.

# ── Abschnitt 1: Systemupdate ──────────────────────────────────────────────
# Aktualisiert die Paketlisten (apt update) beim ersten Boot.
# Stellt sicher, dass alle folgenden Paketinstallationen die neuesten
# Versionen verwenden.
package_update: true

# ── Abschnitt 2: Paketinstallation ─────────────────────────────────────────
# Installiert alle benötigten Pakete in einem einzigen apt-Aufruf.
packages:
  - nginx                  # Webserver – liefert index.html aus
  - certbot                # Let's Encrypt Client – für HTTPS (vorbereitet)
  - python3-certbot-nginx  # nginx-Plugin für certbot (vorbereitet)
  - curl                   # HTTP-Client – wird im Skript für die IP-Abfrage genutzt
  - gnupg                  # GPG-Schlüsselverwaltung (für apt-Repositories)
  - ca-certificates        # TLS-Zertifikate für vertrauenswürdige HTTPS-Verbindungen

# ── Abschnitt 3: Dateien schreiben ─────────────────────────────────────────
# Legt Dateien auf dem Dateisystem der VM an, BEVOR runcmd ausgeführt wird.
write_files:
  - path: /usr/local/bin/init-dashboard.sh  # Zieldpfad auf der VM
    permissions: '0755'                      # Ausführbar für alle Benutzer
    content: |
      #!/bin/bash
      
      # Systemdaten live zur Laufzeit sammeln:

      # Öffentliche IP via externem Service abfragen (Timeout 5s als Sicherheitsnetz)
      PUBLIC_IP=$(curl -s --max-time 5 http://ifconfig.me || echo "Nicht ermittelbar")
      
      # RAM-Übersicht: free -h gibt menschenlesbare Werte,
      # awk filtert die Zeile "Mem:" und formatiert Gesamt und Genutzt
      MEMORY=$(free -h | awk '/^Mem:/ {print "Gesamt: " $2 " / Genutzt: " $3}')
      
      # Kernel-Version + CPU-Architektur aus uname
      KERNEL=$(uname -srm)
      
      # Erkannter Hypervisor (z.B. "kvm" auf Exoscale); Fallback "Unbekannt"
      HYPERVISOR=$(systemd-detect-virt || echo "Unbekannt")
      
      # Root-Partition: df gibt Disk-Free-Infos, awk extrahiert Zeile 2 (Daten)
      ROOT_STORAGE=$(df -h / | awk 'NR==2 {print "Größe: " $2 " / Frei: " $4 " (" $5 " genutzt)"}')
      
      # Alle echten Dateisysteme als HTML-Tabellenzeilen formatieren.
      # -x tmpfs und -x devtmpfs schließen virtuelle Pseudo-Dateisysteme aus.
      FS_TABLE=$(df -hT -x tmpfs -x devtmpfs | tail -n +2 | \
        awk '{print "<tr><td>"$1"</td><td>"$2"</td><td>"$3"</td><td>"$5"</td><td>"$7"</td></tr>"}')

      # HTML-Dashboard generieren und direkt in nginx's Web-Root schreiben.
      # Das here-doc (<<EOF) erlaubt mehrzeiligen Text mit Variablen-Interpolation.
      cat <<EOF > /var/www/html/index.html
      <!DOCTYPE html>
      <html lang="de">
      <head>
          <meta charset="UTF-8">
          <title>VM Dashboard</title>
          <style>
              /* Minimales, sauberes Styling ohne externe Abhängigkeiten */
              body { font-family: 'Segoe UI', sans-serif; margin: 40px auto;
                     max-width: 900px; background-color: #f4f7f6; color: #333; }
              h1 { color: #2c3e50; border-bottom: 2px solid #3498db; }
              table { width: 100%; border-collapse: collapse; background: white;
                      box-shadow: 0 1px 3px rgba(0,0,0,0.1); }
              th { background-color: #3498db; color: white; }
              th, td { padding: 12px 15px; text-align: left;
                       border-bottom: 1px solid #e0e0e0; }
              tr:hover { background-color: #f5f5f5; }
          </style>
      </head>
      <body>
          <h1>Server Dashboard</h1>
          <h2>Hello World! Johannes is greeting you!</h2>
          
          <h2>System Eckdaten</h2>
          <table>
              <tr><th>Eigenschaft</th><th>Wert</th></tr>
              <!-- Variablen werden hier vom Bash-Skript eingesetzt -->
              <tr><td>Öffentliche IP</td><td><strong>$PUBLIC_IP</strong></td></tr>
              <tr><td>Kernel & Architektur</td><td>$KERNEL</td></tr>
              <tr><td>Hypervisor</td><td>$HYPERVISOR</td></tr>
              <tr><td>Arbeitsspeicher (RAM)</td><td>$MEMORY</td></tr>
              <tr><td>System-Speicher (Root)</td><td>$ROOT_STORAGE</td></tr>
          </table>
          
          <h2>Detaillierte Filesysteme</h2>
          <table>
              <tr><th>Dateisystem</th><th>Typ</th><th>Gesamt</th>
                  <th>Verfügbar</th><th>Mountpoint</th></tr>
              $FS_TABLE  <!-- Dynamisch generierte Tabellenzeilen -->
          </table>
      </body>
      </html>
      EOF

# ── Abschnitt 4: Befehle ausführen ─────────────────────────────────────────
# runcmd wird nach write_files ausgeführt. Befehle laufen als root.
runcmd:
  # Das Dashboard-Skript einmalig ausführen → erzeugt die initiale index.html
  - /usr/local/bin/init-dashboard.sh
  
  # nginx beim Boot automatisch starten (systemd enable) und sofort starten
  - systemctl enable nginx
  - systemctl start nginx
```

### Was wird angezeigt?

Das fertige Dashboard unter `http://<IP>/` zeigt:

| Feld | Quelle |
|---|---|
| Öffentliche IP | `curl http://ifconfig.me` |
| Kernel & Architektur | `uname -srm` |
| Hypervisor | `systemd-detect-virt` |
| Arbeitsspeicher | `free -h` |
| Root-Partition | `df -h /` |
| Alle Dateisysteme | `df -hT` (ohne tmpfs/devtmpfs) |

> **Hinweis:** Das Dashboard wird einmalig beim Boot generiert. Die Werte sind ein Snapshot zum Zeitpunkt des ersten Starts und aktualisieren sich nicht automatisch.

---

## 5. Datei: `schurian_deploy.yml` – Infrastruktur erstellen

Dieser GitHub Actions Workflow erstellt die gesamte Exoscale-Infrastruktur durch Ausführen von `terraform apply`. Er wird **manuell** gestartet.

### Annotierter Code

```yaml
name: "Deploy Infrastructure - Schurian"

# Berechtigung zum Schreiben ins Repository – benötigt für den
# "Commit Terraform state"-Schritt am Ende.
permissions:
  contents: write

# Trigger: Nur manuell über GitHub UI (Actions-Tab → "Run workflow").
# Kein automatischer Trigger bei Push/PR – verhindert ungewollte Kosten.
on: workflow_dispatch

jobs:
  terraform:
    runs-on: ubuntu-latest  # Aktuellster GitHub-gehosteter Ubuntu Runner

    # Alle folgenden run-Schritte werden in diesem Verzeichnis ausgeführt.
    # Spart die Angabe von "cd ..." in jedem einzelnen Schritt.
    defaults:
      run:
        working-directory: ./Schurian_Johannes/Abgabe_2_TERRAFORM

    # Umgebungsvariablen für den gesamten Job.
    # Der Exoscale Terraform Provider liest diese automatisch aus –
    # kein Hardcoding von Credentials im Code notwendig.
    env:
      EXOSCALE_API_KEY:    ${{ secrets.EXOSCALE_API_KEY }}    # Aus GitHub Secrets
      EXOSCALE_API_SECRET: ${{ secrets.EXOSCALE_API_SECRET }} # Aus GitHub Secrets
      TF_STATE_PATH: ./Schurian_Johannes/Abgabe_2_TERRAFORM/terraform.tfstate

    steps:
      # Schritt 1: Repository-Code auf den Runner laden
      - name: Checkout Code
        uses: actions/checkout@v4

      # Schritt 2: Terraform CLI installieren (aktuelle stabile Version)
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3

      # Schritt 3: Terraform initialisieren
      # Lädt den Exoscale Provider herunter, liest backend-Konfiguration.
      # Muss vor allen anderen terraform-Befehlen ausgeführt werden.
      - name: Terraform Init
        run: terraform init

      # Schritt 4: Ausführungsplan erstellen und anzeigen
      # Zeigt im Log, welche Ressourcen erstellt/geändert/gelöscht werden –
      # ohne tatsächliche Änderungen vorzunehmen. Gut zur Überprüfung.
      - name: Terraform Plan
        run: terraform plan

      # Schritt 5: Plan anwenden und Infrastruktur tatsächlich erstellen
      # -auto-approve überspringt die interaktive Bestätigungsabfrage
      # (notwendig in CI/CD-Pipelines, da niemand "yes" tippen kann)
      - name: Terraform Apply
        run: terraform apply -auto-approve

      # Schritt 6: Terraform State ins Repository committen
      # Der State (terraform.tfstate) enthält den aktuellen Zustand der
      # Infrastruktur. Er muss gespeichert werden, damit der Destroy-Workflow
      # später weiß, welche Ressourcen er löschen soll.
      # HINWEIS: Für Produktionsumgebungen empfiehlt sich ein Remote Backend
      # (z.B. S3/Object Storage) statt State im Repository.
      - name: Commit Terraform state
        run: |
          # Git-Identität für den Bot-Commit konfigurieren
          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"
          
          git status  # Zur Übersicht: zeigt geänderte Dateien im Log
          
          # State-Datei zur Staging-Area hinzufügen
          # "|| true" verhindert Fehler wenn die Datei nicht existiert
          git add terraform.tfstate || true
          
          # Committen – falls keine Änderungen vorliegen, wird die Fehlermeldung
          # abgefangen und der Workflow läuft trotzdem erfolgreich durch
          git commit -m "Update Terraform state" || echo "No state changes to commit"
          git push  # State ins Remote Repository pushen
```

### Ablauf des Workflows

```
Run workflow (manuell)
       │
       ▼
Checkout Code          → Repository-Inhalt auf Runner laden
       │
       ▼
Setup Terraform        → Terraform CLI installieren
       │
       ▼
Terraform Init         → Exoscale Provider herunterladen
       │
       ▼
Terraform Plan         → Geplante Änderungen anzeigen (kein Apply)
       │
       ▼
Terraform Apply        → Ressourcen auf Exoscale erstellen
       │                  (Security Group + VM)
       ▼
Commit Terraform State → terraform.tfstate ins Repo pushen
                         (für späteres Destroy benötigt)
```

---

## 6. Datei: `schurian_destroy.yml` – Infrastruktur löschen

Dieser Workflow löscht alle von Terraform erstellten Exoscale-Ressourcen. Er liest den State, der vom Deploy-Workflow committed wurde, und entfernt die entsprechenden Ressourcen über die Exoscale API.

### Annotierter Code

```yaml
name: "Destroy Infrastructure - Schurian"

# Schreibberechtigung für den State-Commit am Ende
permissions:
  contents: write

# Nur manuell auslösbar – kein automatischer Destroy
on: workflow_dispatch

jobs:
  terraform:
    runs-on: ubuntu-latest

    defaults:
      run:
        working-directory: ./Schurian_Johannes/Abgabe_2_TERRAFORM

    # Gleiche Credentials wie im Deploy-Workflow –
    # Terraform benötigt sie um die Ressourcen via API zu löschen
    env:
      EXOSCALE_API_KEY:    ${{ secrets.EXOSCALE_API_KEY }}
      EXOSCALE_API_SECRET: ${{ secrets.EXOSCALE_API_SECRET }}

    steps:
      # Schritt 1: Repository auschecken – holt auch den zuletzt
      # committed terraform.tfstate (vom Deploy-Workflow gespeichert)
      - name: Checkout Code
        uses: actions/checkout@v4

      # Schritt 2: Terraform CLI installieren
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3

      # Schritt 3: Terraform initialisieren (Provider laden)
      - name: Terraform Init
        run: terraform init

      # Schritt 4: Destroy-Plan anzeigen
      # Identisch mit "terraform plan -destroy" – zeigt welche Ressourcen
      # gelöscht werden, BEVOR destroy ausgeführt wird
      - name: Terraform Plan
        run: terraform plan

      # Schritt 5: Alle Terraform-verwalteten Ressourcen löschen
      # -auto-approve: keine manuelle Bestätigung notwendig
      # ACHTUNG: Dieser Schritt ist unwiderruflich – VM und alle Daten
      # werden permanent gelöscht!
      - name: Terraform Destroy
        run: terraform destroy -auto-approve

      # Schritt 6: Aktualisierten State committen
      # Nach dem Destroy enthält terraform.tfstate eine leere Infrastruktur.
      # Auch terraform.tfstate.backup (vorheriger State) wird committed.
      - name: Commit Terraform state
        run: |
          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"
          
          git status
          
          # Beide State-Dateien adden (backup enthält den Zustand vor dem Destroy)
          git add terraform.tfstate terraform.tfstate.backup || true
          
          git commit -m "Update Terraform state" || echo "No state changes to commit"
          git push
```

### Unterschied Deploy vs. Destroy

| Merkmal | Deploy | Destroy |
|---|---|---|
| Terraform-Befehl | `apply -auto-approve` | `destroy -auto-approve` |
| Wirkung | Ressourcen **erstellen** | Ressourcen **löschen** |
| State committen | `terraform.tfstate` | `terraform.tfstate` + `.backup` |
| Umkehrbar? | Ja (Destroy ausführen) | **Nein** (Daten weg) |

---

## 7. Verwendung – Schritt-für-Schritt

### Infrastruktur erstellen

1. GitHub Repository öffnen → Tab **Actions**
2. Workflow **"Deploy Infrastructure - Schurian"** in der linken Liste auswählen
3. Rechts den Button **"Run workflow"** klicken → **"Run workflow"** bestätigen
4. Auf den laufenden Workflow klicken und den Fortschritt beobachten
5. Im Schritt **"Terraform Apply"** am Ende des Logs die ausgegebene IP-Adresse notieren:
   ```
   Outputs:
   server_ip = "194.182.xxx.xxx"
   ```
6. **2–3 Minuten warten** bis CloudInit abgeschlossen ist (nginx + Dashboard werden eingerichtet)
7. Im Browser aufrufen: `http://194.182.xxx.xxx/`

### Infrastruktur löschen

1. GitHub Repository → Tab **Actions**
2. Workflow **"Destroy Infrastructure - Schurian"** auswählen
3. **"Run workflow"** → **"Run workflow"** bestätigen
4. Workflow abwarten – alle Exoscale-Ressourcen werden gelöscht

> ⚠️ **Wichtig:** Destroy löscht die VM unwiderruflich. Danach fallen keine weiteren Kosten auf Exoscale an.

---

## 8. Troubleshooting

| Problem | Mögliche Ursache | Lösung |
|---|---|---|
| `Error: authentication failed` | Falsche oder fehlende GitHub Secrets | `EXOSCALE_API_KEY` und `EXOSCALE_API_SECRET` in den Repo-Secrets prüfen |
| Dashboard nach Apply nicht erreichbar | CloudInit läuft noch | 2–3 Minuten warten, dann erneut versuchen |
| `template not found` | Ubuntu 26.04 noch nicht in der Zone verfügbar | `local.template` in `main.tf` auf `"Linux Ubuntu 24.04 LTS 64-bit"` ändern |
| Destroy schlägt fehl (`No state file`) | Deploy-Workflow hat State nicht committed | Im Repo prüfen ob `terraform.tfstate` vorhanden; ggf. manuell via `tofu destroy` ausführen |
| `git push` schlägt fehl | Fehlende `contents: write` Berechtigung | `permissions: contents: write` in beiden Workflow-Dateien sicherstellen |
