# Hyper-Converged Infrastructure (HCI)

## Was ist Hyper-Converged Infrastructure?

Hyper-Converged Infrastructure (HCI), zu Deutsch „hyperkonvergente Infrastruktur", bezeichnet einen modernen IT-Infrastrukturansatz, bei dem **Rechenleistung (Compute), Speicher (Storage) und Netzwerk (Networking)** in einem einzigen, softwaredefinierten System zusammengeführt werden. Anstatt diese drei Schichten wie traditionell üblich auf separater, spezialisierter Hardware zu betreiben, laufen sie gemeinsam auf handelsüblichen x86-Standardservern – sogenannten **Commodity-Hardware-Nodes**.

Der Begriff „hyper" leitet sich von der Hypervisor-Technologie ab, die das Herzstück dieser Architektur bildet. Alle Funktionen – also Virtualisierung, Speicherverwaltung und Netzwerksteuerung – werden durch eine gemeinsame Softwareschicht (den sogenannten **Hypervisor** oder eine spezialisierte HCI-Software) koordiniert. Das Ergebnis ist ein hochintegriertes, einfach skalierbares System, das sich zentral über eine einzige Management-Oberfläche verwalten lässt.

HCI ist die Weiterentwicklung der sogenannten **Converged Infrastructure (CI)**, bei der Server, Storage und Netzwerk zwar als Bundle geliefert, aber noch auf getrennter, dedizierter Hardware betrieben wurden. Bei HCI entfällt diese physische Trennung vollständig – alle Ressourcen sind softwareseitig abstrahiert und werden dynamisch über den gesamten Cluster hinweg verteilt.

---

## Kontext und Einsatzgebiete

HCI wird primär im **Enterprise-Umfeld** eingesetzt, also in mittelgroßen bis großen Unternehmen und Rechenzentren, die eine modernisierte, skalierbare und kosteneffiziente Infrastruktur benötigen. Typische Anwendungsfälle umfassen:

- **Virtual Desktop Infrastructure (VDI):** HCI eignet sich hervorragend für den Betrieb tausender virtueller Desktops, da Rechenleistung und Storage eng verzahnt sind und zentral skaliert werden können.
- **Private und Hybrid Cloud:** Unternehmen nutzen HCI, um intern eine Cloud-ähnliche Infrastruktur aufzubauen, die sich nahtlos in Public-Cloud-Dienste (z. B. AWS, Azure) integrieren lässt.
- **Edge Computing:** Da HCI-Nodes kompakt und einfach zu verwalten sind, werden sie auch an entfernten Standorten (Filialen, Fabrikhallen) eingesetzt, wo keine dedizierte IT-Abteilung vor Ort ist.
- **Backup und Disaster Recovery:** Die integrierte Replikation zwischen HCI-Nodes oder Standorten ermöglicht effiziente Backup-Strategien.
- **Datenbank- und Applikationsbetrieb:** Klassische Enterprise-Applikationen (ERP, CRM) profitieren von der hohen I/O-Performance und der einfachen Skalierbarkeit.

Der Trend zu HCI ist eng mit der Verbreitung von **Cloud-Native-Architekturen** und **DevOps-Prozessen** verbunden: Unternehmen wollen die Agilität der Public Cloud intern abbilden, ohne Daten und Kontrolle abzugeben.

---

## Technische Funktionsweise

### Architektur

Ein HCI-System besteht aus mehreren **Nodes** (physische Server), die zu einem **Cluster** zusammengeschlossen werden. Jeder Node bringt eigene CPU, RAM und lokale Speichermedien (in der Regel NVMe-SSDs oder SSDs/HDDs) mit. Die HCI-Software sorgt dafür, dass alle lokalen Speicherressourcen zu einem **gemeinsamen, verteilten Speicherpool** zusammengefasst werden, auf den alle Nodes im Cluster zugreifen können.

### Verteilter Speicher (Distributed Storage)

Das Kernstück einer HCI-Lösung ist die **verteilte Speicher-Engine**. Diese übernimmt folgende Aufgaben:

- **Datenverteilung:** Daten werden in Blöcke aufgeteilt und auf mehrere Nodes repliziert oder per Erasure Coding (ähnlich RAID, aber softwaredefiniert) verteilt. Damit ist auch beim Ausfall eines Nodes keine Datenverlust möglich.
- **Datenlokalisierung (Data Locality):** Die Software versucht, die Daten einer virtuellen Maschine auf dem gleichen Node zu speichern, auf dem die VM auch ausgeführt wird. Das minimiert Netzwerklast und maximiert die I/O-Performance.
- **Deduplication & Kompression:** Viele HCI-Lösungen bieten inline-Deduplizierung und Datenkompression, um den tatsächlich genutzten Speicherplatz zu reduzieren.
- **Tiering:** Häufig genutzte Daten (Hot Data) verbleiben auf schnellen NVMe-SSDs, seltener genutzte Daten (Cold Data) werden auf langsamere, günstigere Medien ausgelagert.

### Hypervisor und Virtualisierung

Die Virtualisierungsschicht (Hypervisor) abstrahiert die physische Hardware und stellt virtuelle Maschinen (VMs) oder Container bereit. Der Hypervisor kommuniziert direkt mit der Storage-Engine, um I/O-Anfragen effizient zu verarbeiten. Bei manchen Lösungen (z. B. Nutanix AHV) ist der Hypervisor bereits in die HCI-Plattform integriert.

### Netzwerk

HCI-Cluster nutzen üblicherweise **10-GbE- bis 100-GbE-Netzwerke** für die interne Node-Kommunikation. Für latenzempfindliche Storage-Operationen kann **RDMA (Remote Direct Memory Access)** über RoCE oder InfiniBand eingesetzt werden, das Daten direkt im Arbeitsspeicher überträgt und so CPU-Overhead minimiert.

### Skalierung

HCI skaliert **horizontal (Scale-Out)**: Soll die Kapazität erhöht werden, fügt man einfach weitere Nodes zum Cluster hinzu. Die Software erkennt den neuen Node automatisch, nimmt ihn in den Speicherpool auf und verteilt die Last neu. Es ist keine komplexe Reintegration oder Downtime erforderlich.

---

## Gängige Protokolle, Produkte, Hersteller und Projekte

### Protokolle & Standards

| Protokoll / Standard | Beschreibung |
|---|---|
| **NVMe-oF** (NVMe over Fabrics) | Hochperformanter Zugriff auf Storage über das Netzwerk (Ethernet, InfiniBand) |
| **iSCSI** | Block-Storage-Protokoll über IP-Netzwerke; wird von vielen HCI-Lösungen als Backend oder Frontend genutzt |
| **SMB 3.x / NFS v4.1+** | File-basierte Protokolle für geteilten Dateizugriff innerhalb eines HCI-Clusters |
| **VXLAN / Geneve** | Overlay-Netzwerkprotokolle für Software-Defined Networking im HCI-Kontext |
| **RDMA / RoCEv2** | Netzwerkprotokoll für latenzarme, CPU-schonende Datentransfers zwischen Nodes |

### Kommerzielle Produkte & Hersteller

| Hersteller | Produkt | Besonderheit |
|---|---|---|
| **Nutanix** | Nutanix Cloud Platform (ehemals NDFS/AOS) | Marktführer im HCI-Segment mit eigenem Hypervisor (AHV), breite Cloud-Integration |
| **VMware/Broadcom** | VMware vSAN | Tief integriert in vSphere-Ökosystem; weit verbreitet in bestehenden VMware-Umgebungen |
| **Microsoft** | Azure Stack HCI | HCI-Plattform mit Windows Server / Hyper-V; native Azure-Integration |
| **Dell Technologies** | VxRail | Basiert auf VMware vSAN; als Appliance-Lösung vorkonfiguriert geliefert |
| **HPE** | SimpliVity / Alletra dHCI | Fokus auf Backup-Performance und Datenkompression |
| **Cisco** | HyperFlex | Eigener HCI-Stack auf Cisco UCS Hardware |

### Open-Source-Projekte

| Projekt | Beschreibung |
|---|---|
| **Ceph** | Weit verbreitete verteilte Storage-Plattform; bildet das Storage-Backend vieler HCI-Lösungen |
| **Proxmox VE** | Open-Source-Virtualisierungsplattform mit integriertem Ceph-Support und HCI-Fähigkeiten |
| **OpenStack** | Cloud-Management-Plattform, die häufig mit Ceph als Storage-Backend kombiniert wird |
| **Harvester** | Kubernetes-natives Open-Source-HCI auf Basis von Longhorn, KubeVirt und Rancher |
| **oVirt / Red Hat Virtualization** | Enterprise-Virtualisierungsplattform mit integriertem Gluster-Storage für HCI-Szenarien |

---

## Vor- und Nachteile im Überblick

**Vorteile:**
- Einfacheres Management durch eine zentrale Oberfläche
- Schnelle, lineare Skalierung durch Hinzufügen weiterer Nodes
- Reduktion von Hardware-Komplexität (kein separates SAN/NAS nötig)
- Hohe Verfügbarkeit durch integrierte Datenredundanz
- Günstigere Commodity-Hardware statt proprietärer Speziallösungen

**Nachteile:**
- Rechenleistung und Storage müssen immer gemeinsam skaliert werden (kein unabhängiges Scale-Up einzelner Ressourcen)
- Höherer Netzwerk-Overhead durch die verteilte Storage-Architektur
- Vendor-Lock-in bei kommerziellen Lösungen (insbesondere Nutanix, VMware vSAN)
- Kann für sehr I/O-intensive Workloads (z. B. große Datenbanken) weniger effizient sein als dediziertes All-Flash-SAN

---

## Zusammenfassung

Hyper-Converged Infrastructure ist eine softwaregesteuerte Konsolidierung von Compute, Storage und Networking auf Standardhardware. Sie vereinfacht den Betrieb von Rechenzentren erheblich, indem komplexe, voneinander getrennte Systeme in einem einheitlichen Cluster-Ansatz zusammengeführt werden. Durch horizontale Skalierbarkeit, integrierte Redundanz und zentrales Management ist HCI heute eine der meistverbreiteten Plattformen für private Clouds, VDI-Umgebungen und moderne Enterprise-Workloads. Marktführer wie Nutanix und VMware (vSAN) sowie Open-Source-Projekte wie Ceph und Proxmox zeigen die Bandbreite verfügbarer Lösungen – von vollständig integrierten Appliances bis hin zu flexiblen, selbst zusammenstellbaren Plattformen.


## Quellen

https://de.wikipedia.org/wiki/Hyperkonvergente_Infrastruktur

https://www.nutanix.com/de/info/virtualization/hyperconverged-infrastructure

https://www.intel.com/content/www/us/en/learn/what-is-hyperconverged-infrastructure.html

