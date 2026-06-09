# Abgabe 2 - Exoscale VM Info

## Ziel

Diese Lösung erstellt automatisiert eine Ubuntu-VM in Exoscale.
Die VM stellt technische Informationen über HTTP bereit:

* HTML-Website: `/`
* JSON-API: `/api/info`

Die Infrastruktur wird mit OpenTofu/Terraform über GitHub Actions erstellt und gelöscht.
Die Konfiguration der VM erfolgt automatisch über CloudInit.

## Verwendete Technologien

* Exoscale
* Ubuntu 22.04 LTS
* OpenTofu/Terraform
* GitHub Actions
* CloudInit
* nginx
* Bash
* HTML/JSON

## Dateien

Abgabedateien:

```text
Poschinger_Alexander/Abgabe_2_260607/
├── Abgabe_2.md
├── main.tf
├── variables.tf
├── outputs.tf
└── cloud-init.yaml
```

GitHub Actions Workflows:

```text
.github/workflows/
├── poschinger-abgabe-2-create.yml
└── poschinger-abgabe-2-destroy.yml
```

Die Workflows liegen im Root-Verzeichnis, weil GitHub Actions nur dort automatisch erkannt werden.

## Funktionsweise

`main.tf` erstellt die Exoscale-Infrastruktur:

* SSH-Key
* Security Group
* Firewall-Regeln für SSH und HTTP
* Ubuntu-VM
* Übergabe der CloudInit-Konfiguration

Zusätzlich wird ein Remote State Backend verwendet. Dadurch verwenden der Create-Workflow und der Destroy-Workflow denselben OpenTofu-State. Ohne Remote State könnte der Destroy-Workflow die zuvor erstellte VM nicht zuverlässig löschen.

`variables.tf` enthält konfigurierbare Werte wie Zone, VM-Name, Instanztyp und SSH-Key.

`outputs.tf` gibt nach dem Erstellen die öffentliche IP und die URLs aus.

`cloud-init.yaml` konfiguriert die VM automatisch:

* installiert nginx
* erstellt ein Script zum Sammeln der Systeminformationen
* erzeugt die HTML-Seite
* erzeugt den JSON-Endpunkt
* aktualisiert die Informationen regelmäßig per Cronjob

## Endpunkte

Nach erfolgreicher Erstellung sind diese URLs erreichbar:

```text
http://<PUBLIC-IP>/
```

```text
http://<PUBLIC-IP>/api/info
```

Die Website zeigt die Informationen als HTML-Tabelle.
Die API liefert die Informationen im JSON-Format.

## Angezeigte Informationen

Die VM zeigt unter anderem:

* Hostname
* öffentliche IP-Adresse
* System-IP
* Betriebssystem
* Kernel-Version
* Hypervisor
* CPU
* CPU-Kerne
* Arbeitsspeicher
* Storage
* Dateisysteme
* Uptime
* letzte Aktualisierung

## Benötigte GitHub Secrets

Im eigenen Fork müssen folgende Repository Secrets gesetzt sein:

```text
EXOSCALE_API_KEY
EXOSCALE_API_SECRET
SSH_PUBLIC_KEY
```

Der private SSH-Key wird nicht im Repository gespeichert.

## Verwendung

### Infrastruktur erstellen

In GitHub Actions den Workflow starten:

```text
Poschinger Abgabe 2 - Create Infrastructure
```

Der Workflow führt aus:

```text
tofu init
tofu plan
tofu apply -auto-approve
```

Danach sind Website und API über die ausgegebene öffentliche IP erreichbar.

### Infrastruktur löschen

Nach dem Testen den Workflow starten:

```text
Poschinger Abgabe 2 - Destroy Infrastructure
```

Der Workflow führt aus:

```text
tofu init
tofu destroy -auto-approve
```

Dadurch wird die Exoscale-VM wieder gelöscht.

## Test

Die Infrastruktur wurde erfolgreich über GitHub Actions erstellt.
Die Website war über die öffentliche IP erreichbar und zeigte die technischen VM-Informationen an.
Der JSON-Endpunkt `/api/info` lieferte die Daten korrekt im JSON-Format.

Der Destroy-Workflow wurde verwendet, um die erstellte Infrastruktur wieder zu entfernen.

## Hinweis

HTTPS und DNS wurden nicht umgesetzt.
Die Lösung stellt zusätzlich zur HTML-Website einen separaten JSON-Endpunkt bereit.
