# Abgabe 2 - Exoscale VM Info

Diese Abgabe erstellt automatisiert eine Ubuntu-VM in Exoscale. Auf der VM laeuft
eine kleine Webseite, die technische Details der angesprochenen VM anzeigt.
Dieselben Daten gibt es zusaetzlich als JSON API.

## Endpunkte

Nach dem erfolgreichen Create-Workflow stehen in der GitHub-Job-Zusammenfassung
die fertigen URLs:

- Website: `/`
- JSON API: `/api/v1/system`
- Healthcheck: `/healthz`

Ohne DNS-Zone ist die Website per HTTP ueber die Public IP erreichbar. Wenn beim
Workflow eine Exoscale-DNS-Zone angegeben wird, erstellt OpenTofu einen A-Record
und Caddy stellt automatisch HTTPS mit Let's Encrypt bereit.

## Voraussetzungen

Die Secrets werden nicht im fremden Kursrepository gesetzt, sondern in dem
Repository, in dem der Workflow ausgefuehrt wird. Praktisch ist das der eigene
Fork des Kursrepos. Der Pull Request liefert nur den Code zur Abgabe.

In GitHub Actions muessen dort folgende Secrets gesetzt sein:

| Secret | Zweck |
| --- | --- |
| `EXOSCALE_API_KEY` | API-Key fuer Exoscale |
| `EXOSCALE_API_SECRET` | API-Secret fuer Exoscale |
| `SSH_PUBLIC_KEY` | Optionaler SSH-Key fuer Debugging |

Optional kann folgende Repository-Variable gesetzt werden:

| Variable | Zweck |
| --- | --- |
| `RWAGNER_TF_STATE_BUCKET` | Eigener Exoscale-SOS-Bucket fuer den OpenTofu-State |

Wenn die Variable nicht gesetzt ist, verwendet der Workflow den Bucket
`rwagner-abgabe2-tfstate`.

## Infrastruktur erstellen

1. Im eigenen Fork den Reiter **Actions** oeffnen.
2. Workflow **Infrastruktur erstellen** auswaehlen.
3. Optional `dns_zone` und `dns_record_name` ausfuellen.
4. **Run workflow** starten.
5. Nach dem Lauf die URL aus der Job-Zusammenfassung oeffnen.

CloudInit braucht nach dem OpenTofu-Apply meistens noch ein bis zwei Minuten, bis
Caddy und die App antworten.

## Infrastruktur loeschen

1. Im eigenen Fork im Reiter **Actions** den Workflow
   **Infrastruktur loeschen** auswaehlen.
2. **Run workflow** starten.
3. Der Workflow verwendet denselben Remote-State und entfernt die Ressourcen.

## Dateien

```text
.github/workflows/
  wagner-raphael-abgabe2-create.yml
  wagner-raphael-abgabe2-destroy.yml

Wagner_Raphael/Abgabe_2_260607/
  README.md
  HERANGEHENSWEISE.md
  terraform/
    versions.tf
    variables.tf
    main.tf
    outputs.tf
    cloud-init.yaml.tftpl
    files/app.py
```

## Was angezeigt wird

Die Webseite und die API zeigen unter anderem:

- Public und Private IP der VM
- Exoscale Instance ID, Zone und Instanztyp
- Ubuntu/Linux- und Kernel-Informationen
- CPU, RAM und Virtualisierung
- Block Devices und Dateisysteme
- IPv4/IPv6-Netzwerkadressen
- Uptime und Zeitpunkt der Datenerhebung
