# Abgabe 2: Exoscale VM Details Website/API

Diese Abgabe erstellt automatisiert eine Ubuntu VM in Exoscale. Die VM stellt über HTTP eine Website und eine JSON API bereit, die technische Details der VM anzeigen. Optional wird zusätzlich ein DNS A-Record in Exoscale DNS erstellt und HTTPS per Let's Encrypt eingerichtet.

## Architektur

- **OpenTofu/Terraform** erstellt die Exoscale Infrastruktur.
- **GitHub Actions** führt `tofu apply` und `tofu destroy` aus.
- **Cloud-Init** übernimmt die komplette Betriebssystemkonfiguration.
- **Nginx** liefert die Website und den API Endpoint aus.
- **Certbot** richtet optional HTTPS ein, wenn ein FQDN verwendet wird.

## Endpunkte

Nach erfolgreichem Workflow werden folgende Outputs angezeigt:

- `http_url`: Website über HTTP
- `https_url`: Website über HTTPS, wenn DNS/FQDN gesetzt wurde
- `json_api_url`: JSON API mit VM Details

Die JSON API liegt unter:

```text
/api/v1/vm-details.json
```

## Angezeigte Informationen

Die Website und API zeigen unter anderem:

- öffentliche und lokale IP-Adresse
- Hostname und Instance ID
- Betriebssystem
- Kernel und Architektur
- Hypervisor/Virtualisierungstyp
- CPU Modell und Anzahl vCPUs
- RAM gesamt und verfügbar
- Storage Devices
- Filesysteme inklusive Größe, Nutzung und Mountpoint
- Zeitstempel der letzten Aktualisierung

Die Daten werden auf der VM minütlich über einen systemd Timer neu erzeugt.

## Voraussetzungen

1. Fork oder Branch des Repositories `https://github.com/DrackThor/fhb-biti-vica-ss26`.
2. Unterordner `Abgabe_2_eda_konakci` im Repository.
3. Exoscale API Key und Secret mit Rechten für Compute, Security Groups und optional DNS.
4. GitHub Repository Secrets:

```text
EXOSCALE_API_KEY
EXOSCALE_API_SECRET
```

Optional für DNS/HTTPS:

- Eine Domain muss in Exoscale DNS existieren.
- Der Domain-Name wird beim Workflow als `dns_domain` angegeben.
- Der gewünschte Hostname wird als `dns_record_name` angegeben.

Beispiel:

```text
dns_domain      = example.com
dns_record_name = vm-details
```

Ergebnis:

```text
https://vm-details.example.com
```

## Infrastruktur erstellen

1. In GitHub auf **Actions** gehen.
2. Workflow **Create Exoscale Infrastructure** auswählen.
3. **Run workflow** klicken.
4. Werte setzen:
   - `zone`: z.B. `at-vie-1`
   - `dns_domain`: leer lassen für IP-only oder Domain eintragen
   - `dns_record_name`: z.B. `vm-details`
   - `letsencrypt_email`: gültige E-Mail für Let's Encrypt
5. Workflow starten.
6. Nach Abschluss die Outputs im Schritt **Show outputs** prüfen.

Ohne DNS ist die Seite über die öffentliche IP erreichbar:

```text
http://<public-ip>
```

Mit DNS ist sie zusätzlich über HTTPS erreichbar:

```text
https://<dns_record_name>.<dns_domain>
```

## Infrastruktur löschen

1. In GitHub auf **Actions** gehen.
2. Workflow **Delete Exoscale Infrastructure** auswählen.
3. **Run workflow** klicken.
4. Dieselben DNS-Werte wie beim Create Workflow verwenden.
5. Workflow starten.

Der Destroy Workflow entfernt alle von OpenTofu verwalteten Ressourcen.

## Lokaler Test optional

Für lokale Tests kann eine eigene `terraform.tfvars` Datei erstellt werden. Die Datei darf nicht committed werden.

```bash
cd Abgabe_2_eda_konakci/terraform
cp terraform.tfvars.example terraform.tfvars
# terraform.tfvars mit echten Werten befüllen
tofu init
tofu plan
tofu apply
```

Löschen lokal:

```bash
tofu destroy
```

## Hinweise zur HTTPS Einrichtung

Let's Encrypt stellt keine Zertifikate für reine IP-Adressen aus. Deshalb wird HTTPS nur automatisch eingerichtet, wenn ein FQDN gesetzt wurde. Cloud-Init startet Certbot im Hintergrund und versucht bis zu 15 Minuten lang, das Zertifikat auszustellen. Während DNS noch propagiert, bleibt HTTP bereits verfügbar.

## Sicherheit

- HTTP und HTTPS sind öffentlich erreichbar, weil das für die Abgabe gefordert ist.
- SSH ist standardmäßig deaktiviert.
- SSH kann optional über `ssh_public_key` und `ssh_allowed_cidr` aktiviert werden.
- Secrets werden nicht im Code gespeichert, sondern über GitHub Repository Secrets übergeben.
