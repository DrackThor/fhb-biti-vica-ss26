# GitOps-Driven Compute Instance auf Exoscale

Diese Dokumentation beschreibt die Architektur, Funktionsweise und den automatisierten Bereitstellungsprozess (CI/CD) einer Cloud-Infrastruktur auf Exoscale mittels Terraform. Der Fokus liegt auf einem durchgehenden GitOps-Workflow sowie einer automatisierten Post-Deployment-Konfiguration (Cloud-Init) zur Systemanalyse.

---

## 1. Vorbereitung & Berechtigungsmanagement (Exoscale Portal)

Die Bereitstellung folgt dem Prinzip des **Least Privilege** (minimale Rechtevergabe). Im Exoscale-Portal wird ein dedizierter API-Key erstellt, der organisatorisch an eine eingeschränkte IAM-Rolle (z. B. `User` mit Fokus auf den Dienst `compute`) gebunden ist. Die administrative Rolle `Billing Owner` wird bewusst ausgeschlossen, da diese keine Berechtigungen zur Modifikation von Instanzen oder virtuellen Netzwerken besitzt.

---

## 2. Architektur &  Dateistruktur

Die Trennung der Konfiguration in funktionale Einzeldateien ermöglicht Modularität, Wartbarkeit und die strikte Einhaltung von Sicherheitsrichtlinien.

```text
fhb-biti-vica-ss26/
├── .github/workflows/
│   ├── deploy.yml         # Automatisiertes Deployment bei Code-Änderungen
│   └── destroy.yml        # Manueller, kontrollierter Rückbau der Cloud-Ressourcen
└── Jovic_David/
    └── Abgabe_2_260607/
        ├── main.tf               # Ressourcen-Orchestrierung (VM, Firewall)
        ├── providers.tf          # Provider-Anbindung & State-Synchronisation
        ├── variables.tf          # Abstraktion & Parametrisierung
        ├── cloud-init.yaml       # Post-Deployment-Skripting
        └── README.md
```

### 2.1 Funktionsweise der Kernkomponenten

* **`providers.tf` (Schnittstelle & State-Zentralisierung):** Lädt das Exoscale-Plugin. Dies ist das logische Herzstück für die Teamarbeit und CI/CD: Der Infrastruktur-Zustand (`terraform.tfstate`) wird nicht lokal, sondern in einem verschlüsselten Object Storage Bucket gespeichert. Dadurch wissen sowohl der lokale Entwickler-PC als auch die GitHub-Pipeline zu jedem Zeitpunkt exakt, welche Ressourcen real in der Cloud existieren, was Race Conditions und Duplikate verhindert.
* **`variables.tf` (Parametrisierung):** Definiert Stellschrauben (wie Regionen oder Instanzgrößen) als abstrakte Variablen. Dies sorgt dafür, dass die eigentliche Infrastruktur-Logik komplett frei von hardcodierten Werten bleibt und für andere Umgebungen (z. B. Testing vs. Produktion) wiederverwendet werden kann.
* **`main.tf` (Deklarative Orchestrierung):** Beschreibt den gewünschten Soll-Zustand der Cloud-Infrastruktur. Sie verknüpft eine zustandslose Firewall (Security Group für Port 22 und 80), fragt dynamisch das aktuellste Ubuntu-Abbild der Zielregion ab, instanziiert die VM und injiziert die Post-Deployment-Instruktionen.

---

## 3. Sicherheitsarchitektur

Zum Schutz vor unbeabsichtigter Veröffentlichung sensibler API-Schlüssel (Credentials) wird eine strikte **Separation of Concerns** (Trennung der Zuständigkeiten) angewandt:

1. **Lokale Entwicklung:** Zugangsdaten werden exklusiv in einer lokalen `terraform.tfvars` geparkt.
2. **Versionskontrolle (`.gitignore`):** Eine Filterdatei sorgt dafür, dass weder die `.tfvars` noch die temporären lokalen Cache-Verzeichnisse (`.terraform/`) jemals in Git eingecheckt oder auf GitHub hochgeladen werden können.
3. **Pipeline-Sicherheit:** Im automatisierten Betrieb (GitHub Actions) liegen die Schlüssel isoliert im verschlüsselten *Secrets*-Speicher des Repositories und werden zur Laufzeit direkt in den flüchtigen Arbeitsspeicher des Pipeline-Runners geladen.

---

## 4. Der Terraform-Lifecycle (Lokaler Workflow)

Der Bereitstellungsprozess folgt einem dreistufigen, deterministischen Lebenszyklus:

1. **`terraform init` (Initialisierung):** Lädt die benötigten Cloud-Treiber herunter und initialisiert die Verbindung zum S3-Zustandsspeicher.
2. **`terraform plan` (Zustandsabgleich / Trockenlauf):** Terraform vergleicht den deklarativen Code mit dem realen Zustand in der Cloud (via S3-Backend) und errechnet die minimale Differenz. Es wird eine Vorschau der Modifikationen ausgegeben, ohne Änderungen wirksam zu machen.
3. **`terraform apply` (Ausführung):** Die im Plan errechneten Schritte werden sequentiell gegen die Exoscale-API ausgeführt. Nach erfolgreicher Erstellung wird der neue Zustand im S3-Backend fixiert.

---

## 5. Post-Deployment & Dynamisches Monitoring (Funktionsweise)

Sobald die VM von der Cloud-Infrastruktur bereitgestellt wurde, greift die **Cloud-Init-Pipeline** auf Betriebssystemebene. Da dieses Skript autonom beim allerersten Systemstart läuft, arbeitet es unabhängig von externen Zugriffen.

### Ablauf der Server-Provisionierung:
1. **Paketverwaltung:** Aktualisierung der Repositories und native Installation des **Nginx-Webservers**.
2. **Runtime-Metriksammlung:** Ein injiziertes Bash-Skript (`sysinfo.sh`) fragt beim Systemstart die Live-Metriken direkt aus den Linux-Kernelschnittstellen ab (u. a. CPU-Typ, RAM-Belegung, Festplatten-Partitionierung und Hypervisor-Eigenschaften via `uname`, `df` und `/proc`).
3. **Multi-Format-Bereitstellung:** Die gesammelten Live-Daten werden direkt in zwei Repräsentationen in das Web-Verzeichnis (`/var/www/html/`) geschrieben:
   * **HTML-Dashboard (`index.html`):** Eine visuell aufbereitete Weboberfläche für den menschlichen Operator beim Aufruf der Server-IP.
   * **JSON-API (`api.json`):** Eine strukturierte, maschinenlesbare Schnittstelle für Monitoring-Tools und automatisierte Abfragen unter `/api.json`.

---

## 6. CI/CD & GitOps-Workflow (Automatisierung)

Im operativen Betrieb wird die Infrastruktur nach dem GitOps-Prinzip verwaltet. 

### Github Workflow
* **Validierung:** `terraform init` und `terraform plan` wurden erfolgreich durchgeführt. Der Plan liefert das erwartete Ergebnis.
* **Dokumentation:** Im Ordner `/proof` befinden sich Screenshots, die die erfolgreiche lokale Ausführung belegen.

* **Continuous Deployment (Automatischer Build):** Sobald Änderungen am Code in den `main`-Branch gepusht werden, startet GitHub Actions vollautomatisch die Deployment-Pipeline (`deploy.yml`). Der Pipeline-Runner validiert die Syntax, zieht den aktuellen Zustand aus dem S3-Backend, gleicht ihn mit Exoscale ab und rollt Modifikationen ohne manuelles Zutun aus.
* **Controlled Destruction (Sicherer Abbau):** Um ein versehentliches Löschen der Live-Infrastruktur zu verhindern, ist die Zerstörungs-Pipeline (`destroy.yml`) explizit gegen automatische Trigger gesperrt. 
