 # Dokumentation zur Herangehensweise und Funktionsweise der Lösung

Diese Datei beschreibt die Herangehensweise, den Aufbau und die Verwendung der Lösung für die automatisierte Bereitstellung einer Exoscale-VM mit Web- und API-Endpunkt. Die eigentliche technische Umsetzung befindet sich in den Terraform/OpenTofu-, Cloud-Init-, Python-, nginx- und GitHub-Workflow-Dateien im Abgabeordner.

## 1. Ziel der Umsetzung

Ziel der Aufgabe war es, eine URL bereitzustellen, über die technische Informationen einer Exoscale-VM abgerufen werden können. Die URL soll auf eine automatisch erstellte VM in Exoscale zeigen. Die VM stellt einerseits eine HTML-Website für die Darstellung im Browser und andererseits einen JSON-Endpunkt für den Zugriff als API bereit.

Die Bereitstellung und das Löschen der notwendigen Infrastruktur erfolgen automatisiert über GitHub Actions und OpenTofu. Die Konfiguration des Betriebssystems wird beim ersten Start der VM automatisiert über Cloud-Init durchgeführt.

Die finalen Endpunkte lauten sinngemäß:

```text
https://<subdomain>.<domain>/
https://<subdomain>.<domain>/api
```

Der erste Endpunkt liefert eine optisch aufbereitete HTML-Seite. Der zweite Endpunkt liefert dieselben technischen Informationen im JSON-Format.

## 2. Grundlegende Herangehensweise

Zu Beginn wurde eine Basisstruktur für OpenTofu und GitHub Actions aufgebaut. OpenTofu wird verwendet, um die Exoscale-Infrastruktur zu erstellen und wieder zu löschen. GitHub Actions dient als Automatisierungsumgebung, damit die Infrastruktur nicht lokal, sondern direkt über Workflows im Repository verwaltet werden kann.

Im ersten Schritt wurde eine einfache VM-Konfiguration erstellt. Diese VM verwendete ein unterstütztes Ubuntu-Image und erhielt über eine Security Group die notwendigen Firewall-Regeln. Zunächst wurde nur HTTP auf Port 80 verwendet, um zu prüfen, ob die VM erreichbar ist und ob die technischen Informationen erfolgreich ausgegeben werden.

Anschließend wurde die Lösung schrittweise erweitert. Der Python-Webserver wurde aus der Cloud-Init-Datei ausgelagert, nginx wurde als öffentlicher Reverse Proxy ergänzt, DNS wurde über Exoscale konfiguriert und HTTPS wurde über Certbot und Let’s Encrypt eingerichtet.

## 3. Repository-Struktur

Die Lösung ist im Repository in einem eigenen Abgabeordner abgelegt. Die Workflows befinden sich, wie von GitHub Actions gefordert, im Ordner `.github/workflows`.

```text
.github/
└── workflows/
    ├── trinko-matteo_create-infra.yml
    └── trinko-matteo_destroy-infra.yml

Trinko_Matteo/
└── Abgabe_2_260526/
    ├── cloud-init.yaml
    ├── dns.tf
    ├── locals.tf
    ├── main.tf
    ├── outputs.tf
    ├── provider.tf
    ├── securitygroup.tf
    ├── variables.tf
    ├── version.tf
    ├── vm-info-server.py
    ├── vm-info-server.service
    └── vm-info-server-nginx.conf
```

Die Dateien im Abgabeordner haben folgende Aufgaben:

| Datei | Zweck |
|---|---|
| `version.tf` | Definiert die benötigten Provider und Versionen. |
| `provider.tf` | Konfiguriert den Exoscale-Provider. Die Zugangsdaten werden über GitHub Secrets übergeben. |
| `variables.tf` | Enthält zentrale Variablen, zum Beispiel Zone, VM-Name, Instanztyp, Domain und Certbot-E-Mail. |
| `locals.tf` | Erstellt abgeleitete lokale Werte, zum Beispiel den vollständigen FQDN aus Subdomain und Domain. |
| `main.tf` | Erstellt die eigentliche Exoscale-VM und übergibt Cloud-Init als `user_data`. |
| `securitygroup.tf` | Erstellt die Firewall-Regeln für SSH, HTTP und HTTPS. |
| `dns.tf` | Erstellt den DNS-A-Record in Exoscale DNS. |
| `outputs.tf` | Gibt nach dem Erstellen wichtige Informationen wie IP-Adresse, FQDN und URLs aus. |
| `cloud-init.yaml` | Automatisiert die Betriebssystemkonfiguration beim ersten Start der VM. |
| `vm-info-server.py` | Python-Anwendung zur Erfassung und Darstellung der VM-Informationen. |
| `vm-info-server.service` | systemd-Service für den automatischen Start der Python-Anwendung. |
| `vm-info-server-nginx.conf` | nginx-Konfiguration für den öffentlichen Zugriff und Reverse Proxy. |

## 4. GitHub Workflows

Für die Automatisierung wurden zwei GitHub Workflows erstellt. Beide Workflows werden manuell über `workflow_dispatch` gestartet, damit die Infrastruktur kontrolliert erstellt und gelöscht werden kann.

### 4.1 Create-Workflow

Der Workflow `trinko-matteo_create-infra.yml` erstellt die Infrastruktur in Exoscale. Dabei werden zuerst das Repository ausgecheckt und OpenTofu installiert. Danach werden die OpenTofu-Befehle im Abgabeordner ausgeführt.

Der Ablauf ist:

```text
Checkout Repository
Setup OpenTofu
tofu init
tofu validate
tofu plan
tofu apply -auto-approve
State im GitHub Cache speichern
```

Die Exoscale-Zugangsdaten werden nicht im Code gespeichert. Stattdessen werden sie über GitHub Secrets als Umgebungsvariablen bereitgestellt:

```text
EXOSCALE_API_KEY
EXOSCALE_API_SECRET
```

Nach erfolgreichem `tofu apply` wird die Datei `terraform.tfstate` im GitHub Cache unter dem Key `opentofu-state` gespeichert. Dieser State wird vom Destroy-Workflow benötigt, damit OpenTofu weiß, welche Ressourcen gelöscht werden müssen. Im Create-Workflow wird bewusst kein bestehender Cache wiederhergestellt, da der Ablauf auf eine initiale Erstellung und ein anschließendes Löschen ausgelegt ist.

### 4.2 Destroy-Workflow

Der Workflow `trinko-matteo_destroy-infra.yml` löscht die zuvor erstellte Infrastruktur wieder. Dafür wird zuerst der gespeicherte OpenTofu-State aus dem GitHub Cache geladen. Danach wird mit `tofu plan -destroy` geprüft, welche Ressourcen gelöscht werden, und anschließend mit `tofu destroy -auto-approve` gelöscht.

Der Ablauf ist:

```text
Checkout Repository
Setup OpenTofu
State aus GitHub Cache wiederherstellen
tofu init
tofu plan -destroy
tofu destroy -auto-approve
Cache anschließend manuell löschen
```

Nach erfolgreichem Destroy muss der GitHub Cache mit dem State manuell gelöscht werden. Die automatische Cache-Löschung im Workflow wurde nicht verwendet, da sie in dieser Umsetzung nicht zuverlässig funktioniert hat. Durch das manuelle Löschen des Caches kann ein späterer Create-Workflow wieder ohne alten State starten. Diese Lösung wurde gewählt, weil kein externer Remote-State-Speicher zur Verfügung stand.

Wichtig ist, dass diese Cache-Lösung für den Ablauf `Create → Destroy → neuer Create` vorgesehen ist. Ein mehrfaches Ausführen des Create-Workflows ohne vorherigen Destroy ist nicht zuverlässig vorgesehen, da GitHub Caches nicht sauber überschrieben werden können. In einer professionellen Umgebung wäre ein echter Remote State, zum Beispiel in einem S3-kompatiblen Object Storage, die bessere Lösung.

## 5. OpenTofu-Konfiguration

Die Infrastruktur wird über OpenTofu beschrieben. Die VM wird mit einem unterstützten Ubuntu-Image in Exoscale erstellt. Die wichtigsten Parameter wie Zone, Instanztyp, Disk-Größe und Name der VM werden über Variablen zentral verwaltet.

Die Security Group öffnet die notwendigen Ports:

| Port | Zweck |
|---|---|
| 22 | SSH-Zugriff zur Administration und Fehlersuche. |
| 80 | HTTP-Zugriff, Let’s-Encrypt-Validierung und Weiterleitung auf HTTPS. |
| 443 | HTTPS-Zugriff auf die Website und API. |

Die Cloud-Init-Konfiguration wird in `main.tf` über `templatefile()` an die VM übergeben. Dadurch können ausgelagerte Dateien wie der Python-Code, die systemd-Service-Datei und die nginx-Konfiguration sauber in die Cloud-Init-Datei eingefügt werden.

## 6. Cloud-Init und Betriebssystemkonfiguration

Cloud-Init übernimmt die automatische Konfiguration der VM beim ersten Start. Dabei werden Paketquellen aktualisiert, Updates installiert und die benötigten Pakete eingerichtet.

Installiert werden unter anderem:

```text
python3
nginx
snapd
util-linux
iproute2
coreutils
```

Zusätzlich schreibt Cloud-Init die benötigten Konfigurationsdateien auf die VM:

```text
/opt/vm-info-server.py
/etc/systemd/system/vm-info-server.service
/etc/nginx/sites-available/vm-info
```

Danach werden der Python-Service und nginx aktiviert und gestartet. Außerdem wird Certbot verwendet, um ein Let’s-Encrypt-Zertifikat zu erstellen und nginx automatisch auf HTTPS umzustellen.

## 7. Python-Anwendung

Die Datei `vm-info-server.py` enthält die lokale Anwendung, welche die technischen Informationen der VM sammelt und bereitstellt. Die Anwendung läuft nicht direkt öffentlich auf Port 80, sondern nur lokal auf:

```text
127.0.0.1:8080
```

Die Python-Anwendung stellt zwei Endpunkte bereit:

| Endpunkt | Funktion |
|---|---|
| `/` | HTML-Seite mit optisch aufbereiteter Darstellung der VM-Informationen. |
| `/api` | JSON-Ausgabe derselben Informationen für automatisierte Abfragen. |

Die Informationen werden dynamisch beim Aufruf gesammelt. Dazu verwendet das Programm unter anderem Linux-Befehle wie `hostname -I`, `free -h`, `lscpu`, `lsblk`, `df -hT` und `ip addr show`.

Angezeigt werden unter anderem:

```text
Hostname
IP-Adressen
Kernel-Informationen
Betriebssysteminformationen
Hypervisor beziehungsweise Virtualisierungstyp
Arbeitsspeicher
CPU-Informationen
Storage und Blockgeräte
Dateisysteme
Netzwerkinterfaces
```

Die HTML-Seite stellt die Informationen in einzelnen Blöcken dar. Die API unter `/api` bleibt maschinenlesbar und liefert JSON.

## 8. nginx als öffentlicher Webserver

Für eine saubere Architektur wird nginx als öffentlicher Webserver und Reverse Proxy verwendet. Der Python-Webserver ist nur lokal erreichbar. Externe Anfragen gelangen zuerst zu nginx und werden dann intern an den Python-Webserver weitergeleitet.

Die Architektur sieht so aus:

```text
Browser oder API-Client
        ↓
nginx auf Port 80/443
        ↓
Reverse Proxy zu 127.0.0.1:8080
        ↓
Python-Anwendung liefert HTML oder JSON
```

Durch diese Trennung ist nginx für öffentliche HTTP-/HTTPS-Verbindungen zuständig, während Python nur die Datensammlung und Ausgabe übernimmt. Das ist sauberer als ein direkt öffentlich erreichbarer Python-Webserver.

## 9. DNS über Exoscale

Für DNS wird die in Exoscale verfügbare Domain `biti-fhb.org` verwendet. Über die Datei `dns.tf` wird ein A-Record für die Subdomain erstellt. Dieser Record zeigt auf die öffentliche IP-Adresse der Exoscale-VM.

Beispiel:

```text
vm-info.biti-fhb.org → öffentliche IP-Adresse der VM
```

Der vollständige Domainname wird über Variablen und lokale Werte in OpenTofu aufgebaut. Dieser FQDN wird sowohl für den DNS-Record als auch für die nginx- und Certbot-Konfiguration verwendet.

## 10. HTTPS mit Certbot und Let’s Encrypt

Nachdem DNS auf die VM zeigt, wird HTTPS über Certbot und Let’s Encrypt eingerichtet. Certbot wird über Cloud-Init installiert und mit dem nginx-Plugin ausgeführt.

Certbot übernimmt dabei:

```text
Anforderung des Let’s-Encrypt-Zertifikats
Anpassung der nginx-Konfiguration für HTTPS
Konfiguration des HTTPS-Listeners in nginx
Weiterleitung von HTTP auf HTTPS
Neuladen von nginx
```

Die Freigabe von Port 443 erfolgt nicht durch Certbot, sondern bereits über die OpenTofu-Security-Group-Konfiguration.

Dadurch sind die Website und die API über HTTPS erreichbar:

```text
https://vm-info.biti-fhb.org/
https://vm-info.biti-fhb.org/api
```

Port 80 bleibt weiterhin notwendig, da Let’s Encrypt diesen Port für die HTTP-Validierung und die Weiterleitung auf HTTPS benötigt.

## 11. Verwendung der Lösung

Vor der Verwendung müssen im GitHub Repository die Exoscale-Zugangsdaten als Secrets hinterlegt sein:

```text
EXOSCALE_API_KEY
EXOSCALE_API_SECRET
```

Danach kann die Infrastruktur erstellt werden:

1. In GitHub den Reiter `Actions` öffnen.
2. Den Workflow `Create Exoscale Infrastructure` auswählen.
3. `Run workflow` ausführen.
4. Warten, bis der Workflow erfolgreich abgeschlossen ist. Bis die Website über HTTPS verfügbar ist, kann es ein paar Minuten in Anspruch nehmen.
5. Die ausgegebenen URLs oder den konfigurierten FQDN im Browser öffnen.

Die Website ist anschließend erreichbar unter:

```text
https://vm-info.biti-fhb.org/
```

Die API ist erreichbar unter:

```text
https://vm-info.biti-fhb.org/api
```

Ein API-Test kann zum Beispiel mit `curl` durchgeführt werden:

```bash
curl https://vm-info.biti-fhb.org/api
```

Zum Löschen der Infrastruktur:

1. In GitHub den Reiter `Actions` öffnen.
2. Den Workflow `Destroy Exoscale Infrastructure` auswählen.
3. `Run workflow` ausführen.
4. Warten, bis der Workflow erfolgreich abgeschlossen ist.
5. Danach im GitHub-Bereich `Actions` beziehungsweise in der Cache-Übersicht den Cache mit dem Key `opentofu-state` manuell löschen.

Nach erfolgreichem Destroy werden die Exoscale-Ressourcen gelöscht. Das anschließende manuelle Löschen des Caches ist notwendig, damit ein späterer Create-Lauf wieder mit einem sauberen Zustand starten kann.

## 12. Hinweise und Einschränkungen

Die verwendete Cache-Lösung für den OpenTofu-State ist eine pragmatische Lösung für diese Abgabe. Sie ersetzt keinen professionellen Remote State. Der Workflow ist so ausgelegt, dass Create initial ausgeführt wird und danach Destroy den gespeicherten State verwendet.

Wird der Create-Workflow mehrfach ohne vorherigen Destroy ausgeführt, kann es zu Problemen kommen, weil GitHub Caches nicht zuverlässig überschrieben werden können. Deshalb wird der Cache nicht automatisch im Create-Workflow wiederhergestellt. Nach einem erfolgreichen Destroy muss der Cache manuell gelöscht werden, damit ein neuer Durchlauf wieder mit einem sauberen Zustand starten kann.

Für produktive Umgebungen wäre ein echter Remote State in einem externen Storage sowie eine restriktivere SSH-Firewall-Regel empfehlenswert. Außerdem sollte Certbot bei häufigen Testläufen mit dem Let’s-Encrypt-Staging-Modus verwendet werden, um Rate Limits zu vermeiden.

## 13. Zusammenfassung

Die Lösung erstellt automatisiert eine Exoscale-VM mit Ubuntu, richtet über Cloud-Init einen lokalen Python-Webserver, einen systemd-Service, nginx als Reverse Proxy, DNS über Exoscale und HTTPS über Let’s Encrypt ein. Die technischen Informationen der VM werden sowohl als HTML-Website als auch als JSON-API bereitgestellt. Die Erstellung und Löschung der Infrastruktur erfolgt über getrennte GitHub Workflows mit OpenTofu.