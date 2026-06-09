# Aufgabe 1 | LV-Virtualisierung | BITI BB | Niklas Wintner

## Begriffserklärung und -definition: Software Defined Networking (SDN)

## 1. Was ist SDN überhaupt?

Software-Defined Networking, kurz SDN, ist ein Ansatz zur Netzwerkverwaltung, bei dem die Steuerungslogik eines Netzwerks von der eigentlichen Datenweiterleitung physisch und logisch getrennt wird. Im Grunde geht es darum, das Netzwerk „programmierbar" zu machen – also nicht mehr jedes Gerät einzeln zu konfigurieren, sondern das gesamte Netzwerk zentral und softwaregesteuert zu verwalten.

Traditionelle Netzwerke funktionieren so, dass jeder Switch und jeder Router sowohl die Entscheidung trifft, wohin ein Paket weitergeleitet werden soll (*Control Plane*), als auch die eigentliche Weiterleitung durchführt (*Data Plane*) – und das alles auf demselben Gerät, mit eigener Firmware und gerätespezifischer Konfiguration. Das funktioniert zwar, macht aber große Netzwerke extrem komplex und unflexibel. Änderungen müssen auf jedem Gerät einzeln durchgeführt werden, Fehlerquellen häufen sich, und Automatisierung ist nur schwer möglich.

SDN löst dieses Problem, indem die *Control Plane* aus den einzelnen Geräten herausgelöst und in eine zentrale Software – den sogenannten SDN-Controller – ausgelagert wird. Die Netzwerkgeräte selbst (Switches, Router) übernehmen dann nur noch die reine Weiterleitung von Paketen gemäß den Anweisungen, die sie vom Controller erhalten.

## 2. Praktische Einsatzgebiete

SDN wurde ursprünglich im akademischen Umfeld entwickelt – maßgeblich an der Stanford University und der UC Berkeley um das Jahr 2008. Der eigentliche Durchbruch gelang mit der Veröffentlichung des OpenFlow-Protokolls, das eine standardisierte Kommunikation zwischen Controller und Netzwerkgeräten ermöglichte.

Heute ist SDN vor allem in folgenden Bereichen relevant:

| **Einsatzbereich** | **Beschreibung** |
| --- | --- |
| Rechenzentrum | Flexible Netzwerkvirtualisierung für Cloud-Infrastrukturen |
| Telekommunikation | Verwaltung großer Backbone-Netze durch Carrier |
| Campus-Netzwerke | Vereinfachte Verwaltung von Unternehmensnetzen |
| Wide Area Networks (WAN) | SD-WAN als populäre Weiterentwicklung für verteilte Standorte |
| 5G-Infrastruktur | Dynamische Netzwerksteuerung für Mobilfunknetze |

Besonders in Cloud-Umgebungen – etwa bei Amazon Web Services, Google Cloud oder Microsoft Azure – ist SDN heute nicht mehr wegzudenken. Hyperscaler betreiben ihre riesigen Rechenzentren fast ausschließlich auf Basis softwaredefinierter Netzwerkkonzepte, weil sie damit innerhalb von Sekunden Netzwerktopologien anpassen können, ohne physisch an Geräten arbeiten zu müssen.

## 3. Technische Funktionsweise

Die SDN-Architektur lässt sich in drei logische Schichten unterteilen:

| Schicht | Komponenten |
| --- | --- |
| **Application Layer** | SDN-Applikationen |
| **Control Layer** | SDN-Controller (Netzwerk-Logik, Policies) |
| **Infrastructure Layer** | Physische/virtuelle Geräte (Switches, Router, nur Forwarding) |

### 3.1. Application Layer (Anwendungsebene)

Hier laufen Netzwerkanwendungen, die über das Northbound Interface mit dem Controller kommunizieren. Das können Sicherheitsanwendungen sein, Load-Balancing-Logik, Monitoring-Tools oder Quality-of-Service-Regeln. Diese Anwendungen können in Standardprogrammiersprachen (z. B. Python, Java) geschrieben werden und nutzen APIs des Controllers.

### 3.2. Control Layer (Steuerungsebene)

Der SDN-Controller ist das Herzstück der Architektur. Er hat eine globale Sicht auf das gesamte Netzwerk, kennt die Topologie, verwaltet die Flow Tables aller Geräte und reagiert auf Ereignisse (z. B. ein neuer Datenfluss oder ein Geräteausfall). Die Kommunikation mit der Infrastructure Layer erfolgt über das sogenannte Southbound Interface – hier wird häufig OpenFlow eingesetzt.

### 3.3. Infrastructure Layer (Datenebene)

Hier befinden sich die physischen oder virtuellen Netzwerkgeräte – also Switches und Router. Sie führen ausschließlich die Weiterleitung von Paketen durch, basierend auf sogenannten *Flow Tables*, die der Controller zuvor befüllt hat. Die Geräte treffen keine eigenständigen Routing-Entscheidungen mehr.

### 3.4. Flow-basierte Weiterleitung

Ein zentrales Konzept in SDN ist das Flow-basierte Forwarding. Anstatt Pakete anhand statischer Routing-Tabellen weiterzuleiten, arbeiten SDN-fähige Switches mit *Flow Tables*. Ein Flow ist dabei eine Menge von Paketen, die bestimmte Merkmale teilen – z. B. gleiche Quell-IP, Ziel-IP und Protokoll. Wenn ein Switch ein Paket empfängt, das noch keinem bekannten Flow zugeordnet werden kann, schickt er es an den Controller – dieser entscheidet dann, wie der Flow behandelt werden soll (weiterleiten, verwerfen, umleiten) und schreibt diese Regel in die Flow Table des Switches. Nachfolgende Pakete desselben Flows werden dann direkt im Switch verarbeitet, ohne erneute Rückfrage.

### 3.5. Southbound vs. Northbound Interface

- **Southbound Interface:** Verbindung zwischen Controller und Netzwerkgeräten. Hier wird OpenFlow am häufigsten eingesetzt, aber auch NETCONF, OVSDB oder PCEP kommen zum Einsatz.
- **Northbound Interface:** Verbindung zwischen Controller und Anwendungen. Üblicherweise RESTful APIs, über die externe Systeme den Controller steuern oder abfragen können.

## 4. Protokolle, Produkte und Hersteller

### 4.1. Protokolle

**OpenFlow** ist das bekannteste und historisch wichtigste Protokoll im SDN-Umfeld. Es standardisiert, wie ein SDN-Controller mit einem Switch kommuniziert – also wie Flow-Einträge geschrieben, gelöscht und abgefragt werden. OpenFlow wird von der Open Networking Foundation (ONF) entwickelt.

**NETCONF / YANG** ist ein weiteres wichtiges Protokoll, das besonders im Carrier-Umfeld verbreitet ist. Es ermöglicht die strukturierte Konfiguration von Netzwerkgeräten über XML-basierte Datenmodelle.

**OVSDB** (Open vSwitch Database Management Protocol) wird speziell für die Verwaltung von Open vSwitch-Instanzen eingesetzt und ist im Rechenzentrums- und Virtualisierungsumfeld weit verbreitet.

### 4.2. SDN-Controller

| **Controller** | **Entwickler** | **Besonderheit** |
| --- | --- | --- |
| OpenDaylight (ODL) | Linux Foundation | Einer der meistgenutzten Open-Source-Controller, Java-basiert |
| ONOS | ONF/Open Networking Foundation | Fokus auf Carrier-Grade-Netze, hochverfügbar |
| Ryu | NTT Labs | Leichtgewichtig, Python-basiert, gut für Forschung geeignet |
| Floodlight | Big Switch Networks | Java-basiert, REST-API, gut dokumentiert |

### 4.3. Kommerzielle Produkte und Hersteller

**Cisco** bietet mit *Cisco ACI (Application Centric Infrastructure)* eine eigene SDN-Lösung für Rechenzentren an. ACI ist stark auf Policy-basiertes Networking ausgelegt und integriert sich eng mit der restlichen Cisco-Infrastruktur.

**VMware NSX** ist eine der am weitesten verbreiteten kommerziellen SDN-Lösungen. Sie setzt auf Netzwerkvirtualisierung auf Basis von Open vSwitch und ermöglicht es, vollständige Netzwerktopologien in Software abzubilden – inklusive Firewalls, Load Balancer und VPNs.

**Juniper Contrail** (heute Teil von Juniper Apstra) ist eine weitere kommerzielle SDN-Plattform mit starkem Fokus auf Multi-Cloud-Umgebungen.

**SD-WAN-Lösungen** wie *Cisco Viptela*, *VMware Velocloud*, *Fortinet FortiSASE* oder *Zscaler* sind gewissermaßen eine spezifische Ausprägung von SDN, die auf die Vernetzung verteilter Unternehmensstandorte über das Internet ausgerichtet ist.

### 4.4. Open vSwitch (OVS)

Open vSwitch ist ein besonders wichtiges Open-Source-Projekt im SDN-Ökosystem. Es handelt sich um einen softwarebasierten Switch, der auf Linux-Systemen läuft und OpenFlow sowie OVSDB unterstützt. OVS ist die Basis vieler Virtualisierungsplattformen – so wird er z.B. von OpenStack, KVM und auch von VMware NSX intern genutzt.

## 5. Vorteile und Herausforderungen

| Vorteile | Herausforderungen |
| --- | --- |
| **Zentrale Verwaltung:** Das gesamte Netzwerk wird von einer Stelle aus konfiguriert und überwacht – kein mühsames SSH auf jeden einzelnen Switch. | **Single Point of Failure:** Ein zentraler Controller ist auch ein zentrales Angriffs- und Ausfallziel. Hochverfügbarkeit (Clustering) ist zwingend notwendig. |
| **Automatisierung:** Netzwerkkonfigurationen lassen sich per API und Skripte automatisieren, was besonders in CI/CD-Umgebungen wertvoll ist. | **Skalierbarkeit:** Bei sehr großen Netzwerken muss der Controller in der Lage sein, Millionen von Flows zu verwalten. |
| **Flexibilität:** Netzwerktopologien können in Minuten geändert werden, ohne physisch an Geräten zu arbeiten. | **Komplexität der Migration:** Die Umstellung bestehender Netze auf SDN ist aufwendig und kostenintensiv. |
| **Herstellerunabhängigkeit:** Durch offene Standards wie OpenFlow sind Unternehmen weniger an einzelne Hersteller gebunden (Vendor Lock-in wird reduziert). | **Sicherheit:** Die zentrale Steuerungsebene ist ein attraktives Angriffsziel; die Absicherung des Controllers und der Southbound-Kommunikation ist kritisch. |
| **Besseres Monitoring:** Der Controller hat jederzeit eine vollständige Sicht auf das Netzwerk. | |

## 6. Praxisbeispiel (Google B4)

Ein bekanntes Praxisbeispiel für SDN im großen Maßstab ist **Google B4** – das interne WAN-Netzwerk von Google, das seit etwa 2012 auf SDN-Basis betrieben wird. Google setzt dabei auf eigene Hardware-Switches und einen zentralen Controller, der die Auslastung der Verbindungen zwischen Rechenzentren in Echtzeit optimiert. Das Ergebnis: Die durchschnittliche Auslastung der Leitungen konnte laut Google-eigenen Angaben von etwa 30–40 % auf nahezu 100 % gesteigert werden, weil der Controller Datenflüsse viel effizienter verteilen kann als klassisches OSPF/BGP-Routing.

## 7. Abgrenzung: SDN vs. NFV vs. SD-WAN

Diese drei Begriffe werden im Kontext moderner Netzwerkarchitekturen häufig zusammen genannt, bezeichnen aber unterschiedliche Konzepte:

| **Begriff** | **Kernidee** | **Primärer Einsatzbereich** |
| --- | --- | --- |
| SDN | Trennung von Control Plane und Data Plane | Rechenzentrum, Campus, Backbone |
| NFV (Network Function Virtualization) | Netzwerkfunktionen (Firewall, Router) als VMs statt dedizierter Hardware | Carrier-Netze, Telekommunikation |
| SD-WAN | SDN-Prinzipien auf WAN-Ebene angewendet | Vernetzung von Unternehmensstandorten |

SDN und NFV ergänzen sich häufig: SDN steuert das Netzwerk, NFV stellt Netzwerkfunktionen virtuell bereit.

## 8. Fazit

Software-Defined Networking ist kein kurzfristiger Trend, sondern eine grundlegende Weiterentwicklung der Art, wie Netzwerke betrieben und verwaltet werden. Die Trennung von Steuerungslogik und Datenweiterleitung ermöglicht eine bisher nicht dagewesene Flexibilität, Automatisierbarkeit und Zentralisierung des Netzwerkmanagements. Gleichzeitig bringt SDN neue Herausforderungen mit sich – vor allem in Bezug auf Hochverfügbarkeit, Sicherheit und die Migration bestehender Infrastrukturen. Für angehende IT-Infrastruktur-Spezialisten ist das Verständnis von SDN heute unverzichtbar, da moderne Cloud-Umgebungen, Rechenzentren und Carrier-Netze nahezu ausnahmslos auf SDN-Konzepten aufbauen.

## 9. Quellen

- Open Networking Foundation (ONF): *Software-Defined Networking: The New Norm for Networks*, ONF White Paper, 2012. <https://opennetworking.org>
- Kreutz, D. et al.: *Software-Defined Networking: A Comprehensive Survey*, Proceedings of the IEEE, Vol. 103, No. 1, 2015.
- Google: *B4: Experience with a Globally-Deployed Software Defined WAN*, SIGCOMM 2013. <https://research.google/pubs/b4-experience-with-a-globally-deployed-software-defined-wan/>
- OpenDaylight Project: <https://www.opendaylight.org>
- Open vSwitch: <https://www.openvswitch.org>
- Cisco: *ACI Architecture Overview*. <https://www.cisco.com/c/en/us/solutions/data-center-virtualization/application-centric-infrastructure>
- VMware NSX Documentation: <https://docs.vmware.com/en/VMware-NSX>
