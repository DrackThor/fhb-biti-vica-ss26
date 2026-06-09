# Vollständige Projektdokumentation – Exoscale Webserver mit Terraform, Cloud-Init und Nginx (Version HTTP)

---

## Inhaltsverzeichnis

- [1. Projektziel](#1-Projektziel)
- [2. Verwendete Technologien](#2-Verwendete_Technologien)
- [3. Projektstruktur](#3-Projektstruktur)
- [4. Infrastrukturübersicht](#4-Infrastrukturübersicht)
- [5. Terraform Komponenten](#5-Terraform_Komponenten)
- [6. Exoscale_Provider](#6-Exoscale_Provider)
- [7. Provider_Konfiguration](#7-Provider_Konfiguration)
- [8. variables.tf](#8-variables_tf)
- [9. terraform.tfvars](#9-terraform_tfvars)
- [10. Ubuntu_Template](#10-Ubuntu_Template)
- [11. SSH_Key_Resource](#11-SSH_Key_Resource)
- [12. VM_Resource](#12-VM_Resource)
- [13. Warum_user_data?](#13-Warum_user_data)
- [14. Security_Groups](#14-Security_Groups)
- [15. HTTP_Rule](#15-HTTP_Rule)
- [16. SSH_Rule](#16-SSH_Rule)
- [17. outputs.tf](#17-outputs_tf)
- [18. cloud-init.yaml](#18-cloud_init_yaml)
- [19. Benutzerverwaltung](#19-Benutzerverwaltung)
- [20. Nginx_Config](#20-Nginx_Config)
- [21. Terraform_Commands](#21-Terraform_Commands)
- [22. SSH_Zugriff](#22-SSH_Zugriff)
- [23. .gitignore](#23-gitignore)
- [24. GitHub_Actions](#24-GitHub_Actions)
- [25. Aktueller_Projektstatus_auf_Basis_HTTP](#25-Aktueller_Projektstatus_auf_Basis_HTTP)
- [26. Geplante_Erweiterungen](#26-Geplante_Erweiterungen)
- [27. Fazit](#27-Fazit)

---

## 1. Projektziel

Ziel dieser Aufgabe ist die automatisierte Bereitstellung einer virtuellen Maschine (VM) in Exoscale mittels Terraform. Die VM soll einen HTTP-Endpunkt bereitstellen und technische Systeminformationen über das System als JSON-API ausgeben.

Die gesamte Infrastruktur und Konfiguration wird automatisiert erstellt.

---

## 2. Verwendete_Technologien

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

## 3. Projektstruktur

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
|── cloud.tf
├── .gitignore
└── .github/
    └── workflows/
        ├── deploy.yml
        └── destroy.yml
```

---

## 4. Infrastrukturübersicht

Die Lösung erstellt automatisiert:

- eine Ubuntu VM in Exoscale
- Security Groups für HTTP und SSH
- einen Nginx Webserver
- einen zusätzlichen Linux-User ("Tux") mit sudo-Rechten
- einen JSON API-Endpunkt
- SSH Zugriff über Public Key Authentication (Key-Gen außerhalb IaC aus Security-Überlegungen)

---

## 5. Terraform_Komponenten

### main.tf

Die Datei `main.tf` enthält die Hauptkonfiguration der Infrastruktur.

Folgende Ressourcen werden erstellt:

- Exoscale Provider
- Ubuntu Template
- VM Resource
- Security Groups
- Security Group Rules
- SSH Key Resource

---

## 6. Exoscale_Provider

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

## 7. Provider_Konfiguration

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

## 8. variables_tf

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

variable "ssh_public_key" {
  type        = string
  sensitive   = true
  description = "Public SSH key used for VM access"
}
```

### Erklärung

Die Datei definiert Variablen für:

- API Key
- Secret Key
- Exoscale Zone
- SSH Public Key

---

## 9. terraform_tfvars

```hcl
exoscale_key    = "EXAMPLE_KEY"
exoscale_secret = "EXAMPLE_SECRET"
ssh_public_key = "SSH PUBLIC KEY" (außerhalb IaC erstellt und hier eingefügt)
```

### Erklärung

Die Datei enthält die tatsächlichen Zugangsdaten.

Sie wird über `.gitignore` vom Git Tracking ausgeschlossen (Security Überlegungen).

---

## 10. Ubuntu_Template

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

## 11. SSH_Key_Resource

```hcl
resource "exoscale_ssh_key" "ssh" {
  name       = "ssh-key"
  public_key = var.ssh_public_key
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
und in terraform.tfvars

```bash
ssh_public_key = "ssh-ed25519 HTEDSAAA..... example@example.com"
```

kopiert werden (komplette Zeile kopieren)

Terraform lädt den lokalen Public SSH Key zu Exoscale hoch.

Dieser wird später automatisch in die VM eingebunden.

Verwendet wird ein bereits zuvor lokal erstellter SSH Key.

---

## 12. VM_Resource

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

### Erklärung der Parameter

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

## 13. Warum_user_data

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

## 14. Security_Groups

### Security Group

```hcl
resource "exoscale_security_group" "web" {
  name = "abgabe-2-web-sg"
}
```

#### Erklärung

Die Security Group fungiert als Firewall Container.

---

## 15. HTTP_Rule

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

Erlaubt HTTP Traffic auf Port 80 von jeder IP eingehend auf VM.

---

## 16. SSH_Rule

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

Erlaubt SSH Zugriff auf Port 22 von jeder IP eingehend auf VM.

---

## 17. outputs_tf

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

#### Erklärung

Terraform gibt automatisch:

- die öffentliche IP
- die Website URL
- den API Endpunkt

nach `terraform apply` aus.

---

## 18. cloud_init_yaml

### Zweck

Cloud-Init automatisiert die vollständige Linux-Erstkonfiguration.

Die Konfiguration wird automatisch beim ersten Boot der VM ausgeführt.

---

## Verwendete Bereiche

| Bereich | Zweck |
|---|---|
| package_update | Paketlisten aktualisieren |
| packages | nginx Installation |
| users | Linux User anlegen |
| write_files | Dateien erzeugen |
| runcmd | Shell Commands ausführen |

---

## 19. Benutzerverwaltung

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

## 20. Nginx_Config

Es wird die typische Debian/Ubuntu nginx Struktur verwendet:

```text
/etc/nginx/sites-available/
/etc/nginx/sites-enabled/
```

---

### Eigene Website

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

### Warum wird default entfernt?

Ubuntu liefert standardmäßig eine nginx Testseite mit.

Durch das Entfernen werden:

- Konflikte verhindert
- die eigene Site priorisiert
- saubere Deployments ermöglicht

---

### API Endpunkt

#### nginx API Route

```nginx
location /api {
    alias /var/www/meine-website/html/api.json;
    default_type application/json;
}
```

---

### Erklärung von alias

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

### Dynamische JSON API

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

### Beispiel API Ausgabe

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

### Vollständiger runcmd Ablauf

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

## 21. Terraform_Commands

### Warum_destroy_und_apply?

Cloud-Init läuft standardmäßig nur beim ersten Boot.

Änderungen an `cloud-init.yaml` erfordern daher meist:

```powershell
terraform destroy
terraform apply
```

Dadurch wird die VM vollständig neu erzeugt.

---

### terraform_init

```powershell
terraform init
```

#### Zweck

- lädt Provider
- initialisiert Terraform
- erstellt `.terraform/`

---

### terraform fmt

```powershell
terraform fmt
```

#### Zweck

Formatiert Terraform Dateien automatisch.

---

### terraform validate

```powershell
terraform validate
```

#### Zweck

Prüft Syntax und Konfiguration.

---

### terraform plan

```powershell
terraform plan
```

#### Zweck

Zeigt geplante Änderungen an.

Es entstehen dabei noch keine Ressourcen.

---

### terraform apply

```powershell
terraform apply
```

#### Zweck

Erstellt die Infrastruktur tatsächlich in Exoscale.

Ab diesem Zeitpunkt entstehen Cloud-Ressourcen und potenzielle Kosten.

---

### terraform destroy

```powershell
terraform destroy
```

#### Zweck

Löscht die gesamte Infrastruktur wieder.

Dies ist wichtig für:

- Kostenkontrolle
- Reproduzierbarkeit
- Testen der Automatisierung

---

## 22. SSH_Zugriff

### Verbindung

```bash
ssh ubuntu@IP
```

oder:

```bash
ssh tux@IP
```

---

### Warum funktioniert SSH ohne Passwort?

Die Authentifizierung erfolgt über:

- Public Key auf der VM
- Private Key lokal auf dem Client

---

## 23. gitignore

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

### Warum .gitignore wichtig ist

Es verhindert das versehentliche Hochladen von:

- Terraform State
- API Keys
- lokalen Terraform Dateien
- Secrets

---

## 24. GitHub_Actions

### Ziel

Ziel war die Bereitstellung einer VM inklusive automatisierter Konfiguration, API-Endpunkt sowie CI/CD-Deployment via GitHub Workflow.

---

### Vorgehensweise

Im Rahmen der Aufgabe wurde eine automatisierte Webserver-Infrastruktur auf Basis von:

- Terraform
- Exoscale
- Cloud-Init
- GitHub Actions
- HCP Terraform (Remote State)
- Nginx

implementiert.

### Git-Workflow

#### Repository-Struktur

```text
fhb-biti-vica-ss26/
├── .github/
│   └── workflows/
│       ├── deploy.yml
│       └── destroy.yml
│
└── Ostermayer_Dominik/
    └── Abgabe_2_14052026/
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf
        ├── cloud.tf
        ├── cloud-init.yaml
        └─ terraform.tfvars
        
```
---

### Git Ignore

Folgende Dateien wurden bewusst vom Repository ausgeschlossen:

```gitignore
.terraform/
*.tfstate
*.tfstate.*
*.tfvars
```

Dadurch werden sensible Daten und lokale States nicht veröffentlicht.

---

### GitHub Actions Workflow

#### Ziel

Automatisierung von:

- Terraform Init
- Terraform Validate
- Terraform Plan
- Terraform Apply
- Terraform Destroy

---

### Deploy Workflow

Datei:

```text
.github/workflows/deploy.yml
```

#### Funktionen

Der Workflow führt automatisiert aus:

```text
terraform init
terraform validate
terraform plan
terraform apply -auto-approve
```

---

#### Trigger

Während der Testphase:

```yaml
on:
  push:
    branches:
      - feature/webserver-http
```

Später produktiv:

```yaml
on:
  workflow_dispatch:
```

---

### Destroy Workflow

Datei:

```text
.github/workflows/destroy.yml
```

### Funktionen

Der Workflow führt automatisiert aus:

```text
terraform destroy -auto-approve
```

Damit kann die Infrastruktur vollständig automatisiert entfernt werden.

---

### HCP Terraform Remote State

#### Problemstellung

Ein lokaler Terraform State funktioniert nicht zuverlässig mit GitHub Actions, da der GitHub Runner keinen Zugriff auf lokale Dateien besitzt.

---

#### Lösung

Verwendung von:

```text
HCP Terraform / Terraform Cloud
```

Dadurch wird der Terraform State zentral gespeichert.

---

#### Terraform Cloud Konfiguration

Datei:

```text
cloud.tf
```

Beispiel:

```hcl
terraform {
  cloud {
    organization = "dominik-vica"

    workspaces {
      name = "abgabe-2-exoscale-webserver"
    }
  }
}
```

---

### GitHub Secrets

Folgende Secrets wurden im GitHub Repository hinterlegt:

| Secret | Zweck |
|---|---|
| EXOSCALE_API_KEY | Exoscale API Zugriff |
| EXOSCALE_SECRET_KEY | Exoscale Secret |
| SSH_PUBLIC_KEY | SSH Zugriff auf VM |
| TF_API_TOKEN | Zugriff auf HCP Terraform |

---

### SSH-Konzept

#### Umsetzung

Der SSH Public Key wird:

- lokal via Terraform Variable
- in GitHub Actions via Secret

übergeben.

Beispiel:

```hcl
variable "ssh_public_key" {
  type      = string
  sensitive = true
}
```

Dadurch bleibt der Private Key ausschließlich lokal gespeichert.

---

## 25. Aktueller_Projektstatus_auf_Basis_HTTP

### Bereits umgesetzt

- Terraform Infrastruktur (IaC)
- Exoscale VM
- Ubuntu Deployment
- Cloud-Init Automation
- Nginx Webserver
- Security Groups
- SSH Zugriff
- zusätzlicher Linux User
- JSON API
- Terraform Outputs
- Git Struktur
- Remote Terraform State
- CI/CD via GitHub Actions
- Vollautomatisiertes Destroy
- Nachvollziehbare Git-Historie
- Sichere Secret-Verwaltung

---

## 26. Geplante_Erweiterungen

### Optional

- DNS/FQDN
- HTTPS
- Let's Encrypt
- Certbot
- Domain Variablen
- templatefile()

---

## 27. Fazit

Die Lösung implementiert eine automatisierte Cloud Infrastruktur auf Basis von Terraform und Exoscale.

Die gesamte Serverbereitstellung inklusive Betriebssystemkonfiguration, Benutzerverwaltung, Nginx Konfiguration und API Erstellung wird über Infrastructure as Code (IaC) und via GitHub CI/CD Workflow Actions vollständig automatisiert deployed.

Dadurch entsteht eine reproduzierbare, versionierbare und professionell strukturierte DevOps Lösung.

