# Performance Impact with Virtualization: Warum entsteht Leistungsverlust?

## 1. Was ist Leistungsverlust

Bei **Performance Impact with Virtualization** geht es vor allem darum, warum ein System in einer virtualisierten Umgebung oft nicht exakt dieselbe Leistung erreicht wie direkt auf physischer Hardware. Eine virtuelle Maschine arbeitet nicht direkt mit der Hardware. Zwischen Anwendung, Betriebssystem und physischem Server befindet sich eine zusätzliche Verwaltungsschicht, der **Hypervisor**.

Dieser Hypervisor ermöglicht zwar, dass mehrere virtuelle Maschinen auf einem Host laufen, verursacht aber auch zusätzlichen Aufwand. Er muss CPU-Zeit verteilen, Arbeitsspeicher verwalten, Festplattenzugriffe koordinieren und Netzwerkverkehr weiterleiten. Genau dieser zusätzliche Verwaltungsaufwand kann zu Leistungsverlust führen. Man spricht dabei oft von **Virtualisierungs-Overhead**.

Der Leistungsverlust entsteht also nicht, weil virtuelle Maschinen „langsam“ sind, sondern weil mehrere Systeme die selben Ressourcen nutzen und der Hypervisor ständig entscheiden muss, welche VM wann Zugriff auf CPU, RAM, Storage oder Netzwerk bekommt.

---

## 2. Typ-1- und Typ-2-Hypervisor im Vergleich

Ein wichtiger Faktor für den Performance Impact ist die Art des Hypervisors.

Ein **Typ-1-Hypervisor**, auch **Bare-Metal-Hypervisor** genannt, läuft direkt auf der physischen Hardware. Beispiele sind **VMware ESXi**, **Microsoft Hyper-V**, **KVM** (Kernel-based Virtual Machine), **Xen** oder **Proxmox VE**. Da dieser Typ von Hypervisor ohne zusätzliches Host-Betriebssystem direkt mit der Hardware arbeitet, ist der Leistungsverlust meist geringer als bei einem Typ-2-Hypervisor. Typ-1-Hypervisor werden deshalb häufig in Rechenzentren, Serverumgebungen und Cloud-Plattformen eingesetzt.

Ein **Typ-2-Hypervisor** läuft dagegen auf einem normalen Betriebssystem, zum Beispiel auf Windows, macOS oder Linux. Beispiele sind **VirtualBox**, **VMware Workstation** oder **Parallels Desktop**. Hier liegt zwischen VM und Hardware nicht nur der Hypervisor, sondern zusätzlich noch das Host-Betriebssystem. Dadurch entstehen mehr Zwischenschritte. Wenn eine VM zum Beispiel auf eine Festplatte zugreifen möchte, läuft der Zugriff über die VM, den Typ-2-Hypervisor, das Host-Betriebssystem und erst dann zur echten Hardware. Dadurch ist der Overhead meist höher als bei Typ 1.

Vereinfacht:

```text
Typ-1-Hypervisor:

VMs
↓
Hypervisor
↓
Hardware
```

```text
Typ-2-Hypervisor:

VMs
↓
Hypervisor-Anwendung
↓
Host-Betriebssystem
↓
Hardware
```

Für Server ist Typ 1 meistens leistungsfähiger und stabiler. Typ 2 eignet sich gut für lokale Tests, Schulungen, Entwicklung oder Laborumgebungen.

---

## 3. Wie entsteht Leistungsverlust bei der CPU?

Bei der CPU entsteht Leistungsverlust vor allem durch **Scheduling**. Jede VM bekommt virtuelle CPUs, sogenannte **vCPUs**. Diese vCPUs sind aber keine eigenen physischen Prozessoren. Der Hypervisor muss sie auf die echten CPU-Kerne des Hosts verteilen.

Wenn wenige VMs laufen und genug CPU-Kerne vorhanden sind, ist der Leistungsverlust gering. Problematisch wird es, wenn zu viele VMs gleichzeitig CPU-Leistung benötigen. Dann müssen VMs warten, bis sie wieder Rechenzeit bekommen.

Ein wichtiger Begriff ist hier **Steal Time**.

**Steal Time** beschreibt die Zeit, in der eine VM eigentlich CPU-Leistung nutzen möchte, diese aber nicht bekommt, weil der Hypervisor die physische CPU gerade einer anderen VM zugeteilt hat. Aus Sicht der VM sieht es so aus, als wäre die CPU „beschäftigt“, obwohl die VM selbst nichts aktiv berechnet. Die CPU-Zeit wird ihr sozusagen „gestohlen“.

Steal Time ist deshalb ein guter Hinweis auf CPU-Überlastung oder schlechtes Ressourcenmanagement im Virtualisierungshost.

---

## 4. Wie entsteht Leistungsverlust beim Arbeitsspeicher?

Auch RAM wird in der virtualisierten Umgebungen geteilt. Jede VM bekommt eine bestimmte Menge virtuellen Arbeitsspeicher. Der Hypervisor muss diesen Speicher dem physischen RAM des Hosts zuordnen.

Leistungsverlust entsteht besonders dann, wenn mehr RAM an VMs vergeben wird, als der Host tatsächlich frei zur Verfügung hat. Das nennt man **Memory Overcommitment**. Overcommitment kann funktionieren, wenn nicht alle VMs gleichzeitig ihren gesamten RAM nutzen. Wenn aber viele VMs gleichzeitig viel Speicher benötigen, muss der Hypervisor reagieren.

Ein wichtiger Begriff in diesem Zusammenhang ist **Ballooning**.

**Ballooning** ist eine Technik, mit der der Hypervisor Speicher von einer VM zurückholen kann. Dafür läuft in der VM ein spezieller Treiber, der sogenannte **Balloon Driver**. Dieser Treiber belegt innerhalb der VM absichtlich Speicher. Für das Gastbetriebssystem sieht es so aus, als würde eine Anwendung RAM verbrauchen. Dadurch gibt das Gastbetriebssystem weniger genutzten Speicher frei oder lagert Daten aus. Der Hypervisor kann diesen zurückgewonnenen Speicher anschließend einer anderen VM geben.

Das Problem: Wenn Ballooning zu stark genutzt wird, kann die Leistung deutlich sinken. Die VM hat dann weniger nutzbaren Arbeitsspeicher. Anwendungen müssen häufiger auf langsamere Speicherbereiche oder auf die Festplatte ausweichen. Besonders Datenbanken, große Anwendungen oder Systeme mit viel Cache reagieren empfindlich darauf.


---

## 5. Leistungsverlust bei Speicher und Netzwerk

Neben CPU und RAM sind **Speicher** und **Netzwerk** häufige Ursachen für Performance-Probleme.

Bei Speicher greitf eine VM meistens nicht direkt auf eine echte Festplatte zu, sondern auf eine virtuelle Festplatte. Jeder Lese- oder Schreibzugriff muss vom Hypervisor verarbeitet und an das physische Speicher-System weitergeleitet werden. Zusätzliche Funktionen wie Snapshots, Verschlüsselung oder Replikation können den Overhead weiter erhöhen.

Besonders problematisch sind viele kleine zufällige Schreibzugriffe, wie sie zB. bei Datenbanken auftreten. Wenn mehrere VMs gleichzeitig stark auf dieselben Datenträger zugreifen, entsteht I/O-Wartezeit. Die VM wartet dann nicht auf CPU, sondern auf Festplatten- oder SSD-Zugriffe.

Beim Netzwerk entsteht Leistungsverlust durch virtuelle Netzwerkkarten und virtuelle Switches. Eine VM sendet Netzwerkpakete nicht direkt über die physische Netzwerkkarte, sondern über eine virtuelle Netzwerkkarte zum virtuellen Switch des Hypervisors. Von dort gehen die Packete zur echten Netzwerkkarte. Dieser zusätzliche Weg kostet Rechenzeit und kann Latenz erzeugen.

---

## 6. Häufige Ursachen zusammengefasst

Leistungsverlust durch Virtualisierung entsteht vor allem durch:

```
+----------------------+--------------------------------------+
| Bereich              | Ursache des Leistungsverlusts         |
+----------------------+--------------------------------------+
| CPU                  | vCPU-Scheduling, Steal Time           |
| RAM                  | Overcommitment, Ballooning            |
| Storage              | virtuelle Disks, Snapshots, I/O-Stau  |
| Netzwerk             | virtuelle NICs, virtuelle Switches    |
| Typ-2-Hypervisor     | zusätzlicher Weg über Host-OS         |
| Falsche Konfiguration| zu viele vCPUs, zu wenig RAM, Treiber |
+----------------------+--------------------------------------+
```
(NIC...Network Interface Card)

Wichtig ist: Nicht jede Virtualisierung verursacht automatisch starken Leistungsverlust. Moderne Hardware unterstützt Virtualisierung sehr gut. Der Performance Impact wird vor allem dann sichtbar, wenn Ressourcen knapp werden, VMs falsch dimensioniert sind oder ungeeignete Treiber verwendet werden.

---

## 7. Beispiel

Angenommen, auf einem physischen Server laufen acht virtuelle Maschinen. Jede VM hat vier vCPUs, der Host besizt aber nur acht echte CPU-Kerne. Wenn alle VMs gleichzeitig stark rechnen wollen, streiten insgesamt 32 vCPUs um acht echte Kerne. Der Hypervisor muss ständig umschalten und verteilen. Einige VMs warten auf CPU-Zeit. In der VM sieht man dann erhöhte Steal Time.

Ähnlich beim RAM: Der Host hat 64 GB RAM, aber allen VMs zusammen wurden 96 GB zugewiesen. Solange nicht alle VMs den RAM nutzen, funktioniert das. Wenn aber mehrere VMs gleichzeitig viel Speicher benötigen, beginnt der Hypervisor mit Ballooning. Dadurch werden Anwendungen langsamer, weil ihnen effektiver Speicher fehlt.

Bei Storage kann zusätzlich passieren, dass mehrere VMs gleichzeitig große Datenmengen schreiben. Dann entsteht ein I/O-Engpass. Obwohl CPU und RAM vielleicht noch frei sind, fühlt sich die VM langsam an, weil sie auf Festplattenzugriffe wartet.

---

## 8. Fazit

Der Leistungsverlust bei Virtualisierung entsteht hauptsächlich durch eine zusätzliche Verwaltungsschicht und durch das Teilen physischer Ressourcen. Der Hypervisor muss CPU, RAM, Storage und Netzwerk zwischen mehreren VMs aufteilen. Dadurch entstehen Wartezeiten und Overhead.

Ein **Typ-1-Hypervisor** verursacht in der Regel weniger Leistungsverlust, weil er direckt auf der Hardware läuft. Ein **Typ-2-Hypervisor** hat meist mehr Overhead, weil zusätzlich ein Host-Betriebssystem beteiligt ist.

Zusammengefasst: Virtualisierung kostet Leistung, weil mehrere Systeme dieselbe Hardware teilen und der Hypervisor diese Ressourcen verwalten muss. Je knapper die Ressourcen und je schlechter die Konfiguration, desto stärker wird der Leistungsverlust sichtbar.

---

**Quellen**

https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/configuring_and_managing_linux_virtual_machines/optimizing-virtual-machine-performance

https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/7/html-single/virtualization_tuning_and_optimization_guide/index

https://learn.microsoft.com/en-us/windows-server/administration/performance-tuning/role/hyper-v-server/processor-performance

https://learn.microsoft.com/en-us/windows-server/administration/performance-tuning/role/hyper-v-server/processor-performance