# Dokumentation: Infrastruktur-Automatisierung mit Terraform & Cloud-Init

## Herangehensweise
Die Zielsetzung war die automatisierte Bereitstellung einer Web-Infrastruktur auf Exoscale. 

### Infrastruktur-Provisionierung (Terraform)
* **Dynamische Template-Suche:** Um die Fehleranfälligkeit durch veraltete Template-IDs zu minimieren, wird ein `data "exoscale_template"` Block genutzt. Dieser ermittelt zur Laufzeit die ID des aktuellsten **Ubuntu 24.04 LTS** Images in der Zone `at-vie-1`.
* **Sicherheit:** Es wird eine dedizierte Security Group erstellt, die Ingress-Traffic ausschließlich auf **Port 80 (TCP/HTTP)** erlaubt.
* **Automatisierung:** Die gesamte Ausführung ist in GitHub Actions integriert, wobei sensible Daten über GitHub Secrets verwaltet werden.

### Betriebssystem-Konfiguration (Cloud-Init)
Die Konfiguration erfolgt vollständig automatisiert beim ersten Bootvorgang ("First Boot"):
* Installation notwendiger Pakete (`python3-flask`, `python3-psutil`).
* Deployment eines Python-Webservers, der Systemmetriken ausliest.

---

## Funktionsweise der Lösung
Die Anwendung stellt Systeminformationen auf zwei unterschiedlichen Endpunkten bereit:

1. **Website (HTML):** Unter der Root-URL `/` wird eine optisch aufbereitete Tabelle mit Details wie Kernel-Typ, CPU-Anzahl, Memory und Storage-Informationen ausgegeben.
2. **API (JSON):** Unter dem Pfad `/json` liefert die Anwendung die identischen technischen Daten in einem strukturierten JSON-Format für die automatisierte Weiterverarbeitung.

---

## Verwendung der Lösung

### Infrastruktur erstellen (Deploy)
1. Navigieren Sie im GitHub-Repository zum Tab **Actions**.
2. Wählen Sie den Workflow **Exoscale Deploy**.
3. Starten Sie den Workflow via **Run workflow**.
4. Nach Abschluss wird die öffentliche IP-Adresse im Log des Schritts `Terraform Apply` unter "Outputs" angezeigt.

### Infrastruktur löschen (Destroy)
1. Wählen Sie den Workflow **Exoscale Destroy**.
2. Starten Sie den Workflow via **Run workflow**.
*Hinweis: Da in diesem Setup kein persistenter Remote-State konfiguriert wurde, dient der Workflow der prozessualen Demonstration. Die finale Bereinigung wurde manuell im Exoscale-Portal durchgeführt.*

---

## Anhänge
<img width="411" height="213" alt="image" src="https://github.com/user-attachments/assets/28a84535-02ff-44df-8fbd-d738b410088b" />
