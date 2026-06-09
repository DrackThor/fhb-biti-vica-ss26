#!/usr/bin/env python3

from http.server import BaseHTTPRequestHandler, HTTPServer
import json
import platform
import socket
import subprocess
import shutil
from datetime import datetime

def run(cmd):
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=5)
        return result.stdout.strip() or result.stderr.strip()
    except Exception as e:
        return str(e)

def system_info():
    return {
        "generated_at": datetime.utcnow().isoformat() + "Z",
        "hostname": socket.gethostname(),
        "fqdn": socket.getfqdn(),
        "os": platform.platform(),
        "kernel": platform.release(),
        "architecture": platform.machine(),
        "cpu": run(["bash", "-c", "lscpu | grep 'Model name'"]),
        "memory": run(["free", "-h"]),
        "storage": run(["lsblk"]),
        "filesystems": run(["df", "-h"]),
        "ip_addresses": run(["hostname", "-I"]),
        "virtualization": run(["systemd-detect-virt"]),
        "root_disk_usage": shutil.disk_usage("/")._asdict()
    }

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        data = system_info()

        if self.path == "/api/v1/system":
            body = json.dumps(data, indent=2).encode()
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(body)
            return

        html = f"""
        <html>
        <head>
            <title>VM Systeminformationen</title>
            <style>
                body {{ font-family: Arial; margin: 40px; background: #f4f4f4; }}
                h1 {{ color: #222; }}
                pre {{ background: white; padding: 20px; border-radius: 8px; }}
                a {{ color: #0066cc; }}
            </style>
        </head>
        <body>
            <h1>Abgabe 2 - VM Systeminformationen</h1>
            <p>Diese Webseite laeuft auf einer Exoscale VM.</p>
            <p><a href="/api/v1/system">JSON API anzeigen</a></p>
            <pre>{json.dumps(data, indent=2)}</pre>
        </body>
        </html>
        """
        body = html.encode()
        self.send_response(200)
        self.send_header("Content-Type", "text/html")
        self.end_headers()
        self.wfile.write(body)

server = HTTPServer(("0.0.0.0", 8080), Handler)
server.serve_forever()
