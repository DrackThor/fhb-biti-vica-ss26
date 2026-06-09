# Bedienungshinweise für "VM Info auf WebSite". AR-2026-06-02
Ziel ist es auf einer Web-Site technische Informationen der automatisiert erstellten VM anzuzeigen. 
## Erstellen mit terraform apply ausführen.
Im Terminal Fenster in den Ordner C:\BITI_Lokal\repos\fhb-biti-vica-ss26\Riegler_Alexandra\Abgabe_2_260603\terraform 
wechseln.

__terraform apply__ starten
## Die "VM Info" anzeigen. 
Auruf des öffentlichem Link: http://vm-ar-ubuntu

Bei mehrfacher Durchführung (deploy und destroy) muss auf die aktuell vergebene IP adresse gewechselt werden, da der DNS Namen noch auf die ursprüngliche IP-Adresse der VM aufgelöst wird, welche gelöscht ist. 
(Anm.: Externe IP wird vom Provider random vergeben.) 
mit der IP funktioniert es immer, diese ist in excoscale ersichtlich. https://portal.exoscale.com/u/fhb-biti-26/compute/instances
Aufruf mit IP des öffentlcihem Link: http://185.150.9.129/
## Zerstörung: Destroy auf der Exoscale Umgebung
Um Resourcen zu schonen soll die Umgebung bei Nichtverwendung wieder abgebaut "Zerstört" werden. 
Im Terminal Fenster in den Ordner C:\BITI_Lokal\repos\fhb-biti-vica-ss26\Riegler_Alexandra\Abgabe_2_260603\terraform 
wechseln.

__terraform destroy__ starten

## Herangehensweise
Um die VM wiederholbar, automatisiert und nachvollziehbar zu erstellen wird Terraform als Infrastructure as Code verwendet. 
VM wird am Provider Exoscale angelegt, und mit Cloud-Init konfiguriert.

## Funktionsweise
Die Terraform-Konfiguration erstellt eine Ubuntu-VM in der Exoscale-Zone `at-vie-1`. Die VM wird mit einer Cloud-Init-Datei initialisiert, in die eine Flask-Anwendung aus `app.py` eingebunden wird.

Zusätzlich wird ein DNS-A-Record für die Domain `biti-fhb.org` erstellt. Der Hostname entspricht dem Namen der VM und zeigt auf deren öffentliche IP-Adresse.

Über eine Security Group wird Port `80` für HTTP-Zugriffe aus dem Internet geöffnet. 
Dadurch kann die bereitgestellte Webanwendung öffentlich über HTTP erreicht werden. Auf der Startseite werden die technischen Informationen der erstellen VM angezeigt. 
Gunicorn bindet flaks-app auf port 80. Für Produktiv stage ist es nicht sauber. 

# Aufgabenstellung - Abgabe 2 
### Folgender Zielzustand soll erreicht werden:

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

### Abgabe/Format

- geben Sie sämtlichen Code inkl. Dokumentation via PR in folgendem Repo ab https://github.com/DrackThor/fhb-biti-vica-ss26
  - verwenden Sie hierfür den beschriebenen Unterordner `Abgabe_2_xxx`
- kommentieren Sie sämtlichen Code inline
- Beschreiben Sie in einer zusätzlichen Markdown Datei Ihre Herangehensweise und die Funktionsweise Ihrer Lösung.
  - Erklären Sie, wie die Lösung verwendet wird - dies wird bei der Beurteilung angewendet!
- als Abgabe, geben Sie _in diesem Kurs den Link zu ihrem Pull Request ab_

## Bewertung

Bewertet wird anhand folgender Kriterien:

- Vollständigkeit, Korrektheit und Funktionsweise
- Qualität der Dokumentation und Kommentare
- Richtige Verwendung der Tools / Professionalität der Umsetzung
- Inhalt und Qualität der unter der URL dargestellten Informationen
  - Sinnhaftigkeit, optische Darstellung, Aktualität,..

Zusatzpunkte erhalten Sie für..
- die korrekte Verwendung von DNS und Zertifikaten (HTTPS!).
- die Darstellung der Information mittels HTML (als `Website`) und JSON (als `API`)
  - verwenden Sie hierfür zwei unterschiedliche Endpunkte
