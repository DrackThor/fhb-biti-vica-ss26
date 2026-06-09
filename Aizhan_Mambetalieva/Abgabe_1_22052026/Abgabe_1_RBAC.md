# Role-Based Access Control (RBAC)

**Kurs:** BITI VICA 2026  
**Thema:** Rollenbasierte Zugriffskontrolle (RBAC)  
**Datum:** 22. Mai 2026

## 1. Was ist RBAC?
Role-Based Access Control (RBAC) ist ein Modell zur Steuerung von Zugriffsrechten in IT-Systemen. Im Gegensatz zur individuellen Rechtevergabe werden hier Berechtigungen an **Rollen** gebunden. Benutzer erhalten Zugriff, indem ihnen eine oder mehrere dieser Rollen zugewiesen werden.

## 2. Kontext und Verwendung
RBAC ist der Industriestandard für das Identity and Access Management (IAM). Es wird eingesetzt in:
* **Unternehmensnetzwerken:** (z.B. Microsoft Active Directory), um Abteilungen wie "Personal" oder "IT" Rechte zu geben.
* **Cloud-Plattformen:** (Azure, AWS, Google Cloud), um Ressourcen wie virtuelle Maschinen zu verwalten.
* **Containern:** In Kubernetes ist RBAC essenziell, um festzulegen, wer Pods erstellen oder löschen darf.

## 3. Technische Funktionsweise
Das System basiert auf einer dreistufigen Beziehung:
1.  **Benutzer:** Personen oder Systeme, die Zugriff benötigen.
2.  **Rollen:** Gruppierung von Berechtigungen (z.B. "Administrator", "Rechnungsprüfer").
3.  **Berechtigungen:** Erlaubnis für Aktionen (Lesen, Schreiben, Ausführen) auf Objekten (Dateien, APIs).

Durch **Rollenhierarchien** können Rechte vererbt werden. Ein "IT-Manager" erbt dabei automatisch die Rechte eines "IT-Technikers".

## 4. Gängige Tools und Beispiele
* **Microsoft Azure:** Nutzt vordefinierte Rollen wie "Owner", "Contributor" und "Reader".
* **Kubernetes:** Nutzt `ClusterRoles` und `RoleBindings` in YAML-Konfigurationen.
* **Keycloak:** Eine Open-Source-Lösung zur zentralen Verwaltung von Rollen über viele Anwendungen hinweg.

## 5. Fazit
RBAC reduziert den administrativen Aufwand massiv. Wenn ein Mitarbeiter die Abteilung wechselt, muss lediglich seine Rollenzugehörigkeit geändert werden, statt hunderte Einzelrechte manuell anzupassen. Dies erhöht die Sicherheit und erfüllt Compliance-Anforderungen.

---
*Quellen: Dokumentation von Microsoft Azure IAM, Kubernetes RBAC Guide, NIST RBAC Standard.*
