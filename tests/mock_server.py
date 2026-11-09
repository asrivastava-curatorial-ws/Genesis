"""A small HTTP server for the download tests: Range requests, a route that
answers 429 (with Retry-After) the first time, one that drops the connection
half-way the first time, and JSON files. Standard library only.
    python3 tests/mock_server.py <folder> <port>"""
import http.server
import os
import sys
import threading

ROOT, PORT = sys.argv[1], int(sys.argv[2])
SEEN = {}
LOCK = threading.Lock()


class H(http.server.BaseHTTPRequestHandler):
    def log_message(self, *a):
        pass

    def do_GET(self):
        path = self.path.split("?")[0]
        with LOCK:
            n = SEEN.get(path, 0)
            SEEN[path] = n + 1
        if path.startswith("/limited/") and n == 0:
            self.send_response(429)
            self.send_header("Retry-After", "2")
            self.end_headers()
            return
        if path.startswith("/redirect/"):
            self.send_response(302)
            self.send_header("Location", "/files/" + path.split("/", 2)[2])
            self.end_headers()
            return
        name = path.split("/")[-1]
        f = os.path.join(ROOT, "files", name)
        if not os.path.exists(f):
            self.send_response(404)
            self.end_headers()
            return
        data = open(f, "rb").read()
        start = 0
        rng = self.headers.get("Range")
        if rng and rng.startswith("bytes="):
            start = int(rng[6:].split("-")[0])
            if start >= len(data):
                self.send_response(416)
                self.end_headers()
                return
            self.send_response(206)
            self.send_header("Content-Range", "bytes %d-%d/%d" % (start, len(data) - 1, len(data)))
        else:
            self.send_response(200)
        body = data[start:]
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        if path.startswith("/drop/") and n == 0:
            self.wfile.write(body[: len(body) // 2])
            self.wfile.flush()
            self.connection.shutdown(2)
            return
        self.wfile.write(body)


http.server.ThreadingHTTPServer(("127.0.0.1", PORT), H).serve_forever()
