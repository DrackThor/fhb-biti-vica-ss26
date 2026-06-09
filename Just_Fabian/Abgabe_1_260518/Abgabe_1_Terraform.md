# Terraform – Infrastructure as Code

**Fabian Just**

---

## 1. Was ist Terraform?

Terraform ist ein Infrastructure as Code Tool der Firma HashiCorp, welches ermöglicht, Cloud und On-Premise Ressourcen in lesbaren Kofigurationsdateien zu verwalten. Diese Dateien können versioniert, wiederverwendet und geteilt werden. Durch den deklarativen Ansatz von Terraform wird der Zielzustand von Ressourcen wie Rechenleistung, Speichernutzung und Netzwerkkomponenten definiert.

Darüber hinaus können auch High-Level-Komponenten wie DNS-Einträge oder SaaS-Funktionen verwaltet werden, jedoch werden hierfür in der Praxis eher Tools wie Cloud-Init und Ansible verwendet.

---

## 2. Warum Terraform?

Da Terraform mit der vom Hersteller bereitgestellten API arbeitet ist es plattformunabhängig. Es unterstützt eine Vielzahl von Cloud-Anbietern und Diensten von AWS, Azure und Google Cloud bis hin zu On-Premise-Lösungen wie VMware und Proxmox. Diese Eigenschaft macht es besonders attraktiv für Organisationen, die in Multi-Cloud- oder Hybrid-Cloud-Umgebungen arbeiten.

### Abgrenzung zu ähnlichen Werkzeugen

| Tool | Ansatz | Anwendungsgebiet | Stärken |
|---|---|---|---|
| **Terraform** | Deklarativ, über API | Erstellen von VMs, Netzwerken, Kubernetes-Clustern, Cloud-Ressourcen  | Multi-Cloud-Unterstützung, reproduzierbare Infrastruktur |
| **Ansible** | Imperativ, über SSH | Softwaredeployment, Systemupdates, Netzwerkautomatisierung, Orchestrierung | Einfach zu lernen, schnelle Einrichtung, starke Cloud-Integration |
| **Puppet** | Deklarativ, über Agent | Große Enterprise-Umgebungen, Compliance, langfristige Konfigurationsverwaltung | Hohe Konsistenz, starkes Monitoring & Reporting |
| **Chef** | Imperativ, über Agent | Komplexe DevOps-Pipelines, hybride Infrastrukturen | Gute Test- und Verifikationsmöglichkeiten, flexibel |
| **Salt** | Deklarativ, meist über Agent | Große verteilte Systeme, Echtzeit-Orchestrierung, Monitoring | Sehr schnelle Kommunikation, skalierbar, Echtzeit-Steuerung |

---

## 3. Technische Funktionsweise

### 3.1 HashiCorp Configuration Language (HCL)

Terraform-Konfigurationen werden in der HashiCorp Configuration Language (HCL) verfasst. Das ist eine deklarative, leserliche Sprache, die auf JSON basiert, aber deutlich kompakter und kommentierfreundlicher ist. In HCL-Dateien beschreibt man *was* vorhanden sein soll, nicht *wie* es erstellt wird.

### 3.2 Provider

Terraform kommuniziert über externe Dienste mit den jeweiligen Providern. Ein Provider ist ein Plugin, das die API eines bestimmten Dienstes (z. B. AWS, Azure, Proxmox, VMWare) und die Terraform-Ressourcentypen zur Verfügung stellt. Provider werden über die Terraform Registry bereitgestellt und bei der Initialisierung automatisch heruntergeladen.

### 3.3 State (Zustandsdatei)

Terraform speichert den aktuellen Zustand einer Maschine in die (`terraform.tfstate`) Datei. Anhand dieser Datei kann Terraform erkennen, welche Ressourcen bereits existieren, welche geändert und welche gelöscht werden müssen. Der State kann lokal oder in einem Remote Backend (z. B. Terraform Cloud, AWS S3, Azure Blob Storage) gespeichert werden, was besonders für Organisationen wichtig ist.

### 3.4 Der Terraform-Workflow

Der typische Workflow in Terraform besteht aus vier Kernbefehlen:
 
```
terraform init → terraform plan → terraform apply → terraform destroy
```

1. **`terraform init`**: Initialisiert das Arbeitsverzeichnis, lädt Provider-Plugins herunter.
2. **`terraform plan`**: Vergleicht den gewünschten Zielzustand (aus den Konfigurationsdateien) mit dem aktuellen Ist-Zustand (aus der State-Datei) und zeigt an, welche Änderungen durchgeführt werden würden – ohne etwas zu verändern.
3. **`terraform apply`**: Führt die geplanten Änderungen tatsächlich aus und aktualisiert die State-Datei.
4. **`terraform destroy`**: Löscht alle durch Terraform verwalteten Ressourcen.

### 3.5 Module

Provider stellen gewissen Infrastruktureinheiten wie z.B. Rechenleistung oder private Netzwerke als Ressourcen zur Verfügung. Diese Ressourcen können von unterschiedlichen Providern in eine wiederverwendbare Terraform Konfiguration zusammengesetzt und mit einer einheitlichen Sprache und einem konstanten Workflow verwaltet werden.

### 3.6 Architekturübersicht

![Alternativtext](https://miro.medium.com/v2/resize:fit:720/format:webp/1*QjhO01jqvt8bJMTd7BkTgw.png)

---

## 4. Anwendungsbeispiele

**Beispiel 1:** Multi-Cloud-Infrastruktur

Ein Unternehmen betreibt seine Infrastruktur gleichzeitig auf AWS und Azure. Terraform beschreibt beide Clouds in einer einheitlichen Codebase und stellt sie automatisiert zur Verfügung.

**Beispiel 2:** Hybride Umgebung – On-Premise VMware und Azure

Ein Unternehmen betreibt kritische Systeme weiterhin auf lokalen VMware-Servern, während neue Dienste in Azure laufen. Terraform verwaltet beide Seiten gleichzeitig: Der vSphere-Provider provisioniert Ressourcen im eigenen Rechenzentrum, der AzureRM-Provider die Ressourcen in der Cloud. So lassen sich Workloads schrittweise migrieren, ohne den laufenden Betrieb zu unterbrechen.

## 5. Vorteile und Herausforderungen

### Vorteile

- **Reproduzierbarkeit**: Infrastruktur kann jederzeit identisch neu erstellt werden.
- **Versionierung**: Infrastrukturcode kann in Git verwaltet werden (History, Rollback, Reviews).
- **Automatisierung**: Integration in CI/CD-Pipelines möglich.
- **Plattformunabhängigkeit**: Ein Werkzeug für viele Cloud-Anbieter.
- **Große Community**: Tausende verfügbare Provider und Module.

### Herausforderungen

- **State-Management**: Die State-Datei enthält sensible Daten und muss sicher und zentral verwaltet werden.
- **Drift**: Manuelle Änderungen außerhalb von Terraform können zu Inkonsistenzen zwischen State und realer Infrastruktur führen.
- **Lizenzierung**: Der Wechsel zu BSL 1.1 schränkt kommerzielle Nutzung ein; OpenTofu ist eine Alternative.
- **Lernkurve**: Besonders beim Einstieg in komplexe Modulstrukturen und State-Backends.

---

## 6. Fazit

Terraform hat sich für Infrastructure as Code bereits als Industriestandard etabliert. Es erlaubt Organisationen, ihre Cloud-Infrastruktur nachvollziehbar, automatisierbar und plattformübergreifend zu steuern.

---

## Quellen

- HashiCorp - https://developer.hashicorp.com/terraform
- IBM - https://www.ibm.com/de-de/think/topics/terraform
- Red Hat - https://www.redhat.com/en/topics/automation/understanding-ansible-vs-terraform-puppet-chef-and-salt
- OpenTofu - https://opentofu.org/docs/
- HashiCorp Lizenz -  https://www.hashicorp.com/blog/hashicorp-adopts-business-source-license
