# Performance Impact with Virtualization

## Was ist das?

Virtualisierung erlaubt es, physische Hardware durch eine Software-Schicht — den **Hypervisor** — in mehrere unabhängige virtuelle Maschinen (VMs) aufzuteilen. Jede VM verhält sich wie ein echter Rechner mit eigenem Betriebssystem. Diese Abstraktionsschicht verursacht jedoch unvermeidlich einen **Leistungsverlust (Performance Impact)**, da CPU-Befehle, Speicherzugriffe und I/O-Operationen nicht mehr direkt auf der Hardware laufen, sondern durch den Hypervisor vermittelt werden.

## Kontext

Virtualisierung ist in Rechenzentren und bei Cloud-Anbietern wie AWS, Azure oder Google Cloud der Standard. Sie ermöglicht bessere Hardware-Auslastung, einfaches Backup und flexible Ressourcenzuteilung. Der Performance Impact ist besonders kritisch bei latenzempfindlichen Workloads wie Datenbanken oder Echtzeit-Systemen.

## Technische Funktionsweise

Es gibt zwei Hypervisor-Typen: **Typ 1** (Bare-Metal) läuft direkt auf der Hardware (z.B. VMware ESXi, Microsoft Hyper-V, KVM) und hat geringen Overhead. **Typ 2** (Hosted) läuft auf einem Host-Betriebssystem (z.B. VirtualBox, VMware Workstation) und hat durch die zusätzliche Schicht mehr Overhead.

**CPU:** Moderne CPUs bieten Hardware-Unterstützung für Virtualisierung — Intel VT-x und AMD-V. Damit können privilegierte Befehle direkt ausgeführt statt in Software emuliert werden. Der CPU-Overhead sinkt dadurch von bis zu 40 % auf typischerweise 1–5 %.

**Memory:** Der Hypervisor muss Speicheradressen zweistufig übersetzen. Intel EPT und AMD NPT lösen das per Hardware — ohne diese Unterstützung muss der Hypervisor aufwändige Shadow Page Tables in Software verwalten. Weitere Quellen für Overhead sind Memory Ballooning und Memory Deduplication.

**I/O:** Festplatten- und Netzwerkzugriffe laufen bei vollständiger Emulation langsam. Paravirtualisierung (z.B. VirtIO-Treiber unter KVM) behebt das: Die VM kommuniziert über optimierte Treiber direkt mit dem Hypervisor und erreicht nahezu native I/O-Leistung.

## Produkte und Tools

Gängige Typ-1-Hypervisoren sind VMware ESXi, Microsoft Hyper-V, KVM (Linux) und Xen. Typ-2-Hypervisoren sind Oracle VirtualBox und VMware Workstation. Für Performance-Monitoring kommen Tools wie vSphere Performance Charts, Prometheus und Grafana zum Einsatz. Benchmarks werden häufig mit SPECvirt oder der Phoronix Test Suite durchgeführt.

## Vergleich mit Containern

Container (z.B. Docker) teilen sich den Kernel des Host-Systems und verursachen dadurch deutlich weniger Overhead als VMs. Sie starten in Millisekunden, bieten aber schwächere Isolation. VMs starten langsamer, sind dafür vollständig isoliert mit eigenem Kernel — besser geeignet für sicherheitskritische oder betriebssystemfremde Workloads.

## Reale Beispiele

AWS setzt seit dem Nitro System auf KVM mit Hardware-Offloading auf dedizierte Chips — der Overhead ist damit nahezu eliminiert. Bei Gaming-VMs unter Linux ermöglicht GPU-Passthrough (VFIO/KVM) nahezu native Grafik-Performance. Datenbank-Administratoren nutzen Paravirtualisierung und dedizierte Ressourcen-Zuteilung, um Latenz-Spitzen durch Overcommitting zu vermeiden.
