# Abgabe 2 – Exoscale VM mit OpenTofu und CloudInit

## Ziel

Automatisierte Erstellung einer Ubuntu 24.04 LTS VM in Exoscale mittels OpenTofu.

## Verwendete Technologien

- OpenTofu
- Exoscale
- CloudInit
- Nginx
- GitHub Actions

## Deployment

Infrastruktur erstellen:

- Workflow `create.yml` ausführen

Alternativ lokal:

```bash
tofu init
tofu apply
```

## Infrastruktur löschen

- Workflow `destroy.yml` ausführen

Alternativ lokal:

```bash
tofu destroy
```

## Endpunkt

Die Webseite ist nach erfolgreicher Erstellung über die öffentliche IP-Adresse der VM erreichbar.

Beispiel:

```text
http://<PUBLIC-IP>
```

## Enthaltene Dateien

- main.tf
- variables.tf
- outputs.tf
- cloud-init.yaml
- create.yml
- destroy.yml
- Dokumentation.md

Weitere Details befinden sich in der Datei `Dokumentation.md`.
