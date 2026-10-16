"""Servidor local de la página de revisión de sprites de Gota.

Sirve esta carpeta en http://127.0.0.1:<puerto> (8765 por defecto) y guarda las opiniones
en opiniones.json para revisarlas después.
"""
import json
import os
import sys
from datetime import datetime
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer

CARPETA = os.path.dirname(os.path.abspath(__file__))
OPINIONES = os.path.join(CARPETA, "opiniones.json")


def leer():
    try:
        with open(OPINIONES, encoding="utf-8") as f:
            return json.load(f)
    except (FileNotFoundError, json.JSONDecodeError):
        return {}


class Manejador(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=CARPETA, **kwargs)

    def end_headers(self):
        # Siempre la versión más reciente de los sprites
        self.send_header("Cache-Control", "no-store")
        super().end_headers()

    def responder_json(self, datos, codigo=200):
        cuerpo = json.dumps(datos, ensure_ascii=False).encode("utf-8")
        self.send_response(codigo)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(cuerpo)))
        self.end_headers()
        self.wfile.write(cuerpo)

    def do_GET(self):
        if self.path == "/api/opiniones":
            return self.responder_json(leer())
        return super().do_GET()

    def do_POST(self):
        if self.path != "/api/opiniones":
            return self.responder_json({"error": "ruta desconocida"}, 404)
        largo = int(self.headers.get("Content-Length", 0))
        try:
            datos = json.loads(self.rfile.read(largo).decode("utf-8"))
            vid = str(datos["id"])
        except (ValueError, KeyError):
            return self.responder_json({"error": "datos inválidos"}, 400)
        opiniones = leer()
        opiniones[vid] = {
            "voto": datos.get("voto", ""),
            "comentario": datos.get("comentario", ""),
            "favorita": bool(datos.get("favorita", False)),
            "fecha": datetime.now().isoformat(timespec="seconds"),
        }
        with open(OPINIONES, "w", encoding="utf-8") as f:
            json.dump(opiniones, f, ensure_ascii=False, indent=2)
        return self.responder_json({"ok": True})


if __name__ == "__main__":
    puerto = int(sys.argv[1]) if len(sys.argv) > 1 else 8765
    print(f"Revisión en http://127.0.0.1:{puerto}")
    ThreadingHTTPServer(("127.0.0.1", puerto), Manejador).serve_forever()
