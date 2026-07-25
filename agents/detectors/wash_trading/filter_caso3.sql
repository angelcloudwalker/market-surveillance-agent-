-- =============================================================================
-- DETECTOR: Wash Trading — Caso 3
-- Mismo cliente, precio similar (±0.5%%), cantidad similar (±5%%)
-- Variante donde el cliente introduce pequeñas diferencias para disimular
-- el patrón y evitar detección por coincidencia exacta.
-- La tolerancia se aplica sobre precio y cantidad para capturar estas variantes.
-- =============================================================================

SELECT
    v.instrumento_id,
    v.fecha,
    v.cuenta_id                         AS cuenta_vendedora,
    c.cuenta_id                         AS cuenta_compradora,
    cv.numero_cuenta                    AS num_cuenta_venta,
    cc.numero_cuenta                    AS num_cuenta_compra,
    cl.nombre                           AS cliente,
    cl.nivel_riesgo,
    i.ticker,
    i.volumen_promedio_diario,
    v.precio                            AS precio_venta,
    c.precio                            AS precio_compra,
    ABS(v.precio - c.precio) / v.precio * 100   AS diferencia_precio_pct,
    v.cantidad                          AS titulos_venta,
    c.cantidad                          AS titulos_compra,
    ABS(v.cantidad - c.cantidad)::float / v.cantidad * 100  AS diferencia_cantidad_pct,
    v.monto_total                       AS monto,
    EXTRACT(EPOCH FROM (c.timestamp - v.timestamp)) AS segundos_diferencia
FROM surveillance.espejo_operaciones  v
JOIN surveillance.espejo_operaciones  c  ON c.instrumento_id = v.instrumento_id
                                        AND c.tipo           = 'compra'
                                        AND c.fecha          = v.fecha
                                        AND c.cuenta_id     != v.cuenta_id
                                        AND c.timestamp      > v.timestamp
                                        -- tolerancia precio ±0.5%%
                                        AND ABS(v.precio - c.precio) / v.precio <= 0.005
                                        -- tolerancia cantidad ±5%%
                                        AND ABS(v.cantidad - c.cantidad)::float / v.cantidad <= 0.05
                                        -- excluir coincidencias exactas (ya las cubre caso 1 y 2)
                                        AND NOT (c.precio = v.precio AND c.cantidad = v.cantidad)
JOIN surveillance.espejo_cuentas      cv ON cv.id = v.cuenta_id
JOIN surveillance.espejo_cuentas      cc ON cc.id = c.cuenta_id
JOIN surveillance.espejo_clientes     cl ON cl.id = cv.cliente_id
JOIN surveillance.espejo_instrumentos i  ON i.id  = v.instrumento_id
WHERE v.tipo        = 'venta'
  AND v.fecha       = %s
  AND v.estado      = 'ejecutada'
  AND c.estado      = 'ejecutada'
  AND cv.cliente_id = cc.cliente_id
ORDER BY monto DESC;
