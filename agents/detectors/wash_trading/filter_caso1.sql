-- =============================================================================
-- DETECTOR: Wash Trading
-- Art. 212 LMV — manipulación de mercado mediante volumen artificial
--
-- Casos de wash trading en bolsa:
--   Caso 1 — Mismo cliente, mismo operador, precio exacto, cantidad exacta  ← este filter
--   Caso 2 — Mismo cliente, diferente operador, precio exacto               ← filter_caso2.sql
--   Caso 3 — Mismo cliente, precio similar (±0.5%%), cantidad similar (±5%%)  ← filter_caso3.sql
--             Variante para disimular el patrón con pequeñas diferencias
--   Caso 4 — Diferente cliente, mismo operador (coordinación implícita)     ← pendiente
--             El SQL detecta el par pero determinar si hay coordinación
--             requiere análisis de comportamiento histórico del operador.
--             Implementar como agente cuando se valide con área de compliance.
--   Caso 5 — Diferente cliente, diferente operador, precios cruzados        ← fuera de alcance
--             Requiere modelos de series de tiempo para detectar coordinación
--             sin relación directa en BD. No viable en MVP.
--
-- Nota: se registra la alerta sobre la cuenta vendedora (quien inició el patrón)
-- =============================================================================

SELECT
    v.instrumento_id,
    v.operador_id,
    v.fecha,
    v.cuenta_id                         AS cuenta_vendedora,
    c.cuenta_id                         AS cuenta_compradora,
    cv.numero_cuenta                    AS num_cuenta_venta,
    cc.numero_cuenta                    AS num_cuenta_compra,
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
                                        AND c.operador_id    = v.operador_id
                                        AND c.precio         = v.precio
                                        AND c.cantidad       = v.cantidad
                                        AND c.tipo           = 'compra'
                                        AND c.fecha          = v.fecha
                                        AND c.cuenta_id     != v.cuenta_id
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
