# NAS – Network Attached Storage

**Michael Horvath**

---

## 1. Was ist NAS?

**Network Attached Storage (NAS)** ist, vereinfacht gesagt, ein Dateiserver, den man ans Heimnetz oder Firmennetzwerk hängt und dann von jedem Gerät darauf zugreifen kann. Im Unterschied zu einer USB-Platte, die direkt am Rechner hängt, hat ein NAS eine eigene CPU, eigenes RAM, ein eigenes Betriebssystem und mindestens einen Netzwerkanschluss – es ist also ein vollständig eigenständiges Gerät.

Beispiel - NAS Architektur
![NAS Architektur](assets/NAS.png)

Was ein NAS von einem „richtigen" Server unterscheidet, ist vor allem der Verwaltungsaufwand: Ein NAS läuft dauerhaft, ist über ein Web-Interface konfigurierbar und braucht in der Regel keinen Administrator, der Linux-Kommandos kennt. Wer will, kann es natürlich trotzdem so betreiben – gerade bei Open-Source-Lösungen wie TrueNAS ist die Grenze zu einem vollwertigen Server fließend.

---

## 2. Wo wird NAS eingesetzt?

Der Einsatzbereich reicht vom Wohnzimmer bis ins Rechenzentrum, wobei sich die Anforderungen naturgemäß stark unterscheiden.

Im **Heimbereich** geht es typischerweise darum, Fotos, Filme und Musik zentral zu speichern, Backups von mehreren Geräten einzusammeln oder eine Art private Cloud-Lösung zu betreiben. Ein 2-Bay-Gerät mit zwei Festplatten reicht dafür in den meisten Fällen völlig aus.

Im **kleinen Büro oder KMU-Umfeld** steht gemeinsamer Dateizugriff im Vordergrund: Mitarbeiter sollen auf dieselben Dokumente zugreifen können, ohne sich E-Mails mit Anhängen schicken zu müssen. NAS-Systeme übernehmen hier oft gleichzeitig die Rolle eines Backup-Ziels für alle Workstations im Netz.

Größere **Unternehmen** setzen NAS als zentralen Fileserver, als VM-Datenspeicher oder als Backup-Repository ein. Im Rechenzentrum trifft NAS auf Konkurrenz durch SAN (blockbasiert, hochperformant, aber deutlich aufwendiger und teurer) und Object Storage (für unstrukturierte Massendaten, z.B. AWS S3 oder kompatible Systeme). NAS füllt dort eine Nische zwischen diesen beiden Welten.

---

## 3. Technischer Aufbau

### 3.1 Hardware

Ein Consumer-NAS ist oft überraschend bescheiden ausgestattet: ein ARM- oder Intel-Prozessor mit geringem Stromverbrauch, 2–4 GB RAM und ein bis vier Festplatteneinschübe. Das reicht für die meisten Heimanwender vollkommen, weil die Hauptlast im Netzwerk und nicht im Rechnen liegt.

Im Enterprise-Bereich sieht das anders aus. Hier kommen AMD Ryzen oder Intel Xeon als CPUs zum Einsatz, RAM in zweistelliger Gigabyte-Größe ist Standard, und die Geräte haben häufig 10-GbE-Ports oder mehr. Rackmount-Gehäuse mit 12, 24 oder noch mehr Festplattenschächten sind keine Seltenheit.

Was alle NAS-Systeme gemeinsam haben: Sie brauchen zuverlässige Festplatten. NAS-Hersteller empfehlen ausdrücklich Laufwerke, die für den Dauerbetrieb ausgelegt sind (sog. NAS-Drives wie WD Red, Seagate IronWolf o.ä.) – Notebook-Festplatten oder normale Desktop-Laufwerke sind dafür nicht geeignet.

### 3.2 RAID

Wer mehrere Festplatten in einem NAS betreibt, will sie sinnvollerweise in einem RAID-Verbund zusammenfassen. Welcher RAID-Level der richtige ist, hängt davon ab, was man priorisiert – Kapazität, Performance oder Ausfallsicherheit:

| RAID-Level | Funktionsprinzip | Min. Laufwerke | Toleriert Ausfälle |
|---|---|---|---|
| RAID 0 | Striping, kein Schutz | 2 | 0 |
| RAID 1 | Spiegelung (Mirror) | 2 | 1 |
| RAID 5 | Striping + einfache Parität | 3 | 1 |
| RAID 6 | Striping + doppelte Parität | 4 | 2 |
| RAID 10 | Spiegel + Striping kombiniert | 4 | je 1 pro Spiegelpaar |

RAID 5 ist der häufigste Kompromiss im kleinen Büro: Man verliert eine Festplatte an Overhead, darf aber eine ausfallen lassen, ohne Daten zu verlieren. Wer auf Nummer sicher gehen will, greift zu RAID 6 – vor allem bei Festplatten mit großer Kapazität, da Rebuilds nach einem Ausfall mehrere Stunden dauern können und in dieser Zeit ein zweiter Ausfall fatal wäre.

Wichtig: RAID ist kein Backup. Es schützt vor Hardwareausfall, aber nicht vor versehentlichem Löschen, Ransomware oder Feuer.

### 3.3 Dateisysteme

Je nach NAS-Betriebssystem kommen unterschiedliche Dateisysteme zum Einsatz. **ext4** ist weit verbreitet und erprobt, aber eher konservativ. **Btrfs** bietet Snapshots und eine eingebaute Prüfsummenfunktion, die stille Datenfehler erkennt. **ZFS** gilt vielen als das technisch ausgefeilteste, ist aber ressourcenhungriger – es ist Standarddateisystem bei TrueNAS (FreeBSD-Basis) und bei QNAPs QuTS Hero (Linux-Basis).

### 3.4 Netzwerkprotokolle

Das NAS stellt seinen Speicher über standardisierte Protokolle bereit. Windows-Clients nutzen fast immer **SMB** (auch CIFS genannt), Linux-Systeme greifen häufig per **NFS** zu, und ältere Macs sprachen bis vor einigen Jahren noch AFP – das hat sich inzwischen zugunsten von SMB erledigt. Für Backups via Internet oder lokale Backupjobs hat sich **rsync** durchgesetzt, weil es Daten inkrementell überträgt und dabei nur das schickt, was sich geändert hat.

Eine besondere Rolle spielt **iSCSI**: Damit lässt sich ein NAS so ansprechen, als wäre es ein direkt angeschlossenes Blockgerät – nützlich z.B. für VMs, die einen dedizierten Datastore brauchen.

```
┌─────────────────────────────────────────┐
│             Client-Geräte               │
│  PC / Mac / Linux / Smartphone / TV     │
└────────────┬────────────────────────────┘
             │  Netzwerkzugriff (LAN/WLAN/VPN)
             ▼
┌─────────────────────────────────────────┐
│            NAS-Gerät                    │
│  ┌──────────────────────────────────┐   │
│  │  Protokoll-Layer                 │   │
│  │  SMB/CIFS │ NFS │ AFP │ FTP/S    │   │
│  │  WebDAV   │ iSCSI │ HTTP/HTTPS   │   │
│  └──────────────────────────────────┘   │
│  ┌──────────────────────────────────┐   │
│  │  Dateisystem (ext4 / Btrfs / ZFS)│   │
│  └──────────────────────────────────┘   │
│  ┌──────────────────────────────────┐   │
│  │  RAID-Controller / Festplatten   │   │
│  └──────────────────────────────────┘   │
└─────────────────────────────────────────┘
```

---

## 4. Protokollübersicht

| Protokoll | Vollname | Typischer Einsatz |
|---|---|---|
| SMB/CIFS | Server Message Block | Windows-Freigaben |
| NFS | Network File System | Linux/Unix |
| AFP | Apple Filing Protocol | Ältere macOS-Systeme (heute kaum noch) |
| FTP / SFTP / FTPS | File Transfer Protocol (Varianten) | Dateiübertragung, externer Zugriff |
| WebDAV | Web Distributed Authoring and Versioning | Browser-Zugriff, Kalender, Kontakte |
| iSCSI | Internet Small Computer System Interface | Blockzugriff (SAN-ähnlich über IP) |
| HTTP / HTTPS | Hypertext Transfer Protocol | Web-GUI, Nextcloud, Portale |
| rsync | Remote Sync | Inkrementelle Backups |

---

## 5. Hersteller und Produkte

### 5.1 Consumer und SOHO

Für Heimanwender und kleine Büros dominieren vier Hersteller den Markt:

**Synology** ist mit seiner DiskStation-Reihe und dem sehr ausgereiften DSM-Betriebssystem seit Jahren Marktführer. Die Benutzeroberfläche gilt als eine der intuitiv­sten überhaupt, und das App-Ökosystem ist groß – von Surveillance Station bis Synology Drive als Dropbox-Ersatz.

**QNAP** positioniert sich etwas techniklastiger und bietet mit QuTS Hero eine ZFS-basierte Variante seines Betriebssystems an, die sonst Enterprise-Systemen vorbehalten wäre. Die Hardware-Ausstattung ist oft großzügiger.

**Western Digital** (WD My Cloud, PR-Serie) und **Terramaster** sind für preissensible Käufer interessant, bleiben in Software-Tiefe und Ökosystem aber hinter den ersten beiden zurück.

Beispiel – Synology DiskStation:
![NAS DiskStation](assets/Synology.png)

### 5.2 Enterprise

Im Enterprise-Segment spielen andere Namen:

- **NetApp** mit ONTAP-basierten Systemen (AFF, FAS-Serie) – Marktstandard in vielen Rechenzentren
- **Dell EMC** PowerScale (früher Isilon) für horizontale Skalierung bis in den Petabyte-Bereich
- **HPE** StoreEasy und **IBM** FlashSystem runden das Angebot ab

Beispiel – NetApp ONTAP:
![NetApp ONTAP](assets/Netapp.png)

### 5.3 Open Source und DIY

Wer aus alter Hardware oder einem kleinen Server ein NAS bauen will, hat gute Optionen:

**TrueNAS CORE / SCALE** (iXsystems) ist die erste Wahl für ambitionierte Selbstbauer. CORE läuft auf FreeBSD mit ZFS, SCALE auf Linux-Basis. Beide sind kostenlos, und die Dokumentation ist ausgezeichnet.

**OpenMediaVault** ist schlanker, Debian-basiert und funktioniert auch auf einem Raspberry Pi – ideal, wer schnell loslegen will ohne tiefen ZFS-Einstieg.

**Nextcloud** ist streng genommen kein NAS-Betriebssystem, aber es lässt sich auf jedem NAS oder eigenen Server installieren und liefert eine vollständige Private-Cloud-Plattform inklusive Dateisynchronisation, Kalender, Kontakten und Videokonferenzen.

---

## 6. Sicherheit

Ein NAS ist oft der Ort, an dem sensible oder schlicht wichtige Daten eines Haushalts oder einer Firma landen. Entsprechend ernst sollte man das Thema nehmen.

**Zugangskontrolle** beginnt bei starken Passwörtern und Zweifaktor-Authentifizierung – alle großen NAS-Betriebssysteme unterstützen das, aktiviert ist es aber oft nicht standardmäßig. Größere Installationen binden das NAS per LDAP oder Active Directory an das Unternehmensnetz an.

**Verschlüsselung** sollte auf zwei Ebenen stattfinden: die gespeicherten Daten (at rest, z.B. per AES-Ordnerverschlüsselung) und die Übertragung (in transit per TLS/HTTPS).

**Snapshots** sind das wirksamste Mittel gegen Ransomware. Btrfs und ZFS erstellen in kurzen Abständen Zeitpunktaufnahmen des Dateisystems, die Ransomware nicht ohne weiteres verschlüsseln kann – vorausgesetzt, die Snapshots sind schreibgeschützt und nicht vom Client aus erreichbar.

**Internetzugang:** Das NAS sollte nie direkt aus dem Internet erreichbar sein. Stattdessen empfiehlt sich ein VPN (WireGuard oder OpenVPN lassen sich direkt im NAS-Betriebssystem konfigurieren) oder, wenn es einfacher sein muss, der Hersteller-eigene Relay-Dienst wie Synology QuickConnect – auch wenn letzteres naturgemäß Abhängigkeiten schafft.

Schließlich gehört ein NAS in eine vernünftige **Backup-Strategie**. Die 3-2-1-Regel ist hier der Ausgangspunkt: mindestens drei Kopien der Daten, auf zwei verschiedenen Medientypen, davon eine off-site (Cloud-Backup oder zweites NAS an anderem Standort).

---

## 7. Praxisbeispiel

**Kleines Büro, 10 Mitarbeiter**

Ein Unternehmen setzt ein Synology DS923+ ein – 4-Bay-Gerät mit AMD-Ryzen-Prozessor, vier 4-TB-NAS-Festplatten im RAID 5, also rund 12 TB nutzbarer Kapazität. Angebunden ist das NAS per 10-GbE an den zentralen Switch.

Windows-Arbeitsplätze verbinden sich per SMB (mapped drives), Macs ebenfalls. Nächtlich läuft ein rsync-Job, der alle Daten auf ein zweites NAS am anderen Bürostandort spiegelt. Als Dropbox-Ersatz läuft Synology Drive, das Versionierung und selektive Synchronisation mitbringt. Zugriff von außen ist ausschließlich per WireGuard-VPN möglich, das direkt im DSM konfiguriert ist – kein Port-Forwarding, keine offenen Dienste im Internet.

---

## 8. Fazit

NAS-Systeme haben sich von einfachen Netzwerkfestplatten zu vollständigen Plattformen entwickelt. Ob Medienbibliothek, Private Cloud, Überwachungsspeicher oder VM-Datenspeicher – die Grenzen zwischen NAS und einem vollwertigen Heimserver verschwimmen zunehmend. Gleichzeitig sind einsteigerfreundliche Geräte heute günstiger und einfacher bedienbar als je zuvor.

Angesichts wachsender Datenschutzbedenken gegenüber Public-Cloud-Diensten ist der Trend zur eigenen Infrastruktur nachvollziehbar. Ein NAS bietet dabei einen guten Mittelweg: die Kontrolle über die eigenen Daten, ohne den Aufwand eines vollständigen Serverbetriebs – zumindest, wenn man es nicht darauf anlegt.

---

## 9. Quellen

- QNAP Systems – *QTS/QuTS Hero Dokumentation*, https://www.qnap.com/de-de
- Heise / iX Magazin – *NAS-Themenbereich*, https://www.heise.de/thema/NAS
- TrueNAS – *Dokumentations-Hub*, https://www.truenas.com/docs/
- Synology Inc. – *Knowledge Center / DSM-Dokumentation*, https://kb.synology.com
- SNIA (Storage Networking Industry Association) – *RAID und Storage-Standards*, https://www.snia.org
- Evi Nemeth et al. – *UNIX and Linux System Administration Handbook*, 5. Auflage, 2017, Pearson Education
