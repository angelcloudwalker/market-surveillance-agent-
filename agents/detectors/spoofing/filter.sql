-- Detecta cuentas con órdenes de volumen inusual canceladas en menos de N segundos
-- seguidas de una operación ejecutada en dirección contraria (beneficiaria)

WITH params AS (
    SELECT
        MAX(CASE WHEN clave = 'spoofing_segundos_cancelacion' THEN valor::int     END) AS seg_cancelacion,
        MAX(CASE WHEN clave = 'spoofing_pct_volumen_orden'    THEN valor::numeric END) AS pct_volumen
    FROM surveillance.parametros
    WHERE clave IN ('spoofing_segundos_cancelacion', 'spoofing_pct_volumen_orden')
),
ordenes_fantasma AS (
    SELECT
        ord.id                  AS orden_id,
        ord.cuenta_id,
        ord.instrumento_id,
        ord.tipo                AS tipo_orden,
        ord.cantidad,
        ord.precio,
        ord.timestamp_envio,
        ord.timestamp_cancelacion,
        EXTRACT(EPOCH FROM (ord.timestamp_cancelacion - ord.timestamp_envio)) AS segundos_vida,
        ord.fecha,
        ord.cantidad::numeric / NULLIF(i.volumen_promedio_diario, 0) * 100 AS pct_volumen_orden
    FROM surveillance.espejo_ordenes      ord
    JOIN surveillance.espejo_instrumentos i ON i.id = ord.instrumento_id
    CROSS JOIN params p
    WHERE ord.fecha   = %(fecha_jornada)s
      AND ord.estado  = 'cancelada'
      AND EXTRACT(EPOCH FROM (ord.timestamp_cancelacion - ord.timestamp_envio)) <= p.seg_cancelacion
      AND ord.cantidad::numeric / NULLIF(i.volumen_promedio_diario, 0) * 100 >= p.pct_volumen
)
SELECT
    og.cuenta_id,
    og.instrumento_id,
    og.fecha,
    COUNT(og.orden_id)                  AS num_ordenes_fantasma,
    SUM(og.cantidad)                    AS titulos_presion_total,
    AVG(og.segundos_vida)               AS segundos_vida_promedio,
    og.tipo_orden                       AS tipo_presion,
    -- operación ejecutada en dirección contraria dentro de la ventana
    op.id                               AS operacion_beneficiaria_id,
    op.tipo                             AS tipo_operacion_beneficiaria,
    op.cantidad                         AS titulos_beneficiarios,
    op.precio                           AS precio_beneficiario,
    op.monto_total                      AS importe_beneficiario,
    op.timestamp                        AS timestamp_beneficiaria,
    c.numero_cuenta,
    cl.nombre,
    cl.nivel_riesgo,
    i.ticker,
    i.precio_referencia,
    p.seg_cancelacion                   AS umbral_segundos,
    p.pct_volumen                       AS umbral_pct_volumen
FROM ordenes_fantasma og
JOIN surveillance.espejo_operaciones  op ON op.cuenta_id      = og.cuenta_id
                                        AND op.instrumento_id  = og.instrumento_id
                                        AND op.fecha           = og.fecha
                                        AND op.estado          = 'ejecutada'
                                        AND op.tipo           != og.tipo_orden   -- dirección contraria
                                        AND op.timestamp BETWEEN og.timestamp_envio
                                                             AND og.timestamp_cancelacion + INTERVAL '120 seconds'
JOIN surveillance.espejo_cuentas      c  ON c.id  = og.cuenta_id
JOIN surveillance.espejo_clientes     cl ON cl.id = c.cliente_id
JOIN surveillance.espejo_instrumentos i  ON i.id  = og.instrumento_id
CROSS JOIN params p
GROUP BY
    og.cuenta_id, og.instrumento_id, og.fecha, og.tipo_orden,
    op.id, op.tipo, op.cantidad, op.precio, op.monto_total, op.timestamp,
    c.numero_cuenta, cl.nombre, cl.nivel_riesgo,
    i.ticker, i.precio_referencia,
    p.seg_cancelacion, p.pct_volumen
ORDER BY num_ordenes_fantasma DESC, importe_beneficiario DESC;
