# Abgabe 2 - VM System Dashboard

## Beschreibung

Diese Loesung provisioniert automatisiert eine virtuelle Maschine in Exoscale (Zone Wien), die ueber einen HTTP(S)-Endpunkt ein Dashboard mit technischen Systeminformationen bereitstellt. Die Informationen werden sowohl als gestylte HTML-Website als auch als JSON-API angeboten.

## Architektur

```
GitHub Actions Workflow
        |
        v
  Terraform/OpenTofu
        |
        v
  Exoscale Cloud (at-vie-2)
        |
        v
  Ubuntu 24.04 LTS VM
        |
    Cloud-Init
        |
        v
  +-----+------+
  |            |
  v            v
Nginx       Cron-Job
  |            |
  v            v
Website    Systeminformationen
(HTML)     sammeln (jede Minute)
  |
  v
JSON API (/api/info.json)
```

Optional: Cloudflare DNS + Let's Encrypt SSL fuer HTTPS-Zugriff.

## Projektstruktur

```
Abgabe_2_260531/
├── terraform/
│   ├── provider.tf        # Exoscale Provider Definition
│   ├── variables.tf       # Eingabe-Variablen
│   ├── main.tf            # VM, Security Group, SSH Key
│   ├── outputs.tf         # Ausgabe-Werte (IP, URLs)
│   └── .gitignore         # Terraform State ignorieren
├── cloudinit/
│   └── cloud-init.yaml    # Automatische VM-Konfiguration
├── .github/workflows/
│   ├── deploy.yml         # Workflow: VM erstellen
│   └── destroy.yml        # Workflow: VM loeschen
└── How2.md                # Diese Dokumentation
```

## Voraussetzungen

- Exoscale Account mit API-Zugangsdaten
- SSH-Schluesselpaar (fuer optionalen VM-Zugriff)
- GitHub Repository mit konfigurierten Secrets
- (Optional) Cloudflare Account mit eigener Domain

## Anleitung zur Verwendung

### Schritt 1: GitHub Secrets einrichten

Im Repository unter **Settings > Secrets and variables > Actions** folgende Secrets anlegen:

| Secret | Beschreibung | Erforderlich |
|--------|-------------|:---:|
| `EXOSCALE_API_KEY` | Exoscale API Key | Ja |
| `EXOSCALE_API_SECRET` | Exoscale API Secret | Ja |
| `SSH_PUBLIC_KEY` | SSH Public Key (z.B. ssh-ed25519 AAA...) | Ja |
| `DOMAIN_NAME` | Domain fuer HTTPS (z.B. vm.example.at) | Nein |
| `CLOUDFLARE_API_TOKEN` | Cloudflare Token (DNS-Edit Berechtigung) | Nein |
| `CLOUDFLARE_ZONE_ID` | Zone ID der Cloudflare Domain | Nein |
| `LETSENCRYPT_EMAIL` | E-Mail fuer SSL-Zertifikat | Nein |

### Schritt 2: VM erstellen (Deploy)

**Variante A - GitHub Actions (empfohlen):**
1. Im Repository auf **Actions** > **"Deploy VM"** navigieren
2. **"Run workflow"** klicken
3. Aktion **"apply"** auswaehlen und starten

**Variante B - Lokal ausfuehren:**
```bash
cd Gruber_Nicolas/Abgabe_2_260531/terraform

# Variablen-Datei erstellen
cat > terraform.tfvars << EOF
exoscale_api_key    = "EXOxxxxxxxx"
exoscale_api_secret = "xxxxxxxx"
ssh_public_key      = "ssh-ed25519 AAAA..."
EOF

terraform init
terraform plan
terraform apply
```

### Schritt 3: Auf die Website zugreifen

Nach erfolgreichem Deploy werden die URLs im Workflow-Log angezeigt:
- **Website (HTML):** `http://<IP>` bzw. `https://<domain>`
- **API (JSON):** `http://<IP>/api/info.json` bzw. `https://<domain>/api/info.json`

### Schritt 4: VM loeschen (Destroy)

**Variante A - GitHub Actions:**
1. **Actions** > **"Destroy VM"** navigieren
2. **"Run workflow"** klicken
3. Als Bestaetigung **"destroy"** eintippen und starten

**Variante B - Lokal:**
```bash
cd Gruber_Nicolas/Abgabe_2_260531/terraform
terraform destroy
```

## Angezeigte Informationen

Das Dashboard sammelt und zeigt folgende VM-Details:

| Kategorie | Details |
|-----------|---------|
| **System** | Hostname, OS, Kernel, Architektur, Hypervisor, Uptime, Boot-Zeit, laufende Services |
| **Prozessor** | CPU-Modell, Kernanzahl, Load Average (1/5/15 min), Prozessanzahl |
| **Arbeitsspeicher** | Total, Belegt, Frei, Verfuegbar, Swap |
| **Festplatte** | Gesamtgroesse, Belegt, Verfuegbar, Auslastung in %, Block-Devices |
| **Netzwerk** | Private IP, Public IP, Gateway, DNS-Server, Interfaces, Domain |

Die Daten werden **jede Minute** automatisch aktualisiert.
Das HTML-Dashboard fuehrt zusaetzlich alle 30 Sekunden einen Auto-Refresh durch.

## Technische Details

### Terraform Konfiguration
- **Provider:** exoscale/exoscale ~> 0.62
- **Zone:** at-vie-2 (Wien, Oesterreich)
- **Template:** Ubuntu 24.04 LTS 64-bit
- **Instance Type:** standard.micro
- **Security Group:** Ports 22/SSH, 80/HTTP, 443/HTTPS
- **State:** Wird als GitHub Artifact gespeichert

### Cloud-Init
- Installiert nginx, jq, curl, certbot
- Erstellt Shell-Script zur Systeminfo-Erfassung
- Generiert HTML-Dashboard und JSON-API Dateien
- Richtet Cron-Job fuer regelmaessige Aktualisierung ein
- Startet optionales DNS/SSL Setup asynchron

### HTTPS mit Cloudflare (optional)
1. Cloud-Init Script ermittelt die oeffentliche IP der VM
2. Erstellt/aktualisiert A-Record via Cloudflare API
3. Fordert SSL-Zertifikat via certbot (DNS-01 Challenge) an
4. Konfiguriert Nginx mit HTTPS und HTTP->HTTPS Redirect
5. Automatische Zertifikatserneuerung ueber certbot Timer

### Zwei Endpunkte (Zusatzpunkte)
- **`/`** - HTML Website mit gestyltem Dashboard (visuell aufbereitet)
- **`/api/info.json`** - JSON API mit strukturierten Rohdaten (maschinenlesbar)

## Herangehensweise

1. **Infrastruktur als Code:** Terraform definiert alle Cloud-Ressourcen deklarativ. Aenderungen sind nachvollziehbar und reproduzierbar.
2. **Automatisierung:** GitHub Actions fuehren den gesamten Deployment-Prozess ohne manuelle Schritte aus.
3. **Cloud-Init:** Die VM konfiguriert sich beim ersten Start vollautomatisch - kein manuelles SSH-Login noetig.
4. **Zwei Darstellungsformen:** HTML fuer Menschen, JSON fuer maschinelle Weiterverarbeitung.
5. **Optionales HTTPS:** Bei Angabe einer Domain wird automatisch DNS konfiguriert und ein SSL-Zertifikat bezogen.
