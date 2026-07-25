-- =============================================================================
-- DETECTOR: Wash Trading — Caso 2
-- Mismo cliente, diferente operador, precio exacto, cantidad exacta
-- El cliente usa dos traders distintos para ocultar la relación entre cuentas.
-- La señal sigue siendo clara: mismo dueño, mismo instrumento, operaciones espejo.
-- =============================================================================

SELECT
    v.instrumento_id,
    v.fecha,
    v.cuenta_id                         AS cuenta_vendedora,
    c.cuenta_id                         AS cuenta_compradora,
    cv.numero_cuenta                    AS num_cuenta_venta,
    cc.numero_cuenta                    AS num_cuenta_compra,
    v.operador_id                       AS operador_venta,
    c.operador_id                       AS operador_compra,
    cl.nombre                           AS cliente,
    cl.nivel_riesgo,
    i.ticker,
    i.volumen_promedio_diario,
    v.precio                            AS precio,
    v.cantidad                          AS titulos,
    v.monto_total                       AS monto,
    EXTRACT(EPOCH FROM (c.timestamp - v.timestamp)) AS segundos_diferencia
FROM surveillance.espejo_operaciones  v
JOIN surveillance.espejo_operaciones  c  ON c.instrumento_id = v.instrumento_id
                                        AND c.precio         = v.precio
                                        AND c.cantidad       = v.cantidad
                                        AND c.tipo           = 'compra'
                                        AND c.fecha          = v.fecha
                                        AND c.cuenta_id     != v.cuenta_id
                                        AND c.operador_id   != v.operador_id
                                        AND c.timestamp      > v.timestamp
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
