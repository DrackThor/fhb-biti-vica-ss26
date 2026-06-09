# Herangehensweise und Funktionsweise

## Ziel

Die Aufgabe verlangt eine URL, die auf eine VM in Exoscale zeigt und technische
Details dieser VM liefert. Die Erstellung und das Loeschen der Infrastruktur
sollen automatisiert ueber GitHub Actions mit Terraform/OpenTofu erfolgen. Die
Konfiguration des Betriebssystems muss ueber CloudInit passieren.

## Umsetzung

Ich habe die Loesung in drei Teile aufgeteilt:

1. **OpenTofu fuer Infrastruktur**
   OpenTofu erstellt eine Ubuntu-VM, eine Security Group, optional einen SSH-Key
   und optional einen DNS-A-Record in Exoscale.

2. **CloudInit fuer Betriebssystem-Konfiguration**
   CloudInit installiert Python und Caddy, schreibt die App-Datei nach
   `/opt/vminfo/app.py`, legt eine systemd-Unit an und startet App und Webserver.
   Es gibt keine manuellen SSH-Schritte.

3. **Python-App fuer VM-Daten**
   Die App sammelt die Daten live auf der VM. Sie nutzt Linux-Kommandos wie
   `lscpu`, `free`, `lsblk`, `df`, `ip`, `uname` und `systemd-detect-virt`.
   Exoscale-spezifische Daten kommen aus dem Metadata-Service.

## Warum Caddy?

Caddy ist als Reverse Proxy vor der Python-App eingesetzt. Die Python-App hoert
nur lokal auf `127.0.0.1:8080`. Oeffentlich erreichbar ist nur Caddy auf Port 80
und 443.

Wenn ein DNS-Name verwendet wird, kann Caddy automatisch ein Let's-Encrypt-
Zertifikat holen. Damit ist echtes HTTPS moeglich. Ohne DNS bleibt die Loesung
trotzdem per HTTP ueber die Public IP nutzbar.

## OpenTofu-State

GitHub Actions Runner sind kurzlebig. Ein Create-Workflow und ein Destroy-
Workflow teilen sich keinen lokalen State. Deshalb wird der OpenTofu-State in
einem Exoscale-SOS-Bucket gespeichert. Der Create-Workflow legt den Bucket
idempotent an, falls er noch nicht existiert.

Der State-Key ist eindeutig fuer diese Abgabe:

```text
wagner-raphael/abgabe-2/terraform.tfstate
```

Dadurch kollidiert diese Abgabe nicht mit anderen Abgaben im selben Repository.

## Bedienung fuer die Bewertung

1. Im eigenen Fork des Kursrepositories die Secrets `EXOSCALE_API_KEY` und
   `EXOSCALE_API_SECRET` fuer GitHub Actions setzen. Im fremden Kursrepository
   selbst sind diese Secrets fuer Studierende nicht konfigurierbar.
2. Den Workflow **Infrastruktur erstellen** starten.
3. Optional eine Exoscale-DNS-Zone angeben:
   - `dns_zone`, zum Beispiel `example.at`
   - `dns_record_name`, zum Beispiel `vica-rwagner`
4. Die URL aus der Job-Zusammenfassung oeffnen.
5. Die HTML-Ansicht unter `/` pruefen.
6. Die JSON-API unter `/api/v1/system` pruefen.
7. Nach der Bewertung den Destroy-Workflow starten.

Der Pull Request in das Kursrepository enthaelt den gesamten Code und die
Workflow-Dateien. Ausgefuehrt werden die Workflows mit den eigenen Secrets im
Fork oder nach dem Merge durch eine Person mit Zugriff auf das Zielrepository.

## Wichtige Terraform-Variablen

| Variable | Default | Bedeutung |
| --- | --- | --- |
| `zone` | `at-vie-1` | Exoscale-Zone |
| `instance_name` | `rwagner-abgabe2-vminfo` | Name der VM |
| `instance_type` | `standard.micro` | Kleine, guenstige VM-Groesse |
| `disk_size` | `10` | Boot-Disk in GB |
| `template_name` | `Linux Ubuntu 24.04 LTS 64-bit` | Ubuntu-LTS-Image |
| `dns_zone` | leer | Aktiviert optional DNS und HTTPS |
| `dns_record_name` | `vica-rwagner` | Hostname innerhalb der DNS-Zone |

## Ergebnis

Die Loesung erfuellt den Grundzustand per HTTP-IP-Adresse und kann fuer
Zusatzpunkte mit DNS und HTTPS betrieben werden. HTML und JSON werden ueber zwei
unterschiedliche Endpunkte ausgeliefert.
