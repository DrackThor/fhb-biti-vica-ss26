#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Kleiner HTTP(S)-Dienst, der technische Details DIESER VM ausliefert.

Endpunkte:
  GET /          -> HTML-Dashboard mit allen Details
  GET /api/info  -> dieselben Daten als JSON

Der Dienst lauscht auf:
  Port 80  (HTTP)
  Port 443 (HTTPS, self-signed) – nur wenn Zertifikate vorhanden sind.

Bewusst OHNE Fremdpakete (nur Python-Standardbibliothek), damit cloud-init
nichts via pip nachinstallieren muss und der Start robust bleibt.
"""

import html as _html
import json
import os
import ssl
import subprocess
import threading
from datetime import datetime, timezone
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

# ---------------------------------------------------------------------------
# Befehle, deren Ausgabe die in der Angabe geforderten Details liefert:
# IP-Adresse, Storage, Memory, Kernel-Typ, Hypervisor, Filesysteme, ...
# ---------------------------------------------------------------------------
COMMANDS = {
    # Hostname (FQDN)
    "hostname":      ["hostname", "-f"],
    # Betriebssystem (PRETTY_NAME aus /etc/os-release)
    "os_release":    ["bash", "-lc", "source /etc/os-release && echo \"$PRETTY_NAME\""],
    # Kernel-Typ: Name, Release, Architektur, OS
    "kernel":        ["uname", "-srmo"],
    # Hypervisor / Virtualisierung (z. B. "kvm")
    "hypervisor":    ["systemd-detect-virt"],
    # CPU-Eckdaten
    "cpu":           ["bash", "-lc", "lscpu | grep -E 'Model name|^CPU\\(s\\)|Architecture'"],
    # Arbeitsspeicher (Memory)
    "memory":        ["free", "-h"],
    # IPv4-Adressen je Netzwerk-Interface
    "ip_v4":         ["ip", "-brief", "-4", "addr", "show"],
    # IPv6-Adressen je Netzwerk-Interface
    "ip_v6":         ["ip", "-brief", "-6", "addr", "show"],
    # Storage / Block-Devices
    "block_devices": ["lsblk", "-o", "NAME,SIZE,TYPE,MOUNTPOINT"],
    # Eingehängte Filesysteme inkl. Typ und Auslastung
    "filesystems":   ["df", "-hT", "-x", "tmpfs", "-x", "devtmpfs", "-x", "overlay"],
    # Laufzeit seit Boot
    "uptime":        ["uptime", "-p"],
}


def run(cmd):
    """Fuehrt ein Kommando aus und liefert die getrimmte Ausgabe.
    Faengt Fehler ab, damit der Dienst niemals abstuerzt."""
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=10)
        return (result.stdout or result.stderr).strip()
    except Exception as exc:  # noqa: BLE001 - bewusst breit, Robustheit vor Eleganz
        return "<Fehler: %s>" % exc


def collect():
    """Sammelt alle Detailinformationen in ein Dictionary."""
    data = {key: run(cmd) for key, cmd in COMMANDS.items()}
    # Zeitstempel der Erhebung (UTC)
    data["generated_at"] = datetime.now(timezone.utc).isoformat()
    return data


def render_html(data):
    """Rendert die gesammelten Daten als einfaches HTML-Dashboard."""
    sections = "".join(
        "<section><h2>{k}</h2><pre>{v}</pre></section>".format(
            k=_html.escape(key), v=_html.escape(value)
        )
        for key, value in data.items()
    )
    # Doppelte geschweifte Klammern {{ }} sind in .format() ein literales { }.
    return """<!doctype html>
<html lang="de"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>VM Info - {host}</title>
<style>
 body{{font-family:system-ui,Segoe UI,sans-serif;margin:0;background:#0f172a;color:#e2e8f0}}
 header{{padding:1.5rem 2rem;background:#1e293b;border-bottom:1px solid #334155}}
 h1{{margin:0;font-size:1.35rem}}
 main{{padding:1rem 2rem;max-width:960px}}
 section{{margin:1rem 0}}
 h2{{font-size:.78rem;text-transform:uppercase;letter-spacing:.06em;color:#94a3b8;margin:.4rem 0}}
 pre{{background:#1e293b;padding:.8rem 1rem;border-radius:8px;overflow:auto;
     border:1px solid #334155;white-space:pre-wrap;word-break:break-word}}
 a{{color:#38bdf8}}
 footer{{padding:1rem 2rem;color:#64748b;font-size:.8rem}}
</style></head>
<body>
 <header><h1>Technische Details dieser VM &middot; Exoscale</h1></header>
 <main>{sections}
   <p><a href="/api/info">&rarr; Dieselben Daten als JSON (/api/info)</a></p>
 </main>
 <footer>Erhoben am {ts} &middot; cloud-init + Python-Standardbibliothek</footer>
</body></html>""".format(
        host=_html.escape(data.get("hostname", "")),
        sections=sections,
        ts=_html.escape(data.get("generated_at", "")),
    )


class Handler(BaseHTTPRequestHandler):
    """Beantwortet GET-Requests mit HTML bzw. JSON."""

    def _send(self, code, body, content_type):
        self.send_response(code)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):  # noqa: N802 - von BaseHTTPRequestHandler vorgegeben
        data = collect()
        path = self.path.split("?", 1)[0].rstrip("/")
        if path == "/api/info":
            self._send(200, json.dumps(data, indent=2, ensure_ascii=False).encode("utf-8"),
                       "application/json; charset=utf-8")
        elif path in ("", "/"):
            self._send(200, render_html(data).encode("utf-8"),
                       "text/html; charset=utf-8")
        else:
            self._send(404, b"Not Found", "text/plain; charset=utf-8")

    def log_message(self, *args):  # Logs ruhig halten (journald)
        return


def serve_http():
    """HTTP auf Port 80 (Vordergrund-Dienst, haelt den Prozess am Leben)."""
    ThreadingHTTPServer(("0.0.0.0", 80), Handler).serve_forever()


def serve_https():
    """HTTPS auf Port 443 mit self-signed Zertifikat (best effort)."""
    cert, key = "/opt/vminfo/tls/cert.pem", "/opt/vminfo/tls/key.pem"
    if not (os.path.exists(cert) and os.path.exists(key)):
        return  # ohne Zertifikat einfach kein HTTPS
    context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
    context.load_cert_chain(certfile=cert, keyfile=key)
    httpd = ThreadingHTTPServer(("0.0.0.0", 443), Handler)
    httpd.socket = context.wrap_socket(httpd.socket, server_side=True)
    httpd.serve_forever()


if __name__ == "__main__":
    # HTTPS im Hintergrund-Thread, HTTP im Vordergrund.
    threading.Thread(target=serve_https, daemon=True).start()
    serve_http()
