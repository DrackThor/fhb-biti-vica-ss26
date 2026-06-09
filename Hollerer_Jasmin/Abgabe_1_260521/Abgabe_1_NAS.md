
# NAS – Network Attached Storage

NAS steht für **Network Attached Storage** und bezeichnet ein Datenspeichersystem, das über ein Netzwerk für mehrere Clients gleichzeitig zugänglich ist. Ein NAS-Gerät hängt eigenständig im Netzwerk und stellt seinen Speicher als gemeinsame Ressource bereit.

Ein NAS-System ist im Wesentlichen ein kleiner, spezialisierter Rechner: Es verfügt über einen Prozessor, Arbeitsspeicher, ein eigenes Betriebssystem und mehrere Festplatteneinschübe. Es bietet keine vollwertige Desktop-Umgebung, sondern ist darauf ausgelegt, Dateien zentral zu speichern, zu verwalten und über das Netzwerk bereitzustellen.

---

## Einsatzgebiete NAS

- **Kleine Unternehmen**
  - Gemeinsamer Dateizugriff
  - Einfaches Back-Up

- **Rechenzentrum**
  - Skalierbare Dateiserver
  - Archivierung
  - Virtualisierung

- **Privatverwendung**
  - Heimnetzwerke
  - Bibliotheken (Fotos, Musik usw.)
  - Automatische Backups

- **Bildung/Forschung**
  - Gemeinsamer Projektspeicher
  - Datenaustausch zwischen Abteilungen

In Virtualisierungsumgebungen spielt NAS eine besondere Rolle: Hypervisoren wie VMware oder Proxmox können ihre VMs auf einem NAS ablegen, was Live-Migration zwischen Hosts, zentrale Backups und einfache Skalierung ermöglicht.

## Zugriff

Clients greifen nicht blockweise auf den Speicher zu (wie bei SAN), sondern auf Dateiebene. Das NAS stellt Verzeichnisse und Dateien über standardisierte **Netzwerkprotokolle** bereit, die vom Client gemountet werden können.

---

## Aufbau

Ein NAS besteht typischerweise aus:

- Prozessor (CPU)
- Arbeitsspeicher (RAM)
- Einem oder mehreren Festplatteneinschüben
- Netzwerkanschluss (Ethernet, oft 1–10 Gbit/s)
- Betriebssystem (z. B. Synology DSM oder QNAP QTS)

Das NAS-Betriebssystem verwaltet die Festplatten, üblicherweise in einem RAID-Verbund (**Redundant Array of Independent Disks**), um Datensicherheit und/oder Performance zu gewährleisten.

RAID dient hauptsächlich der Verfügbarkeit und Ausfallsicherheit eines Systems. Fällt beispielsweise eine Festplatte aus, können die Daten durch die Redundanz weiterhin verfügbar bleiben. RAID schützt jedoch nicht vor versehentlichem Löschen von Dateien, Schadsoftware, Ransomware oder Hardwarefehlern des gesamten Systems.

Die genauen Funktionen und Vorteile unterscheiden sich jeweils durch die Art des RAID:

| RAID-Level | Beschreibung | Min. Laufwerke | Redundanz |
|---|---|---|---|
| RAID 0 | Striping – höhere Speed, kein Schutz | 2 | nein |
| RAID 1 | Mirroring – Spiegelung auf zwei Platten | 2 | ja |
| RAID 5 | Striping mit Parität, 1 Platte Verlust tolerierbar | 3 | ja |
| RAID 6 | Wie RAID 5, aber 2 Platten Verlust tolerierbar | 4 | ja |
| RAID 10 | Kombination aus Striping und Mirroring | 4 | ja |

![Darstellung Aufbau](../assets/Grafik_NAS-RAID.png)


## Protokolle

Um festzulegen, wie Geräte mit dem Speicher kommunizieren, werden je nach Client verschiedene Protokolle benötigt:

- **SMB/CIFS (Server Message Block)**
  - Windows
  - Weit verbreitet
  - Auch unter Linux/macOS nutzbar

- **NFS (Network File System)**
  - Linux/Unix
  - Standard in Unix-Umgebungen
  - Effizient im LAN

- **AFP (Apple Filing Protocol)**
  - macOS (veraltet)
  - Wurde durch SMB abgelöst

- **FTP/SFTP (File Transfer Protocol)**
  - Plattformübergreifend
  - Dateiübertragung lokal oder über das Internet

- **iSCSI (Internet Small Computer Systems Interface)** *
  - Virtualisierung
  - Blockbasiert
  - NAS verhält sich wie eine lokale Festplatte

*iSCSI ist streng genommen ein SAN-Protokoll, wird aber von vielen NAS-Geräten unterstützt und ermöglicht die Nutzung als Block-Speicher für Hypervisoren.

## Praxisbeispiele

### Unternehmen

Ein 10-köpfiges Entwicklungsteam nutzt ein QNAP-NAS mit sechs Festplatten in RAID 6. Über NFS-Freigaben greifen Linux-Entwicklerrechner auf gemeinsame Projektordner zu.

Täglich werden Snapshots angelegt. Ein zweites NAS im Homeoffice des Administrators spiegelt die Daten jede Nacht über `rsync` nach dem Prinzip der **3-2-1-Backup-Strategie**.

### Privathaushalt

Ein Privathaushalt betreibt ein Synology DS223-NAS mit zwei 4-TB-Festplatten im RAID 1.

Alle Laptops im Heimnetzwerk mounten eine SMB-Freigabe als Netzlaufwerk. Fotos und Videos werden automatisch auf das NAS gesichert.

---

## Abgrenzung zu DAS und SAN

- **DAS (Direct Attached Storage)**
  - Speicher wird direkt an einen einzelnen Rechner angeschlossen
  - Beispiele: USB oder SATA

- **NAS (Network Attached Storage)**
  - Dateibasierter Speicherzugriff über ein Netzwerk

- **SAN (Storage Area Network)**
  - Blockbasierter Speicher
  - Einsatz häufig bei Servern und Virtualisierungsumgebungen mit hoher Performance

---

## Pros und Cons

### Vorteile

- Zentrale Speicherung von Dateien für mehrere Benutzer
- Einfacher Zugriff von unterschiedlichen Geräten (PC, Smartphone, Tablet)
- Automatische Datensicherung möglich
- Benutzer- und Rechteverwaltung
- Erweiterbarkeit durch zusätzliche Festplatten
- Viele NAS-Systeme unterstützen zusätzliche Anwendungen wie Medienserver, Docker-Container oder Cloud-Dienste

### Nachteile

- Höhere Anschaffungskosten als eine externe Festplatte
- Benötigt permanente Stromversorgung
- Leistung hängt stark von der Netzwerkgeschwindigkeit ab
- Fehlerhafte Konfiguration kann Sicherheitsrisiken verursachen
- Wartung und Updates notwendig

---

## Quellen

- Synology: *What is NAS?*  
  https://www.synology.com/en-global/solution/what_is_nas

- TrueNAS Dokumentation  
  https://www.truenas.com/docs/

- OpenMediaVault  
  https://www.openmediavault.org/

- QNAP NAS-Übersicht  
  https://www.qnap.com/

- Wikipedia: *Network-attached storage*  
  https://en.wikipedia.org/wiki/Network-attached_storage

- Heise Online: *NAS-Kaufberatung*  
  https://www.heise.de/tipps-tricks/NAS-Kaufberatung

- Grafik_NAS-RAID.png: selbst erstellt
