# Dokumentation: Infrastruktur-Automatisierung mit Exoscale (Abgabe 2)
**Erstellt von: Albert Reinberg-Leibel**

Ziel war es, automatisiert eine Ubuntu-VM auf Exoscale bereitzustellen, die über eine öffentliche IP-Adresse erreichbar ist und auf einer Webseite ihre eigenen technischen Systemdetails (wie IP, Storage, RAM, etc.) anzeigt. 

## 1. Herangehensweise & Architektur

Um das Projekt nach dem "Infrastructure as Code" (IaC) Prinzip umzusetzen und möglichst leicht ausführbar zu machen, habe ich die Aufgabe in drei logische Ebenen unterteilt:

1. **Infrastruktur (Terraform):** Meine `main.tf` kümmert sich um die Erstellung der Infrastruktur auf Exoscale. Sie sucht sich automatisch das aktuellste Ubuntu 26.04 LTS Image, erstellt eine kleine `standard.micro` Instanz und konfiguriert eine Security Group. Da der Webserver komplett per Code auf- und abgebaut wird, habe ich den SSH Zugang komplett weggelassen. Der Server kommuniziert nur über Web-Traffic (Port 80/443).
   
2. **Server-Konfiguration (Cloud-Init):** Sobald die VM bootet, übernimmt die `cloud-init.yml`. Sie updatet das System, installiert den Nginx-Webserver und richtet mein Bash-Skript (`init-dashboard.sh`) ein. Dieses Skript liest die Livedaten des Servers aus und baut daraus das HTML-Dashboard.

3. **Automatisierung (GitHub Actions):** Sämtliche Schritte zum Aufbauen und Abreißen der Umgebung laufen über zwei separate GitHub Actions Workflows (`Reinberg Deploy Infrastructure` und `Reinberg Destroy Infrastructure`), die gezielt manuell gestartet werden können.

---

## 2. Besonderheiten & "Lessons Learned"

Bei der Umsetzung bin ich auf ein paar Herausforderungen gestoßen, die ich wie folgt gelöst habe:

### Das Terraform-State Problem (und mein Git-Workaround)
Damit der Workflow zum Löschen (`destroy`) funktioniert, muss Terraform wissen, wie die Infrastruktur aktuell aussieht (der sogenannte State). Da bei GitHub Actions jeder Runner nach der Ausführung gelöscht wird, geht auch die lokale `.tfstate` Datei verloren. 

*Ehrlicherweise wusste ich während der Entwicklung nicht, dass man diesen State laut Best-Practice am besten in einem externen Object Storage Bucket (z. B. bei Exoscale) ablegt. Das ist mir erst ganz am Schluss aufgefallen, als in der Exoscale Umgebung einige Buckets von Kollegen gesehen habe.* **Meine Lösung:** Am Ende meiner GitHub Action pusht ein Bot die aktualisierte `terraform.tfstate` Datei einfach per Git-Commit zurück in das Unterverzeichnis dieses Repositories. So ist der State sicher gespeichert und der Destroy-Befehl funktioniert später einwandfrei.

### Ein dynamisches Dashboard statt statischem Text
Die Angabe verlangte die Darstellung technischer Details. Anstatt die Daten nur einmalig beim Serverstart auf eine statische Seite zu schreiben, wollte ich, dass die Seite aktuell bleibt:
* Ich habe in der Cloud-Init Konfiguration einen **Cronjob** eingerichtet, der das Bash-Skript jede Minute neu ausführt und die Systemdaten (inklusive Auslastung in Prozent) aktualisiert.
* Zusätzlich hat die HTML-Seite einen Meta-Refresh-Tag. Das bedeutet, wenn man die Webseite offen lässt, lädt der Browser die Seite automatisch neu und man sieht die Echtzeit-Auslastung des Systems. Optisch wurde das Ganze mit CSS so aufbereitet, dass die Auslastung von RAM und Storage in Dials angezeigt wird.

### Fokus auf die Basislösung
Da Terraform und YAML für mich komplettes Neuland sind habe ich beschlossen mich auf die  **Basislösung** zu beschränken. Bei der Erstellung der Scripts habe ich **Google Gemini** als Lern- und Programmierassistenten zu Hilfe genommen. Auf die optionalen Zusatzpunkte (DNS-Setup, Let's Encrypt Zertifikate für HTTPS sowie ein separater JSON/API-Endpunkt) habe ich hier bewusst verzichtet.

---

## 3. Step by Step Anleitung zur Nutzung

*Vielleicht zu detailliert, aber so sollte es im Zweifelsfall auch ein Neuanfänger, der sich den Code ansehen will starten können:*

### Schritt 1: Zugangsdaten hinterlegen
Da die Exoscale API-Keys aus Sicherheitsgründen nicht im Code stehen, müssen diese im Repository hinterlegt sein. 
Unter *Settings -> Secrets and variables -> Actions* ist sicherzustellen, dass die Repository Secrets `EXOSCALE_API_KEY` und `EXOSCALE_API_SECRET` vorhanden sind.

### Schritt 2: Infrastruktur erstellen (Deploy)
1. In den Tab **Actions** des GitHub Repositories wechseln.
2. Links den Workflow **Reinberg Deploy Infrastructure** auswählen.
3. Rechts auf den blauen Button **Run workflow** klicken.
4. Ca. 1 Minuten warten, bis der Job durchgelaufen ist (am Ende wird der State committet).
5. Den erfolgreichen Lauf anklicken, den Schritt **Terraform Apply** aufklappen und ganz nach unten scrollen. Dort ist die Ausgabe `server_ip` zu finden.

### Schritt 3: Dashboard ansehen
1. Die kopierte `server_ip` in die Adresszeile eines Browsers einfügen.

    *(Hinweis: Es kann nach Fertigstellung der Pipeline noch etwa eine Minute dauern, bis Cloud-Init alle Pakete installiert und Nginx gestartet hat. Bei einem Fehler ist die Seite nach kurzer Zeit neu zu laden.)*

    Das fertige Dashboard wird nun angezeigt. Lässt man die Seite offen, kann man beobachten, wie sie sich jede Minute selbst aktualisiert. Der Zeitpunnkt der letzten Aktualisierung steht unter der Hauptüberschrift.

### Schritt 4: Infrastruktur löschen (Destroy)

1. In den Tab **Actions** wechseln.
2. Links den Workflow **Reinberg Destroy Infrastructure** auswählen.
3. Auf **Run workflow** klicken. 
4. Terraform liest nun den State aus dem Repo, entfernt die VM und die Security Group sauber und committet den leeren State zurück ins Repository.