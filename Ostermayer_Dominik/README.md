# Exoscale Terraform Webserver (Version via HTTP)

## Beschreibung

Automatisierte Bereitstellung eines Ubuntu NGINX-Webservers in Exoscale mittels Terraform und Cloud-Init via vollautomatisierte GitHub CI/CD-Workflow (GitHub Actions).

Die Lösung erstellt:

- Ubuntu VM
- Nginx Webserver
- JSON API Endpoint
- Security Groups
- SSH Zugriff
- Zusätzlichen Linux User

---

## Verwendete Technologien

- Terraform
- Exoscale
- Cloud-Init
- Nginx
- GitHub Actions

---

## Voraussetzungen

- Terraform installiert
- Exoscale API Keys
  
## SSH Key

Aufgrund von Sicherheitsüberlegungen im Zusammenhang mit der SSH-Key-Pair-Erstellgung im Zuge IaC (Private Key landet gezwungenermaßen im State-File) soll die SSH-Key-Pair-Erstellung bereits vor "terraform plan" stattfinden oder es exiert ohnehin bereits ein lokaler Public Key des Systems, der verwendet werden kann.

Der SSH Public Key wird:

- lokal via Terraform Variable
- in GitHub Actions via Secret

übergeben.


Prüfen ob Key bereits vorhanden:
  
```bash
cat ~/.ssh/id_ed25519.pub
```
Wenn nicht dann SSH-Key-Gen:  
  
```bash
ssh-keygen -t ed25519
```
- SSH Public Key anzeigen

```bash
cat ~/.ssh/id_ed25519.pub
```
SSH Public Key muss in Cloud-init.yaml unter
  
```bash
users: 
sssh_authorized_keys:
ssh-ed25519 HTEDSAAA..... example@example.com
```
und in terraform.tfvars

```bash
ssh_public_key = "ssh-ed25519 HTEDSAAA..... example@example.com"
```

kopiert werden (komplette Zeile kopieren).

Terraform lädt den lokalen Public SSH Key zu Exoscale hoch.

Dieser wird später automatisch in die VM eingebunden.

Verwendet wird ein bereits zuvor lokal erstellter SSH Key.

---

## Projekt initialisieren

```powershell oder Git-CLI
terraform init
```

---

## Infrastruktur prüfen

```powershell oder Git CLI
terraform validate
terraform plan
```

---

## Infrastruktur erstellen

```powershell der Git CLI
terraform apply
```

---

## Infrastruktur löschen

```powershell der Git CLI
terraform destroy
```

---

## Zugriff

### Website

```text
http://IP
```

### API

```text
http://IP/api
```

### SSH

```bash
ssh ubuntu@IP
ssh tux@IP
```

---

## Wichtige Dateien

| Datei | Zweck |
|---|---|
| main.tf | Infrastruktur |
| variables.tf | Variablen |
| outputs.tf | Outputs |
| cloud-init.yaml | System-Config |
| .gitignore | Git Ausschlüsse |

---

## Hinweise

- SSH-Public-Key vor "terraform plan" in cloud-init.yaml und terraform.tfvars kopieren
- terraform.tfvars enthält Secrets und wird nicht committed.
- Änderungen an cloud-init.yaml benötigen meist destroy + apply.
- Security Groups erlauben HTTP (80) und SSH (22).
- Die API liefert technische Informationen über die VM als JSON.
- Dokumentation folgt via weiterer Commits
