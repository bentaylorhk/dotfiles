#!/usr/bin/env python3

# Benjamin Michael Taylor (bentaylorhk)
# 2026

# Queries the local ARK server (A2S_INFO) and writes its state for the SSH
# banner. Run every few minutes by ark-health.timer; exits 1 when the service
# is up but has stopped answering, so the failure shows in `systemctl --failed`.
# Installed as /usr/local/bin/ark-health.

import json
import os
import socket
import subprocess
import sys
import time

STATUS = os.environ.get("ARK_HEALTH_FILE", "/run/ark-health/status.json")
QUERY = b"\xff\xff\xff\xffTSource Engine Query\x00"
STARTUP_GRACE = 300
FAILURES_BEFORE_ALERT = 3


def service_state():
    output = subprocess.run(
        [
            "systemctl", "show", "ark-server.service",
            "-p", "ActiveState", "-p", "ActiveEnterTimestampMonotonic",
        ],
        capture_output=True, text=True,
    ).stdout
    values = dict(line.split("=", 1) for line in output.splitlines() if "=" in line)
    started = int(values.get("ActiveEnterTimestampMonotonic") or 0) / 1e6
    return values.get("ActiveState", "unknown"), time.monotonic() - started


def query():
    with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as sock:
        sock.settimeout(5)
        sock.sendto(QUERY, ("127.0.0.1", 27015))
        data, _ = sock.recvfrom(4096)
        if data[4:5] == b"A":
            sock.sendto(QUERY + data[5:9], ("127.0.0.1", 27015))
            data, _ = sock.recvfrom(4096)
    offset = 6
    for _ in range(4):
        offset = data.index(b"\0", offset) + 1
    return data[offset + 2], data[offset + 3]


def previous_failures():
    try:
        with open(STATUS) as status:
            return json.load(status).get("failures", 0)
    except (OSError, ValueError):
        return 0


def main():
    active, uptime = service_state()
    status = {"checked_at": int(time.time()), "state": "stopped",
              "players": 0, "max_players": 0, "failures": 0}

    if active == "active":
        try:
            status["players"], status["max_players"] = query()
            status["state"] = "responding"
        except (OSError, ValueError):
            if uptime < STARTUP_GRACE:
                status["state"] = "starting"
            else:
                status["failures"] = previous_failures() + 1
                status["state"] = (
                    "unresponsive"
                    if status["failures"] >= FAILURES_BEFORE_ALERT
                    else "responding"
                )
                if status["state"] == "responding":
                    # A single missed query is not an alert yet
                    status["state"] = "slow"

    os.makedirs(os.path.dirname(STATUS), exist_ok=True)
    temporary = STATUS + ".tmp"
    with open(temporary, "w") as handle:
        json.dump(status, handle)
    os.replace(temporary, STATUS)

    print(f"ARK health: {status['state']}")
    return 1 if status["state"] == "unresponsive" else 0


if __name__ == "__main__":
    sys.exit(main())
