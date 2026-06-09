\# Abgabe 2

##  Aufgabenstellung

Ziel der Aufgabe war die automatisierte Bereitstellung einer virtuellen
Maschine in der Exoscale Cloud. Die VM soll über eine öffentliche URL
(IP-Adresse oder FQDN) erreichbar sein und über einen HTTP-Endpunkt
technische Informationen über sich selbst bereitstellen.

Beispiele für auszugebende Informationen:

\- Hostname

\- IP-Adresse

\- Betriebssystem

\- Kernel-Version

\- CPU-Informationen

\- Arbeitsspeicher

\- Storage-Geräte

\- Dateisysteme

\- Hypervisor-Typ

\- Uptime

Zusätzlich musste die gesamte Infrastruktur automatisiert erstellt und
gelöscht werden. Hierfür sollten folgende Technologien verwendet werden:

\- OpenTofu/Terraform

\- Exoscale Cloud

\- CloudInit

\- GitHub Actions

##  2. Exoscale vorbereiten

Für die Kommunikation mit Exoscale wurden API-Zugangsdaten benötigt.

Im Exoscale Portal wurden erstellt:

- API Key

- API Secret

Diese werden später entweder lokal über terraform.tfvars und in GitHub
Actions über Secrets bereitgestellt.

## 3. OpenTofu konfigurieren

variables.tf -\> In dieser Datei wurden die benötigten Variablen
definiert:

- API Key

- API Secret

- Zone

- VM Name

## 4. Infrastruktur definieren

main.tf -\> In der Hauptkonfiguration wurden folgende Ressourcen
definiert:

[Provider]{.underline}

Verbindung zu Exoscale:

provider \"exoscale\" {

key = var.exoscale_api_key

secret = var.exoscale_api_secret

}

[Ubuntu Template]{.underline}

Automatische Auswahl eines Ubuntu 22.04 LTS Images:

data \"exoscale_template\" \"ubuntu\" {

zone = var.zone

name = \"Linux Ubuntu 22.04 LTS 64-bit\"

}

[Security Group]{.underline}

Erstellung einer Security Group für die VM.

[HTTP-Regel]{.underline}

Freigabe von Port 80:

resource \"exoscale_security_group_rule\" \"http\" {

start_port = 80

end_port = 80

}

[Compute Instance]{.underline}

Bereitstellung der VM:

resource \"exoscale_compute_instance\" \"vm\" {

\...

user_data = file(\"\${path.module}/cloud-init.yaml\")

}

## 5. CloudInit verwenden

Beim ersten Start der VM werden:

- Systempakete aktualisiert

- Python installiert

- ein HTTP-Service erstellt

- ein systemd-Dienst eingerichtet

- der Dienst automatisch gestartet

## 6. HTTP-Endpunkt erstellen

CloudInit erzeugt automatisch ein Python-Skript.

Der HTTP-Service sammelt Informationen mittels Befehlen:

uname -a

hostname -I

free -h

lscpu

lsblk df -hT

systemd-detect-virt

uptime -p

Die Informationen werden als JSON ausgegeben.

## 7. Outputs definieren

outputs.tf -\> Nach erfolgreichem Deployment werden wichtige
Informationen ausgegeben:

output \"vm_public_ip\" {

value = exoscale_compute_instance.vm.public_ip_address

}

output \"vm_http_url\" {

value = \"http://\${exoscale_compute_instance.vm.public_ip_address}\"

}

## 8. Lokale Tests durchführen

Vor dem Einsatz von GitHub Actions wurde die Infrastruktur lokal
getestet.

Initialisierung:

- tofu init

Validierung:

- tofu validate

Ausführungsplan:

- tofu plan

Der Plan zeigte:

Plan: 3 to add, 0 to change, 0 to destroy

Dadurch konnte überprüft werden, dass die Infrastruktur korrekt erstellt
werden würde.

## 9. Infrastruktur bereitstellen

OpenTofu führt folgende Aktionen aus:

- Security Group erstellen

- Firewall-Regeln erstellen

- Ubuntu VM erstellen

- CloudInit übergeben

Nach erfolgreichem Deployment sollte die öffentliche IP-Adresse
ausgegeben werden.

## 10. GitHub Actions erstellen

Für die Automatisierung wurden zwei Workflows vorgesehen.

deploy.yml -\> Erstellt die Infrastruktur:

- tofu init

- tofu validate

- tofu plan

- tofu apply -auto-approve

delete.yml -\> Löscht die Infrastruktur:

- tofu init

- tofu destroy -auto-approve

Die Exoscale Zugangsdaten werden dabei über GitHub Secrets
bereitgestellt.

## 11. Infrastruktur löschen

Nach Abschluss der Tests kann die Infrastruktur wieder entfernt werden:

tofu destroy

Dadurch werden alle erstellten Ressourcen automatisch gelöscht.

https://developer.hashicorp.com/terraform/tutorials/aws-get-started/aws-create

https://www.exoscale.com/blog/terraform-with-exoscale/
