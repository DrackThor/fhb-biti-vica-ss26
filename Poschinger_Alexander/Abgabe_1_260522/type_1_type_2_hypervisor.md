# Type 1 und Type 2 Hypervisor

## Einleitung

Ein Hypervisor ist eine Software-Schicht, die es ermöglicht, mehrere virtuelle Maschinen auf einer physischen Maschine auszuführen. Eine virtuelle Maschine, kurz VM, verhält sich dabei wie ein eigener Computer mit eigener CPU, eigenem Arbeitsspeicher, eigener Festplatte, Netzwerkkarte und eigenem Betriebssystem. In Wirklichkeit werden diese Ressourcen aber vom physischen Host bereitgestellt und vom Hypervisor verwaltet.

Hypervisoren werden vor allem im Bereich Virtualisierung eingesetzt. Sie sind wichtig in Rechenzentren, Cloud-Umgebungen, Unternehmen, Testlaboren und auch auf privaten Computern. Durch Virtualisierung muss nicht für jeden Dienst ein eigener physischer Server betrieben werden. Stattdessen können mehrere virtuelle Maschinen auf einem leistungsstarken Server laufen. Das spart Hardware, Strom, Platz und Verwaltungsaufwand.

Grundsätzlich unterscheidet man zwischen zwei Arten von Hypervisoren: **Type 1 Hypervisoren** und **Type 2 Hypervisoren**.

---

## Was ist ein Hypervisor?

Ein Hypervisor wird auch als **Virtual Machine Monitor** bezeichnet. Seine Aufgabe ist es, virtuelle Maschinen zu erstellen, auszuführen und voneinander zu trennen. Jede VM bekommt vom Hypervisor virtuelle Hardware zugewiesen. Dazu gehören zum Beispiel virtuelle Prozessoren, virtueller Arbeitsspeicher, virtuelle Festplatten und virtuelle Netzwerkkarten.

Das Gastbetriebssystem innerhalb der VM verhält sich so, als würde es auf echter Hardware laufen. Tatsächlich kommuniziert es aber mit der virtuellen Hardware, die vom Hypervisor bereitgestellt wird. Der Hypervisor übersetzt und koordiniert die Zugriffe auf die echte Hardware.

Wichtig ist dabei die Isolation. Eine VM soll nicht einfach auf den Speicher oder die Daten einer anderen VM zugreifen können. Dadurch können mehrere Systeme parallel betrieben werden, ohne sich gegenseitig direkt zu beeinflussen.

---

## Type 1 Hypervisor

Ein **Type 1 Hypervisor** wird auch **Bare-Metal-Hypervisor** genannt. Er läuft direkt auf der physischen Hardware und benötigt kein normales Betriebssystem darunter.

```text
+-----------------------------+
| Virtuelle Maschinen         |
+-----------------------------+
| Type 1 Hypervisor           |
+-----------------------------+
| Physische Hardware          |
+-----------------------------+
```

Da der Hypervisor direkt mit der Hardware arbeitet, ist diese Variante meist leistungsfähiger und stabiler. Type 1 Hypervisoren werden deshalb häufig in professionellen Serverumgebungen, Rechenzentren und Cloud-Infrastrukturen verwendet.

Typische Beispiele sind:

| Produkt | Hersteller / Projekt | Einsatzbereich |
|---|---|---|
| VMware ESXi | VMware / Broadcom | Enterprise, Rechenzentrum |
| Microsoft Hyper-V | Microsoft | Windows Server, Unternehmen |
| Proxmox VE | Proxmox | Open Source, Homelab, KMU |
| Xen | Xen Project | Server- und Cloud-Virtualisierung |
| KVM | Linux Kernel | Linux-basierte Virtualisierung |

Ein Praxisbeispiel wäre ein Unternehmen, das auf einem physischen Server mehrere VMs betreibt: eine VM als Domänencontroller, eine VM als Fileserver und eine VM als Datenbankserver. Alle Systeme laufen getrennt, verwenden aber dieselbe Hardware.

---

## Type 2 Hypervisor

Ein **Type 2 Hypervisor** wird auch **Hosted Hypervisor** genannt. Er läuft als normale Anwendung auf einem bestehenden Betriebssystem. Dieses Host-Betriebssystem kann zum Beispiel Windows, Linux oder macOS sein.

```text
+-----------------------------+
| Virtuelle Maschinen         |
+-----------------------------+
| Type 2 Hypervisor           |
+-----------------------------+
| Host-Betriebssystem         |
+-----------------------------+
| Physische Hardware          |
+-----------------------------+
```

Type 2 Hypervisoren eignen sich besonders für Schulungen, Entwicklung und Tests. Ein Entwickler kann zum Beispiel auf einem Windows-PC eine Linux-VM starten, ohne Linux direkt auf dem Computer installieren zu müssen.

Typische Beispiele sind:

| Produkt | Hersteller / Projekt | Einsatzbereich |
|---|---|---|
| Oracle VirtualBox | Oracle | Tests, Lernen, Entwicklung |
| VMware Workstation | VMware / Broadcom | Desktop-Virtualisierung |
| VMware Fusion | VMware / Broadcom | VMs auf macOS |
| Parallels Desktop | Parallels | Windows-VMs auf macOS |

Der Nachteil ist, dass Type 2 Hypervisoren meist etwas weniger performant sind. Der Grund dafür ist die zusätzliche Schicht des Host-Betriebssystems.

---

## Technische Funktionsweise

Der Hypervisor verteilt die Ressourcen des Hosts auf die virtuellen Maschinen. Dabei verwaltet er vor allem CPU, RAM, Speicher und Netzwerk.

Bei der **CPU-Virtualisierung** bekommen VMs virtuelle CPUs. Der Hypervisor ordnet diese den echten CPU-Kernen zu. Moderne Prozessoren unterstützen das durch Hardwarefunktionen wie Intel VT-x oder AMD-V.

Bei der **Speicher-Virtualisierung** bekommt jede VM einen eigenen RAM-Bereich. Der Hypervisor verhindert, dass eine VM auf den Speicherbereich einer anderen VM zugreift.

Bei der **Storage-Virtualisierung** verwendet eine VM meist virtuelle Festplatten. Diese liegen auf dem Host als Datei oder Volume. Beispiele für solche Formate sind VHDX bei Hyper-V, VMDK bei VMware oder QCOW2 bei KVM/QEMU.

Bei der **Netzwerk-Virtualisierung** erhalten VMs virtuelle Netzwerkkarten. Diese können über virtuelle Switches mit anderen VMs oder mit dem echten Netzwerk verbunden werden.

---

## Vergleich Type 1 und Type 2

| Merkmal | Type 1 Hypervisor | Type 2 Hypervisor |
|---|---|---|
| Position | Direkt auf Hardware | Auf Host-Betriebssystem |
| Performance | Meist höher | Meist geringer |
| Einsatzgebiet | Server, Rechenzentrum, Cloud | Desktop, Tests, Entwicklung |
| Einrichtung | Etwas aufwendiger | Einfacher |
| Beispiele | ESXi, Hyper-V, Proxmox, KVM | VirtualBox, VMware Workstation, Parallels |

---

## Vorteile und Grenzen

Hypervisoren ermöglichen eine bessere Auslastung der Hardware. Außerdem können neue Systeme schnell erstellt, kopiert oder gesichert werden. Besonders praktisch sind Snapshots, mit denen ein Zustand einer VM gespeichert und später wiederhergestellt werden kann.

Es gibt aber auch Grenzen. Eine VM ist meist nicht ganz so schnell wie ein direkt installiertes Betriebssystem. Außerdem entsteht zusätzlicher Verwaltungsaufwand. Wenn der physische Host ausfällt, sind alle darauf laufenden VMs betroffen. In professionellen Umgebungen werden deshalb Backups, Cluster und Hochverfügbarkeit verwendet.

---

## Fazit

Hypervisoren sind die Grundlage der klassischen Virtualisierung. Sie ermöglichen es, mehrere virtuelle Maschinen auf einer physischen Hardware zu betreiben und deren Ressourcen kontrolliert zu verwalten.

Der wichtigste Unterschied ist die Position im System. Type 1 Hypervisoren laufen direkt auf der Hardware und eignen sich besonders für produktive Serverumgebungen. Type 2 Hypervisoren laufen auf einem bestehenden Betriebssystem und sind besonders praktisch für lokale Tests, Schulungen und Entwicklung.

---

## Quellen

- IBM: [What Are Hypervisors?](https://www.ibm.com/think/topics/hypervisors)
- Microsoft Learn: [Hyper-V virtualization in Windows Server and Windows](https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/overview)
- Oracle: [About Oracle VirtualBox](https://www.virtualbox.org/manual/topics/Introduction.html)
- VMware: [What is a Hypervisor?](https://www.vmware.com/topics/hypervisor)
