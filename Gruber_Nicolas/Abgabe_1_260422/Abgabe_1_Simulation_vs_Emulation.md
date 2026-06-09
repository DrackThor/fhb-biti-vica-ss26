# Simulation vs. Emulation

## 1. Einleitung

In der Informatik und insbesondere im Bereich der Virtualisierung begegnet man häufig den Begriffen **Simulation** und **Emulation**. Obwohl sie im alltäglichen Sprachgebrauch oft synonym verwendet werden, bezeichnen sie grundlegend verschiedene Konzepte. Beide Ansätze dienen dazu, ein System oder eine Umgebung nachzubilden – jedoch auf unterschiedliche Art und Weise und mit unterschiedlichen Zielsetzungen. Dieses Dokument erläutert die beiden Konzepte, grenzt sie voneinander ab und zeigt anhand konkreter Beispiele, wo sie in der Praxis Anwendung finden.

## 2. Was ist Simulation?

Eine **Simulation** bildet das *Verhalten* eines Systems nach, ohne dabei dessen interne Struktur exakt zu reproduzieren. Ziel ist es, die Ausgaben und Reaktionen eines Systems unter bestimmten Bedingungen vorherzusagen oder zu analysieren. Simulationen arbeiten in der Regel mit mathematischen Modellen und Algorithmen, die das Verhalten des Originals approximieren.

**Wesentliche Merkmale:**

- Nachbildung des **Verhaltens**, nicht der Hardware oder Architektur
- Basiert auf **mathematischen Modellen** und Abstraktionen
- Muss **nicht in Echtzeit** ablaufen
- Dient primär der **Analyse, Vorhersage und dem Testen**
- Originalkomponenten (z. B. Software) können in der Regel **nicht direkt** auf der Simulation ausgeführt werden

> **Beispiel:** Eine Flugsimulation (z. B. Microsoft Flight Simulator) bildet die Aerodynamik, Wetterbedingungen und Flugphysik nach. Es handelt sich dabei aber nicht um ein echtes Flugzeug-Cockpit – das Verhalten wird modelliert, nicht die Hardware reproduziert.

## 3. Was ist Emulation?

Eine **Emulation** hingegen repliziert die *vollständige Funktionsweise* eines Systems, inklusive seiner Hardware-Architektur und internen Abläufe. Das Ziel ist es, eine Umgebung zu schaffen, in der Original-Software **unverändert** ausgeführt werden kann, als würde sie auf der echten Hardware laufen.

**Wesentliche Merkmale:**

- Nachbildung der **gesamten Hardware-Architektur** in Software
- Ermöglicht die Ausführung von **Original-Software ohne Modifikation**
- Arbeitet häufig auf **Instruktionsebene** (CPU-Befehle werden einzeln übersetzt)
- In der Regel **langsamer** als das Original, da jede Hardware-Operation in Software nachgebildet wird
- Hohe **Kompatibilität** mit dem Originalsystem

> **Beispiel:** Ein Nintendo-64-Emulator auf dem PC übersetzt jeden einzelnen CPU-Befehl des N64-Prozessors (MIPS R4300i) in x86-Befehle. Originale N64-Spiele (ROMs) können dadurch ohne Änderung ausgeführt werden.

## 4. Gegenüberstellung: Simulation vs. Emulation

| Kriterium | Simulation | Emulation |
|---|---|---|
| **Ziel** | Verhalten nachbilden | System vollständig nachbilden |
| **Abstraktionsebene** | Hoch (Modelle, Algorithmen) | Niedrig (Hardware-Ebene) |
| **Software-Kompatibilität** | Original-Software läuft i. d. R. nicht | Original-Software läuft unverändert |
| **Geschwindigkeit** | Kann schneller oder langsamer als Echtzeit sein | Meist langsamer als das Original |
| **Genauigkeit** | Verhaltensgenau (behavioral accuracy) | Funktional exakt (functional accuracy) |
| **Ressourcenbedarf** | Variabel, abhängig vom Modell | Hoch, da gesamte Hardware nachgebildet wird |
| **Typischer Einsatz** | Forschung, Training, Planung | Kompatibilität, Archivierung, Testing |

## 5. Kontext und Anwendungsbereiche

### 5.1 Simulation in der Praxis

Simulationen finden sich in zahlreichen Bereichen:

- **Netzwerksimulation:** Tools wie *GNS3* (in Kombination mit echten Router-Images) oder *Cisco Packet Tracer* simulieren Netzwerktopologien, um Routing-Protokolle und Konfigurationen zu testen, bevor sie in Produktionsumgebungen eingesetzt werden.
- **Hardwareentwicklung:** Vor der Fertigung eines Chips wird dessen Verhalten in *VHDL/Verilog*-Simulatoren (z. B. *ModelSim*, *Vivado Simulator*) getestet.
- **Wissenschaft und Forschung:** Klimamodelle, Strömungssimulationen (CFD) oder molekulardynamische Simulationen nutzen mathematische Modelle, um komplexe physikalische Prozesse nachzubilden.
- **Cloud und Infrastruktur:** Tools wie *LocalStack* simulieren AWS-Cloud-Services lokal, ohne die tatsächliche AWS-Infrastruktur zu replizieren.

### 5.2 Emulation in der Praxis

Emulationen werden eingesetzt, wenn exakte Hardware-Kompatibilität gefordert ist:

- **Spielekonsolen-Emulation:** Projekte wie *Dolphin* (GameCube/Wii), *RPCS3* (PlayStation 3) oder *Yuzu/Ryujinx* (Nintendo Switch) ermöglichen das Ausführen von Konsolenspielen auf PCs.
- **Mainframe- und Legacy-Systeme:** Unternehmen nutzen Emulatoren wie *Hercules* (IBM Mainframe) oder *QEMU*, um alte Software auf moderner Hardware weiterzubetreiben.
- **Mobile Entwicklung:** *Android Emulator* (Teil von Android Studio) emuliert ARM-basierte Android-Geräte auf x86-PCs, um Apps ohne physisches Gerät zu testen.
- **Retro-Computing und Archivierung:** *MAME* (Multiple Arcade Machine Emulator) bewahrt die Funktionsfähigkeit historischer Arcade-Automaten und Computersysteme.

## 6. Technische Funktionsweise

### 6.1 Simulationsarchitektur

Eine Simulation besteht typischerweise aus folgenden Komponenten:

```
┌──────────────────────────────────────────────────┐
│                Simulationsumgebung                │
│                                                   │
│  ┌─────────────┐   ┌──────────────────────────┐  │
│  │ Eingabe-     │   │  Mathematisches Modell   │  │
│  │ parameter    │──>│  (Gleichungen, Regeln,   │  │
│  │              │   │   Zustandsautomaten)      │  │
│  └─────────────┘   └──────────┬───────────────┘  │
│                                │                   │
│                    ┌───────────▼───────────────┐  │
│                    │  Berechnungs-Engine        │  │
│                    │  (Zeitschritte, Events)    │  │
│                    └───────────┬───────────────┘  │
│                                │                   │
│                    ┌───────────▼───────────────┐  │
│                    │  Ergebnis / Visualisierung │  │
│                    └──────────────────────────-┘  │
└──────────────────────────────────────────────────┘
```

Der Simulationskern iteriert über Zeitschritte oder Ereignisse und berechnet den neuen Systemzustand anhand der definierten Modelle. Die Ergebnisse werden anschließend ausgewertet oder visualisiert.

### 6.2 Emulationsarchitektur

Ein Emulator setzt die komplette Zielarchitektur in Software um:

```
┌──────────────────────────────────────────────────┐
│              Host-System (z. B. x86 PC)          │
│                                                   │
│  ┌──────────────────────────────────────────┐    │
│  │            Emulator-Software              │    │
│  │                                           │    │
│  │  ┌──────────┐  ┌──────────┐  ┌────────┐ │    │
│  │  │ Virtuelle│  │ Virtueller│  │ Virt.  │ │    │
│  │  │   CPU    │  │   RAM     │  │ GPU    │ │    │
│  │  └────┬─────┘  └─────┬────┘  └───┬────┘ │    │
│  │       │               │           │       │    │
│  │  ┌────▼───────────────▼───────────▼────┐ │    │
│  │  │     Virtuelle Bus-/IO-Schnittstelle │ │    │
│  │  └────────────────┬───────────────────-┘ │    │
│  │                   │                       │    │
│  │  ┌────────────────▼───────────────────┐  │    │
│  │  │   Original-Software / ROM / BIOS   │  │    │
│  │  └────────────────────────────────────┘  │    │
│  └──────────────────────────────────────────┘    │
└──────────────────────────────────────────────────┘
```

Der Emulator übersetzt (**interpretiert** oder **recompiliert**) jeden Maschinenbefehl der Ziel-CPU in Befehle der Host-CPU. Bei der *Interpretation* wird jeder Befehl einzeln übersetzt und sofort ausgeführt. Bei der *dynamischen Recompilation* (JIT – Just-In-Time Compilation) werden ganze Befehlsblöcke vorab übersetzt und gecacht, was deutlich schneller ist.

## 7. Gängige Tools und Produkte

| Kategorie | Tool / Produkt | Beschreibung |
|---|---|---|
| **Netzwerksimulation** | Cisco Packet Tracer | Simulation von Cisco-Netzwerkgeräten für Lehrzwecke |
| **Netzwerksimulation** | GNS3 | Netzwerksimulation mit echten Router-Images |
| **Netzwerksimulation** | ns-3 | Open-Source-Netzwerksimulator für Forschung |
| **Cloud-Simulation** | LocalStack | Lokale Simulation von AWS-Services |
| **Hardware-Emulation** | QEMU | Open-Source-Emulator für diverse CPU-Architekturen |
| **Konsolen-Emulation** | Dolphin | Emulator für Nintendo GameCube und Wii |
| **Konsolen-Emulation** | RPCS3 | PlayStation-3-Emulator |
| **Mainframe-Emulation** | Hercules | IBM-Mainframe-Emulator (System/370, ESA/390, z/Architecture) |
| **Mobile Emulation** | Android Emulator | ARM-Emulation für Android-App-Entwicklung |
| **Retro-Archivierung** | MAME | Emulation historischer Arcade- und Computersysteme |
| **Hardware-Simulation** | ModelSim / Vivado | FPGA- und ASIC-Design-Simulation |

## 8. Abgrenzung zur Virtualisierung

Es ist wichtig, Emulation und Simulation auch von **Virtualisierung** abzugrenzen. Bei der Virtualisierung wird die Hardware nicht nachgebildet, sondern durch einen **Hypervisor** direkt an die virtuelle Maschine durchgereicht. Der Gastcode läuft nativ auf der CPU, was deutlich performanter ist als Emulation. Virtualisierung setzt jedoch voraus, dass Gast- und Host-Architektur **identisch** sind (z. B. x86 auf x86), während ein Emulator auch fremde Architekturen abbilden kann (z. B. ARM auf x86).

```
  Emulation              Virtualisierung          Simulation
  ─────────              ────────────────          ──────────
  Hardware in            Hardware wird             Verhalten wird
  Software               durchgereicht             modelliert
  nachgebaut             (Hypervisor)              (mathematisch)
       │                      │                         │
  Fremde Arch.           Gleiche Arch.             Keine Arch.
  möglich                erforderlich              relevant
```

## 9. Fazit

Simulation und Emulation sind beide mächtige Werkzeuge, die jeweils für spezifische Anwendungsfälle optimiert sind. Während die **Simulation** die beste Wahl für Analyse, Forschung und Vorhersage ist, eignet sich die **Emulation** immer dann, wenn Original-Software auf einer anderen Plattform ausgeführt werden muss. In der Praxis ergänzen sich beide Ansätze oft – beispielsweise nutzt ein Netzwerklabor sowohl simulierte Topologien (Packet Tracer) als auch emulierte Router-Images (GNS3 mit echtem Cisco IOS). Das Verständnis der Unterschiede hilft bei der Wahl des richtigen Werkzeugs für den jeweiligen Einsatzzweck.

## Quellen

1. Smith, J. E., & Nair, R. (2005). *Virtual Machines: Versatile Platforms for Systems and Processes*. Morgan Kaufmann.
2. Cisco Systems. (2024). Cisco Packet Tracer. https://www.netacad.com/courses/packet-tracer
3. QEMU Project. (2024). QEMU – Generic Machine Emulator and Virtualizer. https://www.qemu.org/
4. GNS3 Project. (2024). GNS3 – The software that empowers network professionals. https://www.gns3.com/
5. MAME Project. (2024). MAME – Multiple Arcade Machine Emulator. https://www.mamedev.org/
6. Tanenbaum, A. S., & Bos, H. (2014). *Modern Operating Systems* (4th ed.). Pearson.
7. LocalStack. (2024). LocalStack – A fully functional local cloud stack. https://localstack.cloud/
