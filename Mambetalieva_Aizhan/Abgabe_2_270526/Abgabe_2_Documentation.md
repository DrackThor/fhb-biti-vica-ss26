# Technische Dokumentation: Automatisierung & Cloud-Init Infrastruktur

## 1. Studentische Daten und Rahmenbedingungen
- **Name:** Aizhan Mambetalieva
- **Kurs:** Cloud-Infrastrukturen & Virtuelle Instanzen (VICA)
- **Semester:** Sommersemester 2026
- **Repository:** `aizhanai/fhb-biti-vica-ss26`
- **Abgabe-Typ:** Automatisiertes Infrastruktur-Deployment via GitOps (Terraform + GitHub Actions)

---

## 2. Architektur und System-Übersicht
Das Ziel dieser Laborübung ist die vollständige Automatisierung einer Cloud-Infrastruktur nach dem **Infrastruktur als Code (IaC)** Prinzip. Es wird eine virtuelle Maschine (Compute Instance) beim Cloud-Provider **Exoscale** gemietet, provisioniert und ein dynamischer System-Details-Webserver gestartet.

Der gesamte Lebenszyklus (Erstellung, Konfiguration, Zerstörung) wird deklarativ gesteuert. Es ist kein manuelles Eingreifen über das Exoscale-Webportal oder eine lokale SSH-Konsole erforderlich.

### Das 3-Schichten-Modell der Automatisierung:
1. **Orchestrierungsschicht (GitHub Actions):** Steuert die CI/CD-Pipeline, verwaltet die verschlüsselten API-Credentials (`Secrets`) und stößt die Terraform-Befehle remote an.
2. **Infrastrukturschicht (Terraform):** Deklariert die Cloud-Ressourcen (Sicherheitsgruppen, Firewall-Regeln, Compute-Instanz) bei Exoscale und sorgt für den exakten Zielzustand.
3. **Applikations- und Provisionierungsschicht (Cloud-Init & Python):** Richtet das Betriebssystem direkt beim ersten Boot-Vorgang ein, installiert notwendige Pakete und startet die Web-Applikation.

---

## 3. Detaillierte Komponentenbeschreibung

### 3.1 Terraform-Konfiguration (`provider.tf` & `main.tf`)
- **Provider & Authentifizierung:** Terraform nutzt das offizielle Exoscale-Plugin. Die sensitiven Zugangsdaten (API-Key und API-Secret) werden über GitHub Secrets injiziert und fließen als geschützte Variablen ein, um Credential-Leaks im Quellcode zu verhindern.
- **Netzwerksicherheit (Security Groups):** Es wird eine zustandsbehaftete (stateful) Firewall definiert. 
  - **Port 22 (SSH):** Ermöglicht im Bedarfsfall administrative Wartungsarbeiten.
  - **Port 80 (HTTP):** Öffnet den Zugang für weltweiten Web-Traffic, damit Endnutzer die Webseite aufrufen können.
- **Compute Instance:** Es wird eine virtuelle Maschine vom Typ `standard.medium` in der Region Wien (`at-vie-1`) hochgezogen. Als Basis-Image dient ein offizielles Linux-Image (**Ubuntu 22.04 LTS 64-bit**).

### 3.2 Cloud-Init Boot-Provisionierung (`cloud-init.yaml`)
Beim Bootstrapping der VM wertet der Linux-Kernel die übergebenen `user_data` aus. Das Skript führt folgende Schritte vollautomatisch mit Root-Rechten aus:
- **System-Update:** Führt ein `apt-get update` und `upgrade` aus, um die VM auf den neuesten Sicherheitsstand zu bringen.
- **Paket-Installation:** Installiert die Laufzeitumgebung `python3` sowie das Utility-Tool `curl`.
- **Dateisystem-Deployment:** Schreibt das Python-Skript direkt nach `/opt/server.py` und setzt die Ausführungsrechte (`chmod 0755`).

### 3.3 Dynamischer Python-Webserver (`server.py`)
Anstatt einer statischen HTML-Seite wurde ein leichtgewichtiger, nativer Python-HTTP-Server implementiert, der tiefe Einblicke in die virtuelle Maschine gewährt. Das Skript nutzt Linux-Systembefehle (Subprocesses), um die Hardware-Metriken direkt aus dem `/proc`-Verzeichnis und den System-Utilities auszulesen:
- `hostname -I` zur Ermittlung der primären Netzwerk-IP.
- `uname -r` zur Identifikation des aktiven Linux-Kernels.
- `free -h` zur Extraktion des aktuellen Arbeitsspeicher-Status (RAM).
- `df -h /` zur Berechnung der Festplattenbelegung des Root-Verzeichnisses.

---

## 4. Umsetzung der Zusatzpunkte (Erweiterte Endpunkte)
Um die Anforderungen für die Zusatzpunkte zu erfüllen, wurde der HTTP-Request-Handler so modifiziert, dass er inhaltsbasierte Pfad-Unterscheidungen (**Routing**) vornimmt. Je nach URL-Aufruf liefert der Server zwei komplett unterschiedliche Datenrepräsentationen:

### Endpunkt 1: Menschliche Repräsentation (Pfad: `/`)
Wird der Server normal im Browser aufgerufen, wird ein dynamisch generiertes, valides **HTML5-Dokument** ausgeliefert. Das Design wurde mittels modernem CSS3 (Segoe UI Schriftfamilie, strukturierte Flexbox/Grid-Cards und ein dunkles Code-Theme für CLI-Ausgaben) gestaltet, um die Lesbarkeit der Metriken für Systemadministratoren zu maximieren.

### Endpunkt 2: Maschinenlesbare API (Pfad: `/api`)
Für automatisierte Abfragen, Monitoring-Systeme (z. B. Prometheus/Grafana) oder Skripte stellt der Server eine **REST-Schnittstelle** bereit. Beim Aufruf von `/api` sendet der Server den HTTP-Header `Content-Type: application/json` und liefert die Systemdaten als hochstrukturiertes **JSON-Objekt** zurück.

---

## 5. Pipeline-Steuerung (GitOps-Workflow)
Die Ausführung erfolgt über zwei getrennte GitHub Actions Workflows (`workflow_dispatch`), die manuell über das GitHub-Action-UI gesteuert werden können:

- **Terraform Deploy (`deploy.yml`):** Initialisiert das Terraform-Backend, überprüft die Syntax, generiert den Ausführungsplan und baut die Infrastruktur bei Exoscale auf. Am Ende wird die Live-IP-Adresse der VM via `terraform output` direkt in die GitHub-Konsole geschrieben.
- **Terraform Destroy (`destroy.yml`):** Ermöglicht ein sauberes "Teardown" der gesamten Umgebung. Alle gemieteten Ressourcen bei Exoscale werden rückstandslos gelöscht, um unnötige Kosten zu vermeiden.
