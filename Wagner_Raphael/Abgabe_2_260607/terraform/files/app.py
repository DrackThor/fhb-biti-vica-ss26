#!/usr/bin/env python3
"""Small VM information service for Abgabe 2.

The service listens only on 127.0.0.1:8080. Caddy publishes it on HTTP or HTTPS.
It deliberately uses only the Python standard library so cloud-init does not
need pip, virtual environments, or extra package repositories.
"""

from __future__ import annotations

import html
import json
import os
import platform
import shutil
import socket
import subprocess
import time
import urllib.error
import urllib.request
from datetime import datetime, timezone
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from typing import Any


# Exoscale exposes useful instance facts through the metadata service. These
# values prove that the page describes the currently addressed VM.
METADATA_ENDPOINTS = {
    "instance_id": "http://metadata.exoscale.com/latest/meta-data/instance-id",
    "public_ipv4": "http://metadata.exoscale.com/latest/meta-data/public-ipv4",
    "local_ipv4": "http://metadata.exoscale.com/latest/meta-data/local-ipv4",
    "service_offering": "http://metadata.exoscale.com/latest/meta-data/service-offering",
    "availability_zone": "http://metadata.exoscale.com/latest/meta-data/availability-zone",
}


def run(command: list[str]) -> str:
    """Run a Linux command and return stdout or a readable error string."""
    try:
        result = subprocess.run(command, capture_output=True, text=True, timeout=8)
    except Exception as exc:  # Broad on purpose: the status page should not crash.
        return f"Fehler beim Ausfuehren: {exc}"

    output = result.stdout.strip() or result.stderr.strip()
    return output if output else "(keine Ausgabe)"


def metadata(url: str) -> str:
    """Read one value from the Exoscale metadata service with a short timeout."""
    try:
        with urllib.request.urlopen(url, timeout=2) as response:
            return response.read().decode("utf-8", errors="replace").strip()
    except (urllib.error.URLError, TimeoutError, OSError) as exc:
        return f"nicht verfuegbar ({exc.__class__.__name__})"


def first_line(text: str) -> str:
    """Return the first line of command output for compact summary fields."""
    return text.splitlines()[0] if text else ""


def boot_time_utc() -> str:
    """Calculate the boot time from /proc/uptime, with a safe fallback."""
    try:
        uptime_seconds = float(first_line(run(["cut", "-d", " ", "-f1", "/proc/uptime"])))
        boot_timestamp = time.time() - uptime_seconds
        return datetime.fromtimestamp(boot_timestamp, timezone.utc).isoformat(timespec="seconds")
    except ValueError:
        return "nicht verfuegbar"


def collect_system_info() -> dict[str, Any]:
    """Collect all values for the HTML page and JSON API."""
    commands = {
        "cpu": run(["bash", "-lc", "lscpu | grep -E 'Architecture|^CPU\\(s\\)|Model name|Hypervisor vendor'"]),
        "memory": run(["free", "-h"]),
        "block_devices": run(["lsblk", "-o", "NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS"]),
        "filesystems": run(["df", "-hT", "-x", "tmpfs", "-x", "devtmpfs", "-x", "overlay"]),
        "network_ipv4": run(["ip", "-brief", "-4", "addr", "show"]),
        "network_ipv6": run(["ip", "-brief", "-6", "addr", "show"]),
        "virtualization": run(["systemd-detect-virt"]),
    }

    return {
        "generated_at_utc": datetime.now(timezone.utc).isoformat(timespec="seconds"),
        "hostname": socket.getfqdn(),
        "os": platform.platform(),
        "kernel": {
            "system": platform.system(),
            "release": platform.release(),
            "version": platform.version(),
            "machine": platform.machine(),
        },
        "exoscale_metadata": {key: metadata(url) for key, url in METADATA_ENDPOINTS.items()},
        "summary": {
            "uptime": run(["uptime", "-p"]),
            "boot_time_utc": boot_time_utc(),
            "root_disk_usage": shutil.disk_usage("/")._asdict(),
            "python": platform.python_version(),
        },
        "details": commands,
    }


def render_html(data: dict[str, Any]) -> str:
    """Render a compact HTML dashboard from the collected system data."""
    meta = data["exoscale_metadata"]
    kernel = data["kernel"]
    details = data["details"]
    summary = data["summary"]

    root_total_gb = summary["root_disk_usage"]["total"] / (1024**3)
    root_free_gb = summary["root_disk_usage"]["free"] / (1024**3)

    cards = [
        ("Public IP", meta.get("public_ipv4", "")),
        ("Private IP", meta.get("local_ipv4", "")),
        ("Instanztyp", meta.get("service_offering", "")),
        ("Zone", meta.get("availability_zone", "")),
        ("Kernel", f"{kernel['system']} {kernel['release']} ({kernel['machine']})"),
        ("Root-Disk frei", f"{root_free_gb:.1f} GB von {root_total_gb:.1f} GB"),
    ]

    card_html = "\n".join(
        f"<article class='metric'><span>{html.escape(label)}</span><strong>{html.escape(value)}</strong></article>"
        for label, value in cards
    )

    detail_html = "\n".join(
        "<section class='detail'><h2>{}</h2><pre>{}</pre></section>".format(
            html.escape(title.replace("_", " ").title()),
            html.escape(value),
        )
        for title, value in details.items()
    )

    json_preview = html.escape(json.dumps(data, indent=2, ensure_ascii=False)[:900])

    return f"""<!doctype html>
<html lang="de">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>VM Info | Exoscale</title>
  <style>
    :root {{
      color-scheme: light;
      --bg: #f6f3ed;
      --ink: #17202a;
      --muted: #65707c;
      --line: #d9d2c6;
      --panel: #fffaf2;
      --accent: #b44b2a;
      --code: #202a35;
    }}
    * {{ box-sizing: border-box; }}
    body {{
      margin: 0;
      font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
      background: var(--bg);
      color: var(--ink);
      line-height: 1.5;
    }}
    header {{
      padding: 48px clamp(20px, 5vw, 72px) 30px;
      border-bottom: 1px solid var(--line);
      background: linear-gradient(180deg, #fffaf2 0%, #f6f3ed 100%);
    }}
    .eyebrow {{
      margin: 0 0 12px;
      color: var(--accent);
      font-size: 13px;
      font-weight: 700;
      letter-spacing: .08em;
      text-transform: uppercase;
    }}
    h1 {{
      max-width: 900px;
      margin: 0;
      font-size: clamp(34px, 6vw, 72px);
      line-height: .98;
      letter-spacing: 0;
    }}
    .sub {{
      max-width: 760px;
      margin: 20px 0 0;
      color: var(--muted);
      font-size: 18px;
    }}
    main {{
      width: min(1120px, calc(100% - 32px));
      margin: 0 auto;
      padding: 28px 0 48px;
    }}
    .metrics {{
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(190px, 1fr));
      gap: 12px;
      margin: 0 0 28px;
    }}
    .metric {{
      min-height: 116px;
      padding: 18px;
      border: 1px solid var(--line);
      border-radius: 8px;
      background: var(--panel);
    }}
    .metric span {{
      display: block;
      color: var(--muted);
      font-size: 13px;
      margin-bottom: 10px;
    }}
    .metric strong {{
      display: block;
      font-size: 20px;
      overflow-wrap: anywhere;
    }}
    .toolbar {{
      display: flex;
      flex-wrap: wrap;
      gap: 10px;
      margin: 0 0 28px;
    }}
    .toolbar a {{
      min-height: 44px;
      display: inline-flex;
      align-items: center;
      padding: 0 15px;
      border: 1px solid var(--ink);
      border-radius: 999px;
      color: var(--ink);
      text-decoration: none;
      font-weight: 700;
    }}
    .toolbar a:first-child {{
      background: var(--ink);
      color: #f6f3ed;
    }}
    .detail {{
      margin: 14px 0;
      border: 1px solid var(--line);
      border-radius: 8px;
      overflow: hidden;
      background: var(--panel);
    }}
    .detail h2 {{
      margin: 0;
      padding: 13px 16px;
      font-size: 14px;
      letter-spacing: .04em;
      text-transform: uppercase;
      border-bottom: 1px solid var(--line);
    }}
    pre {{
      margin: 0;
      padding: 16px;
      overflow: auto;
      background: var(--code);
      color: #eef1f4;
      font-size: 13px;
      white-space: pre-wrap;
      word-break: break-word;
    }}
    footer {{
      padding: 24px clamp(20px, 5vw, 72px);
      color: var(--muted);
      border-top: 1px solid var(--line);
    }}
  </style>
</head>
<body>
  <header>
    <p class="eyebrow">Exoscale VM Info</p>
    <h1>Technische Details dieser Ubuntu-VM</h1>
    <p class="sub">Die Daten werden bei jedem Request auf der angesprochenen VM gesammelt. CloudInit installiert die App und Caddy automatisch.</p>
  </header>
  <main>
    <div class="metrics">{card_html}</div>
    <nav class="toolbar" aria-label="Endpunkte">
      <a href="/api/v1/system">JSON API</a>
      <a href="/healthz">Healthcheck</a>
    </nav>
    {detail_html}
    <section class="detail">
      <h2>JSON Vorschau</h2>
      <pre>{json_preview}</pre>
    </section>
  </main>
  <footer>Hostname: {html.escape(data["hostname"])} | Aktualisiert: {html.escape(data["generated_at_utc"])}</footer>
</body>
</html>"""


class Handler(BaseHTTPRequestHandler):
    """HTTP request handler for the HTML page, JSON API, and health check."""

    def send_body(self, status: int, body: bytes, content_type: str) -> None:
        self.send_response(status)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self) -> None:  # noqa: N802, method name is defined by the base class.
        path = self.path.split("?", 1)[0].rstrip("/") or "/"

        if path == "/healthz":
            self.send_body(200, b"ok\n", "text/plain; charset=utf-8")
            return

        data = collect_system_info()
        if path == "/api/v1/system":
            body = json.dumps(data, indent=2, ensure_ascii=False).encode("utf-8")
            self.send_body(200, body, "application/json; charset=utf-8")
            return

        if path == "/":
            self.send_body(200, render_html(data).encode("utf-8"), "text/html; charset=utf-8")
            return

        self.send_body(404, b"not found\n", "text/plain; charset=utf-8")

    def log_message(self, _format: str, *args: Any) -> None:
        # Keep journald readable; failed requests are still visible through Caddy logs.
        return


if __name__ == "__main__":
    server = ThreadingHTTPServer(("127.0.0.1", 8080), Handler)
    server.serve_forever()
