# Abgabe 2 – Automatisierte VM-Info-Seite auf Exoscale 

# Erstellt von: Alexander Dirry

## Ziel

Eine über eine URL erreichbare Ubuntu-VM auf Exoscale, die technische
Details über sich selbst anzeigt (IP, Speicher, RAM, Kernel, Hypervisor,
Dateisysteme …). Die gesamte Infrastruktur wird per **OpenTofu/Terraform**
in **GitHub Actions** erstellt und gelöscht; die Konfiguration des
Betriebssystems erfolgt automatisch über **CloudInit**.

## Überblick / Funktionsweise

```
GitHub Actions  ──►  OpenTofu  ──►  Exoscale  ──►  Ubuntu-VM  ──►  CloudInit  ──►  nginx
 (Workflow)        (Infra als     (erstellt die                (richtet beim    (liefert
                    Code)          VM + Firewall)                ersten Boot ein) Website + API)
```

1. **OpenTofu** beschreibt die Infrastruktur deklarativ
   (`main.tf`): eine Security Group mit Regeln für Port 80/443/22, optional
   einen SSH-Key und eine Ubuntu-Compute-Instanz.
2. Die VM erhält über `user_data` ein **CloudInit**-Skript
   (`cloud-init.yaml.tftpl`). Dieses installiert beim ersten Boot `nginx`
   und legt das Python-Skript `generate.py` sowie eine nginx-Konfiguration
   mit zwei Endpunkten an.
3. **`generate.py`** sammelt die Systeminformationen und schreibt sie in
   `index.html` (Website) und `info.json` (API). Ein **systemd-Timer**
   ruft das Skript jede Minute auf, damit die Anzeige aktuell bleibt.
4. Zwei **GitHub-Actions-Workflows** führen `tofu apply` (Erstellen) bzw.
   `tofu destroy` (Löschen) aus.
5. Der Terraform-**State** liegt in einem Exoscale-**SOS-Bucket**
   (`backend.tf`), damit beide Workflows denselben Stand teilen.

## Die zwei Endpunkte

| Endpunkt | Inhalt | Content-Type |
|----------|--------|--------------|
| `http://<IP>/`    | HTML-Seite (Dashboard) | `text/html` |
| `http://<IP>/api` | dieselben Daten als JSON | `application/json` |

## Verwendung

### Einmalige Vorbereitung
1. Exoscale-Account anlegen, **IAM-API-Key + Secret** erstellen.
2. In Exoscale einen **SOS-Bucket** (Zone `at-vie-1`) anlegen und dessen
   Namen in `backend.tf` eintragen.
3. Im GitHub-Repository unter *Settings → Secrets and variables → Actions*
   zwei Secrets anlegen:
   - `EXOSCALE_API_KEY`
   - `EXOSCALE_API_SECRET`

### Erstellen
*Actions → „Abgabe2 – Infrastruktur ERSTELLEN“ → Run workflow.*
Am Ende des Laufs steht im Log die `website_url` und `api_url`.

### Löschen
*Actions → „Abgabe2 – Infrastruktur LÖSCHEN“ → Run workflow.*

## Dateien

| Datei | Zweck |
|-------|-------|
| `main.tf` | Provider, Firewall, SSH-Key, VM |
| `variables.tf` | Eingabewerte (Zone, Typ, Zugangsdaten …) |
| `outputs.tf` | gibt IP und URLs aus |
| `backend.tf` | Remote-State im SOS-Bucket |
| `cloud-init.yaml.tftpl` | Erstkonfiguration der VM |
| `generate.py` | erzeugt HTML + JSON aus den Systemdaten |
| `.github/workflows/abgabe2-create.yml` | Workflow zum Erstellen |
| `.github/workflows/abgabe2-destroy.yml` | Workflow zum Löschen |


