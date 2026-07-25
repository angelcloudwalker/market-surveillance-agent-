-- =============================================================================
-- DETECTOR: Structuring — Caso 3
-- Mismo día, varios instrumentos (compras y ventas por separado)
-- Detecta fragmentación distribuida en distintos instrumentos el mismo día,
-- donde ninguna operación supera el umbral individualmente pero el acumulado sí.
-- Cubre Caso 3a (compras) y Caso 3b (ventas) — tipo entra como parámetro.
-- La LFPIORPI no distingue sentido: ambos se reportan a la UIF.
-- Excluye cuentas ya detectadas por caso 1 (>=3 ops en un mismo instrumento).
-- =============================================================================

WITH umbral AS (
    SELECT valor AS monto
    FROM surveillance.parametros
    WHERE clave = 'limite_structuring_mxn'
),
caso1 AS (
    SELECT DISTINCT o.cuenta_id
    FROM surveillance.espejo_operaciones o
    CROSS JOIN umbral u
    WHERE o.fecha  = %(fecha_jornada)s
      AND o.tipo   = %(tipo)s
      AND o.estado = 'ejecutada'
    GROUP BY o.cuenta_id, o.instrumento_id, u.monto
    HAVING COUNT(*) >= 3 AND MAX(o.monto_total) < u.monto AND SUM(o.monto_total) >= u.monto
)
SELECT
    o.cuenta_id,
    o.operador_id,
    o.fecha,
    COUNT(*)                        AS num_operaciones,
    COUNT(DISTINCT o.instrumento_id) AS num_instrumentos,
    SUM(o.monto_total)              AS importe_total,
    MAX(o.monto_total)              AS importe_maximo,
    MIN(o.monto_total)              AS importe_minimo,
    STDDEV(o.monto_total)           AS desviacion_importe,
    c.numero_cuenta,
    cl.nombre,
    cl.nivel_riesgo,
    u.monto                         AS umbral_mxn
FROM surveillance.espejo_operaciones  o
JOIN surveillance.espejo_cuentas      c  ON c.id  = o.cuenta_id
JOIN surveillance.espejo_clientes     cl ON cl.id = c.cliente_id
CROSS JOIN umbral u
WHERE o.fecha   = %(fecha_jornada)s
  AND o.tipo    = %(tipo)s
  AND o.estado  = 'ejecutada'
  AND o.cuenta_id NOT IN (SELECT cuenta_id FROM caso1)
GROUP BY
    o.cuenta_id, o.operador_id, o.fecha,
    c.numero_cuenta, cl.nombre, cl.nivel_riesgo, u.monto
HAVING
    COUNT(*)                        >= 3
    AND COUNT(DISTINCT instrumento_id) >= 2
    AND MAX(o.monto_total)           < u.monto
    AND SUM(o.monto_total)          >= u.monto
ORDER BY importe_total DESC;
