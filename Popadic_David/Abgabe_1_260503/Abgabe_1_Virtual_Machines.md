# Virtual Machines 

## 1. Definition

Eine virtuelle Maschine (VM) ist eine digitale, vom physischen Computer getrennte Computerumgebung, die wie ein eigenständiges System arbeitet. Sie verfügt über virtuelle Komponenten wie Prozessor, Arbeitsspeicher, Netzwerkschnittstelle und Speicherplatz. Diese Ressourcen werden von der vorhandenen Hardware bereitgestellt und der virtuellen Maschine zugewiesen.

Grundlage dafür ist die Virtualisierung. Sie ermöglicht es, dass ein einzelner physischer Rechner mehrere voneinander unabhängige Systeme gleichzeitig ausführen kann. Dadurch lassen sich verschiedene Betriebssysteme parallel auf derselben Hardware betreiben. Unternehmen nutzen virtuelle Maschinen, um Hardwarekosten zu senken, Systeme flexibler bereitzustellen und vorhandene IT-Ressourcen effizienter zu verwenden.

---

## 2. Funktionsweise virtueller Maschinen

Virtuelle Maschinen laufen auf einem physischen Computer, der als Host-System bezeichnet wird. Auf diesem Host können mehrere virtuelle Maschinen gleichzeitig betrieben werden. Diese werden auch als Guests bezeichnet. Jede virtuelle Maschine besitzt eigene virtuelle Ressourcen wie Prozessor, Arbeitsspeicher, Netzwerkkarte und Speicherplatz.

Die Verwaltung dieser Ressourcen übernimmt eine spezielle Software namens Hypervisor. Er erstellt, startet und verwaltet virtuelle Maschinen und verteilt die vorhandene Hardwareleistung des Hosts auf die einzelnen Guests. Dadurch können mehrere voneinander getrennte Systeme gleichzeitig auf einem Computer betrieben werden.

Für Benutzer verhält sich eine virtuelle Maschine wie ein normaler eigenständiger Computer. Innerhalb der VM kann ein eigenes Betriebssystem installiert und verwendet werden, beispielsweise Windows Server 2022, Ubuntu oder Debian.

Man unterscheidet zwei Arten von Hypervisoren:

- **Typ 1 (Bare Metal):** läuft direkt auf der Hardware. Beispiele sind Microsoft Hyper-V, Xen und KVM  
- **Typ 2 (Hosted):** läuft als Anwendung auf einem bestehenden Betriebssystem. Beispiele sind Oracle VirtualBox und VMware Workstation  

Durch diese Technik können Systeme flexibel bereitgestellt, getestet und effizient genutzt werden.

![Abbildung 1: Architektur einer virtuellen Maschine](../assets/Architektur_einer_virtuellen_Maschine.webp)

*Abbildung 1: Architektur einer virtuellen Maschine (Quelle: IONOS, angepasst nach https://www.ionos.at/digitalguide/server/knowhow/virtuelle-maschinen/)*

---

## 3. Einsatzgebiete virtueller Maschinen

Virtuelle Maschinen werden in vielen Bereichen der IT eingesetzt, da sie flexible, isolierte und leicht verwaltbare Umgebungen bieten.

### Entwicklungs- und Testumgebungen
VMs ermöglichen es, schnell isolierte Testumgebungen zu erstellen. Entwickler können unterschiedliche Betriebssysteme und Konfigurationen parallel betreiben, ohne das Hauptsystem zu beeinflussen. Durch Funktionen wie Snapshots lassen sich Systeme einfach zurücksetzen.

### Cloud Computing
Virtuelle Maschinen bilden die Grundlage moderner Cloud-Dienste. Anbieter wie Amazon Web Services oder Microsoft Azure stellen virtuelle Server als sogenannte Infrastructure-as-a-Service (IaaS) bereit. Dadurch können Ressourcen flexibel und skalierbar genutzt werden.

### Backup und Disaster Recovery
VMs erleichtern die Datensicherung und Wiederherstellung. Systeme können gesichert, repliziert und bei Ausfällen schnell wiederhergestellt werden, wodurch Ausfallzeiten reduziert werden.

### Virtuelle Desktop-Infrastruktur (VDI)
Bei VDI werden komplette Desktop-Systeme als virtuelle Maschinen bereitgestellt. Nutzer können von verschiedenen Geräten aus auf ihre gewohnte Arbeitsumgebung zugreifen, was besonders für Remote-Arbeit relevant ist.

### Sicherheit und Isolation
Virtuelle Maschinen werden genutzt, um Anwendungen voneinander zu isolieren. Dadurch können Sicherheitsrisiken reduziert und beispielsweise unbekannte Programme sicher getestet werden.

### Malware-Analyse
IT-Sicherheitsexperten verwenden VMs, um Schadsoftware in einer kontrollierten Umgebung zu untersuchen, ohne das eigentliche System zu gefährden.

### Betrieb alter oder inkompatibler Software
VMs ermöglichen es, ältere Betriebssysteme oder Programme weiterhin zu nutzen, auch wenn sie auf moderner Hardware nicht mehr direkt lauffähig sind.

### Lastverteilung und Hochverfügbarkeit
Durch den Einsatz mehrerer virtueller Maschinen können Systeme besser skaliert und Ausfälle abgefangen werden. Workloads werden auf mehrere Instanzen verteilt.

---

## 4. Tools und Hersteller

Zur Erstellung und Verwaltung virtueller Maschinen existieren verschiedene Tools und Plattformen, die sowohl im privaten als auch im Unternehmensumfeld eingesetzt werden.

Zu den wichtigsten Herstellern zählen VMware, Microsoft, Oracle und Red Hat.

Ein weit verbreitetes Produkt ist VMware ESXi, ein Typ-1-Hypervisor, der direkt auf der Hardware läuft und vor allem in Unternehmen eingesetzt wird. Er ermöglicht eine effiziente Servervirtualisierung und wird häufig über eine Weboberfläche verwaltet.

Microsoft Hyper-V ist ein Hypervisor, der in Windows Server integriert ist. Er wird häufig in Windows-basierten Infrastrukturen verwendet und spielt auch eine wichtige Rolle in der Cloud-Plattform Microsoft Azure.

Für den Einsatz auf Einzelrechnern ist Oracle VirtualBox eine beliebte Open-Source-Lösung. Sie bietet eine einfache Benutzeroberfläche und eignet sich besonders für Lern- und Testzwecke.

Im Linux-Bereich wird häufig KVM (Kernel-based Virtual Machine) eingesetzt. Dabei wird der Linux-Kernel selbst zum Hypervisor erweitert. KVM bildet auch die Grundlage für Plattformen wie Proxmox VE, die eine komfortable Verwaltung über ein Webinterface ermöglichen.

Darüber hinaus spielen virtuelle Maschinen eine zentrale Rolle im Cloud Computing. Anbieter wie Amazon Web Services stellen virtuelle Server als skalierbare Dienste bereit.

---

## 5. Vorteile und Nachteile

### Vorteile

- **Kosteneffizienz:** Mehrere virtuelle Systeme können auf einer einzigen physischen Hardware betrieben werden. Dadurch werden Kosten für Anschaffung, Energie und Wartung reduziert.  
- **Flexibilität:** Unterschiedliche Betriebssysteme und Anwendungen lassen sich parallel auf einem Host-System ausführen.  
- **Isolation:** Fehler oder Abstürze in einer VM haben in der Regel keinen Einfluss auf andere Systeme.  
- **Sicherheit:** Isolierte Umgebung ermöglicht sicheres Testen und Snapshots zur Wiederherstellung.  

### Nachteile

- **Ressourcenverbrauch:** Hoher Bedarf an CPU, RAM und Speicherplatz.  
- **Leistungseinbußen:** Geringere Performance im Vergleich zu physischer Hardware.  
- **Komplexität:** Verwaltung erfordert technisches Know-how.  

---

## 6. Praxisbeispiel

Ein typisches Einsatzszenario für virtuelle Maschinen ist die Servervirtualisierung in Unternehmen. Früher wurden für verschiedene Dienste wie Dateiserver, Webserver oder Domain Controller jeweils eigene physische Server eingesetzt.

Heute werden solche Dienste als virtuelle Maschinen auf einem zentralen Host-System betrieben. Mithilfe eines Hypervisors wie VMware ESXi oder Microsoft Hyper-V können mehrere virtuelle Server auf einer einzigen physischen Maschine ausgeführt werden.

Beispielsweise kann ein Unternehmen drei virtuelle Maschinen betreiben: eine VM mit Windows Server 2022 als Domain Controller, eine weitere als Fileserver und eine dritte als Webserver. Dadurch wird die vorhandene Hardware effizient genutzt und gleichzeitig die Verwaltung vereinfacht.

Ein großer Vorteil dieser Lösung ist die Möglichkeit, virtuelle Maschinen schnell zu sichern und bei Bedarf wiederherzustellen. Außerdem können neue Systeme flexibel hinzugefügt werden, ohne zusätzliche Hardware anschaffen zu müssen.

---

## 7. Quellen

- Red Hat: https://www.redhat.com/de/topics/virtualization/what-is-a-virtual-machine  
- HPE Glossar: https://www.hpe.com/at/de/what-is/virtual-machine.html  
- DataCamp: https://www.datacamp.com/de/blog/what-is-a-virtual-machine  
- Goldinger IT: https://www.goldingerit.ch/blog/2023-06-02-virtuelle-maschinen-vor-und-nachteile-im-ueberblick/  
- IONOS: https://www.ionos.at/digitalguide/server/knowhow/virtuelle-maschinen/  
