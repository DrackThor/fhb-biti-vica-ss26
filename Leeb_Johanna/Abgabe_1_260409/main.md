# Governance & Policies in Virtualisierung und Cloud

## 1. Begriffserklärung

Unter **„Governance & Policies“** im Kontext von Virtualisierung und Cloud versteht man die Gesamtheit aller Regeln, Richtlinien, Prozesse und Kontrollmechanismen, die festlegen, wie IT-Ressourcen bereitgestellt, genutzt, überwacht und abgesichert werden. Ziel ist es, den Einsatz von virtuellen Maschinen, Containern und Cloud-Diensten strukturiert, sicher und effizient zu gestalten.

**Governance** beschreibt dabei die übergeordneten Leitlinien und Verantwortlichkeiten innerhalb einer Organisation. Dazu gehören unter anderem Entscheidungsstrukturen, Compliance-Vorgaben und organisatorische Regeln.  

**Policies** (Richtlinien) sind konkrete, technisch umsetzbare Vorschriften, die festlegen, was erlaubt ist und was nicht – beispielsweise Zugriffsbeschränkungen oder Sicherheitsregeln.

---

## 2. Kontext und Einsatzgebiet

Governance & Policies sind besonders wichtig in modernen IT-Umgebungen, in denen **Virtualisierung und Cloud-Technologien** eine zentrale Rolle spielen. Ohne klare Regeln kann es schnell zu Problemen kommen, etwa:

- unkontrollierte Erstellung von virtuellen Maschinen („VM-Sprawl“)
- Sicherheitslücken durch falsche Konfigurationen
- Kostenexplosion durch ungenutzte Ressourcen
- Verstöße gegen gesetzliche Vorschriften (z. B. DSGVO)

Typische Einsatzbereiche sind:

- **Private Cloud** (z. B. im Rechenzentrum eines Unternehmens)  
- **Public Cloud** (z. B. Microsoft Azure, AWS, Google Cloud)  
- **Hybrid- und Multi-Cloud-Umgebungen**  

In diesen Szenarien sorgt Governance dafür, dass alle Systeme einheitlich verwaltet werden, während Policies automatisiert sicherstellen, dass Regeln auch eingehalten werden.

---

## 3. Technische Funktionsweise (grob)

Die technische Umsetzung erfolgt meist durch spezielle Tools und Plattformfunktionen. Der Prozess lässt sich vereinfacht wie folgt darstellen:

1. **Definition von Richtlinien**
   - z. B. „Nur bestimmte VM-Typen dürfen erstellt werden“
   - „Daten müssen verschlüsselt sein“

2. **Implementierung in Systemen**
   - Policies werden in Management-Tools hinterlegt
   - z. B. als JSON-Definition oder Regelset

3. **Automatische Durchsetzung**
   - Systeme prüfen bei jeder Aktion die Regeln
   - Verstöße werden blockiert oder gemeldet

4. **Überwachung und Reporting**
   - Logs und Monitoring zeigen, ob Policies eingehalten werden
   - Audits helfen bei der Kontrolle

5. **Anpassung und Optimierung**
   - Policies werden regelmäßig aktualisiert

---

## 4. Gängige Protokolle, Tools und Hersteller

### Wichtige Technologien und Konzepte

- **Identity & Access Management (IAM)**: Steuerung von Benutzerrechten  
- **Role-Based Access Control (RBAC)**: Zugriff nach Rollen  
- **Encryption (z. B. TLS/SSL)**: Sicherung der Datenübertragung  
- **Logging & Monitoring (z. B. Syslog, SIEM-Systeme)**  

### Bekannte Tools und Plattformen

- **Microsoft Azure Policy**  
  → Verwaltung und Durchsetzung von Cloud-Regeln  

- **AWS Organizations & AWS Config**  
  → Governance und Compliance in AWS  

- **Google Cloud Policy Intelligence**  
  → Analyse und Steuerung von Berechtigungen  

- **VMware vSphere & vCenter**  
  → Verwaltung von virtuellen Maschinen im Rechenzentrum  

- **Kubernetes (z. B. mit Admission Controller, OPA/Gatekeeper)**  
  → Richtlinien für Container-basierte Anwendungen  

### Open-Source-Projekte

- **Open Policy Agent (OPA)**  
  → Universelle Policy-Engine für Cloud und Microservices  

- **Terraform (HashiCorp)**  
  → Infrastruktur als Code mit Policy-Integration  

- **Prometheus & Grafana**  
  → Monitoring und Visualisierung  

---

## 5. Beispielhafte Architektur (vereinfacht)

``
