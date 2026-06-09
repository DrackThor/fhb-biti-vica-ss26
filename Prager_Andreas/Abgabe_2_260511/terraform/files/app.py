from flask import Flask, jsonify
import socket
import os

app = Flask(__name__)

def get_system_info():
    load = os.getloadavg()

    disk_usage = os.popen(
        "df -h / | awk 'NR==2 {print $4 \" free / \" $2 \" total\"}'"
    ).read().strip()

    cpu_count = os.cpu_count()
    
    return {
        "hostname": socket.gethostname(),
        "ip_address": os.popen("hostname -I").read().strip(),
        "kernel": os.popen("uname -r").read().strip(),
        "os": os.popen("lsb_release -d").read().split(":")[1].strip(),
        "cpu_cores": cpu_count,
        "memory": os.popen("free -h | awk '/Mem:/ {print $2}'").read().strip(),
        "disk": disk_usage,
        "uptime": os.popen("uptime -p").read().strip().replace("up ", ""),
        "load_average": f"{round((load[2] / cpu_count) * 100, 1)}%"
    }

@app.route("/api")
def api():
    return jsonify(get_system_info())


@app.route("/")
def home():
    info = get_system_info()

    return f"""
    <html>
        <head>
            <title>VM Dashboard</title>

            <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

            <style>
                body {{
                    background: #0f172a;
                    color: #e2e8f0;
                }}

                .dashboard-title {{
                    font-weight: 600;
                    letter-spacing: 0.5px;
                }}

                .card {{
                    background: #111827;
                    border: 1px solid #1f2937;
                    color: #e5e7eb;
                    border-radius: 12px;
                }}

                .metric-label {{
                    font-size: 0.8rem;
                    color: #94a3b8;
                    text-transform: uppercase;
                    letter-spacing: 0.05em;
                }}

                .metric-value {{
                    font-size: 1.25rem;
                    font-weight: 600;
                }}

                .top-bar {{
                    background: #111827;
                    border: 1px solid #1f2937;
                    border-radius: 12px;
                    padding: 16px;
                    margin-bottom: 20px;
                }}

                a.btn {{
                    border-radius: 10px;
                }}
            </style>
        </head>

        <body>
            <div class="container py-5">

                <div class="top-bar d-flex justify-content-between align-items-center">
                    <div>
                        <div class="dashboard-title">VM SYSTEM DASHBOARD</div>
                        <div class="text-secondary small">Live system overview</div>
                    </div>
                    <a class="btn btn-primary btn-sm" href="/api">Raw JSON API</a>
                </div>

                <div class="row g-3">

                    <div class="col-md-6 col-lg-4">
                        <div class="card p-3">
                            <div class="metric-label">Hostname</div>
                            <div class="metric-value">{info['hostname']}</div>
                        </div>
                    </div>

                    <div class="col-md-6 col-lg-4">
                        <div class="card p-3">
                            <div class="metric-label">IP Address</div>
                            <div class="metric-value">{info['ip_address']}</div>
                        </div>
                    </div>

                    <div class="col-md-6 col-lg-4">
                        <div class="card p-3">
                            <div class="metric-label">OS</div>
                            <div class="metric-value">{info['os']}</div>
                        </div>
                    </div>

                    <div class="col-md-6 col-lg-4">
                        <div class="card p-3">
                            <div class="metric-label">Kernel</div>
                            <div class="metric-value">{info['kernel']}</div>
                        </div>
                    </div>

                    <div class="col-md-6 col-lg-4">
                        <div class="card p-3">
                            <div class="metric-label">CPU Cores</div>
                            <div class="metric-value">{info['cpu_cores']}</div>
                        </div>
                    </div>

                    <div class="col-md-6 col-lg-4">
                        <div class="card p-3">
                            <div class="metric-label">Memory</div>
                            <div class="metric-value">{info['memory']}</div>
                        </div>
                    </div>

                    <div class="col-md-6 col-lg-4">
                        <div class="card p-3">
                            <div class="metric-label">Disk</div>
                            <div class="metric-value">{info['disk']}</div>
                        </div>
                    </div>

                    <div class="col-md-6 col-lg-4">
                        <div class="card p-3">
                            <div class="metric-label">Uptime</div>
                            <div class="metric-value">{info['uptime']}</div>
                        </div>
                    </div>

                    <div class="col-md-6 col-lg-4">
                        <div class="card p-3">
                            <div class="metric-label">Load average (15min)</div>
                            <div class="metric-value">{info['load_average']}</div>
                        </div>
                    </div>

                </div>
            </div>
        </body>
    </html>
    """
