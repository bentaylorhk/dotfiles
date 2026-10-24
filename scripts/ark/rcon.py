#!/usr/bin/env python3

# Benjamin Michael Taylor (bentaylorhk)
# 2026

# Minimal Source RCON client for the local ARK server. Reads the admin
# password and port from the live config and never prints the password.
# Installed as /usr/local/bin/ark-rcon.

import argparse
import os
import re
import socket
import struct
import sys

CONFIG = os.environ.get(
    "ARK_CONFIG",
    "/srv/ark-se/ShooterGame/Saved/Config/LinuxServer/GameUserSettings.ini",
)
AUTH, AUTH_RESPONSE, EXEC = 3, 2, 2


def live_setting(key):
    with open(CONFIG) as config:
        for line in config:
            match = re.match(rf"^\s*{key}\s*=\s*(.*?)\s*$", line, re.I)
            if match:
                return match.group(1)
    raise SystemExit(f"{key} is missing from {CONFIG}")


def send(sock, packet_id, packet_type, body):
    data = struct.pack("<ii", packet_id, packet_type) + body.encode() + b"\0\0"
    sock.sendall(struct.pack("<i", len(data)) + data)


def receive_exact(sock, size):
    data = b""
    while len(data) < size:
        chunk = sock.recv(size - len(data))
        if not chunk:
            raise ConnectionError("RCON connection closed")
        data += chunk
    return data


def receive(sock):
    size = struct.unpack("<i", receive_exact(sock, 4))[0]
    data = receive_exact(sock, size)
    packet_id, packet_type = struct.unpack("<ii", data[:8])
    return packet_id, packet_type, data[8:-2].decode(errors="replace")


def run(command, timeout):
    password = live_setting("ServerAdminPassword")
    port = int(live_setting("RCONPort"))
    with socket.create_connection(("127.0.0.1", port), timeout=timeout) as sock:
        sock.settimeout(timeout)
        send(sock, 1, AUTH, password)
        while True:
            packet_id, packet_type, _ = receive(sock)
            if packet_type == AUTH_RESPONSE:
                if packet_id == -1:
                    raise PermissionError("RCON authentication failed")
                break
        send(sock, 2, EXEC, command)
        try:
            while True:
                packet_id, packet_type, body = receive(sock)
                if packet_id == 2:
                    return body
        except ConnectionError:
            # Commands like DoExit close the connection without replying
            return ""


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--timeout", type=float, default=10)
    parser.add_argument("command", nargs="+")
    args = parser.parse_args()
    try:
        output = run(" ".join(args.command), args.timeout)
    except (OSError, PermissionError) as error:
        print(f"ark-rcon: {error}", file=sys.stderr)
        return 1
    if output.strip():
        print(output.strip())
    return 0


if __name__ == "__main__":
    sys.exit(main())
