from http.server import HTTPServer, BaseHTTPRequestHandler
import urllib.parse
import socket
import re

seen_flags = set()


class LoggingHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        decoded_path = urllib.parse.unquote(self.path)
        print(f"{self.client_address[0]} - {decoded_path}")
        flags = re.findall(r"FLAG\{[^}]+\}", decoded_path)
        for flag in flags:
            if flag not in seen_flags:
                seen_flags.add(flag)
                print(f"FLAG FOUND: {flag}")

        self.send_response(204)
        self.end_headers()

    def log_message(self, format, *args):
        pass


def run_server(host="0.0.0.0", port=8000):
    server = HTTPServer((host, port), LoggingHandler)
    server.socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    print(f"Listening on port {port}...")
    server.serve_forever()


if __name__ == "__main__":
    run_server()
