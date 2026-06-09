from flask import Flask, jsonify, render_template_string
import os
import platform
import socket
 
app = Flask(__name__)
# ---------- helpers ----------

def get_ip():
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
        s.close()
        return ip
    except:
        return "unknown"
 
def read_file(path):
    try:
        with open(path, "r") as f:
            return f.read()
    except:
        return ""
def get_memory():
    # Linux only: /proc/meminfo
    meminfo = read_file("/proc/meminfo").splitlines()
    mem = {}
    for line in meminfo:
        parts = line.split(":")
        if len(parts) == 2:
            key = parts[0].strip()
            val = parts[1].strip().replace("kB", "").strip()
            mem[key] = int(val) if val.isdigit() else 0
    total = mem.get("MemTotal", 0) / 1024
    free = mem.get("MemAvailable", 0) / 1024
    used = total - free
    return {
        "total_mb": round(total, 2),
        "used_mb": round(used, 2),
        "free_mb": round(free, 2),
    }
def get_storage(path="/"):
    st = os.statvfs(path)
    total = st.f_blocks * st.f_frsize
    free = st.f_bavail * st.f_frsize
    used = total - free
    return {
        "total_gb": round(total / (1024**3), 2),
        "used_gb": round(used / (1024**3), 2),
        "free_gb": round(free / (1024**3), 2),
    }
 
def get_filesystems():
    fstab = read_file("/proc/mounts").splitlines()
    fs = []
    for line in fstab:
        parts = line.split()
        if len(parts) >= 3:
            fs.append({
                "device": parts[0],
                "mount": parts[1],
                "type": parts[2]
            })

    return fs
 
 
def get_hypervisor():
    cpuinfo = read_file("/proc/cpuinfo").lower()
    if "hypervisor" in cpuinfo:
        return "Virtualized (hypervisor detected)"
    # fallback hint via systemd tool (if available)
    try:
        out = os.popen("systemd-detect-virt").read().strip()
        if out:
            return f"Virtualized ({out})"
    except:
        pass
    return "Bare metal / unknown"

# ---------- routes ----------
@app.route("/")
def index():
    data = {
        "hostname": socket.gethostname(),
        "ip": get_ip(),
        "os": platform.system(),
        "kernel": platform.release(),
        "arch": platform.machine(),
        "hypervisor": get_hypervisor(),
        "memory": get_memory(),
        "storage": get_storage(),
        "filesystems": get_filesystems()[:15],  # limit output
    }
    html = """
<h1>VM Info Dashboard</h1>
    <h3>System</h3>
<ul>
<li>Hostname: {{d.hostname}}</li>
<li>IP: {{d.ip}}</li>
<li>OS: {{d.os}}</li>
<li>Kernel: {{d.kernel}}</li>
<li>Arch: {{d.arch}}</li>
<li>Hypervisor: {{d.hypervisor}}</li>
</ul>
    <h3>Memory (MB)</h3>
<ul>
<li>Total: {{d.memory.total_mb}}</li>
<li>Used: {{d.memory.used_mb}}</li>
<li>Free: {{d.memory.free_mb}}</li>
</ul>
 
    <h3>Disk (/)</h3>
<ul>
<li>Total: {{d.storage.total_gb}} GB</li>
<li>Used: {{d.storage.used_gb}} GB</li>
<li>Free: {{d.storage.free_gb}} GB</li>
</ul>
    <h3>File Systems</h3>
<ul>
    {% for fs in d.filesystems %}
<li>{{fs.device}} → {{fs.mount}} ({{fs.type}})</li>
    {% endfor %}
</ul>

    """
    return render_template_string(html, d=data)
 
@app.route("/api")
def api():
    return jsonify({
        "hostname": socket.gethostname(),
        "ip": get_ip(),
        "os": platform.system(),
        "kernel": platform.release(),
        "arch": platform.machine(),
        "hypervisor": get_hypervisor(),
        "memory": get_memory(),
        "storage": get_storage(),
    })
 
 
if __name__ == "__main__":

    app.run(host="0.0.0.0", port=5000, debug=True)
 