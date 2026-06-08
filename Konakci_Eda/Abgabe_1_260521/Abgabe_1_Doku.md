# Full-Virtualization vs. Paravirtualization

## Was ist Virtualisierung?
Virtualisierung ist ein zentraler Bestandteil moderner IT-Infrastrukturen und bildet die Grundlage für Technologien wie Cloud Computing, flexible Rechenzentren sowie 
Test- und Sicherheitsumgebungen. Sie ermöglicht es, mehrere virtuelle Maschinen (VMs) auf einem einzigen physischen Host-System zu betreiben. Dabei simuliert jede VM ein vollständiges 
Computersystem. Dadurch können Hardware-Ressourcen effizienter genutzt, Betriebskosten reduziert und Administrationsprozesse vereinfacht werden.  
Im Kern schafft die Virtualisierung eine Abstraktionsschicht zwischen der physischen Hardware und dem Betriebssystem. Diese Schicht wird als Hypervisor oder Virtual Machine Monitor (VMM)
bezeichnet. Der Hypervisor verwaltet die virtuellen Maschinen und ermöglicht die Ausführung mehrerer Betriebssysteme auf derselben Hardware. 

Grundsätzlich wird zwischen zwei wichtigen Virtualisierungsansätzen unterschieden:  
 - Full-Virtualization (Vollvirtualisierung)
 - Paravirtualisierung

Bei beiden Verfahren wird dasselbe Ziel verfolgt: mehrere Betriebssysteme parallel auf derselben Hardware zu betreiben. Der wesentliche Unterschied besteht darin, wie stark das
Gastbetriebssystem mit dem Hypervisor zusammenarbeitet und wie die Hardware virtualisiert wird. 

## Full-Virtualization
Bei der Full-Virtualization wird die Hardware eines Computers vollständig simuliert. Dadurch entsteht für das Gastbetriebssystem der Eindruck, als würde es auf einem echten Computer laufen. Das
bedeutet, dass normale Betriebssysteme wie Windows, Linux oder macOS ohne Änderungen in einer virtuellen Maschine installiert und genutzt werden können. Dabei erkennt das Betriebssystem nicht,
dass es sich in einer virtualisierten Umgebung befindet.  
Die Virtualisierung wird durch einen Hypervisor gesteuert. Dieser bildet die benötigte Hardware wie Prozessor, Arbeitsspeicher oder Netzwerkkarten virtuell nach und verwaltet die einzelnen
virtuellen Maschinen.  
Der große Vorteil der Full-Virtualization besteht darin, dass bestehende Systeme unkompliziert übernommen werden können, ohne dass Anpassungen am Betriebssystem erforderlich sind. Dadurch eignet
sich dieses Verfahren besonders für flexible und einfach verwaltbare IT-Umgebungen. 

### Technische Funktionsweise
Der Hypervisor fängt privilegierte Hardwarezugriffe der virtuellen Maschine ab und übersetzt diese in sichere Operationen auf der realen Hardware. Zum Einsatz kommen dabei zwei zentrale Techniken:
Binary Translation sowie Hardware-Assisted Virtualization.  

***Aufbau einer Full-Virtualization-Umgebung:***
```
+-----------------------------+
| Gastbetriebssystem          |
| (unverändert)               |
+-----------------------------+
| Virtuelle Hardware          |
+-----------------------------+
| Hypervisor                  |
+-----------------------------+
| Physische Hardware          |
+-----------------------------+
```
***Typische Produkte und Beispiele***

| Produkt     | Hersteller                       | Besonderheit                      |
| ----------- | -------------------------------- | --------------------------------- |
| VMware ESXi | VMware                           | Marktführer im Enterprise-Bereich |
| Hyper-V     | Microsoft                        | Integration in Windows Server     |
| VirtualBox  | Oracle VirtualBox                | Kostenlos und weit verbreitet     |
| KVM         | KVM Linux Project                | Linux-basierte Virtualisierung    |


## Paravirtualization
Bei der Paravirtualisierung wird das Gastbetriebssystem so angepasst, dass es direkt mit dem Hypervisor zusammenarbeiten kann. Das Betriebssystem weiß somit, dass es in einer virtuellen
Umgebung läuft. Im Gegensatz zur Full-Virtualization muss die Hardware dabei nicht vollständig simuliert werden. Stattdessen kommuniziert das Betriebssystem über spezielle Schnittstellen,
sogenannte Hypercalls, direkt mit dem Hypervisor. Dadurch können viele aufwendige Hardware-Emulationen vermieden werden.  
Der Vorteil dieser Methode ist eine bessere Performance, da Prozesse schneller und effizienter ausgeführt werden können. Allerdings müssen die verwendeten Betriebssysteme für diese Art der
Virtualisierung angepasst oder entsprechend unterstützt werden.

### Technische Funktionsweise
Das Gastbetriebssystem verwendet spezielle sogenannte Hypercalls statt direkter Hardwarezugriffe. Ein Hypercall funktioniert ähnlich wien ein Systemaufruf zwischen Betriebssystem und Kernel.  

***Aufbau Paravirtualization***
```
+-----------------------------+
| Angepasstes Gast-OS         |
| mit Hypercalls              |
+-----------------------------+
| Hypervisor                  |
+-----------------------------+
| Physische Hardware          |
+-----------------------------+
```
***Typische Produkte und Beispiele***

| Produkt/Projekt                                              | Beschreibung                                     |
| ------------------------------------------------------------ | ------------------------------------------------ |
| Xen Project                                                  | Bekanntes Paravirtualisierungsprojekt            |
| VirtIO                                                       | Paravirtualisierte Treiber für KVM               |
| VMware Tools                                                 | Optimierte Treiber für virtuelle Maschinen       |
| Xen PV Drivers                                               | Paravirtualisierte Netzwerk- und Storage-Treiber |


## Einsatzgebiete in der Praxis

| Full-Virtualization | Paravirtualization |
|---|---|
| Cloud-Plattformen | Hochperformante Cloud-Systeme |
| Unternehmensserver | Netzwerkvirtualisierung |
| Testumgebungen | Datenbankserver |
| Desktop-Virtualisierung | Optimierte Linux-Umgebungen |

## Quellen  
- https://www.geeksforgeeks.org/operating-systems/difference-between-full-virtualization-and-paravirtualization/
- https://www.techtarget.com/searchitoperations/tip/Full-virtualization-vs-paravirtualization-Key-differences
- https://biztechmagazine.com/article/2024/07/what-is-paravirtualization-perfcon
- https://de.scribd.com/document/719043044/Difference-between-Full-Virtualization-and-Paravirtualization
