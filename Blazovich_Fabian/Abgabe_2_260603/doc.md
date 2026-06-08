 # Abgabe 2 - Exoscale VM mit OpenTofu und CloudInit

 ### **Autor:** Blazovich Fabian; 2410640002 
<br>

 ## 1. Projektbeschreibung

 Diese Lösung erstellt automatisiert eine Ubuntu VM in Exoscale. Die VM stellt über HTTP eine Website bereit, auf der technische Informationen zur VM angezeigt werden. Zusätzlich gibt es einen JSON-Endpunkt unter `/api`.

 Die Bereitstellung und das Löschen der notwendigen Infrastruktur erfolgen automatisiert über GitHub Actions und OpenTofu.


**Die finalen Endpunkte lauten:**

```text
http://<ip-adresse>
http://<ip-adresse>/api
```

 Der erste Endpunkt liefert eine optisch aufbereitete HTML-Seite. Der zweite Endpunkt liefert dieselben technischen Informationen im JSON-Format.

 <br>

## 2. Herangehensweise

Zu Beginn wurde die Verbindung zwischen OpenTofu und Exoscale eingerichtet. Nachdem der Provider korrekt konfiguriert war, wurde eine erste virtuelle Maschine erstellt und getestet, um sicherzustellen, dass die Kommunikation mit der Exoscale API funktioniert.

Im nächsten Schritt wurde der Netzwerkzugriff konfiguriert. Dafür wurde eine eigene Security Group erstellt, welche ausschließlich die benötigten Ports für SSH, HTTP und HTTPS freigibt.

Anschließend wurde CloudInit integriert, um die VM direkt beim ersten Start automatisch zu konfigurieren. Dadurch konnten wichtige Schritte wie die Installation und Konfiguration von nginx vollständig automatisiert werden, ohne manuell auf die VM zugreifen zu müssen.

Danach wurde eine kleine Website erstellt, welche technische Informationen der VM anzeigt. Zusätzlich wurde ein JSON-Endpunkt implementiert, über welchen dieselben Informationen abgerufen werden können.

Zum Schluss wurde die gesamte Infrastruktur mit GitHub Actions automatisiert. Dafür wurden zwei getrennte Workflows erstellt:

- ein Workflow zur automatisierten Erstellung der Infrastruktur: `fblazovich-create-infra.yml`
- ein Workflow zur automatisierten Löschung der Infrastruktur: `fblazovich-delete-infra.yml`

Da GitHub Actions bei jedem Workflow neue Runner verwendet, musste zusätzlich eine Lösung für das Terraform State Management umgesetzt werden. Dafür wird der Terraform State nach dem Create Workflow gespeichert und im Delete Workflow wiederhergestellt.



<br>

## 3. Verwendete Technologien:

Für die Umsetzung wurden folgende Technologien verwendet:

- OpenTofu
- Exoscale
- GitHub Actions
- CloudInit
- nginx
- Ubuntu Linux

<br>

## 4. Repository-Struktur

Die Lösung ist im Repository in einem eigenen Abgabeordner abgelegt. Die Workflows befinden sich, wie von GitHub Actions gefordert, im Ordner `.github/workflows`.

```text
.github/
└── workflows/
    ├── fblazovich-create-infra.yml
    └── fblazovich-delete-infra.yml

Blazovich_Fabian/
└── Abgabe_2_260623/
    ├── cloud-init.yaml
    ├── doc.md
    ├── main.tf
    ├── outputs.tf
    ├── provider.tf
    ├── security-group.tf
    └── variables.tf
```

<br>

Die Dateien im Abgabeordner haben folgende Aufgaben:

| Datei | Zweck |
|---|---|
| `cloud-init.yaml` | Automatisiert die Betriebssystemkonfiguration beim ersten Start der VM. |
| `provider.tf` | Konfiguriert den Exoscale-Provider. Die Zugangsdaten werden über GitHub Secrets übergeben. |
| `variables.tf` | Enthält zentrale Variablen, zum Beispiel Zone, VM-Name, Instanztyp, Disk-Size |
| `main.tf` | Definiert die eigentliche virtuelle Maschine sowie deren grundlegende Konfiguration. |
| `security-group.tf` | Erstellt die Firewall-Regeln für SSH, HTTP und HTTPS. |
| `outputs.tf` | Gibt nach dem Deployment wichtige Informationen wie die öffentliche IP-Adresse oder URLs der Website aus. |

<br>

## 5. CloudInit und automatische VM Konfiguration 

Die virtuelle Maschine wird nach dem Erstellen automatisch über CloudInit konfiguriert. Dadurch musste keine manuelle Konfiguration direkt auf der VM durchgeführt werden.
Beim ersten Start der VM werden automatisch:
- nginx installiert 
- der Webserver konfiguriert 
- die HTML Website erstellt 
- die JSON API erstellt 
- nginx gestartet 

Zusätzlich werden technische Informationen der VM automatisch gesammelt und auf der Website dargestellt. Dadurch ist die VM direkt nach dem Deployment vollständig einsatzbereit. 

<br>

 ## 6. Website und JSON API 
 
 Die Website zeigt technische Informationen der virtuellen Maschine an. Dazu gehören unter anderem: 
 
 - Hostname 
 - IP-Adresse 
 - Betriebssystem
 - Kernel
 - RAM
 - CPU
 - Root-Disk
 - Hypervisor 
  
 Die Informationen werden dynamisch direkt auf der VM gesammelt.

<br>

## 7. GitHub Actions

Für die Automatisierung wurden zwei getrennte GitHub Actions Workflows erstellt.


### Create Workflow

```text
fblazovich-create-infra.yml
````

Der Create Workflow erstellt die komplette Infrastruktur automatisch.

Dabei werden folgende Schritte ausgeführt:

1. Repository auschecken
2. OpenTofu installieren
3. OpenTofu initialisieren
4. Konfiguration validieren
5. Infrastruktur erstellen
6. Terraform State speichern

---

### Delete Workflow

```text
fblazovich-delete-infra.yml
```

Der Delete Workflow löscht die Infrastruktur automatisch wieder.

Dabei werden folgende Schritte ausgeführt:

1. Repository auschecken
2. Terraform State herunterladen
3. OpenTofu initialisieren
4. Infrastruktur löschen

<br>

## 8. Verwendung der Lösung

Vor der Verwendung müssen im GitHub Repository die Exoscale-Zugangsdaten als Secrets hinterlegt sein:

```text
EXOSCALE_API_KEY
EXOSCALE_API_SECRET
```

### Infrastruktur erstellen:

- GitHub Repository öffnen
- Zum Tab `Actions` wechseln
- Workflow `Create Exoscale Infrastructure` auswählen
- Workflow starten: `Run workflow`

Nach erfolgreichem Abschluss wird die VM automatisch erstellt und konfiguriert.

---

### Website testen:

Die Website kann anschließend über die öffentliche IP-Adresse der VM geöffnet werden.

***Beispiel:***

```text
http://<vm-ip>
````
Die JSON API kann unter folgender URL getestet werden:

```text
http://<vm-ip>/api
```

---

### Infrastruktur löschen:

Zum Löschen der Infrastruktur:

- Tab `Actions` öffnen
- Workflow `Delete Exoscale Infrastructure` auswählen
- Workflow starten: `Run workflow`

Der Workflow lädt automatisch den Terraform State herunter und entfernt anschließend alle erstellten Ressourcen.

<br>

## 9. Erkenntnisse und Fazit

Durch die Aufgabe konnten praktische Erfahrungen in mehreren Bereichen gesammelt werden:

- Infrastructure as Code
- OpenTofu
- GitHub Actions
- CloudInit
- Automatisierung von Infrastruktur

```Die Lösung erfüllt damit die Anforderungen der Aufgabenstellung und ermöglicht eine vollständig automatisierte Bereitstellung und Verwaltung der Infrastruktur. ```
