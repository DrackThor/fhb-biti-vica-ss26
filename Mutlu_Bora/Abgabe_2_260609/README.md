# Abgabe 2 - Exoscale VM mit Info-Endpunkt
# Die README-Dokumentation wurde mit KI-Unterstützung formuliert und strukturiert.

## Ziel

Per Knopfdruck eine Ubuntu-VM in Exoscale erstellen, die unter ihrer oeffentlichen IP technische Infos ueber sich selbst ausliefert. Zwei Endpunkte:

- `/`    HTML-Seite
- `/api` JSON

Alles wird automatisiert aufgebaut (OpenTofu + GitHub Actions) und das OS komplett ueber Cloud-Init konfiguriert. Es gibt einen Workflow zum Erstellen und einen zum Loeschen.

## Aufbau / Ablauf

1. GitHub Actions checkt das Repo aus und installiert OpenTofu.
2. Der Workflow baut zur Laufzeit eine `backend.hcl` (damit der Bucket-Name nicht im Code steht) und macht `tofu init` gegen den SOS-Bucket.
3. `tofu apply` legt Security Group, Regel und die Ubuntu-VM an.
4. Die VM bekommt `cloud-init.yaml` als user_data. Beim ersten Boot: Pakete installieren (nginx, python3, curl), Info-Skript ausfuehren, nginx konfigurieren und starten.
5. Das Python-Skript sammelt die Systemdaten und schreibt `index.html` und `api.json` nach `/var/www/html`. nginx liefert sie aus.

## Verwendete Tools

| Zweck | Tool |
|---|---|
| Infrastruktur | OpenTofu |
| CI/CD | GitHub Actions |
| Cloud | Exoscale |
| Remote-State | Exoscale SOS (S3-kompatibel) |
| Betriebssystem | Ubuntu 24.04 LTS |
| OS-Setup | Cloud-Init |
| Webserver | nginx |
| Datensammlung | Python 3 |

## Dateien

```text
.github/workflows/deploy-bora-mutlu.yml    # Erstellen
.github/workflows/destroy-bora-mutlu.yml   # Loeschen
Abgabe_2_Bora_Mutlu/main.tf                # OpenTofu-Konfiguration
Abgabe_2_Bora_Mutlu/cloud-init.yaml        # OS-Konfiguration
Abgabe_2_Bora_Mutlu/README.md              # diese Datei
```

Die Workflows liegen im Repo-Root unter `.github/workflows`, weil GitHub sie sonst nicht findet.

## Voraussetzungen: GitHub Secrets

Im Repository muessen folgende Secrets gesetzt sein:

```text
EXOSCALE_API_KEY
EXOSCALE_API_SECRET
SOS_ACCESS_KEY
SOS_SECRET_KEY
TF_STATE_BUCKET
```

Der SOS-Bucket muss vorher existieren - dort liegt die `terraform.tfstate`. Das ist noetig, weil Deploy und Destroy in getrennten Workflow-Laeufen passieren und sich denselben State teilen muessen.

## Verwendung

**Erstellen**

1. In GitHub auf **Actions** gehen.
2. Workflow **Abgabe 2 - Deploy Bora Mutlu** -> **Run workflow**.
3. Nach dem Lauf stehen IP und URLs im Output des Schritts "Ergebnis anzeigen".

Aufrufen:

```text
http://<PUBLIC_IP>/
http://<PUBLIC_IP>/api
```

**Loeschen**

1. **Actions** -> Workflow **Abgabe 2 - Destroy Bora Mutlu** -> **Run workflow**.
2. OpenTofu liest den State aus SOS und entfernt VM und Security Group wieder.

## Angezeigte Informationen

Hostname, Betriebssystem, Kernel-Typ und -Release, Architektur, Virtualisierung/Hypervisor, CPU-Modell und Kerne, Memory, oeffentliche und private IP, Exoscale Instance-ID und Zone, Uptime sowie Storage/Filesysteme und Block Devices.

## Designentscheidungen

Statt einer eigenen Web-App erzeugt ein Python-Skript einmalig statische Dateien, die nginx ausliefert. Das reicht fuer die Anforderung, ist leicht nachvollziehbar und hat keinen zusaetzlichen App-Prozess, der laufen muss.

DNS und HTTPS sind hier nicht umgesetzt - der Zugriff laeuft per HTTP ueber die oeffentliche IP der VM.
