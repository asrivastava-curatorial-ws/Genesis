#!/usr/bin/env python3
"""Serves this walkthrough to browsers on this computer and on the same network.

    python3 serve.py                 http://localhost:8080
    python3 serve.py --port 9000
    python3 serve.py --https cert.pem key.pem
                                     https, which a headset's browser needs for VR
                                     unless it reaches this computer as "localhost"

A headset on the same Wi-Fi: open https://<this computer's address>:8443 in its
browser and accept the certificate once. Or, with a USB cable and adb:
    adb reverse tcp:8080 tcp:8080     then open http://localhost:8080 in the headset

Only Python's own library is used. Stop it with Ctrl+C.
"""
import argparse
import functools
import http.server
import os
import socket
import ssl
import sys

TYPES = {
    ".js": "text/javascript", ".mjs": "text/javascript", ".json": "application/json", ".glb": "model/gltf-binary",
    ".f32": "application/octet-stream", ".webp": "image/webp", ".wasm": "application/wasm", ".hdr": "application/octet-stream",
    ".svg": "image/svg+xml", ".woff2": "font/woff2", ".mp4": "video/mp4", ".webm": "video/webm", ".ogg": "audio/ogg", ".mp3": "audio/mpeg",
}


class Handler(http.server.SimpleHTTPRequestHandler):
    extensions_map = {**http.server.SimpleHTTPRequestHandler.extensions_map, **TYPES}
    protocol_version = "HTTP/1.1"

    def end_headers(self):
        # A walkthrough written again must be seen again: nothing is kept by the browser without asking.
        self.send_header("Cache-Control", "no-cache")
        self.send_header("Accept-Ranges", "bytes")
        super().end_headers()

    def send_head(self):
        # Films and sound are asked for in pieces ("Range"); the library's own server sends only whole files.
        rng = self.headers.get("Range")
        path = self.translate_path(self.path)
        if not rng or not os.path.isfile(path) or not rng.startswith("bytes="):
            return super().send_head()
        size = os.path.getsize(path)
        try:
            a, b = rng[6:].split(",")[0].split("-")
            start = int(a) if a else max(size - int(b), 0)
            end = min(int(b), size - 1) if a and b else size - 1
        except ValueError:
            return super().send_head()
        if start > end or start >= size:
            self.send_error(416)
            return None
        f = open(path, "rb")
        f.seek(start)
        self.send_response(206)
        self.send_header("Content-Type", self.guess_type(path))
        self.send_header("Content-Range", "bytes %d-%d/%d" % (start, end, size))
        self.send_header("Content-Length", str(end - start + 1))
        self.end_headers()
        self._left = end - start + 1
        return f

    def copyfile(self, source, outputfile):
        left = getattr(self, "_left", None)
        if left is None:
            return super().copyfile(source, outputfile)
        self._left = None
        while left > 0:
            chunk = source.read(min(65536, left))
            if not chunk:
                break
            outputfile.write(chunk)
            left -= len(chunk)

    def log_message(self, fmt, *args):
        if os.environ.get("ORIEL_SERVE_QUIET"):
            return
        sys.stderr.write("%s  %s\n" % (self.address_string(), fmt % args))


def addresses():
    """This computer's addresses on its networks."""
    out = []
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("10.255.255.255", 1))
        out.append(s.getsockname()[0])
        s.close()
    except OSError:
        pass
    try:
        for a in socket.gethostbyname_ex(socket.gethostname())[2]:
            if a not in out and not a.startswith("127."):
                out.append(a)
    except OSError:
        pass
    return out


def main():
    ap = argparse.ArgumentParser(description="Serves an Oriel web walkthrough.")
    ap.add_argument("--port", type=int, default=0)
    ap.add_argument("--dir", default=os.path.dirname(os.path.abspath(__file__)))
    ap.add_argument("--https", nargs=2, metavar=("CERT", "KEY"))
    ap.add_argument("--local", action="store_true", help="this computer only")
    args = ap.parse_args()
    port = args.port or (8443 if args.https else 8080)
    handler = functools.partial(Handler, directory=args.dir)
    server = http.server.ThreadingHTTPServer(("127.0.0.1" if args.local else "0.0.0.0", port), handler)
    server.daemon_threads = True
    scheme = "http"
    if args.https:
        ctx = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
        ctx.load_cert_chain(args.https[0], args.https[1])
        server.socket = ctx.wrap_socket(server.socket, server_side=True)
        scheme = "https"
    print("ORIEL_SERVE %s://localhost:%d" % (scheme, port), flush=True)
    if not args.local:
        for a in addresses():
            print("ORIEL_SERVE %s://%s:%d" % (scheme, a, port), flush=True)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass


if __name__ == "__main__":
    main()
