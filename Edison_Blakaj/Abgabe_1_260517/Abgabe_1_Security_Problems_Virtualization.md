# Security Problems and Limitations of Virtualization
## Einleitung - Was ist Virtualisierung?
Beim Virtualisieren geht es darum physische Hardware in virtuelle Instanzen (VMs, Container, etc.) umzuwandeln. Ein Hypervisor dient hier als zentrale Schicht, hier kann man verschiedene Hypervisor-Typen unterscheiden.
	**Typ 1:** Bare-Metal
	**Typ 2:** hosted
Die Einsatzgebiete hierfür sind breit, sie dienen zur Serverkonsolidierung, für Cloud Computing, DevOps, oder stellen auch Testumgebungen bereit. Die bekanntesten Produkte und Hersteller sind hier u.a. VMware vSphere/ESXi, Microsoft Hyper-V, KVM (Linux), Citrix, Oracle Virtualbox und Proxmox VE. Neben VMs gibt es auch bekannte Container Provider wie Docker, Podman, Kubernetes, LXC.

## Sicherheitsprobleme in der Virtualisierung
Virtualisierte Maschinen (VMs) werden im Bereich der Cyber Security gerne verwendet, um Malware und sonstige Sicherheitslücken zu analysieren. Durch die Abstrahierungsschicht kann Malware nicht auf die physischen Komponenten des Rechners zugreifen, weswegen viele Techniken wie die Verschlüsselung der Festplatte, Auslesen der Daten oder Keylogger nicht funktionieren, da alles simuliert ist. Problematisch ist es, wenn Hacker sich darauf vorbereiten, dass deren Malware in sogenannten "Sandboxes" analysiert werden und versuchen das entweder auszunutzen, oder das Verhalten der Malware ändern. Folgende Schwachstellen im Zusammenhang mit Virtualisierung sind bisher bekannt:

![[Pasted image 20260516235140.png]]
### VM Escape
Bei einem VM Escape kann der Angreifer aus der VM ausbrechen und erreicht den Hypervisor oder den Host, von diesem Punkt kann der Angreifer dann weitere VMs auf dem Host angreifen.
**Bekannte CVEs:**
CVE-2015-3456 ("VENOM") - Schwachstelle im virtuellen Floppy-Disk-Controller von QEMU
CVE-2017-4901 (VMware Workstation Drag-and-Drop-Funktion)

### Hypervisor-Angriffsfläche
Sobald der Hypervisor kompromittiert ist, hat der Angreifer sämtlichen Zugriff auf alle virtuellen Maschinen. Zugang dazu sind Angriffe auf Management-Interfaces, zudem erben Typ-2-Hypervisoren zusätzlich Schwachstellen des Host-OS.
**Bekannte CVEs:**
CVE-2021-21985: kritische RCE-Schwachstelle in VMware vCenter Server

### Side-Channel-Angriffe
Virtuelle Maschinen teilen sich selbst bei Virtualisierung die selbe physische CPU, den selben Cache und den selben Speicher. Die Gefahr skaliert wenn man sich diese Schwachstelle in Cloud Umgebungen vorstellt, wo auch fremde VMs auf gleicher Hardware gehostet werden. Rowhammer ist hier ein DRAM-basierter Angriff und kann VM-Isolationen durchbrechen.
**Bekannte CVEs:**
CVE-2017-5753/5715 (Spectre)
CVE-2017-5754 (Meltdown)
Beide: CPU-Cache-basierte Angriffe, Cross-VM-Datenexfiltration möglich

### Netzwerksicherheit in virtualisierten Umgebungen
Virtuelle Switches (vSwitch) operieren unterhalb klassischer Netzwerk-Firewalls und Intrusion Detection Systems, somit erkennen Firewalls East-West-Traffic, also von VM zu VM nicht. Ebenso ist VLAN-Hopping innerhalb virtueller Netzwerke möglich.

### Image- und Snapshot-Sicherheit
VM Images enthalten komplette Betriebssysteme, sollte ein Angreifer Zugang zu diesen Systemklonen erlangen, hätte er unter Umständen Zugang zu sensiblen Daten die im RAM abgespeichert sind wie Passwörter oder Keys.

### Container-spezifische Probleme
Container teilen sich im Gegensatz zu virtuelle Maschinen den Host-Kernel, dazu haben privilegierte Container quasi Root-Zugriff auf den Host. Die Gefahr liegt hier hierbei, unsichere Base-Images aus öffentlichen Registries zu beziehen
**Bekannte CVEs:**
CVE-2019-5736: runc-Schwachstelle erlaubte Container Escape

## Limitierung und Grenzen der Virtualisierung aus Security-Sicht
Virtualisierung ist kein vollständiger Ersatz für physische Isolation. Sogenannte air-gapped Systeme bieten vollkommenen Schutz, da selbst wenn der Angreifer bzw. die Malware das System, der Schaden sich auf das einzelne physische Gerät beschränkt. Ebenso erweist sich das Patch-Management als schwierig da sich die Angriffsfläche auf das Host-OS + Hypervisor und jede einzelne VM erstreckt. Das Logging ist begrenzt möglich da Standard-SIEM den intra-Host-Verkehr oft nicht sieht. Ganz schwierig ist die Nachweisbarkeit der Mandantentrennung in Multi-Tenant-Cloud Umgebungen.

## Best Practices
Folgende Punkte erweisen sich als technisch Sinnvoll aber auch als notwendig:
- Hardening des Hypervisors
- Mikrosegmentierung
- Verschlüsselter VM-Speicher
- Regelmäßiges Patching der gesamten Stack-Kette
- Least-Privilege Zugänge für das VM-Management
- Image-Scanning (Trivy, Grype, Snyk Container)
- Monitoring von East-West-Traffic

## Fazit
Virtualisierung bringt enorme Vorteile aber ebenso enorme Risiken, die Sicherheitsarchitektur muss die geteilte Infrastruktur explizit berücksichtigen. Eine Isolation in diesem Fall ist nie zu 100% gewährt - eine Defense-in-Depth bleibt weiterhin Pflicht.

