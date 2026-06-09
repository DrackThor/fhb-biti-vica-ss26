# Ausarbeitung: Virtual Machines

**Autor:** Fabian Grafschafter
**Datum:** 18.05.2026
**Kurs:** BITI-VICA-SS26

---

## 1. Worum handelt es sich bei dem Begriff?
Eine virtuelle Maschine ist die softwarebasierte Nachbildung eines vollständigen physischen Computersystems. Es handelt sich dabei um eine gekapselte und isolierte Laufzeitumgebung, die ein eigenes Gast-Betriebssystem ausführt. Aus Sicht eines Anwenders oder einer installierten Applikation verhält sich eine virtuelle Maschine exakt gleich wie ein realer, physischer Computer. In der Realität existieren diese Maschinen jedoch nur aus einer Menge von Dateien und Prozessen auf einem Host-System, welches diese virtuellen Maschinen überhaupt zum leben erweckt. Ein Host-System stellt Ressourcen, Rechenleistung und Speicherplatz oder andere Dienste zur Verfügung, welche von einer virtuellen Maschine konsumiert werden.

Die Kernmerkmale einer virtuellen Maschine lassen sich primär in drei Konzepte zusammenfassen:

1.**Hardware-Abstraktion:** Die VM besitzt keine eigene, dedizierte Hardware. Physische Komponenten des Wirtsrechners wie Prozessor (CPU), Arbeitsspeicher (RAM), Festplatten und Netzwerkkarten werden der VM lediglich simuliert zur Verfügung gestellt.

2.**Isolation:** Auf einem einzigen Host-System können dutzende VMs parallel betrieben werden. Jede VM ist dabei logisch und speichertechnisch komplett von allen anderen VMs getrennt, was auch Kapselung genannt wird. Ein Softwarefehler, Systemabsturz oder andere Probleme innerhalb einer VM betreffen nur ads jeweilige System und nicht alle anderen VMs oder gar das zugrundeliegende Host-System.

3.**Portabilität:** Da eine VM auf Hardware-Ebene vollständig abstrahiert ist, ist sie nicht an die physischen Spezifikationen des Host-System gebunden. Eine VM besteht letztlich nur aus Konfigurations- und virtuellen Festplattendateien. Dadruch kann man sie im laufenden Betrieb sichern, klonen oder auch auf einen anderen physischen Server in kurzer Zeit (wenige Sekunden, abhängig von Größe der VM) verschieben.

Abgrenzung zu Containern bei Docker:
Während bei einer virtuellen Maschine stets ein komplettes Gast-Betriebssystem inklusive Kernel virtualisiert wird, was auch sehr ressourcenintensiv ist, virtualisiert ein Container lediglich die Anwendungsebene. Container teilen sich den Kernel des Host-Betriebssystem, wodurch sie deutlich leichtgewichtiger sind und schneller starten.


## 2. In welchem Kontext wird der Begriff verwendet?
Virtuelle Maschinen sind heute das Fundament moderner IT-Infrastrukturen und werden überall eingesetzt, wo Flexibilität, Hardware-Effizienz und strikte Isolationen erwartet werden Der Begriff fällt primär in den folgenden Anwendungsbereichen:

### Serverkonsolidierung im Rechenzentrum
In traditionellen IT-Umgebungen wurde oft die Sichtweise "Ein Server, eine Anwendung" verfolgt, was dazu führte, dass die phsysische Hardware häufig nur 10-15% asugelastet war. In Rechenzentren werden VMs eingesetzt, um diese Hardware-Ressourcen effizientere verwenden zu können. Durch Virtualisierung können Admins mehrere isolierte Server-VMs auf einem einzigen leistungsstarken physischen Server (Host) betreiben, was massiv Platz, Kühlung und Stromkosten spart.

### Cloud Computing
Der gesamte Begriff des "Cloud Computings" basiert auf der automatisierten Bereitstellung von virtuellen Maschinen. Wenn ein Unternehmen einige Cloud-Server mietet, werden fast immer VMs auf gigantischen Server-Clustern der Cloud-Providern (Azure, AWS, usw.) betrieben.

### Sandboxing und IT-Security
Im Kontext der Cybersicherheit und Softwareentwicklung spricht man oft von "Sandboxing". Da VMs komplett isoliert laufen, eignen sie sich auch als sichere und isolierte Testumgebung. Malware-Analysten nutzen VMs um potenzielle gefährliche Software wie Trojaner oder Viren kontrolliert auszuführen ohne das Produktivsystem zu gefährten.

### Weiterbetrieb von Legacy-Software (Altsystemen)
Oftmals sind Unternehmen auf ältere Fachanwendung wie im Bankwesen oder Gesundheitswesen angewiesen, die z.B.: nur auf Windows Server 2008 oder auch älteren Linux-Distros laufen. Da diese Betriebssysteme moderne Hardware nicht mehr unterstützen, wird das alte System mit der Anwendung in einer virtuellen Umgebung gepackt. So können ältere Anwendungen problemlos auch auf modernen Infrastrukturen weiterbetrieben werden.

## 3. Technische Funktionsweise
Die technische Realisierung einer Virtuellen Maschine basiert im Wesentlichen auf einer Zwischenschicht, die sich zwischen der physischen Hardware und den Betriebssystemen befindet. Diese Schicht wird Hypervisor genannt.
<img width="800" height="400" alt="image" src="https://github.com/user-attachments/assets/084e4e35-0d4e-4c30-841e-8b186d9f87e7" />

### 3.1 Hypervisor-Typen
Je nach Architektur unterscheidet man zwischne zwei Arten von Hypervisoren:
| Kriterium | Typ 1 Hypervisor (Bare Metal) | Typ 2 Hypervisor (Hosted) |
| :--- | :--- | :--- |
| **Architektur** | Wird wie ein Betriebssystem direkt auf der nackten Server-Hardware installiert. | Wird als normales Programm auf einem bereits bestehenden Betriebssystem (z.B. Windows) installiert. |
| **Leistung** | Extrem performant und ausfallsicher. | Geringere Leistung, da das Host-OS Ressourcen verbraucht. |
| **Einsatzbereich** | Rechenzentren und Cloud-Server. | Lokale Entwickler-PCs und Testumgebungen. |

### 3.2 Hardwareunterstützte Virtualisierung
Früher musste der Hypervisor sämtliche Systemaufrufe der virtuellen Maschine aufwendig in Software übersetzen. Heute übernehmen dies spezielle Befehlssatzerweiterungen moderner Prozessoren, welche fachlich auch "Hardware-assisted virtualization" genannt werden. Sie werden unter Intel als "Intel VT-x" und bei AMD als "AMD-V" benannt.
Diese in den Prozessor integrierten Funktionen ermöglichen es der VM, einen Großteil ihrer Befehle direkt und sicher auf der physischen CPU auszuführen, ohne dass der Hypervisor jeden Schritt übersetzen muss. Das reduziert den Overhead massiv und sorgt dafür, dass VMs heutzutage fast dieselbe Performance (Near-Native-Speed) erreichen wie direkte physische Installationen. Diese Funktionen müssen oft initial im BIOS bzw. UEFI des Host-Systems aktiviert werden, bevor überhaupt VMs genutzt werden können.

### 3.3 Ressourcenmanagement durch den Hypervisor
Ein Hypervisor ist das zentrale Betriebssystem für die Virtualisierung. Die Hauptaufgabe ist das dynamische Ressourcenmanagement bei dem er Rechenleistung, Arbeitsspeicher und Speicherplatz als Pool zusammenfast und den VMs bereitstellt.
- **CPU-Verwaltung:** Der Hypervisor teilt die Rechenleistung des physischen Prozessors durch Techniken wie Time-Slicing fair auf die verschiedenen VMs auf. Einer VM wird dabei vorgespielt, sie hätte eigene, dedizierte Prozessorkerne (vCPUs).
- **RAM-Verwaltung:** Durch Paging- und Mapping-Techniken übersetzt der Hypervisor die virtuellen Speicheradressen der VM in reale, physische Speicherblöcke. Dabei sorgt er dafür, dass die Speicherbereiche der einzelnen VMs strikt voneinander getrennt bleiben.

## 4. Gängige Produkte, Tools, Hersteller und Projekte
Der Markt für virtuelle Maschinen und Hypervisoren wird von großen Enterprise-Anbietern sowie starken Open-Source-Projekten geprägt. Man unterscheidet im groben wischen Server-Virtualisierung und Desktop-Virtualisierung. 

### 4.1 Enterprise-Lösungen (Typ 1 Hypervisoren)
Im professionellen Unternehmensumfeld dominieren Lösungen, die als Basis für große Rechenzentren und Cloud-Infrastrukturen dienen:

- **VMware vSphere (ESXi):** VMware gilt als Pionier der x86-Virtualisierung und gilt als Standard in Enterprise-Rechenzentren. ESXi ist der Bare-Metal-Hypervisor, der über Tools wie vCenter zentral verwaltet wird.

- **Microsoft Hyper-V:** Die Microsoft-Lösung ist tief in Windows Server integriert und bildet gleichzeitig die technische Grundlage für die gesamte Microsoft Azure Cloud.

- **Proxmox VE:** Eine zunehmend wachsende, Debian-basierte Open-Source-Alternative die besonders im Mittelstand und bei Homelab-Enthusiasten beliebt ist. Sie kombiniert den KVM-Hypervisor mit Container-Verwaltung in einer webbasierten Oberfläche.

### 4.2 Open-Source-Projekte (Linux-basiert)
In der Linux-Welt sind Virtualisierungstechnologien tief im Betriebssystem verankert.

- **KVM (Kernel-based Virtual Machine):** KVM verwandelt den Linux-Kernel selbst in einen Typ-1-Hypervisor. Er ist hochperformant und dient als Basis für viele andere Projekte wie Proxmox oder OpenStack.

- **Xen Project:** Ein sehr etablierter Open-Source-Hypervisor, der lange Zeit als Standard in der AWS-Cloud genutzt wurde und von Firmen wie Citrix kommerziell vertrieben wird. 

### 4.3 Desktop- und Entwickler-Tools (Typ-2-Hypervisoren)
Für Entwickler, die schnell eine isolierte Umgebung auf ihrem lokalen Windows-, Mac- oder Linux-PC aufsetzen möchten, kommen sogenannte Hosted-Hypervisoren zum Einsatz.

- **Oracle VM VirtualBox:** Die wohl bekannteste und kostenlose Lösung für Heimanwender und Entwickler um schnell Gast-Systeme aufzusetzen.

- **VMware Workstation Pro / Player:** Die Desktop-Variante von VMware, primär für Windows- und Linux-Hosts.

- **Parallels Desktop:** Ist der Markführer für Mac-Nutzer, um zum Beispiel eine Windows-VM nahtlos unter macOS ausfürhren zu können.

### 4.4 Dateiformate und Protokolle
Virtuelle Maschinen bestehen auf Dateiebene meist aus einer Konfigurationsdatei und mindestens einer virtuellen Festplattendatei. Gängige Formate sind:

- **.VMDK** (Virtual Machine Desk): Standardformat bei VMware.

- **.VHD / .VHDX** (Virtual Hard Disk): Standardformat bei Microsoft Hyper-V.

- **.QCOW2:** Ist ein dynamisch wachsendes Festplattenformat, das primär bei KVM/QEMU genutzt wird.

- **OVF / OVA** (Open Virtualization Format): Ist ein herstellerunabhängiges Standardformat zum Exportieren und Importieren kompletter virtueller Maschinen zwischen verschiedenen Hypervisoren.

## 5. Beispiele und reale Anwendungsmöglichkeiten
Die Virtualisierung von Hardware ist nicht nur ein abstraktes Konzept, sondern löst sher konkrete Probleme im IT-Alltag.

### 5.1 Isolierung von Serverrollen (Sicherheitssegmentierung)
In einem Unternehmensnetzwerk dürfen kritische Dienste wie ein Domain Controller und ein öffentlich erreichbarer Webserver nie auf dem selben Betriebssystem laufen. Durch Virtualisierung kann das Unternehmen einen einzigen starken physischen Server kaufen und dann darauf 2 virtuelle VMs betreiben. Wird der Webserver gehackt, bleibt der Domain Controller durch die Abschottung der VM vollständig geschützt.

### 5.2 Snapshot-Technologie und Backup
Vor einem kritischen Software-Update (z.B. einem Exchange Server CU/SU Update) kann der Administrator einen sogenannten "Snapshot" der virtuellen Maschine erstellen. Dies speichert den exakten Speicher- und Festplattenzustand der VM ab. Wenn das Update nun schiefgelaufen ist, kann man den Ist-Stand von vor dem Update zurückspielen. Dies wäre bei einem Bare-Metal Server ohne stundenlanges Einspielen von Backups unmöglich.

### 5.3 Live-Migration bei Hardware-Ausfällen
Moderne Hypervisoren wie VMware vSphere oder Microsoft Hyper-V unterstützen Live Migration. Bei einer Live Migartion kann man die gehosteten Server bei einem Ausfall oder Wartung direkt auf einen anderen physischen Server verschieben. Die Daten werden über das Netzwerk auf einen anderen Host migriert und die Endanwender merken von dem Umzug absolut nichts.

## 6 Architekturschaubild
<img width="1600" height="1039" alt="image" src="https://github.com/user-attachments/assets/7df04a89-54cb-42b1-a5ca-91f59ba03d7d" />


## 7 Quellen
https://www.datacamp.com/de/blog/what-is-a-virtual-machine?dc_referrer=https%3A%2F%2Fwww.perplexity.ai%2F

https://www.spaceship.com/de/blog/how-to-use-a-virtual-machine/

https://www.ionos.at/digitalguide/server/konfiguration/virtualisierungssoftware-im-vergleich/

https://www.ionos.de/digitalguide/server/knowhow/was-ist-ein-hypervisor/

https://www.redhat.com/de/topics/virtualization/what-is-a-virtual-machine




