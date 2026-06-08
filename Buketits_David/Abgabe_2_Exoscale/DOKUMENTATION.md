# Dokumentation zur Exoscale-Terraform-Lösung

## Ziel der Lösung

Ziel dieser Lösung ist es, eine virtuelle Maschine bei Exoscale automatisiert bereitzustellen und darauf einen einfachen Webserver mit einer dynamisch erzeugten Statusseite zu betreiben. Die Infrastruktur wird mit Terraform beschrieben, die Erstkonfiguration der VM erfolgt über Cloud-Init und das Deployment beziehungsweise Entfernen der Infrastruktur wird über GitHub Actions automatisiert.

Nach erfolgreichem Deployment ist über die öffentliche IP-Adresse der VM ein Nginx-Webserver erreichbar. Die ausgelieferte Webseite zeigt ein kleines Server-Dashboard mit Informationen wie öffentlicher IP-Adresse, Kernel, Virtualisierung, RAM-Auslastung und Speicherbelegung.

## Verwendete Dateien

| Datei | Aufgabe |
|---|---|
| `main.tf` | Definiert die Exoscale-Infrastruktur mit Terraform. |
| `cloud-init.yml` | Installiert und konfiguriert die Software auf der VM beim ersten Start. |
| `buketits_deploy.yml` | GitHub-Actions-Workflow zum Erstellen oder Aktualisieren der Infrastruktur. |
| `buketits_destroy.yml` | GitHub-Actions-Workflow zum Entfernen der Infrastruktur. |

## Herangehensweise

Die Lösung wurde in drei Bereiche aufgeteilt:

1. **Infrastruktur als Code mit Terraform**  
   In `main.tf` wird festgelegt, welche Cloud-Ressourcen benötigt werden. Dazu gehören eine Security Group, passende Firewall-Regeln und eine Compute Instance bei Exoscale.

2. **Automatische Server-Konfiguration mit Cloud-Init**  
   Direkt beim ersten Start der VM wird `cloud-init.yml` ausgeführt. Dadurch werden benötigte Pakete installiert und eine HTML-Startseite für Nginx generiert.

3. **Automatisierte Ausführung über GitHub Actions**  
   Die beiden Workflow-Dateien ermöglichen es, die Infrastruktur direkt über GitHub Actions zu erstellen oder wieder zu löschen. Dadurch muss Terraform nicht manuell lokal ausgeführt werden.

## Funktionsweise der Terraform-Konfiguration

Die Datei `main.tf` verwendet den Exoscale-Provider in Version `0.69.2`. Die Zugangsdaten werden nicht direkt in der Terraform-Datei gespeichert, sondern über Umgebungsvariablen gelesen:

- `EXOSCALE_API_KEY`
- `EXOSCALE_API_SECRET`

Diese Werte werden in GitHub Actions über Repository-Secrets bereitgestellt. Dadurch bleiben die Zugangsdaten geschützt und werden nicht im Quellcode abgelegt.

Als Zone wird `at-vie-1` verwendet, also die Exoscale-Zone in Wien. Als Betriebssystem-Template wird ein Ubuntu-Linux-Template verwendet.

Die Terraform-Konfiguration erstellt folgende Ressourcen:

### 1. Exoscale-Template

Terraform sucht zuerst das angegebene Ubuntu-Template in der Zone `at-vie-1`. Dieses Template wird danach als Basis für die virtuelle Maschine verwendet.

### 2. Security Group

Es wird eine Security Group mit dem Namen `buketits-sg` erstellt. Diese wirkt wie eine Firewall für die VM.

Erlaubt werden nur:

- HTTP auf Port `80`
- HTTPS auf Port `443`

SSH auf Port `22` wird bewusst nicht geöffnet. Dadurch ist die VM nicht direkt per SSH aus dem Internet erreichbar, was die Angriffsfläche reduziert.

### 3. Compute Instance

Die virtuelle Maschine wird mit folgenden Eigenschaften erstellt:

- Name: `buketits-web-server`
- Zone: `at-vie-1`
- Typ: `standard.micro`
- Festplatte: `10 GB`
- Security Group: `buketits-sg`
- Initialisierung: über `cloud-init.yml`

Die Datei `cloud-init.yml` wird über die Terraform-Funktion `file()` eingelesen und als `user_data` an die VM übergeben. Exoscale führt diese Konfiguration beim ersten Start der VM aus.

### 4. Output

Nach dem Deployment gibt Terraform die öffentliche IP-Adresse der VM als Output `server_ip` aus. Diese IP-Adresse wird verwendet, um die Webseite im Browser aufzurufen.

## Funktionsweise von Cloud-Init

Die Datei `cloud-init.yml` beschreibt, was beim ersten Start der VM automatisch passieren soll.

### Paketinstallation

Zuerst wird die Paketliste aktualisiert. Danach werden folgende Pakete installiert:

- `nginx`
- `certbot`
- `python3-certbot-nginx`
- `curl`
- `gnupg`
- `ca-certificates`

Nginx dient als Webserver. Certbot ist vorbereitet, falls später HTTPS-Zertifikate über Let's Encrypt eingerichtet werden sollen.

### Dashboard-Skript

Cloud-Init erstellt das Skript:

```bash
/usr/local/bin/init-dashboard.sh
```

Dieses Skript sammelt Systeminformationen der VM, unter anderem:

- öffentliche IP-Adresse
- RAM-Informationen
- Kernel und Architektur
- erkannte Virtualisierung beziehungsweise Hypervisor
- Speicherbelegung des Root-Dateisystems
- Übersicht der vorhandenen Dateisysteme

Anschließend erzeugt das Skript die Datei:

```bash
/var/www/html/index.html
```

Diese HTML-Datei wird von Nginx ausgeliefert und bildet das Server-Dashboard.

### Start des Webservers

Nach dem Erzeugen der HTML-Datei wird Nginx aktiviert und gestartet:

```bash
systemctl enable nginx
systemctl start nginx
```

Damit startet Nginx auch nach einem Neustart der VM automatisch wieder.

## Funktionsweise des Deploy-Workflows

Die Datei `buketits_deploy.yml` definiert einen manuell startbaren GitHub-Actions-Workflow mit dem Namen **Buketits Deploy Infrastructure**.

Der Workflow wird über `workflow_dispatch` gestartet. Das bedeutet, dass er manuell im GitHub-Repository unter **Actions** ausgeführt werden kann.

Der Workflow führt folgende Schritte aus:

1. Repository auschecken
2. Terraform installieren
3. `terraform init` ausführen
4. `terraform plan` ausführen
5. `terraform apply -auto-approve` ausführen
6. Terraform-State-Datei committen und zurück ins Repository pushen

Der Arbeitsordner ist dabei:

```text
./Buketits_David/Abgabe_2_Exoscale
```

In diesem Ordner müssen die Terraform- und Cloud-Init-Dateien liegen, damit der Workflow korrekt funktioniert.

## Funktionsweise des Destroy-Workflows

Die Datei `buketits_destroy.yml` definiert einen zweiten manuell startbaren Workflow mit dem Namen **Buketits Destroy Infrastructure**.

Dieser Workflow dient dazu, die zuvor erstellte Infrastruktur wieder zu löschen.

Er führt folgende Schritte aus:

1. Repository auschecken
2. Terraform installieren
3. `terraform init` ausführen
4. `terraform plan -destroy` ausführen
5. `terraform destroy -auto-approve` ausführen
6. Aktualisierte Terraform-State-Dateien committen und zurück ins Repository pushen

Auch dieser Workflow verwendet denselben Arbeitsordner:

```text
./Buketits_David/Abgabe_2_Exoscale
```

## Voraussetzungen für die Verwendung

Damit die Lösung funktioniert, müssen folgende Voraussetzungen erfüllt sein:

1. Ein Exoscale-Konto ist vorhanden.
2. Ein API-Key und ein API-Secret wurden in Exoscale erstellt.
3. Im GitHub-Repository sind folgende Secrets hinterlegt:
   - `EXOSCALE_API_KEY`
   - `EXOSCALE_API_SECRET`
4. Die Dateien liegen im Repository im Ordner:

```text
Buketits_David/Abgabe_2_Exoscale
```

5. GitHub Actions ist für das Repository aktiviert.

## Verwendung: Infrastruktur bereitstellen

Zum Bereitstellen der Infrastruktur werden folgende Schritte durchgeführt:

1. GitHub-Repository öffnen.
2. In den Bereich **Actions** wechseln.
3. Den Workflow **Buketits Deploy Infrastructure** auswählen.
4. Auf **Run workflow** klicken.
5. Warten, bis der Workflow erfolgreich abgeschlossen ist.
6. Im Log des Terraform-Apply-Schritts oder in den Terraform-Outputs die öffentliche IP-Adresse der VM ablesen.
7. Die Webseite im Browser öffnen:

```text
http://<server_ip>
```

Dabei wird `<server_ip>` durch die von Terraform ausgegebene öffentliche IP-Adresse ersetzt.


Wenn alles korrekt funktioniert, erscheint das Server-Dashboard mit den Systeminformationen der VM.

## Verwendung: Infrastruktur entfernen

Zum Entfernen der Infrastruktur werden folgende Schritte durchgeführt:

1. GitHub-Repository öffnen.
2. In den Bereich **Actions** wechseln.
3. Den Workflow **Buketits Destroy Infrastructure** auswählen.
4. Auf **Run workflow** klicken.
5. Warten, bis der Workflow erfolgreich abgeschlossen ist.

Nach erfolgreichem Abschluss werden die Exoscale-Ressourcen gelöscht. Dadurch fallen für diese VM keine weiteren laufenden Kosten an.

## Lokale Verwendung mit Terraform

Alternativ kann die Lösung auch lokal ausgeführt werden, wenn Terraform installiert ist und die Exoscale-Zugangsdaten als Umgebungsvariablen gesetzt sind.

### Zugangsdaten setzen

Unter Linux oder macOS:

```bash
export EXOSCALE_API_KEY="<dein-api-key>"
export EXOSCALE_API_SECRET="<dein-api-secret>"
```

### Deployment lokal ausführen

```bash
terraform init
terraform plan
terraform apply
```

Beim lokalen Ausführen fragt Terraform vor dem Anwenden nach einer Bestätigung. Diese kann mit `yes` bestätigt werden.

### Infrastruktur lokal löschen

```bash
terraform plan -destroy
terraform destroy
```

Auch hier muss die Ausführung bestätigt werden.

## Überprüfung der Lösung

Nach dem Deployment kann die Lösung wie folgt überprüft werden:

1. Prüfen, ob der GitHub-Actions-Workflow erfolgreich abgeschlossen wurde.
2. Prüfen, ob Terraform eine öffentliche IP-Adresse ausgegeben hat.
3. Die IP-Adresse im Browser mit `http://` öffnen.
4. Kontrollieren, ob die Dashboard-Seite angezeigt wird.
5. Kontrollieren, ob Systemdaten wie Kernel, RAM und Speicherbelegung angezeigt werden.

Da in der Security Group Port `80` freigegeben ist, sollte die Webseite über HTTP erreichbar sein. Port `443` ist ebenfalls freigegeben, allerdings wird in der aktuellen Konfiguration noch kein Zertifikat automatisch eingerichtet. HTTPS ist damit vorbereitet, aber noch nicht vollständig automatisiert aktiviert.

## Sicherheitsaspekte

Die Lösung berücksichtigt mehrere grundlegende Sicherheitsaspekte:

- Zugangsdaten werden nicht im Code gespeichert, sondern über GitHub-Secrets eingebunden.
- SSH wird nicht öffentlich geöffnet.
- Es werden nur die Web-Ports `80` und `443` freigegeben.
- Die Infrastruktur kann reproduzierbar erstellt und wieder gelöscht werden.

## Hinweise zur Beurteilung

Für die Beurteilung sollte folgender Ablauf verwendet werden:

1. Prüfen, ob die Secrets `EXOSCALE_API_KEY` und `EXOSCALE_API_SECRET` vorhanden sind.
2. Den Deploy-Workflow manuell starten.
3. Nach erfolgreichem Deployment die ausgegebene öffentliche IP-Adresse öffnen.
4. Das Dashboard im Browser kontrollieren.
5. Danach den Destroy-Workflow ausführen, um die Ressourcen wieder zu entfernen.