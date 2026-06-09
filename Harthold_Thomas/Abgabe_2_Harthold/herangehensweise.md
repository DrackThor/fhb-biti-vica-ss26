# Abgabe 2 – Herangehensweise 

## 1. Ziel der Lösung

Ziel dieser Abgabe ist es, eine vollständig automatisierte Infrastruktur in Exoscale bereitzustellen.

Am Ende soll eine öffentlich erreichbare URL existieren, die auf eine Ubuntu-VM in Exoscale zeigt. Diese VM stellt über HTTP technische Informationen über sich selbst bereit.


Die Infrastruktur wird nicht manuell erstellt, sondern automatisiert über GitHub Actions und OpenTofu/Terraform. Die Betriebssystemkonfiguration der VM erfolgt vollständig automatisiert über Cloud-Init.

---

## 2. Verwendete Technologien

Für die Lösung werden folgende Technologien verwendet:

- **GitHub Actions**  
  Führt die Automatisierung aus. Es gibt einen Workflow zum Erstellen der Infrastruktur und einen Workflow zum Löschen der Infrastruktur.

- **OpenTofu / Terraform**  
  Beschreibt und erstellt die Infrastruktur in Exoscale als Infrastructure as Code.

- **Exoscale**  
  Stellt die Cloud-Infrastruktur bereit, insbesondere die Compute Instance und die Security Group.

- **Ubuntu**  
  Wird als Betriebssystem der VM verwendet.

- **Cloud-Init**  
  Konfiguriert die VM beim ersten Start automatisch.

- **nginx**  
  Stellt den HTTP-Endpunkt auf der VM bereit.

- **Exoscale SOS / S3-kompatibler Remote State**  
  Speichert den OpenTofu/Terraform State, damit der Create- und der Destroy-Workflow denselben Infrastrukturzustand verwenden können.

---

## 3. Herangehensweise

Die Lösung wurde so aufgebaut, dass keine manuellen Schritte auf der VM notwendig sind.

Die Automatisierung läuft in folgender Reihenfolge ab:

1. Ein GitHub Actions Workflow wird manuell gestartet.
2. GitHub Actions installiert OpenTofu.
3. OpenTofu initialisiert den Remote State im Exoscale SOS Bucket.
4. OpenTofu prüft und plant die Infrastruktur.
5. OpenTofu erstellt die notwendigen Ressourcen in Exoscale.
6. Exoscale startet eine Ubuntu VM.
7. Die VM erhält beim Start eine Cloud-Init-Konfiguration.
8. Cloud-Init installiert und konfiguriert automatisch nginx und die benötigten Hilfsprogramme.
9. Ein Script sammelt technische Informationen der VM.
10. Die Informationen werden als HTML-Seite und als JSON-Datei bereitgestellt.
11. Der Benutzer kann die VM über die öffentliche IP-Adresse im Browser aufrufen.

Die Infrastruktur kann später über einen zweiten GitHub Actions Workflow wieder gelöscht werden.
