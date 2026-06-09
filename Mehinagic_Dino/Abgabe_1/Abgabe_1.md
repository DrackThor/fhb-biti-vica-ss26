# Server- und Client-Virtualisierung via Virtual Machines

**Fachbereich:** IT-Infrastruktur-Management  
**Thema:** Virtual Machines (VMs)

---

## 1. Definition: Was ist eine Virtual Machine?

Eine **Virtual Machine (VM)** ist eine softwarebasierte, logisch vollständig isolierte Emulation eines physischen Computersystems. Sie führt ein eigenes, unabhängiges Betriebssystem (das sogenannte **Guest OS**) aus und greift auf virtuelle Hardwarekomponenten zu, die ihr durch eine Virtualisierungsschicht zur Verfügung gestellt werden. Zu diesen abstrahierten Komponenten gehören virtuelle Prozessoren (vCPUs), virtueller Arbeitsspeicher (vRAM), virtuelle Netzwerkschnittstellen (vNICs) sowie virtuelle Festplatten.

Aus Sicht der installierten Anwendungen und des Betriebssystems verhält sich eine VM identisch zu einem physischen Bare-Metal-Server. Die physische Hardware, auf der eine oder mehrere VMs betrieben werden, wird als **Host** bezeichnet.

---

## 2. Kontext und technologische Einsatzgebiete

Virtual Machines bilden das informationstechnische Fundament moderner Rechenzentren und Cloud-Infrastrukturen. Die Kernbereiche ihrer Verwendung umfassen:

*   **Server-Konsolidierung:** Historisch bedingt lief pro physischem Server meist nur eine Server-Anwendung (z. B. eine SQL-Datenbank), um gegenseitige Software-Inkompatibilitäten zu vermeiden. Dies führte zu einer geringen Hardwareauslastung (oft unter 10–15 %). Durch den Einsatz von VMs können dutzende logisch getrennte Systeme auf einer einzigen leistungsstarken Server-Hardware konsolidiert werden, was die Hardware-, Energie- und Kühlkosten drastisch senkt.
*   **Mandantenfähigkeit und Isolation (Multi-Tenancy):** In Public-Cloud-Umgebungen teilen sich verschiedene Kunden (Mandanten) dieselbe physische Infrastruktur. Der Hypervisor garantiert eine strikte logische Barriere, sodass kein Mandant auf den Speicherbereich oder die Daten eines anderen Mandanten zugreifen kann.
*   **Softwareentwicklung und Testing:** Entwickler können innerhalb von Sekunden standardisierte, reproduzierbare Umgebungen mit unterschiedlichen Betriebssystemen (z. B. Linux, Windows Server) instanziieren, testen und bei Fehlern per Snapshot-Technologie verwerfen.
*   **Betrieb von Legacy-Systemen:** Veraltete Softwareanwendungen, die moderne Hardwarearchitekturen oder aktuelle Betriebssysteme nicht unterstützen, lassen sich in einer VM auf Basis eines älteren Gast-Betriebssystems ohne Sicherheitsrisiko für das restliche Firmennetzwerk weiterbetrieben.

---

## 3. Technische Funktionsweise und Ressourcen-Abstraktion

Die technologische Grundlage jeder Virtualisierung ist der **Hypervisor**, auch bekannt als **Virtual Machine Monitor (VMM)**. Seine primäre Aufgabe ist es, die physischen Hardwareressourcen abzufangen, zu multiplexen und den verschiedenen VMs geordnet zuzuweisen.

### Klassifizierung der Hypervisoren
In der Praxis wird strikt zwischen zwei Architekturmodellen unterschieden:

1.  **Typ-1 Hypervisor (Bare-Metal):** Dieser Hypervisor wird direkt auf der nackten physischen Hardware installiert (ohne ein darunterliegendes Standard-Betriebssystem). Er besitzt einen extrem geringen Overhead und bietet die maximale Performance und Sicherheit. Typ-1-Systeme steuern Hardwarezugriffe direkt und sind der Standard im Enterprise- und Cloud-Bereich.
2.  **Typ-2 Hypervisor (Hosted):** Dieser Hypervisor wird als Anwendung innerhalb eines bereits laufenden Host-Betriebssystems (z. B. Windows 11 oder Linux) ausgeführt. Der Hardwarezugriff erfolgt hierbei indirekt über das Host-OS, was zu einem messbaren Performance-Overhead führt. Typ-2-Hypervisoren finden primär im Desktop-, Schulungs- und Entwicklungsbereich Anwendung.

### Hardware-Assisted Virtualization
Frühe Virtualisierungstechniken mussten Befehle zeitaufwendig per Software übersetzen (Binary Translation). Moderne x86- und ARM-Prozessoren verfügen über dedizierte Hardwareerweiterungen wie **Intel VT-x** und **AMD-V**. Diese Erweiterungen führen ein zusätzliches CPU-Privilegienlevel ein (den sogenannten *Root-Modus* für den Hypervisor und den *Non-Root-Modus* für das Guest-OS). Dadurch können unkritische CPU-Befehle der VM direkt ohne Software-Intervention auf der physischen CPU ausgeführt werden, was die Virtualisierungsgeschwindigkeit nahe an die native Hardware-Performance bringt.

### Kapselung und Portabilität
Ein wesentlicher technischer Vorteil von VMs ist die vollständige Kapselung. Eine VM besteht aus Sicht des Host-Speichers lediglich aus einer Konfigurationsdatei (XML, JSON oder proprietär) und einer oder mehreren Abbilddateien, welche die virtuellen Festplatten repräsentieren. Da die VM keine direkte Abhängigkeit von spezifischen physischen Hardwaretreibern des Hosts besitzt, ist sie vollständig portabel. Dies ermöglicht Technologien wie die **Live Migration**, bei der eine VM im laufenden Betrieb ohne Unterbrechung für den Endnutzer von einem physischen Host auf einen anderen verschoben wird.

---

## 4. Architektur-Vergleich: Physisch vs. Virtuell

Der direkte Vergleich zeigt, wie die Virtualisierung starre Hardwarekomponenten in flexible Software-Ressourcen transformiert:

| Eigenschaft | Physischer Server (Bare-Metal) | Virtuelle Maschine (VM) |
| :--- | :--- | :--- |
| **Kopplung an Hardware** | Starr. Das Betriebssystem benötigt spezifische Treiber für Mainboard, Netzwerkkarte und Speichercontroller. | Abstrahiert. Der Hypervisor präsentiert standardisierte, generische Hardwaretreiber. |
| **Skalierbarkeit** | Schwer und mit Ausfallzeiten verbunden (physischer Einbau von RAM/CPUs). | Hochflexibel. Ressourcen (vCPUs, vRAM) können per Software-Konfiguration (oft im laufenden Betrieb) angepasst werden. |
| **Bereitstellungszeit** | Stunden bis Wochen (Abhängig von Beschaffung, Einbau, Verkabelung und OS-Installation). | Minuten oder Sekunden durch automatisierte Vorlagen (Templates/Clones). |
| **Sicherung & Recovery** | Komplex. Erfordert Bare-Metal-Backup-Images und identische Zielhardware im Katastrophenfall. | Einfach. Erstellung von konsistenten **Snapshots** und hardwareunabhängigen Dateikopien. |

---

## 5. Ökosystem: Produkte, Tools und Formate

Die Virtualisierungslandschaft ist durch hochentwickelte kommerzielle Systeme sowie mächtige Open-Source-Projekte geprägt:

### Relevante Produkte und Enterprise-Plattformen
*   **VMware vSphere / ESXi:** Der langjährige Marktführer im Enterprise-Segment (Typ-1-Hypervisor) mit umfassenden Verwaltungs- und Automatisierungstools (vCenter).
*   **Microsoft Hyper-V:** Ein nativ in Windows Server integrierter Typ-1-Hypervisor, der besonders tief in Active-Directory-Umgebungen verzahnt ist.
*   **KVM (Kernel-based Virtual Machine):** Ein Open-Source-Virtualisierungsmodul, das den Linux-Kernel selbst in einen Typ-1-Hypervisor verwandelt. KVM stellt die technologische Basis für fast alle großen Public-Cloud-Anbieter dar.
*   **Proxmox VE (Virtual Environment):** Eine populäre Open-Source-Plattform, die KVM-Virtualisierung und LXC-Container über eine übersichtliche Webschnittstelle kombiniert.
*   **Oracle VM VirtualBox:** Ein weit verbreiteter Open-Source Typ-2-Hypervisor für x86-Infrastrukturen auf Client-Betriebssystemen.

### Virtuelle Disk-Formate
Die emulierten Festplatten werden in standardisierten Dateiformaten gespeichert:
*   `.vmdk` (Virtual Machine Disk) – Standardformat von VMware.
*   `.vhdx` (Virtual Hard Disk v2) – Standardformat von Microsoft Hyper-V.
*   `.qcow2` (QEMU Copy-On-Write) – Hochflexibles Format im Linux-/KVM-Umfeld, das dünne Speicherzuweisung (Thin Provisioning) unterstützt.
*   `.raw` – Unkomprimiertes, sequentielles Byte-Abbild mit maximaler Lese-/Schreibgeschwindigkeit, aber ohne erweiterte Features.

---

## 6. Abgrenzung: Virtual Machine vs. OS-Virtualisierung (Container)

Für das Verständnis moderner Architekturen ist die Unterscheidung zu Containern (z. B. Docker) essenziell. Während eine **VM die Hardware abstrahiert** und ein vollständiges, schweres Gast-Betriebssystem inklusive eigenem Kernel booten muss, setzt die **OS-Virtualisierung (Containerisierung) auf Betriebssystemebene an**. Container teilen sich den Kernel des Host-Betriebssystems und isolieren lediglich die Anwendungsprozesse im Userspace. VMs bieten dadurch eine signifikant höhere Sicherheitsisolation, weisen jedoch im Vergleich zu Containern längere Startzeiten und einen höheren Ressourcenverbrauch auf.

---

## 7. Fachliche Quellenangaben

1.  Silberschatz, A., Galvin, P. B., & Gagne, G. (2018). *Operating System Concepts* (10th ed.). Wiley. (Kapitel 16: Virtualization).
2.  Tanenbaum, A. S., & Bos, H. (2015). *Modern Operating Systems* (4th ed.). Pearson. (Kapitel 7: Virtualization and the Cloud).
3.  Intel Corporation. (2023). *Intel 64 and IA-32 Architectures Software Developer's Manual Volume 3C: System Programming Guide, Part 3* (Dedizierte Dokumentation zu Intel VT-x Funktionalitäten).
4.  Kivity, A., Kamay, Y., Laor, D., Lublin, U., & Liguori, A. (2007). *kvm: the Linux Kernel-based Virtual Machine*. Proceedings of the Linux Symposium, Vol. 1, 225-230.
5.  Barham, P., Dragovic, B., Fraser, K., Hand, S., Harris, T., Ho, A., Neugebauer, R., Pratt, I., & Warfield, A. (2003). *Xen and the art of virtualization*. ACM SIGOPS Operating Systems Review, 37(5), 164-177.
