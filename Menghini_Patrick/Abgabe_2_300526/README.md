# Übersicht
Eine GitHub Action deployt automatisch eine Ubuntu-VM auf Exoscale, die per HTTPS-Endpunkt technische Details über sich selbst bereitstellt. Die gesamte Infrastruktur wird mit Terraform über GitHub Actions Workflows erstellt und wieder gelöscht. Cloud-Init übernimmt die vollständige VM-Konfiguration — ein manueller Eingriff ist nicht nötig.

**Endpunkt:** `https://<VM-IP>` (self-signed Zertifikat)

**Angezeigte Systeminfos:**
- Hostname, Betriebssystem, Uptime
- Öffentliche und private IP-Adressen
- CPU (Modell, Kerne, Architektur)
- Arbeitsspeicher (Gessamt, Genutzt, Verfügbar)
- Kernel (Version, Typ, Architektur)
- Hypervisor
- Storage (Root-Partition, Block Devices)
- Dateisysteme

---

## Architektur

```
GitHub Actions                     Exoscale Cloud (at-vie-1)
+------------------+              +---------------------------+
| Deploy Workflow  |--Terraform-->| Security Group            |
|                  |              |   Port 80, 443, 22 offen  |
| Destroy Workflow |              |                           |
+------------------+              | Ubuntu 26.04 VM           |
                                  |   Cloud-Init:             |
  Terraform State                 |   - Caddy (HTTPS, :443)   |
  (im Git Repo)                   |   - Python Server (:8080) |
                                  |   - Sysinfo-Skript        |
                                  |   - Cronjob (1 min)       |
                                  +-------------+-------------+
                                                |
                                     https://<IP>
                                                |
                                     +----------+---------+
                                     | HTML-Seite mit     |
                                     | technischen Details |
                                     +--------------------+
```

**Datenfluss:**
1. Caddy empfaengt HTTPS-Request auf Port 443 (Port 80 leitet auf HTTPS um)
2. Caddy leitet intern an Python HTTP-Server auf localhost:8080 weiter
3. Python liefert die statische HTML-Seite aus `/var/www/html/index.html`
4. Ein Cronjob aktualisiert die HTML-Seite jede Minute mit frischen Systemdaten

---

## Dateistruktur

```
Menghini_Patrick/Abgabe_2_300526/
+-- terraform/
|   +-- main.tf              # Terraform Hauptkonfiguration (Provider, VM, Security Group)
|   +-- variables.tf         # Eingabevariablen (Zone, Instanztyp, Name)
|   +-- cloud-init.yaml      # Automatische VM-Konfiguration beim Boot
|
.github/workflows/            # (im Repo-Root, nicht im Unterordner)
+-- deploy.yml        # Workflow: Infrastruktur erstellen
+-- destroy.yml       # Workflow: Infrastruktur loeschen
```

---

## Voraussetzungen

1. **Exoscale Account** mit API-Zugriff
2. **Exoscale API Key + Secret** (erstellen unter: Exoscale Console > IAM > API Keys)
3. **GitHub Repository Secrets** (Settings > Secrets and variables > Actions):
   - `EXOSCALE_API_KEY` — der API Key
   - `EXOSCALE_API_SECRET` — das API Secret

---

## Loesung verwenden

### Schritt 1: Infrastruktur erstellen

1. Im GitHub Repository auf den Tab **Actions** klicken
2. Links den Workflow **"pmen753 - deployen"** auswaehlen
3. Rechts auf **"Run workflow"** klicken und bestaetigen
4. Warten bis der Workflow abgeschlossen ist (ca. 2-3 Minuten)
5. Im Workflow-Log unter dem Step **"Show VM URL"** steht die URL, z.B.:
   ```
   VM URL: https://85.217.174.108
   ```

### Schritt 2: Endpunkt aufrufen

Die URL im Browser oeffnen:
```
https://<IP-aus-Schritt-1>
```

Der Browser zeigt eine Zertifikatswarnung (self-signed Zertifikat). Auf **"Erweitert"** und dann **"Trotzdem fortfahren"** klicken.

Alternativ per Terminal:
```bash
curl -k https://<IP>
```

Es erscheint eine HTML-Seite mit allen technischen Details der VM.

### Schritt 3: Infrastruktur loeschen

1. Im GitHub Repository auf den Tab **Actions** klicken
2. Links den Workflow **"pmen753 - destroy"** auswaehlen
3. Rechts auf **"Run workflow"** klicken und bestaetigen
4. Warten bis der Workflow abgeschlossen ist (ca. 2 Minuten)

Die VM und alle zugehoerigen Ressourcen (Security Group) werden geloescht. Der Terraform State wird automatisch aus dem Repository entfernt.

---

## Technische Details der Loesung

### Terraform (main.tf)

Erstellt drei Ressourcentypen auf Exoscale:
- **Security Group** mit Ingress-Regeln fuer Port 80 (HTTP-Redirect), 443 (HTTPS) und 22 (SSH)
- **Compute Instance** basierend auf Ubuntu 26.04 LTS mit Cloud-Init als `user_data`

Der Provider liest die API-Credentials aus den Umgebungsvariablen `EXOSCALE_API_KEY` und `EXOSCALE_API_SECRET`. Es werden keine Credentials im Code gespeichert.

### Cloud-Init (cloud-init.yaml)

Wird beim ersten Boot der VM automatisch ausgefuehrt und konfiguriert:

1. **Paket-Updates** und Installation von curl, dmidecode, openssl etc.
2. **generate-sysinfo.sh** — Bash-Skript das alle Systemdaten sammelt und als HTML-Seite speichert
3. **Python HTTP-Server** als systemd-Service auf localhost:8080 (nur intern erreichbar)
4. **Caddy** als Reverse Proxy mit self-signed TLS-Zertifikat auf Port 443
5. **Cronjob** der die Systemdaten jede Minute aktualisiert (Uptime, RAM etc. aendern sich)

### GitHub Actions Workflows

- **pmen753-deploy.yml**: Installiert Terraform, fuehrt `init/plan/apply` aus, speichert den Terraform State als Commit im Repository, wartet auf Cloud-Init und testet den HTTPS-Endpunkt
- **pmen753-destroy.yml**: Fuehrt `terraform destroy` aus und entfernt den State aus dem Repository

Beide Workflows werden manuell ueber `workflow_dispatch` ausgeloest.

### Terraform State

Der State wird im Git Repository gespeichert (`terraform.tfstate`), damit der Destroy-Workflow weiss welche Ressourcen geloescht werden muessen. Nach dem Destroy wird die State-Datei automatisch aus dem Repository entfernt.

### HTTPS

Caddy generiert beim ersten Start ein self-signed TLS-Zertifikat mit OpenSSL. Port 80 leitet automatisch auf HTTPS (Port 443) um. Der Browser zeigt eine Zertifikatswarnung, da das Zertifikat nicht von einer offiziellen CA signiert ist — das ist bei einer IP-Adresse ohne Domain normal und erwartet.

---

## Verwendete Technologien

| Komponente | Technologie | Zweck |
|---|---|---|
| Infrastruktur | Terraform + Exoscale Provider | VM und Security Group erstellen/loeschen |
| CI/CD | GitHub Actions | Automatisierte Workflows |
| Cloud Provider | Exoscale (Zone at-vie-1) | Hosting der VM |
| Betriebssystem | Ubuntu 26.04 LTS | VM-Grundlage |
| OS-Konfiguration | Cloud-Init | Automatisierte Einrichtung beim Boot |
| HTTPS Proxy | Caddy | TLS-Terminierung und Reverse Proxy |
| Webserver | Python http.server | HTML-Seite ausliefern |
| Zertifikat | OpenSSL (self-signed) | HTTPS-Verschluesselung |
| Systemdaten | Bash + lscpu, free, df, dmidecode | Technische Details sammeln |
