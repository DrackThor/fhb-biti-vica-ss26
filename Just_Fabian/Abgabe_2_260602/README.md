# Abgabe 2 – Infrastructure as Code

>**Fabian Just**

## Überblick

In folgendem Projekt wird automatisiert eine virtuelle Maschine in der Exoscale-Cloud
bereitgestellt, die unter einer festen Domain technische Informationen über sich selbst
ausliefert.

Die gesamte Infrastruktur wird per **Terraform** beschrieben und über zwei
**GitHub-Actions-Workflows** erstellt bzw. wieder gelöscht. Die Konfiguration des
Betriebssystems (Webserver, Info-Skript, HTTPS-Zertifikat) erfolgt vollständig
automatisiert über **CloudInit**.

Erreichbar unter:

- Website (HTML): <https://just.biti-fhb.org/>
- API (JSON): <https://just.biti-fhb.org/api>

## Herangehensweise

Bei der Umsetzung wurde folgende Lösungen gewählt:

- Ein Shell-Skript sammelt die Systeminfos und schreibt diese einmalig beim Boot in eine fertige HTML- und  
  JSON-Datei. Die Infos werden mithilfe eines Nginx angezeigt.
- Der Terraform-State wird vom Create-Workflow zurück ins Repository committet, damit der Destroy-Workflow
  weiß, welche Ressourcen zu löschen sind.
- Zwei getrennte Endpunkte: `/` liefert eine HTML-Seite, `/api` die gleichen
  Daten als JSON (für maschinelle Weiterverarbeitung).
- HTTPS: certbot holt automatisch ein Let's-Encrypt-Zertifikat und richtet
  nginx auf Port 443 ein.

## Funktionsweise

1. Ein GitHub-Actions-Workflow startet Terraform auf einem Runner.
2. Terraform legt in Exoscale die Security Group, die VM und den DNS-Record an.
3. Beim ersten Start der VM führt CloudInit die hinterlegte Konfiguration aus:
   Pakete installieren, Info-Skript ausführen, nginx konfigurieren, Zertifikat holen.
4. Das Info-Skript sammelt die Systemdaten und erzeugt `index.html`
   und `api.json` im Verzeichnis `/var/www/sysinfo`.
5. nginx liefert unter `/` die HTML-Seite und unter `/api` die JSON-Datei aus.
6. Ein zweiter Workflow kann die gesamte Infrastruktur wieder löschen.

## Voraussetzungen

- Ein **Exoscale-Account** mit API-Key und API-Secret.
- Eine in Exoscale bereits angelegte **DNS-Domain** (`biti-fhb.org`).
- Ein in Exoscale bereits hinterlegter **SSH-Key**
  (`EXO18f6bb603ff65cbb12f63106`) und **SSH-Secret** (`F0JJm1pBCHTL55iNd17Nc2ylTBTcxtngveS-8ojmPmA`).
- Ein **GitHub-Repository** mit folgenden **Secrets**
  (Settings → Secrets and variables → Actions → Secrets):
  - `EXOSCALE_API_KEY`
  - `EXOSCALE_API_SECRET`

## Verwendung

### 1. Secrets hinterlegen

Im GitHub-Repository unter **Settings → Secrets and variables → Actions** die beiden
Secrets `EXOSCALE_API_KEY` und `EXOSCALE_API_SECRET` mit den Exoscale-Zugangsdaten
anlegen.

### 2. Infrastruktur erstellen

1. Im Repository den Tab **Actions** öffnen.
2. Links den Workflow **„Infrastruktur erstellen"** auswählen.
3. Rechts auf **Run workflow** klicken und bestätigen.
4. Den Durchlauf abwarten, bis er grün ist.

### 3. Ergebnis prüfen

Nach ca. 5 Minuten sind 

- HTML-Website: <https://just.biti-fhb.org/>
- JSON-API: <https://just.biti-fhb.org/api>

erreichbar.

### 4. Infrastruktur löschen

1. Im Tab **Actions** den Workflow **„Infrastruktur löschen"** auswählen.
2. **Run workflow** klicken und bestätigen.
3. Nach dem Durchlauf ist die VM in der Exoscale-Konsole nicht mehr vorhanden.

### Beschreibung der einzelnen Dateien

- **provider.tf** – Bindet den Exoscale-Provider ein und übergibt die Zugangsdaten.
- **variables.tf** – Definiert die Eingabevariablen. API-Key und -Secret kommen über
  Umgebungsvariablen (`TF_VAR_...`) aus den GitHub-Secrets, der SSH-Key-Name ist als
  Default hinterlegt.
- **main.tf** – Beschreibt alle Exoscale-Ressourcen: Security Group samt Regeln für
  die Ports 22/80/443, die Compute Instance inklusive CloudInit, die Abfrage
  der bestehenden Domain sowie den DNS-A-Record für `just.biti-fhb.org`.
- **cloud-init.yaml** – Konfiguriert das Betriebssystem automatisch: installiert die
  benötigten Pakete, schreibt das Info-Skript und die nginx-Konfiguration, generiert
  die Inhalte und holt das HTTPS-Zertifikat.
- **abgabe2_just_create.yml / abgabe2_just_destroy.yml** – GitHub-Actions-Workflows, die manuell gestartet
  werden (`workflow_dispatch`) und Terraform ausführen. Der Create-Workflow committet
  den State zurück, der Destroy-Workflow nutzt ihn zum Löschen.

## Dargestellte Informationen

Die Website und die API liefern folgende technische Details der VM:

- Hostname
- IP-Adresse(n)
- Kernel-Version
- Hypervisor-Typ
- Memory (gesamt / belegt / frei)
- Storage (Blockgeräte)
- Filesysteme (Mountpoints, Größe, Belegung)
- Zeitstempel der letzten Generierung
