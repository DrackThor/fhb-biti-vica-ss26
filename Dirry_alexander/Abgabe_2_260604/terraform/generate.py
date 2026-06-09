#!/usr/bin/env python3
# =====================================================================
# generate.py
# ---------------------------------------------------------------------
# Sammelt technische Details ueber DIESE VM und schreibt sie an zwei
# Stellen ins Web-Verzeichnis:
#   * info.json   -> wird ueber den API-Endpunkt  /api  ausgeliefert
#   * index.html  -> wird ueber den Website-Endpunkt  /  ausgeliefert
#
# Das Skript wird per CloudInit auf die VM kopiert und dort von einem
# systemd-Timer jede Minute ausgefuehrt (=> die Anzeige bleibt aktuell).
# =====================================================================
import json
import subprocess
import datetime
import os

WEBROOT = "/var/www/vminfo"  # Verzeichnis, aus dem nginx ausliefert


def sh(cmd):
    """Fuehrt einen Shell-Befehl aus und gibt dessen Ausgabe als Text zurueck.
    Schlaegt der Befehl fehl, wird 'n/a' zurueckgegeben (robust gegen Fehler)."""
    try:
        return subprocess.check_output(
            cmd, shell=True, text=True, stderr=subprocess.DEVNULL
        ).strip()
    except Exception:
        return "n/a"


def os_pretty():
    """Liest den schoenen Betriebssystem-Namen aus /etc/os-release."""
    try:
        with open("/etc/os-release") as f:
            for line in f:
                if line.startswith("PRETTY_NAME="):
                    return line.split("=", 1)[1].strip().strip('"')
    except Exception:
        pass
    return "unknown"


# --- 1) Alle gewuenschten technischen Details einsammeln ----------------
info = {
    "hostname": sh("hostname"),
    # Zeitstempel der Generierung -> zeigt die Aktualitaet der Daten
    "generated_at_utc": datetime.datetime.now(datetime.timezone.utc)
    .replace(microsecond=0)
    .isoformat(),
    "operating_system": os_pretty(),
    "kernel": sh("uname -srmo"),                  # Kernel-Typ/Version/Arch
    "hypervisor": sh("systemd-detect-virt") or "none",  # z.B. kvm
    "uptime": sh("uptime -p"),
    # oeffentliche IP von einem externen Dienst abfragen
    "public_ip": sh("curl -s --max-time 5 https://api.ipify.org") or "unknown",
    "private_ip": sh("hostname -I"),
    "cpu_model": sh("grep -m1 'model name' /proc/cpuinfo | cut -d: -f2").strip(),
    "cpu_cores": sh("nproc"),
    "memory": sh(
        "free -h --si | awk 'NR==2{print $2\" gesamt, \"$3\" belegt, \"$4\" frei\"}'"
    ),
    # Block-Devices/Storage als strukturierte Liste (lsblk kann JSON ausgeben)
    "storage": json.loads(
        sh("lsblk -b -o NAME,SIZE,TYPE,MOUNTPOINT --json") or "{}"
    ).get("blockdevices", []),
    "filesystems": [],  # wird gleich befuellt
}

# Dateisysteme mit df einsammeln (Quelle, Typ, Groesse, belegt, frei, Mount)
df = sh(
    "df -h --output=source,fstype,size,used,avail,target "
    "-x tmpfs -x devtmpfs -x squashfs"
)
for line in df.splitlines()[1:]:           # erste Zeile = Ueberschrift -> ueberspringen
    cols = line.split()
    if len(cols) >= 6:
        info["filesystems"].append(
            {
                "device": cols[0],
                "type": cols[1],
                "size": cols[2],
                "used": cols[3],
                "avail": cols[4],
                "mount": cols[5],
            }
        )

# Sicherstellen, dass das Zielverzeichnis existiert
os.makedirs(WEBROOT, exist_ok=True)

# --- 2) JSON schreiben (das ist der API-Endpunkt /api) ------------------
with open(os.path.join(WEBROOT, "info.json"), "w") as f:
    json.dump(info, f, indent=2, ensure_ascii=False)

# --- 3) HTML schreiben (das ist der Website-Endpunkt /) -----------------
# Hilfsfunktion: Dateisystem-Zeilen als HTML-Tabellenzeilen erzeugen
fs_rows = "".join(
    f"<tr><td>{x['device']}</td><td>{x['type']}</td><td>{x['size']}</td>"
    f"<td>{x['used']}</td><td>{x['avail']}</td><td>{x['mount']}</td></tr>"
    for x in info["filesystems"]
)

html = f"""<!DOCTYPE html>
<html lang="de">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<!-- Seite laedt sich alle 60s neu -> Anzeige bleibt aktuell -->
<meta http-equiv="refresh" content="60">
<title>VM Info - {info['hostname']}</title>
<style>
  :root {{ --bg:#0f172a; --card:#1e293b; --ac:#38bdf8; --tx:#e2e8f0; --mut:#94a3b8; }}
  * {{ box-sizing:border-box; }}
  body {{ margin:0; font-family:system-ui,-apple-system,sans-serif;
         background:var(--bg); color:var(--tx); padding:2rem; }}
  h1 {{ color:var(--ac); margin:0 0 .25rem; font-size:1.6rem; }}
  .sub {{ color:var(--mut); margin-bottom:2rem; font-size:.9rem; }}
  .grid {{ display:grid; gap:1.25rem;
          grid-template-columns:repeat(auto-fit,minmax(320px,1fr)); }}
  .card {{ background:var(--card); border-radius:14px; padding:1.25rem 1.5rem;
          box-shadow:0 8px 24px rgba(0,0,0,.25); }}
  .card h2 {{ margin:0 0 .75rem; font-size:.8rem; color:var(--ac);
             text-transform:uppercase; letter-spacing:.06em; }}
  table {{ width:100%; border-collapse:collapse; font-size:.9rem; }}
  th {{ text-align:left; color:var(--mut); font-weight:500;
       padding:.35rem .75rem .35rem 0; vertical-align:top; white-space:nowrap; }}
  td {{ padding:.35rem 0; word-break:break-word; }}
  tr+tr th, tr+tr td {{ border-top:1px solid rgba(148,163,184,.15); }}
  a {{ color:var(--ac); }}
</style>
</head>
<body>
  <h1>VM-Information: {info['hostname']}</h1>
  <div class="sub">Automatisch generiert am {info['generated_at_utc']} (UTC)
    &middot; aktualisiert sich alle 60&nbsp;s
    &middot; <a href="/api">JSON-API ansehen &rarr;</a></div>
  <div class="grid">
    <div class="card"><h2>System</h2><table>
      <tr><th>Betriebssystem</th><td>{info['operating_system']}</td></tr>
      <tr><th>Kernel</th><td>{info['kernel']}</td></tr>
      <tr><th>Hypervisor</th><td>{info['hypervisor']}</td></tr>
      <tr><th>Uptime</th><td>{info['uptime']}</td></tr>
    </table></div>
    <div class="card"><h2>Netzwerk</h2><table>
      <tr><th>Public IP</th><td>{info['public_ip']}</td></tr>
      <tr><th>Private IP</th><td>{info['private_ip']}</td></tr>
    </table></div>
    <div class="card"><h2>CPU &amp; RAM</h2><table>
      <tr><th>CPU</th><td>{info['cpu_model']}</td></tr>
      <tr><th>Kerne</th><td>{info['cpu_cores']}</td></tr>
      <tr><th>Arbeitsspeicher</th><td>{info['memory']}</td></tr>
    </table></div>
    <div class="card" style="grid-column:1/-1"><h2>Dateisysteme</h2><table>
      <tr><th>Geraet</th><th>Typ</th><th>Groesse</th><th>Belegt</th>
          <th>Frei</th><th>Mount</th></tr>
      {fs_rows}
    </table></div>
  </div>
</body>
</html>"""

with open(os.path.join(WEBROOT, "index.html"), "w") as f:
    f.write(html)
