# Dokumentation: Automatisierte Bereitstellung eines Monitoring-Centers

## 1. Einleitung & Zielsetzung

Ziel dieses Projekts ist die vollautomatisierte Bereitstellung einer virtuellen Maschine (VM) auf Exoscale, welche tiefgehende technische Details (Metriken, Hardware-Infos, OS-Parameter) über sich selbst über sichere HTTP(S)-Endpunkte bereitstellt.

Die gesamte Infrastruktur wird als Code (Infrastructure as Code - IaC) mittels OpenTofu (Terraform) definiert und über GitHub Actions Workflows (`deploy` und `destroy`) verwaltet. Die Konfiguration des Betriebssystems (Ubuntu 26.04 LTS) erfolgt nahtlos und automatisiert über Cloud-Init.

Um nicht nur die Grundanforderungen, sondern auch alle Zusatzpunkte zu erfüllen, wurde die Architektur um automatisiertes DNS-Management, valide Let's Encrypt SSL-Zertifikate und ein Dual-Endpoint-Design (HTML-Website & JSON-API) erweitert.

---

## 2. Architektur & Designentscheidungen

Die Lösung setzt auf eine moderne, containerisierte Microservice-Architektur:

- **Netdata** *(Das Backend & HTML-Frontend)*: Anstatt eines simplen Skripts wird Netdata verwendet. Es sammelt hochauflösende Systemmetriken (IP, Storage, Memory, Kernel, Hypervisor etc.) in Echtzeit und stellt diese als optisch ansprechendes HTML-Dashboard bereit.

- **Swagger-UI** *(Die JSON-API Darstellung)*: Um die Anforderung an eine dedizierte JSON-API-Darstellung zu erfüllen, wird die native JSON-API von Netdata über eine eigene Swagger-UI Instanz visualisiert und konsumierbar gemacht.

- **Caddy** *(Reverse Proxy & HTTPS)*: Caddy fungiert als API-Gateway. Es übernimmt vollautomatisch die Ausstellung der SSL-Zertifikate via Let's Encrypt, löst CORS-Konflikte und leitet den Traffic sicher an die Container weiter.

- **OpenTofu & Cloud-Init**: OpenTofu provisioniert die Exoscale-Infrastruktur (VM, Security Groups, DNS-Records) und injiziert ein maßgeschneidertes Cloud-Init-Skript. Dieses Skript umgeht elegante typische apt-lock-Probleme bei Ubuntu-Bootvorgängen, installiert Docker und startet die Container.

---

## 3. Funktionsweise der Komponenten (Code-Analyse)

### 3.1. Infrastructure as Code (`main.tf` & `variables.tf`)

- **Provider & Compute**: Es wird der Exoscale-Provider genutzt, um eine `standard.small` VM mit Ubuntu 26.04 in der Zone `at-vie-1` zu erstellen.
- **Security Group**: Die Firewall-Regeln (`exoscale_security_group_rule`) erlauben strikt nur den Ingress-Traffic auf den Ports `22` (SSH), `80` (HTTP) und `443` (HTTPS).
- **DNS Automation** *(Zusatzpunkt)*: Es werden dynamisch zwei A-Records in der Zone `biti-fhb.org` angelegt — einer für das HTML-Dashboard (`stats.*`) und einer für die API (`api.*`). Die TTL ist auf 60 Sekunden optimiert, um DNS-Caching-Probleme bei Neu-Deployments zu vermeiden.
- **Template Injection**: Die Konfigurationsdateien (`cloud-init.yml` und `caddyfile.tftpl`) werden über die `templatefile()`-Funktion gerendert, wodurch Variablen wie Domainnamen dynamisch in das OS injiziert werden.

### 3.2. Betriebssystem-Konfiguration (`cloud-init.yml`)

Das Skript ist äußerst robust (bulletproof) konzipiert:

- **Repository-Setup**: Um Race-Conditions mit Ubuntus internen `unattended-upgrades` zu vermeiden, werden die offiziellen Docker-GPG-Keys via `write_files` mit dem Flag `defer: true` angelegt.
- **File Writing**: Die `docker-compose.yml` wird direkt auf das Dateisystem geschrieben.
- **Bootstrapping** (`runcmd`): Docker wird installiert, der Service aktiviert und es wird aktiv gewartet, bis der Docker-Daemon responsiv ist (`until docker info...`), bevor der `docker compose up` Befehl ausgeführt wird. Start-Logs werden in `/var/log/docker-compose-startup.log` gesichert.

### 3.3. Reverse Proxy & Routing (`caddyfile.tftpl`)

Caddy lauscht auf die beiden via Terraform erstellten Subdomains:

- **Stats-Domain** (`stats.*`): Leitet Anfragen mit einem "Ghost-Proxy-Trick" (`header_up Host localhost`) an Netdata weiter, um hostbasierte Sicherheitsblockaden von Netdata zu umgehen. Störende interne CORS-Header von Netdata werden entfernt (`header_down`) und durch saubere, globale Header ersetzt. Der Root-Pfad (`/`) wird komfortabel auf das moderne Dashboard (`/v3`) weitergeleitet.
- **API-Domain** (`api.*`): Leitet Anfragen direkt an den Swagger-UI Container weiter.

### 3.4. CI/CD Pipelines (GitHub Actions)

- **`deploy.yml`**: Führt `tofu init` und `apply` aus. Eine Besonderheit ist der implementierte Health-Check-Loop (Polling): Die Pipeline wartet aktiv mit `curl`, bis die Applikation einen HTTP `200`/`302` Statuscode liefert. Die Pipeline ist erst erfolgreich, wenn die SSL-Zertifikate bezogen wurden und die Container wirklich laufen. Der State wird als GitHub-Artifact gesichert (`if: always()`), sodass selbst bei Abbrüchen kein State verloren geht.
- **`destroy.yml`**: Lädt das Terraform-State-Artifact des letzten Deploy-Runs herunter und führt `tofu destroy` sauber aus, um alle Ressourcen restlos zu entfernen.

---

## 4. Erfüllung der Anforderungen (Mapping)

| Anforderung | Umsetzung in der Lösung |
|---|---|
| URL liefert technische Details der VM | Netdata liefert in Echtzeit hunderte Metriken (Kernel, IP, Storage, CPU, RAM) des Hosts. |
| VM auf Exoscale & Ubuntu OS | Provisioniert via `exoscale_compute_instance` (Ubuntu 26.04). |
| Komplette Automatisierung via Cloud-Init | Docker-Installation, File-Creation und Service-Start passieren ohne manuellen Eingriff via `cloud-init.yml`. |
| Tofu GitHub Workflows (Deploy & Destroy) | Zwei getrennte, funktionale Actions inkl. intelligentem State-Handling über Artifacts. |
| Zusatzpunkt: DNS und Zertifikate (HTTPS) | Terraform setzt automatisiert die A-Records. Caddy generiert On-the-Fly gültige Let's Encrypt SSL-Zertifikate. HTTP wird forciert auf HTTPS umgeleitet. |
| Zusatzpunkt: HTML und JSON über zwei Endpunkte | **Endpunkt 1** (`stats.ggruenwald...`): HTML-Website (Netdata Dashboard). **Endpunkt 2** (`api.ggruenwald...`): JSON API grafisch aufbereitet (Swagger-UI). |

---

## 5. Anleitung zur Verwendung (Usage Guide)

### Schritt 1: Infrastruktur aufbauen

1. Navigieren Sie in diesem GitHub-Repository zum Reiter **Actions**.
2. Wählen Sie links den Workflow **"Deploy Infrastructure"** aus.
3. Klicken Sie auf **"Run workflow"** (Branch: `main` bzw. Ihr Abgabe-Branch).

> **Hinweis:** Die Pipeline wartet am Ende in einer Loop, bis Caddy das SSL-Zertifikat bezogen hat und Netdata gebootet ist. Wenn der Workflow grün wird, ist die Applikation zu 100% erreichbar.

### Schritt 2: Ergebnisse begutachten

Sobald der Workflow erfolgreich durchgelaufen ist, können die beiden Endpunkte aufgerufen werden:

- **HTML-Website** *(Visualisierung der Systemdaten)*:
  Rufen Sie [`https://stats.ggruenwald.biti-fhb.org`](https://stats.ggruenwald.biti-fhb.org) im Browser auf. Sie werden automatisch auf das hochdetaillierte V3-Dashboard von Netdata weitergeleitet (Verbindung ist via SSL gesichert).

- **JSON API Endpunkt** *(Technische Rohdaten)*:
  Rufen Sie [`https://api.ggruenwald.biti-fhb.org`](https://api.ggruenwald.biti-fhb.org) im Browser auf. Sie sehen die Swagger-UI, welche die JSON-Schnittstelle von Netdata dokumentiert und konsumierbar macht.

### Schritt 3: Infrastruktur abbauen

1. Navigieren Sie zurück zu **Actions**.
2. Wählen Sie den Workflow **"Destroy Infrastructure"** aus.
3. Klicken Sie auf **"Run workflow"**.

Die Pipeline lädt automatisch den letzten State herunter und löscht die VM, die Security Groups und die DNS-Records auf Exoscale rückstandslos.
