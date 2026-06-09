# Network File System (NFS)

## Was ist NFS?

Das Network File System (NFS) ist ein verteiltes Dateisystem, das es ermöglicht, Dateien über ein Netzwerk so zu nutzen, als wären sie lokal auf dem eigenen Rechner gespeichert. Entwickelt wurde NFS ursprünglich von Sun Microsystems und wird heute vor allem in Unix- und Linux-Umgebungen eingesetzt.

Das grundlegende Ziel von NFS ist es, Ressourcen effizient zu teilen. Ein Server stellt Verzeichnisse zur Verfügung, die von mehreren Clients gleichzeitig genutzt werden können. Dadurch wird eine zentrale Datenhaltung ermöglicht, was insbesondere in großen IT-Infrastrukturen von Vorteil ist.

---

## Kontext und Einsatzgebiete

NFS wird hauptsächlich in folgenden Bereichen verwendet:

- Unternehmensnetzwerke (zentrale Datenablage)
- Rechenzentren
- Virtualisierungsumgebungen (z. B. für VM-Storage)
- High Performance Computing (HPC)
- Cloud-Umgebungen

Ein typisches Szenario ist ein Server, der Home-Verzeichnisse für mehrere Benutzer bereitstellt. Jeder Benutzer greift über das Netzwerk auf seine Daten zu, ohne dass diese lokal gespeichert werden müssen.

---

## Technische Funktionsweise

NFS basiert auf einem Client-Server-Modell:

- **NFS-Server**: Stellt Verzeichnisse zur Verfügung
- **NFS-Client**: Bindet diese Verzeichnisse in sein eigenes Dateisystem ein

Der Zugriff erfolgt über das Remote Procedure Call (RPC)-Protokoll. Dabei sendet der Client Anfragen an den Server, z. B. zum Lesen oder Schreiben von Dateien.

Wichtige Eigenschaften:

- Transparentes Arbeiten (Dateien wirken lokal)
- Zustandslosigkeit (bei älteren Versionen wie NFSv3)
- Unterstützung für parallelen Zugriff mehrerer Clients

---

## Architektur (vereinfachtes Schema)

```
Client 1 ----\
Client 2 -----> NFS Server (exportierte Verzeichnisse)
Client 3 ----/
```


Der Server stellt ein oder mehrere Verzeichnisse bereit, auf die mehrere Clients gleichzeitig zugreifen können.

---

## Protokolle und Versionen

NFS hat sich über mehrere Versionen hinweg weiterentwickelt:

| Version | Eigenschaften |
|--------|-------------|
| NFSv3  | Zustandslos, weit verbreitet |
| NFSv4  | Stateful, bessere Sicherheit, ACL-Unterstützung |
| NFSv4.1/4.2 | Verbesserte Performance und Parallelisierung |

Zusätzlich nutzt NFS weitere Dienste wie:

- RPC (Remote Procedure Call)  
- Portmapper (Zuordnung von Diensten zu Ports)  
- Mount-Protokoll (für Verbindungsaufbau)  

---

## Tools, Produkte und Implementierungen

Typische Implementierungen und Produkte im Zusammenhang mit NFS sind:

- **nfs-utils** (Standard unter Linux)  
- **TrueNAS / FreeNAS**  
- **NetApp Storage-Systeme**  
- **Synology und QNAP NAS-Geräte**  
- **AWS Elastic File System (EFS)**  

Diese Systeme bieten oft zusätzliche Funktionen wie Backup, Snapshotting oder Skalierung.

---

## Vorteile von NFS

- Zentrale Verwaltung von Daten  
- Einfache Einrichtung und Konfiguration  
- Gute Performance im lokalen Netzwerk  
- Plattformübergreifend in Unix/Linux-Umgebungen  
- Transparenter Zugriff für Benutzer  

---

## Nachteile und Einschränkungen

- Sicherheitsrisiken bei falscher Konfiguration  
- Abhängigkeit von Netzwerkgeschwindigkeit und -stabilität  
- Eingeschränkte Unterstützung in Windows-Umgebungen  
- Potenzielle Probleme bei Dateisperren (Locking)  

---

## Vergleich mit anderen Technologien

| Technologie | Unterschied zu NFS |
|------------|------------------|
| SMB/CIFS   | Besser für Windows-Umgebungen geeignet |
| iSCSI      | Blockbasiert statt dateibasiert |
| FTP        | Kein transparentes Dateisystem |

---

## Fazit

NFS ist ein wichtiges Werkzeug in modernen IT-Infrastrukturen, insbesondere in Linux- und Unix-Umgebungen. Es ermöglicht die zentrale Bereitstellung von Daten und vereinfacht die Zusammenarbeit zwischen mehreren Systemen erheblich.

Trotz einiger Einschränkungen bleibt NFS aufgrund seiner Einfachheit, Flexibilität und Leistungsfähigkeit eine weit verbreitete Lösung für die gemeinsame Nutzung von Dateien über Netzwerke hinweg.

## Quellen

- Microsoft Learn: Übersicht über NFS  
  https://learn.microsoft.com/de-de/windows-server/storage/nfs/nfs-overview  

- IBM Dokumentation: Network File System  
  https://www.ibm.com/docs/de/aix/7.2.0?topic=management-network-file-system  

- AWS: Unterschied zwischen NFS und SMB  
  https://aws.amazon.com/de/compare/the-difference-between-nfs-smb/  

- Linux Magazin: Einführung in NFS  
  https://www.linux-magazin.de/ausgaben/2008/06/dateisystem-im-server/  

- Ubuntuusers Wiki: NFS  
  https://wiki.ubuntuusers.de/NFS/  

- Atera Blog: What is NFS?  
  https://www.atera.com/de/blog/what-is-nfs-understanding-the-network-file-system/  
