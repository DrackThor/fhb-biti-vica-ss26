# Abgabe 2 – Exoscale VM-Info



Diese Lösung erstellt mittels IaC eine VM in Exoscale, auf der ein
HTTP(S)-Endpunkt läuft, der technische Details dieser VM ausliefert
Erstellen und Löschen erfolgen über zwei GitHub-Workflows.

---

## Herangehensweise

**OpenTofu:** erstellt/löscht die Infrastruktur deklarativ.

**Remote-State in Exoscale SOS:** Jeder Workflow-Lauf startet auf einem neuen
Runner ohne lokalen State. Damit der *Löschen*-Workflow weiß, was der
*Erstellen*-Workflow gebaut hat, liegt der State in einem S3-kompatiblen
SOS-Bucket. Dieser wird im Create-Workflow automatisch angelegt (idempotent).

**cloud-init:**  OS-Konfiguration auf der VM

**Info-Dienst:** Python-Dienst sammelt die Daten bei Request live und liefert sie
als HTML bzw. JSON. HTTP auf Port 80, HTTPS (self-signed)
auf Port 443.

---

## Verzeichnisstruktur

```
.github/workflows/                  # MUSS im Repo-ROOT liegen (s. Abschnitt 5)
├── abgabe2-infra-create.yml        # Workflow: Infrastruktur erstellen
└── abgabe2-infra-destroy.yml       # Workflow: Infrastruktur löschen

Habel_Michael/Abgabe_2_260606/
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

---

## Funktionsweise im Detail

1. **`tofu init`** initialisiert das S3/SOS-Backend (Bucket-Name via
   `-backend-config`).
2. **`tofu apply`** erstellt:
   - einen `exoscale_template`-Lookup für *Ubuntu 24.04 LTS* in der Zone,
   - eine `exoscale_security_group` mit INGRESS-Regeln für 22/80/443,
   - optional einen `exoscale_ssh_key` (nur wenn `ssh_public_key` gesetzt ist),
   - eine `exoscale_compute_instance` mit dem cloud-init als `user_data`.
3. **cloud-init** auf der VM: Pakete installieren → `server.py` und systemd-Unit
   schreiben → self-signed Zertifikat erzeugen → Dienst `vminfo` starten.
4. **`server.py`** beantwortet Requests und liefert das Ergebnis als HTML/JSON.
5. **`tofu destroy`** entfernt alle Ressourcen wieder.

---

## Voraussetzungen & Einrichtung

### Exoscale

**IAM-API-Key:** Exoscale-Konsole → *IAM → API Keys*.

### GitHub-Secrets

Repo → Settings → Secrets and variables → Actions → *Secrets*

| Secret                | Bedeutung           |
| --------------------- | ------------------- |
| `EXOSCALE_API_KEY`    | Exoscale API-Key    |
| `EXOSCALE_API_SECRET` | Exoscale API-Secret |

---

## Speicherort der Workflows

GitHub Actions führt Workflows aus dem Verzeichnis
`.github/workflows/` im Repository-Root aus.
Die beiden YAML-Dateien liegen deshalb dort und verweisen über
`working-directory: Michael_Habel/Abgabe_2_260606/terraform` auf den Abgabeordner.

---

## Verwendung

1. **Secrets setzen** –  `EXOSCALE_API_KEY` und `EXOSCALE_API_SECRET`.
2. **Erstellen:** Reiter **Actions** → *„Abgabe2 - Infrastruktur erstellen“* →
   **Run workflow**.
3. Nach dem Lauf erscheint in der **Job-Zusammenfassung** (Summary) die
   **Ziel-URL** (HTTP, HTTPS und JSON) samt IP.
4. **Aufrufen:** URL im Browser öffnen
5. **Löschen:** Reiter **Actions** → *„Abgabe2 - Infrastruktur loeschen“* →
   **Run workflow**.---

---
