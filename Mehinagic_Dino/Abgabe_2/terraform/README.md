# Dokumentation: Automatisierte System-Info VM auf Exoscale

## Herangehensweise & Konzept
- **Infrastruktur:** Beschreibung, warum Terraform/OpenTofu gewählt wurde (Deklarativ, State-Management).
- **Betriebssystem & Provisionierung:** Erklärung von Cloud-Init. Warum Nginx kombiniert mit einem leichtgewichtigen Bash-Dämon verwendet wurde (Ressourcenschonend, native Linux-Bordmittel wie `df`, `free`, `uname`).
- **Architektur:** Kurze Skizzierung des Datenflusses (GitHub -> Exoscale API -> VM Creation -> Cloud-Init initiiert Nginx & Skript -> Endnutzer greift auf Port 80/443 zu).

## Funktionsweise der Lösung
- **Terraform:** Erkläre die Ressourcen (`exoscale_compute_instance`, `exoscale_security_group`).
- **Daten-Generierung:** Beschreibe, wie das Skript `/usr/local/bin/generate_sysinfo.sh` die Daten extrahiert (z.B. `systemd-detect-virt` für den Hypervisor) und warum es als `systemd`-Service läuft (Ausfallsicherheit, automatischer Neustart).
- **Endpunkte:** - `http://<IP>/` -> Visualisierung via HTML (Tailwind CSS).
  - `http://<IP>/api.json` -> Maschinell lesbare API-Schnittstelle.

## Bedienungsanleitung (How to use)
1. **GitHub Secrets hinterlegen:** `EXOSCALE_KEY` und `EXOSCALE_SECRET` im Repo eintragen.
2. **Infrastruktur starten:** In GitHub Actions den Workflow `Terraform Deploy` manuell triggern.
3. **Ergebnis prüfen:** Nach ca. 2-3 Minuten (Bootzeit + Paketinstallation) die im Workflow-Output oder Exoscale-Dashboard angezeigte IP im Browser aufrufen.
4. **Infrastruktur löschen:** Den Workflow `Terraform Destroy` ausführen, um Kosten zu vermeiden.
