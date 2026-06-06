# Abgabe 2 – Exoscale VM-Info-Endpunkt (OpenTofu + GitHub Actions + cloud-init)

Diese Lösung erstellt **vollautomatisiert** eine VM in Exoscale, auf der ein
HTTP(S)-Endpunkt läuft, der technische Details *dieser* VM ausliefert
(IP-Adresse, Storage, Memory, Kernel-Typ, Hypervisor, Filesysteme, …).
Erstellen und Löschen erfolgen über zwei GitHub-Workflows.

---

## 1. Herangehensweise / Architektur

```
GitHub Actions (workflow_dispatch)
        │  EXOSCALE_API_KEY / _SECRET (Secrets)
        ▼
   OpenTofu  ──────────────►  Exoscale (Zone at-vie-1 / Wien)
        │                        ├─ Security Group (22 / 80 / 443)
        │                        └─ Compute-Instanz (Ubuntu 24.04 LTS)
        │                               │
        │                               └─ user_data = cloud-init
        │                                     ├─ installiert python3 + openssl
        │                                     ├─ schreibt /opt/vminfo/server.py
        │                                     ├─ erzeugt self-signed TLS-Zertifikat
        │                                     └─ startet systemd-Dienst "vminfo"
        │
        └─ State liegt remote in Exoscale SOS (S3-kompatibel)
           → der Destroy-Workflow findet den State wieder
```

**Designentscheidungen:**

- **OpenTofu** (kompatibel zu Terraform) erstellt/löscht die Infrastruktur
  deklarativ. Provider: [`exoscale/exoscale`](https://registry.terraform.io/providers/exoscale/exoscale/latest).
- **Remote-State in Exoscale SOS:** Jeder Workflow-Lauf startet auf einem neuen
  Runner ohne lokalen State. Damit der *Löschen*-Workflow weiß, was der
  *Erstellen*-Workflow gebaut hat, liegt der State in einem S3-kompatiblen
  SOS-Bucket. Dieser wird im Create-Workflow **automatisch angelegt** (idempotent).
- **cloud-init** übernimmt die **gesamte** OS-Konfiguration (Vorgabe): Pakete,
  Dienst-Code, TLS-Zertifikat, systemd-Unit.
- **Info-Dienst ohne Fremdpakete:** ein kleiner Python-Dienst (nur
  Standardbibliothek) sammelt die Daten bei *jedem* Request live und liefert sie
  als HTML (`/`) bzw. JSON (`/api/info`). HTTP auf Port 80, HTTPS (self-signed)
  auf Port 443.

---

## 2. Verzeichnisstruktur

```
.github/workflows/                  # MUSS im Repo-ROOT liegen (s. Abschnitt 5)
├── abgabe2-infra-create.yml        # Workflow: Infrastruktur erstellen
└── abgabe2-infra-destroy.yml       # Workflow: Infrastruktur löschen

Abgabe_2_xxx/
├── README.md                       # diese Datei
└── terraform/
    ├── versions.tf                 # Provider-Versionen + SOS-Remote-Backend
    ├── variables.tf                # Eingabeparameter (mit Defaults)
    ├── main.tf                     # VM, Security Group, Regeln, Template-Lookup
    ├── outputs.tf                  # Ausgaben: IP + Ziel-URLs
    ├── cloud-init.yaml.tftpl       # OS-Konfiguration (Terraform-Template)
    └── files/
        └── server.py               # der HTTP(S)-Info-Dienst (Quelle der Wahrheit)
```

> **`Abgabe_2_xxx` umbenennen:** `xxx` durch deine Kennung (z. B. Matrikelnummer)
> ersetzen. Wird der Ordner umbenannt, in **beiden** Workflows die Variable
> `TF_WORKDIR` entsprechend anpassen.

---

## 3. Funktionsweise im Detail

1. **`tofu init`** initialisiert das S3/SOS-Backend (Bucket-Name via
   `-backend-config`).
2. **`tofu apply`** erstellt:
   - einen `exoscale_template`-Lookup für *Ubuntu 24.04 LTS* in der Zone,
   - eine `exoscale_security_group` mit INGRESS-Regeln für 22/80/443,
   - optional einen `exoscale_ssh_key` (nur wenn `ssh_public_key` gesetzt ist),
   - eine `exoscale_compute_instance` mit dem cloud-init als `user_data`.
3. **cloud-init** auf der VM: Pakete installieren → `server.py` und systemd-Unit
   schreiben → self-signed Zertifikat erzeugen → Dienst `vminfo` starten.
4. **`server.py`** beantwortet Requests, indem es Live-Kommandos ausführt
   (`uname`, `free`, `lsblk`, `df`, `ip`, `systemd-detect-virt`, …) und das
   Ergebnis als HTML/JSON ausliefert.
5. **`tofu destroy`** entfernt alle Ressourcen wieder.

---

## 4. Voraussetzungen & Einrichtung

### 4.1 Exoscale
- Ein Exoscale-Account.
- Ein **IAM-API-Key** (Key + Secret) mit Rechten für *Compute* und *SOS*
  (für den Kurs genügt ein unrestricted Key). Exoscale-Konsole → *IAM → API Keys*.

### 4.2 GitHub-Secrets (Repo → Settings → Secrets and variables → Actions → *Secrets*)

| Secret                | Pflicht | Bedeutung                                   |
|-----------------------|:-------:|---------------------------------------------|
| `EXOSCALE_API_KEY`    |   ja    | Exoscale API-Key                            |
| `EXOSCALE_API_SECRET` |   ja    | Exoscale API-Secret                         |
| `SSH_PUBLIC_KEY`      |  nein   | öffentlicher SSH-Key für optionalen Zugang  |

### 4.3 GitHub-Variable (Reiter *Variables*) – optional

| Variable          | Default                              | Bedeutung                          |
|-------------------|--------------------------------------|------------------------------------|
| `TF_STATE_BUCKET` | `fhb-biti-vica-ss26-abgabe2-tfstate` | Name des SOS-Buckets für den State |

> Nur ändern, falls der Default-Bucketname in deiner Exoscale-Organisation
> bereits vergeben ist.

---

## 5. Wichtig: Speicherort der Workflows

GitHub Actions führt Workflows **ausschließlich** aus dem Verzeichnis
`.github/workflows/` im **Repository-Root** aus – nicht aus Unterordnern.
Die beiden YAML-Dateien liegen deshalb dort und verweisen über
`working-directory: Abgabe_2_xxx/terraform` auf den Abgabeordner.
Der restliche Code (Terraform, cloud-init, Doku) liegt wie gefordert komplett
unter `Abgabe_2_xxx/`.

---

## 6. Verwendung (wird bei der Beurteilung angewendet)

1. **Secrets setzen** (Abschnitt 4.2) – mindestens `EXOSCALE_API_KEY` und
   `EXOSCALE_API_SECRET`.
2. **Erstellen:** Reiter **Actions** → *„Abgabe2 - Infrastruktur erstellen“* →
   **Run workflow**.
3. Nach dem Lauf erscheint in der **Job-Zusammenfassung** (Summary) die
   **Ziel-URL** (HTTP, HTTPS und JSON) samt IP.
4. **Aufrufen:** URL im Browser öffnen (ca. 1–2 Min. nach dem Apply, bis
   cloud-init fertig ist). Es erscheint das Dashboard mit den VM-Details.
   - JSON: `http://<IP>/api/info`
   - HTTPS: `https://<IP>/` (self-signed → Browser-Warnung ist erwartet und ok)
5. **Löschen:** Reiter **Actions** → *„Abgabe2 - Infrastruktur loeschen“* →
   **Run workflow**.

Schneller Test per Kommandozeile:

```bash
curl http://<IP>/                 # HTML
curl http://<IP>/api/info         # JSON
curl -k https://<IP>/             # HTTPS (self-signed -> -k)
```

---

## 7. Was der Endpunkt liefert

Hostname (FQDN), Betriebssystem, **Kernel-Typ**, **Hypervisor/Virtualisierung**,
CPU, **Memory**, **IPv4/IPv6-Adressen** je Interface, **Storage/Block-Devices**,
eingehängte **Filesysteme** (inkl. Typ und Auslastung) und Uptime – jeweils live
zum Zeitpunkt des Requests erhoben.

---

## 8. Hinweise

- **Kosten:** `standard.micro` ist klein und günstig; nach dem Test bitte den
  *Löschen*-Workflow ausführen.
- **Zone:** Standard ist `at-vie-1` (Wien). Eine andere Zone erfordert das
  Anpassen von `var.zone` **und** des Backend-Blocks in `versions.tf`
  (Region + SOS-Endpunkt), da diese zusammenpassen müssen.
- **Idempotenz:** Mehrfaches Ausführen des Create-Workflows ändert nichts, wenn
  sich die Konfiguration nicht ändert (deklaratives IaC).
