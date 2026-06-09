# Hypervisoren – Type 1 und Type 2

**Kurs:** BITI VICA SS26  
**Thema:** Type 1 / Type 2 Hypervisor  
**Autor:** *(Name eintragen)*  
**Datum:** Mai 2026

---

## 1. Was ist ein Hypervisor?

Ein **Hypervisor** – auch bekannt als *Virtual Machine Monitor (VMM)* – ist eine Software- oder Firmware-Schicht, die es ermöglicht, mehrere **virtuelle Maschinen (VMs)** auf einem einzigen physischen Host-System gleichzeitig zu betreiben. Jede virtuelle Maschine verhält sich dabei so, als würde sie auf dedizierter Hardware laufen, obwohl sie sich die zugrundeliegenden Ressourcen – CPU, RAM, Speicher und Netzwerk – mit anderen VMs teilt.

Der Begriff stammt vom englischen Wort *supervisor* (dt. Aufseher), wobei das Präfix *hyper-* auf eine übergeordnete Kontrollebene hinweist. Der Hypervisor bildet also die Abstraktionsschicht zwischen physischer Hardware und den virtuellen Gastbetriebssystemen.

Hypervisoren sind das Kernstück moderner **Virtualisierungsinfrastrukturen** und damit eine fundamentale Technologie in Rechenzentren, Cloud-Umgebungen und der Entwicklung von Software.

---

## 2. Kontext und Einsatzgebiete

Virtualisierung durch Hypervisoren ist in verschiedenen Bereichen der IT allgegenwärtig:

| Bereich | Typischer Einsatz |
|---|---|
| **Rechenzentren / Enterprises** | Server-Konsolidierung, Ressourcenauslastung maximieren |
| **Cloud Computing** | Mandantenfähige Infrastruktur (AWS, Azure, GCP) |
| **Entwicklung & Testing** | Isolierte Testumgebungen, Snapshots, Rollback |
| **Desktop-Virtualisierung (VDI)** | Thin Clients greifen auf zentrale VMs zu |
| **Sicherheit & Forensik** | Malware-Analyse in isolierten Sandboxen |
| **Ausbildung** | Verschiedene Betriebssysteme auf einem Gerät simulieren |

Ohne Hypervisoren wäre das Geschäftsmodell von Cloud-Anbietern in dieser Form nicht realisierbar: Tausende Kunden teilen sich dieselbe physische Hardware, ohne voneinander zu wissen oder sich gegenseitig zu beeinflussen.

---

## 3. Arten von Hypervisoren

Es gibt zwei grundlegende Typen, die sich in ihrer **Architektur** und ihrem **Einsatzzweck** wesentlich unterscheiden:

### 3.1 Type-1-Hypervisor (Bare-Metal)

Ein **Type-1-Hypervisor** läuft direkt auf der physischen Hardware des Host-Systems, ohne dass ein klassisches Host-Betriebssystem darunter liegt. Er ist selbst das "Betriebssystem" der Maschine und hat **direkten Zugriff auf die Hardware-Ressourcen**.

```
+------------------------------------------+
|          VM 1   |  VM 2   |  VM 3        |  ← Gastbetriebssysteme
+------------------------------------------+
|             Type-1-Hypervisor            |  ← Direkt auf Hardware
+------------------------------------------+
|     Hardware (CPU, RAM, Storage, NIC)    |
+------------------------------------------+
```

**Eigenschaften:**
- Höchste Performance, da kein Host-OS als Zwischenschicht vorhanden ist
- Sehr hohe Stabilität und Sicherheit
- Primär für den professionellen, serverbasierter Einsatz konzipiert
- Benötigt oft dedizierte Management-Konsolen oder separate Management-VMs

**Vorteile:**
- Geringer Overhead
- Starke Isolation der VMs
- Produktionsreif für Enterprise- und Cloud-Umgebungen

**Nachteile:**
- Komplexere Einrichtung und Verwaltung
- Weniger geeignet für den Desktop-Einsatz

---

### 3.2 Type-2-Hypervisor (Hosted)

Ein **Type-2-Hypervisor** wird als gewöhnliche Anwendung auf einem bestehenden **Host-Betriebssystem** (z. B. Windows, macOS oder Linux) installiert und betrieben. Er nutzt die Betriebssystem-Dienste des Hosts als Vermittler für den Hardware-Zugriff.

```
+----------------------------+
|  VM 1   |  VM 2   |  VM 3  |  ← Gastbetriebssysteme
+----------------------------+
|    Type-2-Hypervisor       |  ← Läuft als Anwendung
+----------------------------+
|    Host-Betriebssystem     |  ← z. B. Windows 11, macOS
+----------------------------+
|       Hardware             |
+----------------------------+
```

**Eigenschaften:**
- Einfache Installation wie jede andere Software
- Abhängig vom Host-Betriebssystem
- Höherer Overhead durch die zusätzliche OS-Schicht
- Ideal für Einzelnutzer, Entwickler und Testumgebungen

**Vorteile:**
- Benutzerfreundlich und einfach einzurichten
- Läuft neben dem normalen Desktop-Betrieb
- Keine dedizierte Hardware notwendig

**Nachteile:**
- Höherer Ressourcenverbrauch
- Abhängig von der Stabilität des Host-OS
- Weniger geeignet für produktive Serverumgebungen

---

## 4. Technische Funktionsweise

### 4.1 CPU-Virtualisierung

Moderne CPUs (Intel VT-x, AMD-V) bieten native **Hardware-Virtualisierungsunterstützung**. Der Hypervisor nutzt diese Fähigkeiten, um Gastbetriebssystemen eine vollständige virtuelle CPU bereitzustellen. Der sogenannte **VMX-Mode** (Virtual Machine Extensions) erlaubt es, dass Gastcode privilegierte Instruktionen ausführt, ohne direkten Zugriff auf die reale Hardware zu erhalten – der Hypervisor fängt solche Aufrufe ab und behandelt sie sicher.

### 4.2 Speicherverwaltung

Der Hypervisor implementiert eine eigene **Speicherverwaltung (Memory Management Unit)**, die den Gastbetriebssystemen virtuelle Adressräume zuteilt. Techniken wie **Shadow Page Tables** (ältere Methode) oder **Extended Page Tables / Nested Paging** (hardwaregestützt) werden genutzt, um die Adressübersetzung effizient durchzuführen.

### 4.3 I/O-Virtualisierung

Zugriffe auf Festplatten, Netzwerkkarten und andere Geräte werden durch virtuelle Gerätetreiber abstrahiert. Gängige Ansätze sind:

- **Emulation:** Der Hypervisor emuliert ein bekanntes Gerät vollständig (langsam, aber maximal kompatibel).
- **Para-Virtualisierung:** Das Gastbetriebssystem "weiß", dass es virtualisiert wird, und kommuniziert über optimierte Schnittstellen (z. B. `virtio` unter Linux).
- **Hardware-Passthrough (SR-IOV / VFIO):** Ein physisches Gerät wird direkt einer VM zugeordnet – maximale Performance, aber nur exklusiv nutzbar.

### 4.4 Isolation und Sicherheit

Jede VM läuft in einem eigenen, vollständig abgeschotteten Namespace. Ein Fehler oder ein Sicherheitsvorfall in einer VM kann – bei korrekter Konfiguration – nicht auf andere VMs oder den Hypervisor übergreifen. Diese starke **Isolation** ist ein wesentlicher Sicherheitsvorteil gegenüber Container-Technologien wie Docker.

---

## 5. Vergleich: Type 1 vs. Type 2

| Merkmal | Type-1 (Bare-Metal) | Type-2 (Hosted) |
|---|---|---|
| **Laufumgebung** | Direkt auf Hardware | Auf Host-Betriebssystem |
| **Performance** | Sehr hoch | Mittel (OS-Overhead) |
| **Sicherheit** | Sehr hoch | Abhängig vom Host-OS |
| **Einsatzgebiet** | Server, Rechenzentren, Cloud | Desktop, Entwicklung, Tests |
| **Einstiegshürde** | Hoch | Gering |
| **Ressourcenverbrauch** | Gering | Höher |
| **Beispiele** | VMware ESXi, Microsoft Hyper-V, KVM | VirtualBox, VMware Workstation, Parallels |

---

## 6. Gängige Protokolle, Produkte und Tools

### Type-1-Hypervisoren

| Produkt | Hersteller | Beschreibung |
|---|---|---|
| **VMware ESXi** | Broadcom (ehem. VMware) | De-facto-Standard in Unternehmensrechenzentren; Teil der vSphere-Plattform |
| **Microsoft Hyper-V** | Microsoft | In Windows Server integriert; auch als eigenständige Rolle verfügbar |
| **KVM (Kernel-based Virtual Machine)** | Open Source / Red Hat | Im Linux-Kernel integriert; Basis für viele Cloud-Plattformen (z. B. OpenStack) |
| **Xen Project** | Open Source / Linux Foundation | Wird von AWS (Amazon EC2) als Basis eingesetzt; sehr ausgereift |
| **Proxmox VE** | Proxmox Server Solutions | Open-Source-Plattform auf KVM-Basis; populär für Homelab und SMB |

### Type-2-Hypervisoren

| Produkt | Hersteller | Beschreibung |
|---|---|---|
| **Oracle VirtualBox** | Oracle | Kostenlos und plattformübergreifend; weit verbreitet in Entwicklung und Ausbildung |
| **VMware Workstation / Fusion** | Broadcom | Professionelle Desktop-Lösung für Windows/Linux (Workstation) bzw. macOS (Fusion) |
| **Parallels Desktop** | Corel / Parallels | Populär auf macOS, insbesondere für Windows-Virtualisierung auf Apple-Silicon-Chips |
| **QEMU** | Open Source | Technisch ein Emulator/Hypervisor; oft in Kombination mit KVM genutzt |

### Relevante Protokolle und Standards

- **SPICE / RDP / VNC:** Remote-Protokolle für den Zugriff auf die grafische Oberfläche von VMs
- **OVF/OVA (Open Virtualization Format):** Standardformat zum Austausch von VM-Images zwischen verschiedenen Hypervisoren
- **ACPI:** Standard für Energieverwaltung in virtuellen Maschinen
- **virtio:** Para-virtualisierte Treiberschnittstelle, die unter KVM und QEMU verwendet wird

---

## 7. Architektur-Schaubild: Vergleich beider Typen

```
╔══════════════════════════╗      ╔══════════════════════════════╗
║      TYPE-1 (Bare-Metal) ║      ║      TYPE-2 (Hosted)         ║
╠══════════════════════════╣      ╠══════════════════════════════╣
║  VM A  │  VM B  │  VM C  ║      ║  VM A  │  VM B  │  VM C      ║
╠══════════════════════════╣      ╠══════════════════════════════╣
║    Hypervisor (z.B. ESXi)║      ║  Hypervisor (z.B.VirtualBox) ║
╠══════════════════════════╣      ╠══════════════════════════════╣
║                          ║      ║   Host-OS (Windows/Linux)    ║
╠══════════════════════════╣      ╠══════════════════════════════╣
║   Physische Hardware     ║      ║   Physische Hardware         ║
╚══════════════════════════╝      ╚══════════════════════════════╝
        ↑ Direkter Zugriff                ↑ Indirekter Zugriff
```

---

## 8. Praxisbeispiele und reale Anwendungsfälle

### Beispiel 1: Cloud-Infrastruktur (AWS EC2)

Amazon Web Services setzt auf Xen und mittlerweile auf einen eigenen KVM-basierten Hypervisor namens **Nitro System**. Wenn ein Nutzer eine EC2-Instanz startet, wird eine VM auf einem physischen Server in einem AWS-Rechenzentrum gestartet – vollständig isoliert von tausenden anderer Kunden-VMs auf derselben Hardware. Mehrere Kunden können denselben physischen Host nutzen, ohne voneinander zu wissen.

### Beispiel 2: Entwickler-Workstation (VirtualBox)

Ein Webentwickler auf Windows möchte seine Anwendung unter Ubuntu Linux testen. Er installiert Oracle VirtualBox (Type-2), erstellt eine Ubuntu-VM und kann beide Betriebssysteme parallel nutzen. Snapshots erlauben es, den Zustand vor einem riskanten Eingriff zu speichern und bei Bedarf wiederherzustellen.

### Beispiel 3: Unternehmensrechenzentrum (Proxmox VE)

Ein mittelständisches Unternehmen betreibt früher 20 physische Server für verschiedene Dienste (Datenbankserver, Webserver, Fileserver). Durch Virtualisierung mit Proxmox VE (Type-1, KVM-basiert) werden alle Dienste als VMs auf 4 leistungsstarken Hosts konsolidiert. Das spart Strom, Kühlungskosten und vereinfacht die Administration erheblich.

### Beispiel 4: Malware-Analyse (Sandboxing)

Sicherheitsforscher analysieren unbekannte Schadsoftware in einer isolierten VM. Die Malware kann die Analysewerkzeuge befallen, Dateien löschen oder Netzwerkverbindungen aufbauen – dank der starken Isolation des Hypervisors bleibt das Host-System jedoch unberührt. Nach der Analyse wird die VM einfach zurückgesetzt.

---

## 9. Abgrenzung: Hypervisor vs. Container

Häufig werden Hypervisoren mit Container-Technologien wie **Docker** oder **Kubernetes** verglichen. Beide ermöglichen Isolation, unterscheiden sich aber grundlegend:

| Merkmal | Hypervisor (VM) | Container (Docker) |
|---|---|---|
| **Isolation** | Vollständiges OS pro VM | Gemeinsamer OS-Kernel |
| **Overhead** | Höher (eigenes OS) | Sehr gering |
| **Startzeit** | Sekunden bis Minuten | Millisekunden |
| **Sicherheit** | Sehr stark isoliert | Schwächer isoliert |
| **Einsatz** | Unterschiedliche OS, starke Isolation | Microservices, skalierbare Apps |

In der Praxis werden beide Technologien oft **kombiniert**: Container laufen innerhalb von VMs – so profitieren sie von der starken Hypervisor-Isolation und der Leichtgewichtigkeit von Containern gleichzeitig.

---

## 10. Fazit

Hypervisoren sind eine Schlüsseltechnologie der modernen IT-Infrastruktur. **Type-1-Hypervisoren** bieten maximale Performance und Sicherheit und sind der Standard in Rechenzentren und Cloud-Umgebungen. **Type-2-Hypervisoren** punkten durch einfache Bedienbarkeit und niedrige Einstiegshürde – sie sind das Mittel der Wahl für Entwickler, Studenten und Einzelanwender.

Die Wahl des richtigen Hypervisor-Typs hängt stark vom Einsatzzweck ab: Wer Server konsolidieren oder eine Cloud-Plattform betreiben will, greift zu Type 1. Wer schnell eine Testumgebung aufsetzen oder mehrere Betriebssysteme auf dem eigenen Laptop ausprobieren möchte, ist mit Type 2 bestens bedient.

---

## Quellen

1. Portnoy, M. (2012). *Virtualization Essentials*. Sybex/Wiley.
2. VMware Inc. (2024). *What is a Hypervisor?* – [https://www.vmware.com/topics/glossary/content/hypervisor](https://www.vmware.com/topics/glossary/content/hypervisor)
3. Red Hat Inc. (2024). *What is KVM?* – [https://www.redhat.com/en/topics/virtualization/what-is-KVM](https://www.redhat.com/en/topics/virtualization/what-is-KVM)
4. Microsoft Docs (2024). *Hyper-V Technology Overview* – [https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/hyper-v-technology-overview](https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/hyper-v-technology-overview)
5. Xen Project (2024). *Xen Project Software Overview* – [https://wiki.xenproject.org/wiki/Xen_Project_Software_Overview](https://wiki.xenproject.org/wiki/Xen_Project_Software_Overview)
6. Amazon Web Services (2024). *The AWS Nitro System* – [https://aws.amazon.com/ec2/nitro/](https://aws.amazon.com/ec2/nitro/)
7. Intel Corporation (2023). *Intel® Virtualization Technology (Intel® VT)* – [https://www.intel.com/content/www/us/en/virtualization/virtualization-technology/intel-virtualization-technology.html](https://www.intel.com/content/www/us/en/virtualization/virtualization-technology/intel-virtualization-technology.html)