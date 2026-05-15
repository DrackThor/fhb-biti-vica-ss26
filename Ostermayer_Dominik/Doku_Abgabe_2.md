# Vollständige Projektdokumentation – Exoscale Webserver mit Terraform, Cloud-Init und Nginx (Version HTTP)

## Projektziel

Ziel dieser Aufgabe ist die automatisierte Bereitstellung einer virtuellen Maschine (VM) in Exoscale mittels Terraform. Die VM soll einen HTTP-Endpunkt bereitstellen und technische Systeminformationen über das System als JSON-API ausgeben.

Die gesamte Infrastruktur und Konfiguration wird automatisiert erstellt.

---

# Verwendete Technologien

| Technologie | Zweck |
|---|---|
| Terraform | Infrastructure as Code (IaC) |
| Exoscale Provider | Bereitstellung der Cloud-Ressourcen |
| Ubuntu 22.04 LTS | Betriebssystem der VM |
| Cloud-Init | Automatische Erstkonfiguration der VM |
| Nginx | Webserver |
| Git/GitHub | Versionsverwaltung |
| GitHub Actions | CI/CD Workflow |
| SSH | Sicherer Zugriff auf die VM |

---

# Projektstruktur

```text
README.md
Doku_Abgabe_2.md
Abgabe_2_Dominik/
│
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
├── cloud-init.yaml
├── .gitignore
└── .github/
    └── workflows/
        ├── deploy.yml
        └── destroy.yml
```

---

# Infrastrukturübersicht

Die Lösung erstellt automatisiert:

- eine Ubuntu VM in Exoscale
- Security Groups für HTTP und SSH
- einen Nginx Webserver
- einen zusätzlichen Linux-User ("Tux") mit sudo-Rechten
- einen JSON API-Endpunkt
- SSH Zugriff über Public Key Authentication (Key-Gen außerhalb IaC aus Security-Überlegungen)

---

# Terraform Komponenten

## main.tf

Die Datei `main.tf` enthält die Hauptkonfiguration der Infrastruktur.

Folgende Ressourcen werden erstellt:

- Exoscale Provider
- Ubuntu Template
- VM Resource
- Security Groups
- Security Group Rules
- SSH Key Resource

---

## Exoscale Provider

```hcl
terraform {
  required_providers {
    exoscale = {
      source  = "exoscale/exoscale"
      version = "0.69.2"
    }
  }
}
```

### Erklärung

Terraform lädt den offiziellen Exoscale Provider aus der Terraform Registry.

Die Version wurde fixiert, damit reproduzierbare Deployments möglich sind.

---

## Provider Konfiguration

```hcl
provider "exoscale" {
  key    = var.exoscale_key
  secret = var.exoscale_secret
}
```

### Erklärung

Der Provider authentifiziert sich mit den API Keys gegenüber Exoscale.

Die Keys werden nicht direkt im Code gespeichert, sondern über Variablen eingelesen.

---

# variables.tf

```hcl
variable "exoscale_key" {
  type = string
}

variable "exoscale_secret" {
  type = string
}

variable "zone" {
  type    = string
  default = "at-vie-1"
}
```

### Erklärung

Die Datei definiert Variablen für:

- API Key
- Secret Key
- Exoscale Zone

---

# terraform.tfvars

```hcl
exoscale_key    = "EXAMPLE_KEY"
exoscale_secret = "EXAMPLE_SECRET"
```

### Erklärung

Die Datei enthält die tatsächlichen Zugangsdaten.

Sie wird über `.gitignore` vom Git Tracking ausgeschlossen.

---

# Ubuntu Template

```hcl
data "exoscale_template" "ubuntu" {
  zone = var.zone
  name = "Linux Ubuntu 22.04 LTS 64-bit"
}
```

### Erklärung

Das Ubuntu Image wird dynamisch über die Exoscale API referenziert.

Dadurch muss keine feste Template-ID verwendet werden.

---

# SSH Key Resource

```hcl
resource "exoscale_ssh_key" "ssh" {
  name       = "ssh-key"
  public_key = file(pathexpand("~/.ssh/id_ed25519.pub"))
}
```

### Erklärung

Voraussetzung hierfür ist, dass bereits vorab ein Key-Pair generiert wurde und ein lokaler Public Key existiert.
Aus Security-Überlegungen (Wenn Key-Pair im IaC implementiert wird landet der Private Key gezwungenermaßen im State-File) wird ein Key-Pair-Gen außerhalb von IaC bevorzugt.

- Prüfen ob Key bereits vorhanden:
- 
```bash
cat ~/.ssh/id_ed25519.pub
```
- Wenn nicht dann SSH-Key-Gen:  
  
```bash
ssh-keygen -t ed25519
```
- SSH Public Key anzeigen

```bash
cat ~/.ssh/id_ed25519.pub
```
- SSH Public Key muss in Cloud-init.yaml unter
  
```bash
users: 
sssh_authorized_keys:
ssh-ed25519 HTEDSAAA..... example@example.com
```
- kopiert werden (komplette Zeile kopieren)

Terraform lädt den lokalen Public SSH Key zu Exoscale hoch.

Dieser wird später automatisch in die VM eingebunden.

Verwendet wird ein bereits zuvor lokal erstellter SSH Key.

---

# VM Resource

```hcl
resource "exoscale_compute_instance" "web" {
  zone        = var.zone
  name        = "abgabe-2-webserver"
  template_id = data.exoscale_template.ubuntu.id
  type        = "standard.small"
  disk_size   = 10

  security_group_ids = [
    exoscale_security_group.web.id
  ]

  ssh_key_ids = [
    exoscale_ssh_key.default.id
  ]

  user_data = file("${path.module}/cloud-init.yaml")
}
```

---

## Erklärung der Parameter

| Parameter | Bedeutung |
|---|---|
| zone | Exoscale Region |
| name | Name der VM |
| template_id | Ubuntu Image |
| type | VM Größe |
| disk_size | Storage Größe |
| security_group_ids | Zugewiesene Firewall |
| ssh_key_ids | Public SSH Key |
| user_data | Cloud-Init Konfiguration |

---

# Warum user_data?

```hcl
user_data = file("${path.module}/cloud-init.yaml")
```

Die Datei `cloud-init.yaml` wird beim ersten Start der VM automatisch ausgeführt.

Dadurch wird:

- nginx installiert
- die Website erstellt
- die API erzeugt
- Benutzer angelegt
- nginx konfiguriert

Cloud-Init ermöglicht somit vollständige Serverautomatisierung.

---

# Security Groups

## Security Group

```hcl
resource "exoscale_security_group" "web" {
  name = "abgabe-2-web-sg"
}
```

### Erklärung

Die Security Group fungiert als Firewall Container.

---

# HTTP Rule

```hcl
resource "exoscale_security_group_rule" "http" {
  security_group_id = exoscale_security_group.web.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 80
  end_port          = 80
}
```

### Erklärung

Erlaubt HTTP Traffic auf Port 80.

---

# SSH Rule

```hcl
resource "exoscale_security_group_rule" "ssh" {
  security_group_id = exoscale_security_group.web.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 22
  end_port          = 22
}
```

### Erklärung

Erlaubt SSH Zugriff auf Port 22.

---

# outputs.tf

```hcl
output "public_ip" {
  value = exoscale_compute_instance.web.public_ip_address
}

output "website_url" {
  value = "http://${exoscale_compute_instance.web.public_ip_address}"
}

output "api_url" {
  value = "http://${exoscale_compute_instance.web.public_ip_address}/api"
}
```

### Erklärung

Terraform gibt automatisch:

- die öffentliche IP
- die Website URL
- den API Endpunkt

nach `terraform apply` aus.

---

# cloud-init.yaml

## Zweck

Cloud-Init automatisiert die vollständige Linux-Erstkonfiguration.

Die Konfiguration wird automatisch beim ersten Boot der VM ausgeführt.

---

# Verwendete Bereiche

| Bereich | Zweck |
|---|---|
| package_update | Paketlisten aktualisieren |
| packages | nginx Installation |
| users | Linux User anlegen |
| write_files | Dateien erzeugen |
| runcmd | Shell Commands ausführen |

---

# Benutzerverwaltung

```yaml
users:
  - default

  - name: tux
    groups: sudo
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL

    ssh_authorized_keys:
      - ssh-ed25519 AAAA...
```

### Erklärung

Es wird ein zusätzlicher Linux User erstellt:

- Name: tux
- sudo Rechte
- SSH Key Authentication

Der Standarduser `ubuntu` bleibt zusätzlich bestehen.

---

# nginx Struktur

Es wird die typische Debian/Ubuntu nginx Struktur verwendet:

```text
/etc/nginx/sites-available/
/etc/nginx/sites-enabled/
```

---

# Eigene Website

Die Default nginx Website wird deaktiviert:

```bash
rm -f /etc/nginx/sites-enabled/default
```

Danach wird die eigene Website aktiviert:

```bash
ln -sf /etc/nginx/sites-available/meine-website \
         /etc/nginx/sites-enabled/meine-website
```

---

# Warum wird default entfernt?

Ubuntu liefert standardmäßig eine nginx Testseite mit.

Durch das Entfernen werden:

- Konflikte verhindert
- die eigene Site priorisiert
- saubere Deployments ermöglicht

---

# API Endpunkt

## nginx API Route

```nginx
location /api {
    alias /var/www/meine-website/html/api.json;
    default_type application/json;
}
```

---

# Erklärung von alias

Der Browser ruft auf:

```text
/api
```

nginx liefert intern die Datei:

```text
/var/www/meine-website/html/api.json
```

Dadurch entsteht eine API URL.

---

# Dynamische JSON API

Die API Datei wird dynamisch im `runcmd` Block erzeugt.

Folgende Informationen werden gesammelt:

| Information | Quelle |
|---|---|
| Hostname | hostname |
| Public IP | curl ifconfig.me |
| Private IP | hostname -I |
| Kernel | uname -r |
| RAM | free -m |
| Disk | df -h |
| Filesystem | df -T |
| Virtualization | lscpu |
| Hypervisor Vendor | lscpu |
| Virtualization Type | lscpu |

---

# Beispiel API Ausgabe

```json
{
  "hostname": "abgabe-2-webserver",
  "public_ip": "85.xxx.xxx.xxx",
  "private_ip": "10.xxx.xxx.xxx",
  "kernel": "6.x.x",
  "memory": "1024 MB",
  "disk": "10G",
  "filesystem": "ext4",
  "virtualization": "VT-x",
  "hypervisor_vendor": "KVM",
  "virtualization_type": "full",
  "webserver": "nginx",
  "configured_by": "cloud-init"
}
```

---

# Vollständiger runcmd Ablauf

Der `runcmd` Block führt folgende Schritte aus:

1. Website-Verzeichnis erstellen
2. HTML Datei vorerst nach /temp verschieben da Verzeichnis noch nicht erstellt ist
3. API JSON generieren
4. Rechte setzen
5. Default nginx Site deaktivieren
6. Eigene Site aktivieren
7. nginx Konfiguration testen
8. nginx aktivieren
9. nginx neu laden

---

# Warum destroy + apply?

Cloud-Init läuft standardmäßig nur beim ersten Boot.

Änderungen an `cloud-init.yaml` erfordern daher meist:

```powershell
terraform destroy
terraform apply
```

Dadurch wird die VM vollständig neu erzeugt.

---

# terraform init

```powershell
terraform init
```

### Zweck

- lädt Provider
- initialisiert Terraform
- erstellt `.terraform/`

---

# terraform fmt

```powershell
terraform fmt
```

### Zweck

Formatiert Terraform Dateien automatisch.

---

# terraform validate

```powershell
terraform validate
```

### Zweck

Prüft Syntax und Konfiguration.

---

# terraform plan

```powershell
terraform plan
```

### Zweck

Zeigt geplante Änderungen an.

Es entstehen dabei noch keine Ressourcen.

---

# terraform apply

```powershell
terraform apply
```

### Zweck

Erstellt die Infrastruktur tatsächlich in Exoscale.

Ab diesem Zeitpunkt entstehen Cloud-Ressourcen und potenzielle Kosten.

---

# terraform destroy

```powershell
terraform destroy
```

### Zweck

Löscht die gesamte Infrastruktur wieder.

Dies ist wichtig für:

- Kostenkontrolle
- Reproduzierbarkeit
- Testen der Automatisierung

---

# SSH Zugriff

## Verbindung

```bash
ssh ubuntu@IP
```

oder:

```bash
ssh tux@IP
```

---

# Warum funktioniert SSH ohne Passwort?

Die Authentifizierung erfolgt über:

- Public Key auf der VM
- Private Key lokal auf dem Client

---

# .gitignore

```gitignore
.terraform/

*.tfstate
*.tfstate.*

*.tfvars
*.tfplan

crash.log

override.tf
override.tf.json
```

---

# Warum .gitignore wichtig ist

Es verhindert das versehentliche Hochladen von:

- Terraform State
- API Keys
- lokalen Terraform Dateien
- Secrets

---

# Git Workflow

- Repository klonen

- Repo forken

- Feature Branch erstellen

- Änderungen committen

- In das Repo pushen

- PR erstellen

---

# GitHub Actions

## Ziel

Terraform soll automatisiert über GitHub ausgeführt werden.

Geplant sind:

- deploy.yml
- destroy.yml

---

# GitHub Secrets

Folgende Secrets werden im Repository hinterlegt:

| Secret | Zweck |
|---|---|
| EXOSCALE_API_KEY | API Key |
| EXOSCALE_SECRET_KEY | Secret Key |

---

# Aktueller Projektstatus

## Bereits umgesetzt

- Terraform Infrastruktur
- Exoscale VM
- Ubuntu Deployment
- Cloud-Init Automation
- nginx Webserver
- Security Groups
- SSH Zugriff
- zusätzlicher Linux User
- JSON API
- Terraform Outputs
- Git Struktur

---

# Geplante Erweiterungen

## Optional

- DNS/FQDN
- HTTPS
- Let's Encrypt
- Certbot
- Domain Variablen
- templatefile()
- vollständiger GitHub CI/CD Workflow

---

# Fazit

Die Lösung implementiert eine automatisierte Cloud Infrastruktur auf Basis von Terraform und Exoscale.

Die gesamte Serverbereitstellung inklusive Betriebssystemkonfiguration, Benutzerverwaltung, nginx Konfiguration und API Erstellung erfolgt automatisiert über Infrastructure as Code (IaC).

Dadurch entsteht eine reproduzierbare, versionierbare und professionell strukturierte DevOps Lösung.

