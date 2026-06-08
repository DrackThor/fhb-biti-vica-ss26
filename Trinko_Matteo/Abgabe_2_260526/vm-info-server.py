#!/usr/bin/env python3

import json
import platform
import socket
import subprocess
from http.server import BaseHTTPRequestHandler, HTTPServer
from datetime import datetime


# Führt einen Shell-Befehl aus und gibt dessen Ausgabe als Text zurück.
def run_command(command):
    try:
        result = subprocess.run(
            command,
            shell=True,
            check=False,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )

        # Gibt die Standardausgabe zurück, falls vorhanden.
        if result.stdout.strip():
            return result.stdout.strip()

        # Gibt Fehlermeldungen zurück, falls keine Standardausgabe vorhanden ist.
        if result.stderr.strip():
            return result.stderr.strip()

        return ""
    except Exception as error:
        return str(error)


# Sammelt technische Informationen über die laufende VM.
def collect_vm_info():
    return {
        "Timestamp": datetime.utcnow().isoformat() + "Z",
        "Hostname": socket.gethostname(),
        "IP Addresses": run_command("hostname -I"),
        "Kernel": {
            "system": platform.system(),
            "release": platform.release(),
            "version": platform.version(),
            "machine": platform.machine()
        },
        "Operating System": run_command("cat /etc/os-release"),
        "Hypervisor": run_command("systemd-detect-virt || true"),
        "Memory": run_command("free -h"),
        "CPU": run_command("lscpu"),
        "Storage": run_command("lsblk"),
        "Filesystems": run_command("df -hT"),
        "Network Interfaces": run_command("ip addr show")
    }


# Escaped Sonderzeichen, damit dynamische Inhalte sicher in HTML angezeigt werden.
def html_escape(text):
    return (
        str(text)
        .replace("&", "&amp;")
        .replace("<", "&lt;")
        .replace(">", "&gt;")
    )


# Erstellt aus den gesammelten VM-Informationen eine übersichtliche HTML-Webseite.
def generate_html(info):
    html_sections = ""

    # Dezente Farben für die einzelnen Informationsblöcke.
    card_colors = [
        "#eff6ff",
        "#ecfdf5",
        "#fefce8",
        "#fdf2f8",
        "#f5f3ff",
        "#f0fdfa"
    ]

    # Erstellt für jeden Informationsblock eine eigene farbige Karte.
    for index, (key, value) in enumerate(info.items()):
        if isinstance(value, dict):
            formatted_value = json.dumps(value, indent=2)
        else:
            formatted_value = value

        card_color = card_colors[index % len(card_colors)]

        html_sections += f"""
        <section class="card" style="background: {card_color};">
            <h2>{html_escape(key)}</h2>
            <pre>{html_escape(formatted_value)}</pre>
        </section>
        """

    return f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>VM Technical Details</title>
    <style>
        body {{
            margin: 0;
            font-family: Arial, sans-serif;
            background: #f3f4f6;
            color: #1f2937;
        }}

        header {{
            background: linear-gradient(135deg, #111827, #374151);
            color: white;
            padding: 2.5rem 1rem;
            text-align: center;
        }}

        header h1 {{
            margin: 0;
            font-size: 2rem;
        }}

        header p {{
            margin: 0.5rem 0 0;
            color: #d1d5db;
        }}

        header a {{
            color: #bfdbfe;
            font-weight: bold;
        }}

        main {{
            max-width: 1100px;
            margin: 2rem auto;
            padding: 0 1rem;
        }}

        .card {{
            border-radius: 12px;
            padding: 1.25rem;
            margin-bottom: 1.25rem;
            border: 1px solid rgba(0, 0, 0, 0.06);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.06);
        }}

        .card h2 {{
            margin: 0 0 0.75rem;
            font-size: 1.1rem;
            color: #111827;
            border-bottom: 1px solid rgba(0, 0, 0, 0.08);
            padding-bottom: 0.5rem;
            text-transform: capitalize;
        }}

        pre {{
            margin: 0;
            white-space: pre-wrap;
            word-break: break-word;
            background: rgba(255, 255, 255, 0.75);
            padding: 0.9rem;
            border-radius: 8px;
            overflow-x: auto;
            font-size: 0.9rem;
            line-height: 1.4;
        }}

        footer {{
            text-align: center;
            color: #6b7280;
            font-size: 0.9rem;
            padding: 1rem 0 2rem;
        }}
    </style>
</head>
<body>
    <header>
        <h1>VM Technical Details</h1>
        <p>Automatically generated system information from this Exoscale VM</p>
        <p>JSON API: <a href="/api">/api</a></p>
    </header>

    <main>
        {html_sections}
    </main>

    <footer>
        Generated dynamically by the local Python service behind nginx.
    </footer>
</body>
</html>
"""


# HTTP-Handler für die Endpunkte der Anwendung.
class VMInfoHandler(BaseHTTPRequestHandler):

    # Verarbeitet eingehende GET-Anfragen.
    def do_GET(self):
        info = collect_vm_info()

        # JSON-Endpunkt für maschinenlesbare VM-Informationen.
        if self.path == "/api":
            response = json.dumps(info, indent=2)

            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(response.encode("utf-8"))
            return

        # HTML-Endpunkt für die Darstellung im Browser.
        if self.path == "/":
            response = generate_html(info)

            self.send_response(200)
            self.send_header("Content-Type", "text/html; charset=utf-8")
            self.end_headers()
            self.wfile.write(response.encode("utf-8"))
            return

        # Antwort für unbekannte Pfade.
        self.send_response(404)
        self.send_header("Content-Type", "text/plain")
        self.end_headers()
        self.wfile.write(b"404 Not Found")


# Startet den Webserver nur lokal auf der VM.
# Der öffentliche Zugriff erfolgt über nginx als Reverse Proxy.
if __name__ == "__main__":
    server_address = ("127.0.0.1", 8080)
    httpd = HTTPServer(server_address, VMInfoHandler)
    print("VM info server running locally on port 8080")
    httpd.serve_forever()