# Herangehensweise

## Ziel

Ziel der Aufgabe war die automatisierte Bereitstellung einer virtuellen Maschine auf Exoscale unter Verwendung von Terraform und GitHub Actions.

## Umsetzung

Zunächst wurden die Terraform-Konfigurationsdateien erstellt. Diese definieren die virtuelle Maschine, die benötigten Sicherheitsregeln und die Ausgabewerte.

Anschließend wurde mittels CloudInit die automatische Konfiguration der VM umgesetzt. Dabei werden die benötigten Pakete installiert und eine Webseite inklusive JSON-Endpunkt bereitgestellt.

Die Bereitstellung sowie das Löschen der Infrastruktur erfolgen automatisiert über GitHub Actions Workflows.

## Funktionsweise

1. GitHub Action startet.
2. Terraform/OpenTofu erstellt die Infrastruktur.
3. CloudInit konfiguriert die VM.
4. Nginx stellt die Webseite bereit.
5. Der API-Endpunkt liefert Systeminformationen im JSON-Format.

## Verwendete Technologien

- Exoscale
- Terraform
- CloudInit
- GitHub Actions
- Nginx
