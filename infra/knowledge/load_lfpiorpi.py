"""
Carga los artículos de la LFPIORPI desde el PDF a surveillance.ley_articulos.
Uso: python load_lfpiorpi.py
"""
import re
import pdfplumber
import psycopg2
from pathlib import Path

PDF_PATH = Path(__file__).parent.parent.parent / "docs" / "LFPIORPI.pdf"
LEY = "LFPIORPI"

HEADER = "LEY FEDERAL PARA LA PREVENCIÓN E IDENTIFICACIÓN DE OPERACIONES CON RECURSOS DE PROCEDENCIA ILÍCITA"
SUBHEADER = r"CÁMARA DE DIPUTADOS.*?Secretaría de Servicios Parlamentarios"


def extraer_articulos(pdf_path: Path) -> list[tuple[int, str]]:
    texto = ""
    with pdfplumber.open(pdf_path) as pdf:
        for page in pdf.pages:
            t = page.extract_text()
            if t:
                t = t.replace(HEADER, "")
                t = re.sub(SUBHEADER, "", t, flags=re.DOTALL)
                texto += t + "\n"

    articulos = []
    for chunk in re.split(r"(?=Artículo \d+[°º\.]?)", texto):
        chunk = chunk.strip()
        if not chunk.startswith("Artículo"):
            continue
        m = re.match(r"Artículo (\d+)[°º\.]?", chunk)
        if m:
            articulos.append((int(m.group(1)), chunk))
    return articulos


def cargar(articulos: list[tuple[int, str]]):
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
                [(LEY, num, texto) for num, texto in articulos]
            )
    conn.close()
    print(f"{len(articulos)} artículos cargados.")


if __name__ == "__main__":
    articulos = extraer_articulos(PDF_PATH)
    cargar(articulos)
