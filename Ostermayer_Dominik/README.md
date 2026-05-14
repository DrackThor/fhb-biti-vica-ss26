# Exoscale Terraform Webserver (Version via HTTP)

## Beschreibung

Automatisierte Bereitstellung eines Ubuntu NGINX-Webservers in Exoscale mittels Terraform und Cloud-Init.

Die Lösung erstellt:

- Ubuntu VM
- nginx Webserver
- JSON API Endpoint
- Security Groups
- SSH Zugriff
- zusätzlichen Linux User

---

## Verwendete Technologien

- Terraform
- Exoscale
- Cloud-Init
- nginx
- GitHub Actions

---

## Voraussetzungen

- Terraform installiert
- Exoscale API Keys
- SSH Key bereits vorhanden
- ansonsten vorher:
  
```bash
ssh-keygen -t ed25519
```


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
| cloud-init.yaml | Linux Automation |
| .gitignore | Git Ausschlüsse |

---

## Hinweise

- terraform.tfvars enthält Secrets und wird nicht committed.
- Änderungen an cloud-init.yaml benötigen meist destroy + apply.
- Security Groups erlauben HTTP (80) und SSH (22).
- Die API liefert technische Informationen über die VM als JSON.
- Dokumentation folgt via weiterer Commits
