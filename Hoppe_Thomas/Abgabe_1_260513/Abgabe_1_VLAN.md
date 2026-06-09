# VLAN – Virtual Local Area Network

## Was ist ein VLAN?

Ein VLAN (Virtual Local Area Network) ist im Grunde eine Möglichkeit, ein physisches Netzwerk in mehrere logische Teilnetze aufzuteilen – und zwar rein per Konfiguration, ohne extra Hardware. Geräte werden dabei unabhängig von ihrem Standort oder ihrer Verkabelung in gemeinsame Broadcast-Domänen gruppiert. Das heißt: Zwei Rechner können im selben VLAN sein, obwohl sie an komplett unterschiedlichen Switches hängen. Und umgekehrt können zwei Geräte am selben Switch in getrennten VLANs laufen, ohne sich gegenseitig zu sehen.

Der Kerngedanke dahinter ist, die starre Kopplung zwischen physischer Topologie und logischer Netzwerkstruktur aufzubrechen. In einem klassischen LAN gehören alle Geräte am selben Switch automatisch zur selben Broadcast-Domäne. Mit VLANs lässt sich das frei definieren – ein PC in Raum A und ein Drucker in Raum B landen im selben logischen Netz, wenn man das so konfiguriert. Kein Kabel umstecken, kein neuer Switch nötig.

## Kontext und Einsatzgebiete

VLANs sind heute in praktisch jedem Unternehmensnetzwerk Standard. Sobald ein Netz eine gewisse Größe erreicht, kommt man um Segmentierung nicht herum. Typische Szenarien sind die Trennung von Abteilungen (Buchhaltung, Entwicklung, HR), die Isolation von Gäste-WLANs vom internen Netz, eigene Segmente für VoIP-Telefone oder die Absicherung von Server-Infrastruktur. Gerade bei VoIP ist das relevant, weil man Voice-Traffic priorisieren will – und das geht über VLANs mit QoS-Markierungen sehr gut.

Auch in Rechenzentren und bei ISPs sind VLANs unverzichtbar. Sie ermöglichen Mandantenfähigkeit, also die logische Trennung verschiedener Kunden auf derselben physischen Infrastruktur. In Campus-Netzwerken von Unis funktioniert das genauso – Studierende, Verwaltung und Forschung teilen sich die gleichen Switches, sehen sich aber gegenseitig nicht. Der große Vorteil dabei: Änderungen an der Netzwerkstruktur sind reine Konfigurationsarbeit. Kein Techniker muss durch die Gebäude laufen und Kabel umstecken.

## Technische Funktionsweise

### IEEE 802.1Q – Der Standard

Die technische Basis für VLANs ist der Standard **IEEE 802.1Q**, erstmals 1998 veröffentlicht. Er definiert, wie Ethernet-Frames mit einem VLAN-Tag versehen werden, um sie einem bestimmten VLAN zuzuordnen. Das Tag wird dabei direkt in den Frame eingefügt – zwischen Quell-MAC-Adresse und EtherType-Feld.

### Aufbau des VLAN-Tags

Der 802.1Q-Tag ist 4 Byte (32 Bit) groß und besteht aus folgenden Feldern:

| Feld | Länge | Beschreibung |
|------|-------|--------------|
| TPID (Tag Protocol Identifier) | 16 Bit | Fester Wert `0x8100` – markiert den Frame als 802.1Q-getaggt |
| PCP (Priority Code Point) | 3 Bit | Prioritätsstufe (0–7) für Quality of Service nach IEEE 802.1p |
| DEI (Drop Eligible Indicator) | 1 Bit | Zeigt an, ob der Frame bei Überlastung verworfen werden darf |
| VID (VLAN Identifier) | 12 Bit | Die eigentliche VLAN-ID (nutzbar: 1–4094) |

Die 12 Bit für die VLAN-ID ergeben theoretisch 4.096 mögliche VLANs. Da ID 0 und 4095 reserviert sind, bleiben 4.094 nutzbare VLANs. Durch das zusätzliche Tag wächst die maximale Frame-Größe von 1518 auf 1522 Byte – das wurde im Standard IEEE 802.3ac berücksichtigt.

### Port-Typen: Access und Trunk

Bei der VLAN-Konfiguration auf Switches gibt es zwei zentrale Port-Typen:

**Access Ports** sind für Endgeräte gedacht – PCs, Drucker, IP-Telefone. Ein Access Port gehört immer genau einem VLAN an. Der Switch ordnet eingehende Frames intern dem konfigurierten VLAN zu und schickt ausgehende Frames ohne Tag raus. Das Endgerät bekommt von der ganzen VLAN-Geschichte nichts mit.

**Trunk Ports** verbinden Switches untereinander oder Switches mit Routern. Über einen einzigen physischen Link wird Traffic aus mehreren VLANs transportiert. Jeder Frame trägt dabei seinen 802.1Q-Tag, damit die Gegenseite weiß, zu welchem VLAN er gehört. Eine Besonderheit: Das sogenannte **Native VLAN** wird ungetaggt übertragen – Frames ohne Tag landen automatisch in diesem VLAN.

### Zuordnungsverfahren

Es gibt verschiedene Wege, Frames einem VLAN zuzuordnen. Die gängigsten:

**Port-basiert** ist die Standardvariante und am weitesten verbreitet. Jeder Switch-Port wird fest einem VLAN zugewiesen – alles, was an diesem Port hängt, gehört zu dem VLAN. Einfach zu konfigurieren, einfach zu verstehen.

**Tag-basiert** arbeitet auf Frame-Ebene nach IEEE 802.1Q. Ein Port kann hier Mitglied mehrerer VLANs gleichzeitig sein. Das ist das Verfahren, das bei Trunk-Verbindungen zum Einsatz kommt.

Daneben gibt es noch weniger verbreitete Methoden wie MAC-basierte VLANs (Zuordnung über die MAC-Adresse), protokollbasierte VLANs (nach Netzwerkprotokoll) und richtlinienbasierte VLANs (nach definierten Policies).

## Architektur

Das folgende Schaubild zeigt eine typische VLAN-Architektur in einem Unternehmensnetz:

```
                        ┌──────────────┐
                        │    Router     │
                        │  (Inter-VLAN  │
                        │   Routing)    │
                        └──────┬───────┘
                               │ Trunk (alle VLANs)
                               │
                        ┌──────┴───────┐
                        │   Core Switch │
                        └──┬────────┬──┘
              Trunk ┌──────┘        └──────┐ Trunk
                    │                      │
             ┌──────┴───────┐       ┌──────┴───────┐
             │  Switch Fl.1 │       │  Switch Fl.2 │
             └──┬───┬───┬──┘       └──┬───┬───┬──┘
                │   │   │             │   │   │
               PC  PC  Tel          PC  PC  Tel
            VLAN  VLAN VLAN       VLAN VLAN VLAN
             10   20   30          10   20   30

    VLAN 10 = Verwaltung    VLAN 20 = Entwicklung    VLAN 30 = VoIP
```

Die Endgeräte hängen an Access Ports in ihren jeweiligen VLANs. Zwischen den Switches und zum Router laufen Trunk-Verbindungen, die den Traffic aller VLANs transportieren. Wichtig: Kommunikation *zwischen* VLANs – also z. B. von der Verwaltung (VLAN 10) zur Entwicklung (VLAN 20) – geht nur über den Router. Das nennt sich **Inter-VLAN Routing**. Dadurch bleibt die Trennung der Broadcast-Domänen sauber, und man kann den Traffic zwischen den Segmenten gezielt über Firewall-Regeln oder Access Control Lists (ACLs) steuern.

## Protokolle, Produkte und Hersteller

### Relevante Protokolle und Standards

| Protokoll / Standard | Beschreibung |
|----------------------|--------------|
| IEEE 802.1Q | Zentraler Standard für VLAN-Tagging in Ethernet-Netzen |
| IEEE 802.1p | Prioritätsstufen (PCP) im 802.1Q-Tag für QoS |
| IEEE 802.1X | Port-basierte Authentifizierung – wird oft mit dynamischer VLAN-Zuweisung kombiniert |
| MVRP | Automatische VLAN-Propagierung zwischen Switches, hat GVRP abgelöst |
| VTP (VLAN Trunking Protocol) | Proprietäres Cisco-Protokoll zur zentralen VLAN-Verwaltung |

### Hersteller und Produkte

Praktisch jeder managed Switch unterstützt VLANs nach IEEE 802.1Q. Im Enterprise-Bereich dominieren **Cisco** (Catalyst, Nexus), **Juniper** (EX-Serie), **Aruba/HPE** (Aruba CX) und **Arista Networks**. Für kleinere Setups und Homelabs bieten **Ubiquiti** (UniFi), **MikroTik**, **Netgear** (ProSafe) und **TP-Link** (JetStream) ebenfalls VLAN-fähige Switches an – oft zu einem Bruchteil des Preises.

### Konfigurationsbeispiel (Cisco Switch)

```
! VLAN erstellen
Switch(config)# vlan 10
Switch(config-vlan)# name Verwaltung

! Access Port konfigurieren
Switch(config)# interface GigabitEthernet0/1
Switch(config-if)# switchport mode access
Switch(config-if)# switchport access vlan 10

! Trunk Port konfigurieren
Switch(config)# interface GigabitEthernet0/24
Switch(config-if)# switchport mode trunk
Switch(config-if)# switchport trunk allowed vlan 10,20,30
```

## Vorteile und Grenzen

VLANs bringen einiges an Vorteilen mit: bessere Sicherheit durch Segmentierung, weniger Broadcast-Traffic und damit geringere Netzlast, flexible Netzwerkorganisation ohne Hardware-Änderungen, und QoS-Unterstützung durch die Priorisierung im Tag.

Die größte Limitierung liegt im Adressraum – 4.094 VLANs klingen erstmal viel, reichen aber in großen Cloud- und Rechenzentrumsumgebungen nicht aus. Genau dafür wurde **VXLAN** (Virtual Extensible LAN) entwickelt, das mit einem 24-Bit-Identifier bis zu ca. 16 Millionen logische Segmente ermöglicht. Außerdem wird die VLAN-Konfiguration mit wachsender Netzwerkgröße zunehmend aufwendig – in modernen Umgebungen setzt man daher auf SDN-Lösungen (Software Defined Networking), um VLANs automatisiert zu verwalten.

---

**Quellen:**

- IEEE 802.1Q Standard: [IEEE SA – IEEE 802.1Q-2018](https://standards.ieee.org/ieee/802.1Q/6844/)
- VLAN Grundlagen: [Thomas-Krenn-Wiki – VLAN Grundlagen](https://www.thomas-krenn.com/de/wiki/VLAN_Grundlagen)
- VLAN Typen: [ITWISSEN – VLAN Typen](https://itwissen.net/wissen/vlan-typen/)
- Access vs. Trunk Ports: [Cisco – Assign an Interface VLAN](https://www.cisco.com/c/en/us/support/docs/smb/switches/Cisco-Business-Switching/kmgmt-2253-assign-an-interface-vlan-as-an-access-or-trunk-port-on-a-swi.html)
- 802.1Q Tagging: [Study CCNA – IEEE 802.1Q](https://study-ccna.com/ieee-802-1q/)
