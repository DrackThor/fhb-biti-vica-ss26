# Abgabe 2 - VM Info Website

## Uebersicht

Diese Loesung erstellt automatisiert eine VM in Exoscale, die ueber einen HTTP(S)-Endpunkt technische Details ueber die VM bereitstellt.

**Architektur:**
```
GitHub Actions --> Terraform --> Exoscale VM --> Nginx --> VM-Info Website + JSON API
                                      |
                              Cloudflare DNS + Let's Encrypt SSL
```

## Voraussetzungen

- Exoscale Account mit API Key/Secret
- SSH Key Pair (fuer VM-Zugriff)
- GitHub Repository mit Secrets
- _(Optional)_ Cloudflare Account mit Domain fuer DNS + SSL

## Projektstruktur

```
Abgabe_2_260507/
├── terraform/                    # Terraform Konfiguration
│   ├── provider.tf              # Exoscale Provider
│   ├── variables.tf             # Variablen-Definitionen
│   ├── main.tf                  # Hauptkonfiguration (VM, Security Group, SSH Key)
│   ├── outputs.tf               # Outputs (IP, URLs)
│   ├── terraform.tfvars.example # Beispiel-Variablen
│   └── .gitignore               # Terraform-Dateien ignorieren
├── cloudinit/
│   └── cloud-init.yaml          # CloudInit-Konfiguration fuer VM
├── .github/workflows/
│   ├── deploy.yml               # Workflow: Infrastruktur erstellen
│   └── destroy.yml              # Workflow: Infrastruktur loeschen
└── How2.md                      # Diese Dokumentation
```

## Verwendung

### 1. GitHub Secrets konfigurieren

In den Repository-Settings > Secrets and variables > Actions:

| Secret | Beschreibung | Pflicht |
|--------|-------------|---------|
| `EXOSCALE_API_KEY` | Exoscale API Key | Ja |
| `EXOSCALE_API_SECRET` | Exoscale API Secret | Ja |
| `SSH_PUBLIC_KEY` | Oeffentlicher SSH Key (ssh-ed25519 AAAA...) | Ja |
| `DOMAIN_NAME` | Domain fuer DNS (z.B. vm-info.example.com) | Nein |
| `CLOUDFLARE_API_TOKEN` | Cloudflare API Token (DNS-Edit) | Nein |
| `CLOUDFLARE_ZONE_ID` | Cloudflare Zone ID der Domain | Nein |
| `LETSENCRYPT_EMAIL` | E-Mail fuer Let's Encrypt | Nein |

### 2. Infrastruktur erstellen

**Option A: GitHub Actions (empfohlen)**
1. Gehe zu Actions > "Deploy Infrastructure"
2. Klicke "Run workflow"
3. Waehle "apply" aus
4. Klicke "Run workflow"

**Option B: Lokal**
```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# terraform.tfvars mit eigenen Werten fuellen
terraform init
terraform plan
terraform apply
```

### 3. Infrastruktur loeschen

**Option A: GitHub Actions**
1. Gehe zu Actions > "Destroy Infrastructure"
2. Klicke "Run workflow"
3. Tippe "destroy" als Bestaetigung ein
4. Klicke "Run workflow"

**Option B: Lokal**
```bash
cd terraform
terraform destroy
```

## Endpunkte

Nach dem Deploy:

| Endpoint | URL | Beschreibung |
|----------|-----|-------------|
| HTML Website | `https://<domain>/` | VM-Info als Website (HTTPS) |
| JSON API | `https://<domain>/api/info.json` | VM-Info als JSON (HTTPS) |
| HTML (Fallback) | `http://<IP>/` | VM-Info als Website (HTTP) |
| JSON (Fallback) | `http://<IP>/api/info.json` | VM-Info als JSON (HTTP) |

## Gesammelte Informationen

Die Website/API zeigt folgende VM-Details:

- **System**: Hostname, OS, Kernel, Architektur, Hypervisor, Uptime
- **CPU**: Modell, Kerne, Load Average, Prozesse
- **Arbeitsspeicher**: Total, Belegt, Frei, Verfuegbar, Swap
- **Storage**: Total, Belegt, Frei, Auslastung
- **Netzwerk**: Private/Public IP, Interfaces, Domain
- **Filesysteme**: lsblk-Ausgabe

## Technische Details

### Terraform

- **Provider**: exoscale/exoscale ~> 0.62
- **Template**: Linux Ubuntu 22.04 LTS 64-bit
- **Instance Type**: standard.micro (konfigurierbar)
- **Security Group**: Ports 22 (SSH), 80 (HTTP), 443 (HTTPS)
  
### CloudInit

- Installiert Nginx, certbot, python3-certbot-dns-cloudflare
- Erstellt Shell-Script zur Info-Sammlung
- Generiert HTML- und JSON-Dateien
- Cron-Job aktualisiert alle 60 Sekunden
- Bei Domain-Konfiguration:
  - Erstellt DNS A-Record in Cloudflare
  - Holt SSL-Zertifikat via certbot + DNS Challenge
  - Konfiguriert Nginx mit HTTPS + HTTP-Redirect

### Cloudflare DNS + SSL (optional)

1. **DNS**: CloudInit erstellt/aktualisiert A-Record via Cloudflare API
2. **SSL**: certbot mit `--dns-cloudflare` Plugin (DNS-01 Challenge)
3. **Nginx**: HTTP->HTTPS Redirect, SSL mit Let's Encrypt Zertifikat
4. **Renewal**: Certbot Renewal Hook fuer automatisches Nginx-Reload

### GitHub Actions

- **Deploy**: Manuell oder bei Push zu terraform/cloudinit
- **Destroy**: Nur manuell mit Bestaetigung
- **State**: Wird als Artifact gespeichert

## Cloudflare Setup

### API Token erstellen
1. https://dash.cloudflare.com/profile/api-tokens
2. "Create Token" > "Edit zone DNS" Template
3. Zone auf die gewuenschte Domain beschraenken
4. Token kopieren

### Zone ID finden
1. https://dash.cloudflare.com > Domain auswaehlen
2. "Overview" > Rechts unten "Zone ID"
