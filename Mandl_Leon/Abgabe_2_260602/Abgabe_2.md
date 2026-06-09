# Abgabe 2 - Exoscale VM mit OpenTofu

## Ziel

Ziel dieser Aufgabe war es, automatisch eine VM in Exoscale bereitzustellen.

Die VM ist über eine öffentliche HTTP-URL erreichbar und zeigt technische Informationen über sich selbst an. Dafür wird eine Ubuntu VM erstellt. Auf der VM läuft ein Nginx-Webserver, der eine HTML-Seite mit VM-Informationen ausliefert.

Die URL hat nach dem Deployment dieses Format:

http://<public-ip>

## Verwendete Technologien

Für die Umsetzung wurden folgende Technologien verwendet:

- OpenTofu
- Exoscale
- GitHub Actions
- CloudInit
- Ubuntu
- Nginx

## Aufbau der Lösung

Der Code für die Abgabe liegt im Ordner:

Mandl_Leon/Abgabe_2_260602

Die GitHub Actions Workflows liegen unter:

.github/workflows/leon_deploy.yml
.github/workflows/leon_destroy.yml

Die wichtigsten Dateien sind:

- main.tf
- variables.tf
- outputs.tf
- cloud-init.yaml
- Abgabe_2.md

## OpenTofu

Mit OpenTofu wird die Infrastruktur in Exoscale erstellt.

Dabei werden folgende Ressourcen angelegt:

- eine Security Group
- eine Firewall-Regel für HTTP auf Port 80
- eine Ubuntu VM
- ein Output für die Public IP
- ein Output für die Service URL

Die Zugangsdaten für Exoscale werden nicht direkt im Code gespeichert. Sie werden über GitHub Secrets eingebunden:

- EXOSCALE_API_KEY
- EXOSCALE_API_SECRET

## Ubuntu, Nginx und CloudInit

Die VM verwendet ein unterstütztes Ubuntu Image.

Die Konfiguration der VM erfolgt automatisch über CloudInit. In der Datei cloud-init.yaml wird festgelegt, dass Nginx installiert und gestartet wird. Zusätzlich wird ein Script erstellt, das technische VM-Informationen sammelt und daraus eine HTML-Datei erzeugt.

CloudInit übernimmt automatisch:

- Paketquellen aktualisieren
- Nginx installieren
- benötigte Systemtools installieren
- Script für die VM-Informationen erstellen
- HTML-Datei unter /var/www/html/index.html erzeugen
- Nginx starten

Dadurch muss auf der VM nichts manuell eingerichtet werden.

## Angezeigte Informationen

Die Webseite zeigt technische Informationen über die angesprochene VM an.

Angezeigt werden unter anderem:

- Hostname
- Public IP
- Local IP
- Instance ID
- Exoscale Zone
- Betriebssystem
- Kernel
- Arbeitsspeicher
- Virtualisierung
- Storage
- Filesysteme

Damit ist direkt im Browser sichtbar, welche VM angesprochen wird und welche technischen Eigenschaften sie hat.

## GitHub Actions

Es gibt zwei Workflows.

### Deploy Workflow

Der Workflow Deploy Leon Infrastructure erstellt die Infrastruktur.

Dabei werden folgende OpenTofu-Befehle ausgeführt:

- tofu init
- tofu validate
- tofu plan
- tofu apply -auto-approve

Nach erfolgreichem Lauf gibt der Workflow die Public IP und die service_url aus.

### Destroy Workflow

Der Workflow Destroy Leon Infrastructure löscht die Infrastruktur wieder.

Dafür wird der gespeicherte OpenTofu State aus dem Deploy Workflow verwendet. Anschließend werden die VM und die Security Group wieder gelöscht.

Der wichtigste Befehl ist:

tofu destroy -auto-approve

## Verwendung

### Infrastruktur erstellen

1. In GitHub auf Actions gehen.
2. Workflow Deploy Leon Infrastructure auswählen.
3. Run workflow klicken.
4. Nach erfolgreichem Lauf die ausgegebene service_url öffnen.

Die URL sieht so aus:

http://<public-ip>

### Infrastruktur löschen

1. In GitHub auf Actions gehen.
2. Workflow Destroy Leon Infrastructure auswählen.
3. Run workflow klicken.
4. Die erstellten Exoscale-Ressourcen werden wieder gelöscht.

## Test

Der Deploy Workflow wurde erfolgreich ausgeführt. Die VM wurde in Exoscale erstellt und war über HTTP erreichbar.

Die Webseite zeigte die technischen Informationen der VM korrekt an.

Danach wurde der Destroy Workflow getestet. Die Infrastruktur wurde erfolgreich wieder gelöscht.
