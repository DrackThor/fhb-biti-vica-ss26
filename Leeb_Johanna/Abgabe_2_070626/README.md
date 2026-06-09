    
# Dokumentation Abgabe 2

Diese Dokumentation beschreibt die Funktionsweise, die Herangehensweise sowie die Bedienung der automatisierten Infrastruktur-Lösung für die IaC Aufgabe in Exoscale

Folgender Zielzustand soll erreicht werden:

- es gibt eine URL (IP oder FQDN), welche einen HTTP(S) Endpunkt bereitstellt
- die URL zeigt auf eine VM in Exoscale
- die URL liefert technische Details über die angesprochene VM
  - zB IP Adresse, Storage, Memory, Kernel Typ, Hypervisor, Filesysteme,..

Die Erstellung aller für diesen Zielzustand nötigen Komponenten muss automatisiert werden.
Verwenden Sie hierfür folgende Technologien/Tools:

- Terraform/openTofu erstellt/löscht in einem GitHub Workflow die nötige Exoscale Infrastruktur
  - ein Workflow zum Erstellen der Infrastruktur
  - ein Workflow zum Löschen der Infrastruktur
- die VM verwendet ein unterstütztes Ubuntu Betriebssystem
- sämtliche Konfiguration des Betriebssystems passiert automatisiert über CloudInit

---

## 1. Herangehensweise & Architektur

### Struktur in Github
Abgabe_2_xxx/                  
    ├── .github/                   
    │   └── workflows/           <-- Ordner für Github Workflows
    │       ├── deploy.yml       <-- Workflow zum Erstellen der Infrastruktur  
    │       └── destroy.yml      <-- Workflow zum Löschen der Infrastruktur  
    ├── terraform/               <-- Terraform-Code  
    │   ├── main.tf              <-- Hauptdatei (Anbieter, VM, Firewall)  
    │   ├── variables.tf         <-- Definition der Passwörter/Schlüssel  
    │   ├── outputs.tf           <-- Gibt am Ende die fertige URL/IP aus  
    │   └── cloud-init.yaml      <-- Der Merkzettel für die VM-Einrichtung  
    └── README.md                <-- Deine Dokumentation und Anleitung  

VM-Namen bzw. Security_Groupnamen in Exoscale enthalten im Namen jole207

### Herangehensweise:
1. **Trigger:** Der Benutzer startet die Pipeline manuell im GitHub-Webinterface.
2. **Infrastruktur-Build (Terraform):** Terraform authentifiziert sich über GitHub Secrets bei Exoscale, sucht dynamisch nach dem passenden Betriebssystem-Template (Ubuntu 24.04 LTS) in der Region Wien (`at-vie-1`), erstellt eine personalisierte Firewall (Security Group) und fährt die Compute-Instanz hoch.
3. **VM-Konfiguration (Cloud-Init):** Beim ersten Start der VM wird eine definierte Befehlskette abgearbeitet. Ein Bash-Skript sammelt die Live-Systemdaten und speichert sie in einer UTF-8-kodierten HTML-Datei. Ein im Hintergrund laufender Python-Webserver stellt diese Datei auf Port 80 bereit.
4. **State-Management (Git-Trick):** Da GitHub Actions flüchtige Runner nutzt, wird der kritische Infrastruktur-Spickzettel (`terraform.tfstate`) nach dem erfolgreichen Deployment automatisiert per Bot-Commit zurück in das Git-Repository gepusht. Dadurch steht er dem Löschen-Workflow später wieder zur Verfügung.

---

## 2. Funktionsweise der Komponenten

### Terraform (`main.tf`, `variables.tf`, `outputs.tf`)
* **Dynamische Vorlagensuche:** Nutzt einen `data`-Block, um die exakte UUID des Ubuntu-Templates in Wien live abzufragen, anstatt eine statische (und fehleranfällige) ID hart zu codieren.
* **Sicherheit:** Erstellt eine spezifische Security Group (`jole207-web-sg-v2`), die ausschließlich eingehenden TCP-Verkehr auf Port 80 (HTTP) von überall (`0.0.0.0/0`) erlaubt. Alle sensiblen API-Schlüssel sind als sensitive Variablen ausgelagert.

### Cloud-Init (`cloud-init.yaml`)
* **Datensammlung:** Verwendet native Linux-Befehle (`hostnamectl`, `uname`, `free`, `df`), um Systemdaten präzise auszulesen.
* **Umlaut-Fix:** Der HTML-Kopf erzwungen das `<meta charset="utf-8">`-Tag, um deutsche Umlaute in Browsern fehlerfrei darzustellen.
* **Webserver:** Nutzt das standardmäßig in Ubuntu enthaltene Modul `python3 -m http.server`, um ohne Overhead einen schlanken HTTP-Endpunkt bereitzustellen.

### GitHub Actions Workflows (`deploy.yml`, `destroy.yml`)
* **Rechteverwaltung:** Benötigt explizite `contents: write`-Rechte, damit der `github-actions[bot]` den Terraform-State pushen und nach dem Löschen wieder aufräumen darf.
* **Schleifen-Schutz:** Der Commit verwendet das Flag `[skip ci]`, um zu verhindern, dass der automatische Push eine unendliche Kette an Workflow-Starts auslöst.

---

## 3. Voraussetzungen (Prerequisites)

Bevor die Pipelines gestartet werden können, müssen die Exoscale-API-Zugangsdaten im GitHub-Repository hinterlegt werden.

1. Navigieren Sie im GitHub-Repository zu **Settings** -> **Secrets and variables** -> **Actions**.
2. Erstellen Sie über den Button **New repository secret** folgende zwei Geheimnisse:
   * `EXOSCALE_KEY`: Ihr persönlicher Exoscale API-Key.
   * `EXOSCALE_SECRET`: Ihr geheimes Exoscale API-Passwort.

---

## 4. Bedienungsanleitung (Anwendung der Lösung)

### Schritt 1: Infrastruktur automatisch erstellen (Deploy)
1. Klicken Sie im GitHub-Repository oben auf den Reiter **Actions**.
2. Wählen Sie in der linken Seitenleiste den Workflow **"1. Exoscale Infrastruktur Erstellen"**.
3. Klicken Sie rechts auf das Dropdown-Menü **Run workflow** und bestätigen Sie mit dem grünen Button **Run workflow**.
4. Warten Sie ca. 1–2 Minuten, bis der Workflow mit einem grünen Haken erfolgreich beendet wurde.

### Schritt 2: Technische Details abrufen
1. Klicken Sie auf den soeben durchgelaufenen Workflow-Eintrag, um das Protokoll zu öffnen.
2. Öffnen Sie den Job **Terraform Apply** und scrollen Sie im Textfenster ganz nach unten.
3. Unter der Sektion `Outputs:` finden Sie die generierte URL (z. B. `http://193.5.x.x`).
<img width="1085" height="447" alt="image" src="https://github.com/user-attachments/assets/f93f54de-97c8-487e-989a-83380340f537" />

4. Kopieren Sie diese URL in Ihren Webbrowser. *(Hinweis: Es kann nach dem Pipeline-Ende noch bis zu einer Minute dauern, bis Cloud-Init die VM fertig konfiguriert und den Webserver gestartet hat).*
5. Sie sehen nun eine formatierte HTML-Seite mit den technischen Details (Kernel, RAM, Speicherplatz, Dateisysteme) Ihrer spezifischen VM.

### Schritt 3: Infrastruktur rückstandslos löschen (Destroy)
1. Navigieren Sie erneut zum Reiter **Actions**.
2. Wählen Sie in der linken Seitenleiste den Workflow **"2. Exoscale Infrastruktur Loeschen"**.
3. Klicken Sie rechts auf **Run workflow** und bestätigen Sie den Start.
4. Der Workflow lädt den zuvor gespeicherten State, entfernt die VM sowie die Firewall-Regeln restlos aus Ihrem Exoscale-Konto und bereinigt abschließend das Git-Repository.
