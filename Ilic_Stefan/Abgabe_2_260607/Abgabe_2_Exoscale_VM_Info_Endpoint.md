# Abgabe 2 – Automatisierte Exoscale-VM mit technischem Info-Endpunkt

Vollautomatisierte Bereitstellung einer Ubuntu-VM auf **Exoscale**, die unter
zwei HTTPS-URLs technische Details über sich selbst ausliefert – als **Website
(HTML)** und als **API (JSON)**. Erstellung und Löschung laufen über
**GitHub-Workflows** mit **OpenTofu** und **CloudInit**.

## Herangehensweise

Der geforderte Zielzustand verlangt eine VM, die per URL ihre eigenen
technischen Daten liefert, vollständig automatisiert erstellt und gelöscht.

| Anforderung | Umsetzung |
|---|---|
| Infrastruktur erstellen/löschen | OpenTofu, je ein GitHub-Workflow |
| Unterstütztes Ubuntu | `Linux Ubuntu 26.04 LTS 64-bit` (Template-Lookup) |
| OS-Konfiguration automatisiert | CloudInit (Caddy, Info-Generator, Timer) |
| HTTP(S)-Endpunkt mit VM-Details | Caddy liefert HTML + JSON |
| **HTTPS + Zertifikat (Bonus)** | Let's Encrypt, automatisch durch Caddy |
| **DNS (Bonus)** | A-Records in der Exoscale-Zone `biti-fhb.org` |
| **Zwei Endpunkte (Bonus)** | zwei Subdomains (Website / API) |

### DNS und HTTPS

Terraform fragt die vom Kurs in Exoscale verwaltete DNS-Zone `biti-fhb.org` ab
(`data.exoscale_domain`) und legt dynamisch zwei A-Records an
(`exoscale_domain_record`), die auf die Public-IP der erzeugten VM zeigen:

- `ilic.biti-fhb.org` → Website (HTML)
- `api.ilic.biti-fhb.org` → API (JSON)

Da beide Domains bereits beim `apply` feststehen, werden sie via `templatefile`
direkt in das Caddyfile eingesetzt. Caddy bezieht beim Start automatisch
vertrauenswürdige Let's-Encrypt-Zertifikate für beide Subdomains. Über die
Variable `acme_staging` kann zum Testen auf die Staging-CA umgeschaltet werden,
um Produktions-Rate-Limits zu vermeiden.

### State-Verwaltung

Der OpenTofu-State wird lokal gehalten und vom Deploy-Workflow als
GitHub-Actions-Artefakt hochgeladen; der Destroy-Workflow lädt ihn wieder
herunter. So ist kein separates State-Backend (Bucket) nötig.

## Funktionsweise

```
GitHub Workflow (ilic_deploy.yml)
  └─ OpenTofu ─► Exoscale: Security Group (22/80/443+ICMP) + Ubuntu-VM
                   ├─ CloudInit: Caddy + Python-Generator + systemd-Timer (60s)
                   └─ DNS: A-Records ilic / api.ilic  →  Public-IP
        ┌─ https://ilic.biti-fhb.org/        → HTML (Website)
        └─ https://api.ilic.biti-fhb.org/    → JSON (API)
  └─ State als Artefakt hochgeladen

GitHub Workflow (ilic_destroy.yml) ─► State-Artefakt laden ─► OpenTofu destroy
```

Der Generator (`gen-info.py`) sammelt bei jedem Lauf Hostname, Public-IP, OS,
Kernel, Architektur, **Hypervisor** (`systemd-detect-virt`), CPU, RAM,
**Storage/Block-Devices** (`lsblk`) und **Filesysteme** (`df`) und schreibt
`index.html` + `api.json`. Der systemd-Timer ruft ihn jede Minute auf → die
Anzeige bleibt aktuell.

## Verwendung

### 1. GitHub-Secrets setzen

`Settings → Secrets and variables → Actions → Secrets`:

| Secret | Wert |
|---|---|
| `EXOSCALE_API_KEY` | Exoscale API-Key (Compute **und** DNS) |
| `EXOSCALE_API_SECRET` | zugehöriges Secret |

Optional unter `Variables` (sonst greifen die Defaults):
`SECOND_LEVEL_DOMAIN` (z. B. `ilic`), `ACME_STAGING` (`true`/`false`).

### 2. Deployen

`Actions → Deploy Infrastruktur → Run workflow`. URLs erscheinen danach im
Job-Summary. Erstes Zertifikat + DNS-Propagierung dauern 1–3 Minuten.

### 3. Prüfen

```bash
curl -s https://api.ilic.biti-fhb.org/ | jq    # JSON-API
# Website: https://ilic.biti-fhb.org/
```

### 4. Löschen

`Actions → Destroy Infrastruktur → Run workflow`, Feld `confirm` = `destroy`.

### Optional: SSH-Zugriff

Der Deploy-Workflow legt das private Keypair als Artefakt `ssh-private-key` ab:

```bash
chmod 600 deploy_key
ssh -i deploy_key ubuntu@<public_ip>
```

## Verzeichnisstruktur

```
Ilic_Stefan/Abgabe_2_260607/
├── Abgabe_2_Exoscale_VM_Info_Endpoint.md   # diese Doku
├── terraform/
│   ├── providers.tf      # Provider (kein Remote-Backend)
│   ├── variables.tf      # Eingabevariablen
│   ├── locals.tf         # zentrale Domain-Strings
│   ├── main.tf           # Security Group, DNS-Records, VM
│   ├── outputs.tf        # URLs + IP
│   └── cloud-init.yaml   # OS-Konfiguration (Template)
└── workflows/            # Doku-Kopien der Workflows

.github/workflows/        # im Repo-Root – hier laufen die Actions
├── ilic_deploy.yml
└── ilic_destroy.yml
```
