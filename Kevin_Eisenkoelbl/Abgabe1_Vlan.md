# VLAN – Virtual Local Area Network

## 1. Was ist ein VLAN?

Ein **Virtual Local Area Network (VLAN)** ist eine logische Netzwerksegmentierung, die es ermöglicht, physisch verbundene Geräte in voneinander getrennte, virtuelle Netzwerksegmente aufzuteilen – unabhängig davon, wo diese Geräte physisch angeschlossen sind. Mit anderen Worten: Ein VLAN erlaubt es, aus einem einzigen physischen Netz mehrere logische Netze zu formen.

Ohne VLANs befinden sich alle Geräte, die an denselben Switch angeschlossen sind, automatisch im gleichen **Broadcast-Domain**. Das bedeutet: Jedes Paket, das als Broadcast versandt wird (z. B. ARP-Anfragen), wird an alle angeschlossenen Geräte weitergeleitet – unabhängig davon, ob der Empfänger dieses Paket überhaupt benötigt. Bei wachsenden Netzwerken führt das zu unnötigem Datenverkehr, Sicherheitsproblemen und eingeschränkter Verwaltbarkeit.

VLANs lösen dieses Problem, indem sie **Broadcast-Domains logisch trennen**: Geräte in unterschiedlichen VLANs können nicht direkt miteinander kommunizieren, selbst wenn sie am selben physischen Switch hängen. Die Kommunikation zwischen VLANs erfordert zwingend ein **Layer-3-Gerät** (Router oder Layer-3-Switch).

---

## 2. Kontext und Einsatzgebiete

VLANs werden überall dort eingesetzt, wo Netzwerke strukturiert, segmentiert oder abgesichert werden müssen. Typische Anwendungsszenarien:

| Einsatzbereich | Beschreibung |
|---|---|
| **Unternehmensnetze** | Trennung von Abteilungen (z. B. HR, IT, Buchhaltung) ohne eigene physische Infrastruktur |
| **Hochschulen & Schulen** | Separierung von Studierenden-, Lehrenden- und Verwaltungsnetz |
| **Rechenzentren** | Isolierung von Kundennetzwerken (Mandantentrennung / Multi-Tenancy) |
| **Heimnetzwerke** | Trennung von IoT-Geräten vom Hauptnetz zur Absicherung |
| **Industrie & OT** | Trennung von Produktionsnetz (OT) und Büronetz (IT) |
| **Gastnetze** | Isoliertes WLAN für Besucher ohne Zugriff auf interne Ressourcen |

In allen diesen Fällen geht es um die drei zentralen Ziele von VLANs: **Sicherheit**, **Performance** und **Verwaltbarkeit**.

---

## 3. Technische Funktionsweise

### 3.1 VLAN-Kennzeichnung (Tagging)

Der zentrale technische Mechanismus von VLANs ist das sogenannte **VLAN-Tagging**. Dabei wird jedem Ethernet-Frame ein zusätzlicher 4-Byte-Header eingefügt, der die zugehörige VLAN-ID trägt. Dieser Standard wird durch **IEEE 802.1Q** definiert (auch „Dot1Q" genannt).

Ein markierter Ethernet-Frame sieht vereinfacht so aus:

```
+----------+----------+-----------+------+------+-----+
| Ziel-MAC | Quell-MAC| 802.1Q Tag| EType| Daten| FCS |
+----------+----------+-----------+------+------+-----+
                           ↑
              4 Byte: TPID + TCI (inkl. VLAN-ID 1–4094)
```

Der 802.1Q-Tag enthält:
- **TPID** (Tag Protocol Identifier): `0x8100` – kennzeichnet das Frame als getaggt
- **PCP** (Priority Code Point): 3 Bit für QoS-Priorisierung
- **DEI** (Drop Eligible Indicator): 1 Bit für Congestion-Management
- **VID** (VLAN Identifier): 12 Bit → **4094 mögliche VLANs** (0 und 4095 sind reserviert)

### 3.2 Access Ports vs. Trunk Ports

An einem Switch unterscheidet man grundlegend zwei Port-Typen:

| Port-Typ | Beschreibung | Typische Verwendung |
|---|---|---|
| **Access Port** | Gehört genau einem VLAN; sendet/empfängt **ungetaggte** Frames | Endgeräte (PC, Drucker, IP-Telefon) |
| **Trunk Port** | Überträgt **mehrere VLANs gleichzeitig** mit Tags | Switch-zu-Switch, Switch-zu-Router |

Ein Endgerät muss nichts von VLANs wissen – es sendet normale Frames. Der Switch fügt beim Eingang den Tag hinzu und entfernt ihn beim Ausgang wieder. Auf Trunk-Links bleiben die Tags erhalten, damit der nächste Switch die Zuordnung kennt.

### 3.3 Native VLAN

Auf einem Trunk-Port gibt es das sogenannte **Native VLAN** (Standard: VLAN 1). Frames dieses VLANs werden auf dem Trunk-Link **ohne Tag** übertragen. Das Native VLAN muss auf beiden Seiten einer Trunk-Verbindung identisch konfiguriert sein, sonst entstehen Fehler (VLAN-Mismatch). Aus Sicherheitsgründen empfiehlt es sich, das Native VLAN auf einen ungenutzten VLAN-Wert zu setzen, um sogenannte **VLAN-Hopping-Angriffe** zu erschweren.

### 3.4 Inter-VLAN-Routing

Da VLANs voneinander isolierte Layer-2-Segmente sind, ist für die Kommunikation zwischen ihnen ein **Layer-3-Gerät** notwendig. Es gibt zwei gängige Architekturen:

**Router-on-a-Stick:**  
Ein einzelner physischer Router-Port wird als Trunk konfiguriert und in mehrere logische Subinterfaces aufgeteilt – eines pro VLAN. Der Router routet den Datenverkehr zwischen den VLANs über diesen einen Uplink.

```
[Switch] ──── (Trunk) ──── [Router]
  VLAN 10                  ├── Subif 0.10: 192.168.10.1/24
  VLAN 20                  └── Subif 0.20: 192.168.20.1/24
```

**Layer-3-Switch (SVIs):**  
Ein Layer-3-Switch kann das Routing intern durchführen. Für jedes VLAN wird eine virtuelle Layer-3-Schnittstelle (**SVI – Switched Virtual Interface**) angelegt. Dies ist die leistungsfähigere und in Unternehmensnetzen bevorzugte Variante, da das Routing im ASIC des Switches stattfindet und dadurch sehr schnell ist.

---

## 4. VLAN-Typen

| VLAN-Typ | Beschreibung |
|---|---|
| **Default VLAN** | VLAN 1, alle Ports sind standardmäßig Mitglied; sollte aus Sicherheitsgründen nicht für Nutzdaten verwendet werden |
| **Data VLAN** | Für regulären Nutzdatenverkehr der Endgeräte |
| **Management VLAN** | Für den administrativen Zugriff auf Netzwerkgeräte (SSH, SNMP, etc.) |
| **Voice VLAN** | Separiertes VLAN für VoIP-Geräte, ermöglicht QoS-Priorisierung |
| **Native VLAN** | Ungetaggtes VLAN auf Trunk-Ports |

---

## 5. Grafische Übersicht

```
Physischer Switch
┌─────────────────────────────────────────────────┐
│  Port 1    Port 2    Port 3    Port 4   Trunk   │
│  [VLAN10] [VLAN10] [VLAN20] [VLAN20]  [10+20]  │
└────┬──────────┬──────────┬──────────┬──────┬───┘
     │          │          │          │      │
    PC-A       PC-B      PC-C      PC-D   Router
  10.0.0.1  10.0.0.2  20.0.0.1  20.0.0.2

  ◄─── VLAN 10 (Entwicklung) ──►  ◄── VLAN 20 (Buchhaltung) ──►

 PC-A ↔ PC-B: direkte Kommunikation ✓ (gleiches VLAN)
 PC-A ↔ PC-C: nur über Router möglich (verschiedene VLANs)
```

*Legende: Geräte im gleichen VLAN bilden eine gemeinsame Broadcast-Domain.*

---

## 6. Protokolle und Standards

### IEEE 802.1Q
Der zentrale Standard für VLAN-Tagging in Ethernet-Netzen. Er definiert das Frame-Format, die VLAN-ID-Vergabe sowie das Verhalten von Access- und Trunk-Ports. Praktisch alle modernen Switches unterstützen diesen Standard.

### IEEE 802.1ad (Q-in-Q / Double Tagging)
Eine Erweiterung von 802.1Q für Provider-Netzwerke (Carrier Ethernet). Hier werden zwei 802.1Q-Tags verschachtelt: ein **Service-Tag (S-Tag)** des Providers und ein **Customer-Tag (C-Tag)** des Kunden. Dadurch können Provider mehrere Kundennetzwerke über dasselbe physische Netz transportieren, ohne dass die VLAN-IDs der Kunden kollidieren.

### VTP – VLAN Trunking Protocol (Cisco-proprietär)
Ein Cisco-eigenes Protokoll, das die VLAN-Konfiguration automatisch über alle Switches in einer VTP-Domain synchronisiert. Es unterscheidet die Modi Server, Client und Transparent. Obwohl es die Verwaltung erleichtert, gilt VTP wegen seiner Fehleranfälligkeit und dem Risiko ungewollter VLAN-Löschungen in vielen Organisationen als umstritten.

### GVRP / MVRP
Offene Standards (IEEE 802.1Q / 802.1ak) für die dynamische VLAN-Registrierung – die herstellerneutrale Alternative zu VTP.

---

## 7. Produkte, Tools und Hersteller

### Hardware-Hersteller (Managed Switches mit VLAN-Unterstützung)

| Hersteller | Produktreihen |
|---|---|
| **Cisco** | Catalyst 9000, Nexus (Datacenter), Meraki (Cloud-managed) |
| **Juniper Networks** | EX Series, QFX Series |
| **HP / Aruba** | Aruba CX, ProCurve |
| **MikroTik** | RouterOS-basierte Switches (kostengünstig, sehr konfigurierbar) |
| **Netgear** | Smart Switches (ProSAFE-Serie) |
| **TP-Link** | TL-SG und T-Serien (Einsteiger/KMU) |
| **Ubiquiti** | UniFi-Switches (cloud-managed, beliebt im Heimbereich) |

### Software & Simulation

| Tool | Verwendungszweck |
|---|---|
| **Cisco Packet Tracer** | Netzwerksimulation, ideal zum Lernen und Testen von VLAN-Konfigurationen |
| **GNS3** | Emulation echter Netzwerkbetriebssysteme (IOS, JunOS) |
| **EVE-NG** | Professionelle Netzwerkemulationsplattform |
| **Open vSwitch (OVS)** | Software-Switch für virtuelle/Cloud-Umgebungen, VLAN-fähig |
| **Linux (ip/bridge)** | Native VLAN-Unterstützung über `ip link add link eth0 name eth0.10 type vlan id 10` |

---

## 8. Konfigurationsbeispiel (Cisco IOS)

Das folgende Beispiel zeigt exemplarisch, wie ein VLAN auf einem Cisco-Switch konfiguriert und einem Port zugewiesen wird – sowie wie ein Trunk-Port eingerichtet wird:

```bash
! VLAN erstellen
Switch(config)# vlan 10
Switch(config-vlan)# name Entwicklung

Switch(config)# vlan 20
Switch(config-vlan)# name Buchhaltung

! Access Port für VLAN 10 konfigurieren
Switch(config)# interface FastEthernet 0/1
Switch(config-if)# switchport mode access
Switch(config-if)# switchport access vlan 10

! Trunk Port konfigurieren (z. B. Uplink zum Router)
Switch(config)# interface GigabitEthernet 0/1
Switch(config-if)# switchport mode trunk
Switch(config-if)# switchport trunk allowed vlan 10,20

! Inter-VLAN-Routing via SVI (Layer-3-Switch)
Switch(config)# ip routing
Switch(config)# interface vlan 10
Switch(config-if)# ip address 192.168.10.1 255.255.255.0
Switch(config)# interface vlan 20
Switch(config-if)# ip address 192.168.20.1 255.255.255.0
```

---

## 9. Sicherheitsaspekte

VLANs werden oft als Sicherheitsmaßnahme eingesetzt, haben jedoch auch bekannte Schwachstellen:

- **VLAN Hopping:** Durch gezieltes Senden von Frames mit doppeltem VLAN-Tag (Double Tagging) oder durch Manipulation des Trunk-Aushandlungsprotokolls (DTP) kann ein Angreifer unter Umständen in ein fremdes VLAN eindringen. Gegenmaßnahme: Native VLAN auf ein ungenutztes VLAN setzen, DTP deaktivieren.
- **Switch Spoofing:** Ein Angreifer täuscht vor, ein Switch zu sein, und handelt einen Trunk-Link aus. Gegenmaßnahme: DTP auf Access Ports deaktivieren (`switchport nonegotiate`).
- **VLAN ≠ Firewall:** VLANs sind kein Ersatz für Firewalls. Sie trennen Broadcast-Domains, bieten aber keinen umfassenden Schutz vor Angriffen auf Layer 3 und höher.

---

## 10. Zusammenfassung

VLANs sind ein grundlegendes und unverzichtbares Werkzeug in der modernen Netzwerktechnik. Sie ermöglichen die **logische Segmentierung** physischer Netzwerke, wodurch sich Sicherheit, Performance und Verwaltbarkeit erheblich verbessern lassen. Der Standard **IEEE 802.1Q** definiert das VLAN-Tagging auf Ethernet-Ebene und ist heute in nahezu jeder Managed-Switch-Plattform implementiert. Für die Kommunikation zwischen VLANs ist stets ein Layer-3-Gerät erforderlich – entweder ein Router (Router-on-a-Stick) oder ein Layer-3-Switch mit SVIs.

VLANs finden sich in Unternehmensnetzen, Rechenzentren, Schulen und sogar im Heimnetz – überall dort, wo Netze sauber getrennt, administriert und abgesichert werden sollen.

---

## Quellen

- IEEE Std 802.1Q-2022 – *IEEE Standard for Local and Metropolitan Area Networks – Bridges and Bridged Networks*. IEEE. https://standards.ieee.org/ieee/802.1Q/10394/
- Cisco Systems. *VLAN Configuration Guide, Cisco IOS Release 15.2(7)E (Catalyst 2960-X Switches)*. https://www.cisco.com/c/en/us/td/docs/switches/lan/catalyst2960x/software/15-2_7_e/configuration_guide/b_1527e_consolidated_2960x_cg/configuring_vlans.html
- Tanenbaum, A. S., & Wetherall, D. J. (2011). *Computer Networks* (5th ed.). Prentice Hall. Kapitel 4.8: VLANs.
- Odom, W. (2020). *CCNA 200-301 Official Cert Guide, Volume 1*. Cisco Press. Kapitel 8–10.
- Lammle, T. (2019). *CompTIA Network+ Study Guide*. Sybex. Kapitel 4: Switching Technologies.
