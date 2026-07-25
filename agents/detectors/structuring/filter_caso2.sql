-- =============================================================================
-- DETECTOR: Structuring — Caso 2
-- Varios días, mismo instrumento (compras y ventas por separado)
-- Detecta fragmentación distribuida en una ventana de días donde ninguna
-- operación supera el umbral individualmente pero el acumulado sí,
-- y las operaciones ocurren en al menos 3 días distintos.
-- Cubre Caso 2a (compras) y Caso 2b (ventas) — GROUP BY incluye tipo.
-- La LFPIORPI no distingue sentido: ambos se reportan a la UIF.
-- Parámetro ventana: structuring_ventana_dias (default 30)
-- =============================================================================

WITH params AS (
    SELECT
        MAX(CASE WHEN clave = 'limite_structuring_mxn'    THEN valor END) AS umbral,
        MAX(CASE WHEN clave = 'structuring_ventana_dias'  THEN valor END) AS ventana_dias
    FROM surveillance.parametros
    WHERE clave IN ('limite_structuring_mxn', 'structuring_ventana_dias')
)
SELECT
    o.cuenta_id,
    o.instrumento_id,
    o.operador_id,
    COUNT(*)                        AS num_operaciones,
    COUNT(DISTINCT o.fecha)         AS num_dias,
    MIN(o.fecha)                    AS fecha_inicio,
    MAX(o.fecha)                    AS fecha_fin,
    SUM(o.monto_total)              AS importe_total,
    MAX(o.monto_total)              AS importe_maximo,
    MIN(o.monto_total)              AS importe_minimo,
    STDDEV(o.monto_total)           AS desviacion_importe,
    c.numero_cuenta,
    cl.nombre,
    cl.nivel_riesgo,
    i.ticker,
    p.umbral                        AS umbral_mxn,
    p.ventana_dias
FROM surveillance.espejo_operaciones  o
JOIN surveillance.espejo_cuentas      c  ON c.id  = o.cuenta_id
JOIN surveillance.espejo_clientes     cl ON cl.id = c.cliente_id
JOIN surveillance.espejo_instrumentos i  ON i.id  = o.instrumento_id
CROSS JOIN params p
WHERE o.fecha  BETWEEN %(fecha_jornada)s::date - (p.ventana_dias || ' days')::interval
                   AND %(fecha_jornada)s::date
  AND o.tipo   = %(tipo)s
  AND o.estado = 'ejecutada'
GROUP BY
    o.cuenta_id, o.instrumento_id, o.operador_id,
    c.numero_cuenta, cl.nombre, cl.nivel_riesgo, i.ticker,
    p.umbral, p.ventana_dias
HAVING
    COUNT(DISTINCT o.fecha) >= 3
    AND MAX(o.monto_total)   < p.umbral
    AND SUM(o.monto_total)  >= p.umbral
    -- excluir los que ya detecta caso 1 (todas las ops en el mismo día)
    AND COUNT(DISTINCT o.fecha) > 1
ORDER BY importe_total DESC;
