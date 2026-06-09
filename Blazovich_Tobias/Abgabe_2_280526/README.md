## Hinweise zur Ausführung

Die Bereitstellung der Infrastruktur erfolgt automatisiert über OpenTofu und GitHub Actions. Zusätzlich wurde eine DNS- und HTTPS-Konfiguration mittels Exoscale DNS sowie Let's Encrypt umgesetzt.

Da die Ausstellung eines TLS-Zertifikats von der erfolgreichen DNS-Auflösung der Domain abhängt, kann die Zertifikatserstellung zeitlich von der Verfügbarkeit des DNS-Eintrags beeinflusst werden. Die Infrastruktur ist unabhängig davon unmittelbar nach der Bereitstellung über die öffentliche IP-Adresse der VM erreichbar.

Für die Verwaltung der Infrastruktur über getrennte GitHub Actions Workflows ist die Verwendung eines zentral gespeicherten OpenTofu-State empfehlenswert. Dadurch kann der Infrastrukturzustand auch über mehrere Workflow-Ausführungen hinweg konsistent verwaltet werden.