"""
Carga los artículos de cualquier ley desde PDF a surveillance.ley_articulos.
Uso: python load_ley.py <clave_ley> <ruta_pdf>

Ejemplos:
    python load_ley.py LFPIORPI ../docs/LFPIORPI.pdf
    python load_ley.py LMV ../docs/LMV.pdf
    python load_ley.py CPF ../docs/CPF.pdf
"""
import re
import sys
import pdfplumber
import psycopg2
from pathlib import Path

HEADER_PATTERNS = [
    r"CÁMARA DE DIPUTADOS.*?Secretaría de Servicios Parlamentarios",
    r"Secretaría General\nSecretaría de Servicios Parlamentarios",
]


def extraer_texto(pdf_path: Path) -> str:
    texto = ""
    with pdfplumber.open(pdf_path) as pdf:
        for page in pdf.pages:
            t = page.extract_text()
            if t:
                for pattern in HEADER_PATTERNS:
                    t = re.sub(pattern, "", t, flags=re.DOTALL)
                texto += t + "\n"
    return texto


def chunkear_articulos(texto: str) -> list[tuple[str, str]]:
    """Retorna lista de (numero_articulo, texto_completo)."""
    articulos = []
    for chunk in re.split(r"(?=Artículo \d+)", texto):
        chunk = chunk.strip()
        if not chunk.startswith("Artículo"):
            continue
        m = re.match(r"Artículo (\d+\s*(?:Bis|Ter|Quáter)?)[°º\.]?", chunk, re.IGNORECASE)
        if m:
            numero = m.group(1).strip()
            articulos.append((numero, chunk))
    return articulos


def cargar(ley: str, articulos: list[tuple[str, str]]):
    conn = psycopg2.connect(
        host="localhost", dbname="market_surveillance",
        user="postgres", password="postgres"
    )
    with conn:
        with conn.cursor() as cur:
            cur.executemany(
                """
                INSERT INTO surveillance.ley_articulos (ley, articulo, texto)
                VALUES (%s, %s, %s)
                ON CONFLICT (ley, articulo) DO UPDATE SET texto = EXCLUDED.texto
                """,
                [(ley, numero, texto) for numero, texto in articulos]
            )
    conn.close()
    print(f"{len(articulos)} artículos cargados para {ley}.")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Uso: python load_ley.py <CLAVE_LEY> <ruta_pdf>")
        sys.exit(1)

    ley = sys.argv[1].upper()
    pdf_path = Path(sys.argv[2])

    if not pdf_path.exists():
        print(f"Archivo no encontrado: {pdf_path}")
        sys.exit(1)

    texto = extraer_texto(pdf_path)
    articulos = chunkear_articulos(texto)
    cargar(ley, articulos)
