-- =============================================================================
-- DETECTOR: Structuring (fragmentación)
-- Art. 17 LFPIORPI — fragmentar operaciones deliberadamente por debajo del
-- umbral de reporte (645 x UMA diaria) para evadir el aviso a la UIF.
--
-- Casos de structuring en bolsa:
--   Caso 1a — Mismo día, mismo instrumento, compras    ← este filter
--   Caso 1b — Mismo día, mismo instrumento, ventas     ← este filter (GROUP BY incluye tipo)
--   Caso 2a — Varios días, mismo instrumento, compras  ← filter_caso2.sql
--   Caso 2b — Varios días, mismo instrumento, ventas   ← filter_caso2.sql (GROUP BY incluye tipo)
--   Caso 3a — Mismo día, varios instrumentos, compras  ← filter_caso3.sql
--   Caso 3b — Mismo día, varios instrumentos, ventas   ← filter_caso3.sql (tipo como parámetro)
--   Caso 4  — Varias cuentas, mismo beneficiario       ← pendiente: requiere contexto de negocio
--             Desarrollarlo sobre supuestos no validados con dueños del conocimiento puede generar
--             falsos positivos en un sistema regulatorio. Además del filtro SQL implica consultas
--             a documentación KYC, actas constitutivas, poderes notariales y catálogos de grupos
--             económicos que el broker debe exponer. Requiere sesión con área de KYC/onboarding.
--             Para modelar redes de beneficiarios (familiar, representante, empresa controlada)
--             podría implementarse una base de grafos (ej. Amazon Neptune) que permita traversals
--             eficientes sobre relaciones entre clientes sin queries recursivas en SQL.
-- Nota: compras y ventas se detectan y reportan por separado — la LFPIORPI no distingue sentido
-- =============================================================================

WITH umbral AS (
    SELECT valor AS monto
    FROM surveillance.parametros
    WHERE clave = 'limite_structuring_mxn'
)
SELECT
    o.cuenta_id,
    o.instrumento_id,
    o.operador_id,
    o.fecha,
    COUNT(*)                        AS num_operaciones,
    SUM(o.monto_total)              AS importe_total,
    MAX(o.monto_total)              AS importe_maximo,
    MIN(o.monto_total)              AS importe_minimo,
    STDDEV(o.monto_total)           AS desviacion_importe,
    c.numero_cuenta,
    cl.nombre,
    cl.nivel_riesgo,
    i.ticker,
    u.monto                         AS umbral_mxn
FROM surveillance.espejo_operaciones  o
JOIN surveillance.espejo_cuentas      c  ON c.id = o.cuenta_id
JOIN surveillance.espejo_clientes     cl ON cl.id = c.cliente_id
JOIN surveillance.espejo_instrumentos i  ON i.id  = o.instrumento_id
CROSS JOIN umbral u
WHERE o.fecha   = %(fecha_jornada)s
  AND o.tipo    = %(tipo)s
  AND o.estado  = 'ejecutada'
GROUP BY
    o.cuenta_id, o.instrumento_id, o.operador_id, o.fecha,
    c.numero_cuenta, cl.nombre, cl.nivel_riesgo, i.ticker, u.monto
HAVING
    COUNT(*)               >= 3
    AND MAX(o.monto_total)  < u.monto
    AND SUM(o.monto_total) >= u.monto
ORDER BY importe_total DESC;
