# infra/knowledge

Base de conocimiento regulatorio del sistema de vigilancia.

## Contenido

| Archivo | Descripción |
|---|---|
| `01_schema.sql` | Tabla `surveillance.ley_articulos` |
| `load_ley.py` | Carga cualquier ley en PDF → `surveillance.ley_articulos` |

---

## Cómo cargar una ley nueva

### 1. Agregar el PDF
Colocar el PDF en `docs/`.

### 2. Crear la tabla (solo la primera vez)
```bash
psql -U postgres -d market_surveillance -f infra/knowledge/01_schema.sql
```

### 3. Correr el script
```bash
python infra/knowledge/load_ley.py <CLAVE_LEY> docs/<archivo>.pdf
```

Ejemplos:
```bash
python infra/knowledge/load_ley.py LFPIORPI docs/LFPIORPI.pdf
python infra/knowledge/load_ley.py LMV      docs/LMV.pdf
python infra/knowledge/load_ley.py CPF      docs/CPF.pdf
```

### 4. Verificar
```sql
SELECT ley, COUNT(*) FROM surveillance.ley_articulos GROUP BY ley;
```

### 5. Actualizar el registro de leyes cargadas (tabla abajo)

---

## Registro de leyes

| Ley | Archivo | Estado | Artículos clave |
|---|---|---|---|
| LFPIORPI | `docs/LFPIORPI.pdf` | ✅ Cargada | Art. 15 (entidades financieras), Art. 17 (actividades vulnerables), Art. 18 (plazo de reporte) |
| LMV | `docs/LMV.pdf` | ⬜ Pendiente | Art. 212, Art. 226 Bis (umbrales mercado de valores) |
| CPF | `docs/CPF.pdf` | ⬜ Pendiente | Título XXIII Cap. II (lavado de dinero) |

---

## Notas

- El script detecta artículos con sufijos: `Bis`, `Ter`, `Quáter`
- Re-cargar una ley no genera duplicados (`ON CONFLICT DO UPDATE`)
- El campo `ley` es la clave para filtrar: `WHERE ley = 'LFPIORPI'`
