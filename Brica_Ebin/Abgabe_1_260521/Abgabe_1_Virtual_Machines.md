# Virtual Machines

> Ausarbeitung zum Thema Virtualisierung und virtuelle Maschinen von Brica Ebin am 21.05.2026

---

## Inhaltsverzeichnis

1. Einleitung
2. Grundprinzip einer Virtual Machine
3. Technische Funktionsweise
4. Arten von Hypervisoren
5. Bekannte Produkte und Tools
6. Einsatzgebiete von Virtual Machines
7. Vorteile und Nachteile
8. Vergleich zwischen physischem und virtuellem System
9. Praxisbeispiel
10. Fazit
11. Quellen

---

## Einleitung

Virtual Machines (VMs) sind virtuelle Computersysteme, die innerhalb eines bestehenden Computers ausgeführt werden. Obwohl sie nicht direkt auf eigener Hardware laufen, verhalten sie sich wie eigenständige physische Rechner.
Jede virtuelle Maschine besitzt ein eigenes Betriebssystem, eigene virtuelle Hardware und kann unabhängig vom eigentlichen Host-System verwendet werden.

Die Virtualisierung ist heute ein wichtiger Bestandteil moderner IT-Infrastrukturen. Unternehmen verwenden virtuelle Maschinen, um Server effizienter zu nutzen, Kosten zu reduzieren und mehrere Systeme gleichzeitig auf einer Hardware zu betreiben.
Auch im privaten Bereich kommen virtuelle Maschinen häufig zum Einsatz, beispielsweise zum Testen neuer Betriebssysteme oder zum sicheren Ausführen unbekannter Software. Weiters, sind virtuelle Maschinen bei Bildungseinrichtungen
wie z.B der Hochschule Burgenland sehr beliebt, da es den Studenten ermöglicht sich auf diesen Systemen "auszutoben".

Besonders im Bereich Cloud Computing spielen Virtual Machines eine zentrale Rolle. Große Anbieter wie Amazon Web Services (AWS), Microsoft Azure oder Google Cloud basieren zu einem großen Teil auf Virtualisierungstechnologien.

---

## Grundprinzip einer Virtual Machine

Eine virtuelle Maschine läuft nicht direkt auf der physischen Hardware. Zwischen Hardware und virtueller Maschine befindet sich eine zusätzliche Software-Schicht, der sogenannte Hypervisor.

Der Hypervisor verwaltet die verfügbaren Ressourcen des Computers:

* Prozessorleistung (CPU)
* Arbeitsspeicher (RAM)
* Festplattenspeicher
* Netzwerkverbindungen

Dadurch können mehrere virtuelle Maschinen gleichzeitig auf einem einzigen physischen System betrieben werden.

### Vereinfachte Darstellung

```text
+----------------------------------+
| Virtuelle Maschine 1 (Linux)    |
+----------------------------------+
| Virtuelle Maschine 2 (Windows)  |
+----------------------------------+
| Hypervisor                      |
+----------------------------------+
| Physische Hardware              |
+----------------------------------+
```

Jede virtuelle Maschine arbeitet unabhängig von den anderen Systemen. Ein Fehler innerhalb einer VM beeinflusst normalerweise weder die anderen virtuellen Maschinen noch das eigentliche Host-System.

---

## Technische Funktionsweise

Eine virtuelle Maschine erhält virtuelle Hardware zugewiesen. Dazu gehören beispielsweise:

* virtuelle CPU
* virtueller Arbeitsspeicher
* virtuelle Netzwerkkarten
* virtuelle Festplatten

Der Hypervisor übersetzt die Zugriffe der virtuellen Maschinen auf die reale Hardware des Hosts.

Wenn eine VM beispielsweise 4 GB RAM benötigt, reserviert der Hypervisor diesen Speicherbereich auf dem physischen Rechner. Dasselbe gilt für Prozessorzeit oder Speicherplatz.

Moderne Prozessoren von Intel und AMD besitzen spezielle Virtualisierungstechnologien wie:

* Intel VT-x
* AMD-V

Diese Funktionen verbessern die Leistung und Sicherheit virtueller Maschinen erheblich.

Virtuelle Maschinen werden häufig in Form einzelner Dateien gespeichert. Dadurch können sie leicht kopiert, gesichert oder auf andere Systeme übertragen werden.

---

## Arten von Hypervisoren

Hypervisoren werden grundsätzlich in zwei Typen eingeteilt.

| Typ               | Beschreibung                          | Beispiele                      |
| ----------------- | ------------------------------------- | ------------------------------ |
| Type-1 Hypervisor | Läuft direkt auf der Hardware         | VMware ESXi, Hyper-V, Proxmox  |
| Type-2 Hypervisor | Läuft innerhalb eines Betriebssystems | VirtualBox, VMware Workstation |

### Type-1 Hypervisor

Ein Type-1 Hypervisor wird direkt auf der Hardware installiert und benötigt kein zusätzliches Betriebssystem. Dadurch ist die Leistung meist besser und die Verwaltung effizienter.

Diese Variante wird hauptsächlich in Rechenzentren und Unternehmen verwendet.

Bekannte Beispiele:

* VMware ESXi
* Microsoft Hyper-V
* Proxmox VE
* Xen

### Type-2 Hypervisor

Ein Type-2 Hypervisor läuft als normales Programm innerhalb eines Betriebssystems.

Beispiel:

```text
Windows → VirtualBox → Linux VM
```

Diese Variante eignet sich besonders für:

* Testumgebungen
* Entwicklung
* Schulungen
* private Nutzung

---

## Bekannte Produkte und Tools

### VMware

VMware gehört zu den bekanntesten Herstellern im Bereich Virtualisierung. Besonders VMware ESXi wird häufig in Unternehmen und Rechenzentren eingesetzt.

### Oracle VirtualBox

VirtualBox ist eine kostenlose Virtualisierungslösung von Oracle. Sie wird oft im privaten Bereich oder im Unterricht verwendet.

Vorteile:

* kostenlos
* einfach zu bedienen
* unterstützt viele Betriebssysteme

### Microsoft Hyper-V

Hyper-V ist die Virtualisierungslösung von Microsoft und in vielen Windows-Versionen integriert.

### KVM

KVM (Kernel-based Virtual Machine) ist eine Linux-basierte Virtualisierungstechnologie und wird häufig bei Linux-Servern eingesetzt.

### Proxmox VE

Proxmox ist eine Open-Source-Plattform zur Verwaltung virtueller Maschinen und Container. Besonders in kleineren Unternehmen und Homelabs ist Proxmox sehr beliebt.

---

## Einsatzgebiete von Virtual Machines

Virtuelle Maschinen werden heute in vielen Bereichen verwendet.

### Servervirtualisierung

Mehrere Server können auf einer einzigen physischen Maschine betrieben werden. Dadurch sinken:

* Stromkosten
* Hardwarekosten
* Wartungsaufwand

### Cloud Computing

Cloud-Anbieter verwenden tausende virtuelle Maschinen in ihren Rechenzentren. Kunden können virtuelle Server flexibel mieten und konfigurieren.

### Softwareentwicklung und Testing

Entwickler testen Programme häufig in verschiedenen Betriebssystemen gleichzeitig.

Beispiel:

* Windows 11 Host
* Ubuntu VM
* Windows Server VM

### IT-Sicherheit

Virtuelle Maschinen ermöglichen sichere Testumgebungen. Verdächtige Programme können isoliert ausgeführt werden, ohne das eigentliche System zu gefährden.

### Schulung und Ausbildung

In Schulen und Fachhochschulen werden virtuelle Maschinen verwendet, um Netzwerke, Server oder Betriebssysteme gefahrlos zu testen.

---

## Vorteile und Nachteile

| Vorteile                     | Nachteile                  |
| ---------------------------- | -------------------------- |
| bessere Hardwareauslastung   | etwas geringere Leistung   |
| mehrere Systeme gleichzeitig | hoher RAM-Bedarf           |
| einfache Backups             | komplexere Verwaltung      |
| sichere Testumgebungen       | mögliche Sicherheitslücken |
| flexible Skalierung          | abhängig vom Host-System   |

---

## Vergleich zwischen physischem und virtuellem System

| Physischer Computer      | Virtuelle Maschine              |
| ------------------------ | ------------------------------- |
| direkte Hardware         | virtuelle Hardware              |
| eigenes Gerät notwendig  | mehrere Systeme auf einem Gerät |
| weniger flexibel         | leicht kopierbar                |
| Hardwaretausch aufwendig | einfache Migration              |

---

## Praxisbeispiel

Ein Student verwendet Windows 11 auf seinem Laptop, benötigt jedoch Linux für Netzwerk- und Serverübungen.

Anstatt einen zweiten Computer zu kaufen, installiert er VirtualBox und erstellt eine Ubuntu-VM.

Dadurch kann er:

* Linux verwenden
* Netzwerke testen
* Server konfigurieren
* Snapshots erstellen
* und bei Fehlern die VM einfach zurücksetzen

Dieses Prinzip wird auch in Unternehmen genutzt, allerdings meist mit professionellen Lösungen wie VMware oder Proxmox.

---

## Fazit

Virtual Machines sind ein zentraler Bestandteil moderner IT-Systeme. Sie ermöglichen es, mehrere Betriebssysteme gleichzeitig auf einer Hardware auszuführen und Ressourcen effizient zu nutzen.

Besonders im Bereich Cloud Computing, Servervirtualisierung und Softwareentwicklung sind virtuelle Maschinen heute kaum mehr wegzudenken.

Durch Hypervisoren können virtuelle Systeme sicher voneinander getrennt und flexibel verwaltet werden. Trotz eines gewissen Performanceverlusts überwiegen die Vorteile deutlich.

Virtualisierung wird in Zukunft weiterhin eine wichtige Rolle spielen, insbesondere in Kombination mit Cloud-Technologien und automatisierten Rechenzentren.

---

# Quellen

* Oracle VirtualBox Documentation: [https://www.virtualbox.org/wiki/Technical_documentation](https://www.virtualbox.org/wiki/Technical_documentation)
* Microsoft Hyper-V Documentation: [https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/overview](https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/overview)
* Proxmox VE Documentation: [https://pve.proxmox.com/wiki/Main_Page](https://pve.proxmox.com/wiki/Main_Page)
* Red Hat – What is a Virtual Machine?: [https://www.redhat.com/en/topics/virtualization/what-is-a-virtual-machine](https://www.redhat.com/en/topics/virtualization/what-is-a-virtual-machine)
