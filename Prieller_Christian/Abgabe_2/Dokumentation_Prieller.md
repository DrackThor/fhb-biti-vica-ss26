
# Dokumentation Abgabe 2 – Christian Prieller

## Projektziel

Automatisierte Bereitstellung einer VM in Exoscale, die unter einer HTTPS-URL technische Systeminformationen als Webseite bereitstellt. Die gesamte Infrastruktur wird als IaC verwaltet und über GitHub Actions-Workflows erstellt bzw. gelöscht.

---

## Verwendete Technologien

| Technologie | Zweck |
|---|---|
| OpenTofu (Terraform) | Infrastructure as Code|
| Exoscale | Cloud Provider (Zone: at-vie-1, Wien) |
| Ubuntu 26.04 LTS | OS der VM |
| CloudInit | Automatische VM-Konfiguration beim ersten Boot |
| nginx | Webserver mit HTTPS |
| GitHub Actions | CI/CD Workflows für Deploy und Destroy |
| OpenSSL | Generierung des TLS-Zertifikats |

---

## Projektstruktur

```
Prieller_Christian/
└── Abgabe_2/
    ├── README.md                   # Kurzanleitung
    ├── .gitignore                  # Schützt sensible Dateien
    └── terraform/
        ├── versions.tf             # Provider-Version
        ├── providers.tf            # Exoscale Authentifizierung
        ├── variables.tf            # Konfigurierbare Variablen
        ├── main.tf                 # VM und Security Groups
        ├── outputs.tf              # IP und URL Ausgabe
        └── cloud-init.yaml         # VM-Konfiguration

.github/workflows/
├── deploy.yml                      # Workflow: VM erstellen
└── destroy.yml                     # Workflow: VM löschen
```

---

## Herangehensweise

### Schritt 1: Terraform-Code erstellen

Der erste Schritt war die Erstellung der Terraform-Dateien mit den IaC-Tool Terraform. Das bedeuted, es wird die gewünschte Infrastruktur als Code in eine "Textdatei" geschrieben und Terraform erstellt daraus die VM in der Cloud (Exoscale).

Die Terraform-Konfiguration wurde auf mehrere Dateien aufgeteilt:

**versions.tf** legt fest, welcher Provider (Exoscale) in welcher Version verwendet wird.

**providers.tf** konfiguriert die Verbindung zur Exoscale API. Die Zugangsdaten werden nicht direkt im Code gespeichert, sondern über Variablen übergeben.

**variables.tf** definiert alle konfigurierbaren Parameter: API-Keys, Zone (at-vie-1 für Wien), VM-Name, Betriebssystem-Template und VM-Größe. Duch Verwendung von Variablen kann die Konfiguration 
angepasst werden ohne dabei den Code zu ändern.

**main.tf** ist die "Hauptdatei" und beschreibt die eigentlichen Ressourcen:
- Ein Ubuntu 26.04 LTS Template wird als Datenquelle referenziert
- Eine Security Group wird als virtuelle Firewall erstellt
- Drei Firewall-Regeln öffnen die Ports 80 (HTTP), 443 (HTTPS) und 22 (SSH)
- Eine Compute Instance wird mit der CloudInit-Konfiguration erstellt

**outputs.tf** gibt nach dem Deployment die öffentliche IP-Adresse und die URLs für Website und API aus.

### Schritt 2: CloudInit-Konfiguration

Die cloud-init.yaml-Datei wird beim ersten Bootvorgang ausgeführt und konfoiguriert die komplette VM.

1. **Paketinstallation**: nginx, openssl, curl und dmidecode werden installiert
2. **Info-Script**: Ein Bash-Script sammelt alle technischen VM-Informationen (IP, Kernel, CPU, RAM, Disk, Hypervisor, etc.)
3. **HTML-Seite**: Das Script erzeugt eine Webseite welche die gesammelten technischen VM-Informationen anzeigt
4. **JSON-API**: Erzeugt eine JSON-Datei unter /api/vm-info
5. **SSL-Zertifikat**: Ein self-signed Zertifikat wird via OpenSSL erstellt
6. **nginx-Konfiguration**: Der Webserver wird mit HTTPS konfiguriert, HTTP wird automatisch auf HTTPS umgeleitet

### Schritt 3: Lokales Testen

Bevor die GitHub Actions Workflows erstellt wurden, wurde die Lösung lokal getestet:

```bash
cd Abgabe_2/terraform
export TF_VAR_exoscale_api_key="hier_ist_mein_Key"
export TF_VAR_exoscale_api_secret="und_hier_ist_mein_Secret"
tofu init
tofu plan
tofu apply
```

Die Installation von OpenTofu auf Debian 13 war nicht ganz so trivial wir ursprünglich gedacht. Das erste Installationsscript wurde nicht ausgeführt.  
Lösung - direkter Download des .deb-Pakets:
```bash
curl -Lo /tmp/tofu.deb https://github.com/opentofu/opentofu/releases/download/v1.8.8/tofu_1.8.8_amd64.deb
sudo dpkg -i /tmp/tofu.deb
```

In VSCodium war tofu anfangs nicht auffindbar, da das Terminal als Flatpak-Container läuft. Der Pfad `/run/host/usr/bin/tofu` musste verwendet werden.

### Schritt 4: GitHub Actions Workflows

Die Aufgabe verlangt zwei GitHub Workflows: einen zum Erstellen und einen zum Löschen der Infrastruktur.

**deploy.yml** führt folgende Schritte aus:
1. Repository auschecken (Branch abgabe-2-prieller)
2. OpenTofu installieren
3. `tofu init` ausführen
4. `tofu apply -auto-approve` ausführen
	 beim Ausführen von `tofu apply` kommt eine yes/no-Abfrage. Um mir das zu umgehen wurde die Option `-auto-approve` dem Befehl beigefügt
5. Outputs anzeigen (IP und URLs)
6. Den Terraform State in den Git-Branch committen

**destroy.yml** führt folgende Schritte aus:
1. Repository auschecken (Branch abgabe-2-prieller, inklusive State-Datei)
2. OpenTofu installieren
3. `tofu init` ausführen
4. `tofu destroy -auto-approve` ausführen

### Schritt 5: Git und Pull Request

Das Original-Repository wurde geforkt, ein Feature-Branch `abgabe-2-prieller` erstellt, die Dateien hinzugefügt und ein Pull Request eröffnet.

Die GitHub Secrets `EXOSCALE_API_KEY` und `EXOSCALE_API_SECRET` wurden im Fork unter Settings > Secrets > Actions eingerichtet.

---

## Probleme und Lösungen

### Problem 1: CloudInit wurde nicht ausgeführt

**Symptom**: Die VM startete, aber nginx war nicht installiert und keine es wurden auch keine weiteren Dateien erstellt.

**Ursache**: Die wichtigste Zeile der cloud-init.yaml fehlte `#cloud-config`. Ohne dieser Zeile erkennt CloudInit die Datei nicht als Konfiguration und ignoriert sie komplett.

**Lösung**: `#cloud-config` als allererste Zeile hinzugefügt. Da die CloudInit nur beim ersten Boot läuft, musste die fehlerhafte VM wieder gelöscht werden and danach wieder mit `tofu apply` erstellt werden.

### Problem 2: Security Group existiert bereits

**Symptom**: `tofu apply` schlug fehl mit der Meldung "Security group already exists".

**Ursache**: Bei einem vorherigen Test wurde die VM manuell im Exoscale Portal gelöscht, aber die Security Group blieb bestehen (vergessen zu löschen).

**Lösung**: Die Security Group manuell im Exoscale Portal löschen, danach funktionierte `tofu apply` wieder.

### Problem 3: Destroy-Workflow – State-Datei nicht gefunden (Hauptproblem)

**Symptom**: Der Destroy-Workflow schlug jedesmal fehl mit "Artifact not found for name: terraform-state".

**Ursache**: Das war das zeitaufwändigste Problem. Terraform speichert den Zustand aller erstellten Ressourcen in einer State-Datei (terraform.tfstate). Ohne diese Datei weiß Terraform nicht, welche Ressourcen existieren und kann sie daher nicht löschen.

In GitHub Actions hat jeder Workflow-Run eine eigene, frische Umgebung. Der State vom Deploy-Workflow existiert nach dessen Ausführung nicht mehr. Es wurden mehreres versucht:

**Versuch 1 – GitHub Artifacts**: Der Deploy-Workflow speicherte den State als Artifact, der Destroy-Workflow versuchte ihn mit `actions/download-artifact@v4` zu laden. Das schlug fehl, weil `download-artifact@v4` standardmäßig nur Artifacts aus dem eigenen Workflow finden kann, nicht aus anderen Workflows.

**Versuch 2 – GitHub API**: Der State wurde über die GitHub REST API (`gh api`) heruntergeladen. Auch das funktionierte nicht.

**Versuch 4 – actions/cache**: Statt Artifacts wurde der GitHub Cache verwendet, der zwischen Workflows geteilt werden kann. Auch das führte zu nichts.

**Lösung:**
**State im Git-Branch speichern**: Der Deploy-Workflow committet den State direkt in den Git-Branch. Der Destroy-Workflow checkt denselben Branch aus und hat damit automatisch Zugriff auf die State-Datei. Diese hat schließlich funktioniert.

---

## Dashboard und API

### HTML-Webseite

Die Webseite zeigt in einer einfachen Auflistung:
- Hostname und IP-Adressen (Public und Private)
- Betriebssystem (Ubuntu 26.04 LTS), Kernel und Architektur
- CPU-Modell und Anzahl der Kerne
- Arbeitsspeicher (Gesamt und Belegt)
- Festplattenspeicher (Gesamt, Belegt, Frei) und Dateisystem-Typ
- Virtualisierungs-Typ und Hypervisor
- BIOS-Vendor und Hersteller
- Uptime

### JSON-API

Dieselben Informationen stehen auch als JSON zur Verfügung. Das ermöglicht die maschinelle Varbeitung der Daten.

### HTTPS

Die Verbindung ist mit TLS 1.2/1.3 verschlüsselt. Da ein self-signed Zertifikat verwendet wird, zeigt der Browser eine Sicherheitswarnung die manuell akzeptiert werden muss. Für Produktionsbetrieb würde man Let's Encrypt mit Certbot verwenden, was eine eigene Domain voraussetzt.

---

## Anleitung zur Verwendung

### Voraussetzungen

- GitHub-Account mit Zugriff auf das Repository
- Exoscale-Account mit API Key und Secret
- GitHub Secrets einrichten: `EXOSCALE_API_KEY` und `EXOSCALE_API_SECRET`

### VM erstellen

1. Im GitHub Repository den **Actions** Tab öffnen
2. Workflow **"Deploy Infrastruktur"** auswählen
3. Auf **"Run workflow"** klicken, Branch **abgabe-2-prieller** auswählen
4. Warten bis der Workflow abgeschlossen ist (ca. 2-5 Minuten) - grüner Haken erscheint
5. Im Workflow-Log den Schritt "Outputs anzeigen" öffnen und die URL kopieren
6. Bei der Sicherheitswarnung "Erweitert" > "Weiter"

### VM löschen

1. Im GitHub Repository den **Actions** Tab öffnen
2. Workflow **"Destroy Infrastruktur"** auswählen
3. Auf **"Run workflow"** klicken, Branch **abgabe-2-prieller** auswählen
4. Warten bis der Workflow abgeschlossen ist (ca. 2-5 Minuten) - grüner Haken erscheint
5. Alle Ressourcen werden gelöscht (VM und die Security Group)

---

## Fazit

Es wird eine vollständig automatisierte Cloud-Infrastruktur auf Basis von OpenTofu und Exoscale erzeugt. Vom Terraform-Code über CloudInit bis zu den GitHub Actions Workflows ist der gesamte Lebenszyklus der VM automatisiert.

Die größte Herausforderung für mich war das State-Management zwischen den GitHub Actions-Workflows. Das Problem wurde durch das Committen des States in den Git-Branch gelöst.

Die VM wird automatisiert erstellt, HTTPS ist aktiv, technische Details werden über ein Dashboard und eine JSON-API aufgelistet, und die Infrastruktur kann über Workflows erstellt und gelöscht werden.
