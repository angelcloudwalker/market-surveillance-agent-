-- Detecta cuentas que concentran un porcentaje inusual del volumen
-- total operado de un instrumento en la jornada

WITH params AS (
    SELECT valor::numeric AS pct_concentracion
    FROM surveillance.parametros
    WHERE clave = 'limite_concentration_pct_volumen'
),
volumen_instrumento AS (
    SELECT
        instrumento_id,
        fecha,
        SUM(cantidad)    AS titulos_totales_jornada,
        SUM(monto_total) AS importe_total_jornada,
        COUNT(DISTINCT cuenta_id) AS cuentas_participantes
    FROM surveillance.espejo_operaciones
    WHERE fecha  = %(fecha_jornada)s
      AND estado = 'ejecutada'
    GROUP BY instrumento_id, fecha
)
SELECT
    o.cuenta_id,
    o.instrumento_id,
    o.fecha,
    SUM(o.cantidad)                                                         AS titulos_cuenta,
    SUM(o.monto_total)                                                      AS importe_cuenta,
    vi.titulos_totales_jornada,
    vi.importe_total_jornada,
    vi.cuentas_participantes,
    SUM(o.cantidad)::numeric / NULLIF(vi.titulos_totales_jornada, 0) * 100  AS pct_titulos,
    SUM(o.monto_total) / NULLIF(vi.importe_total_jornada, 0) * 100          AS pct_importe,
    i.volumen_promedio_diario,
    SUM(o.cantidad)::numeric / NULLIF(i.volumen_promedio_diario, 0) * 100   AS pct_vs_promedio,
    c.numero_cuenta,
    cl.nombre,
    cl.nivel_riesgo,
    i.ticker,
    p.pct_concentracion AS umbral_pct
FROM surveillance.espejo_operaciones  o
JOIN volumen_instrumento              vi ON vi.instrumento_id = o.instrumento_id
                                        AND vi.fecha          = o.fecha
JOIN surveillance.espejo_cuentas      c  ON c.id  = o.cuenta_id
JOIN surveillance.espejo_clientes     cl ON cl.id = c.cliente_id
JOIN surveillance.espejo_instrumentos i  ON i.id  = o.instrumento_id
CROSS JOIN params p
WHERE o.fecha  = %(fecha_jornada)s
  AND o.estado = 'ejecutada'
GROUP BY
    o.cuenta_id, o.instrumento_id, o.fecha,
    vi.titulos_totales_jornada, vi.importe_total_jornada, vi.cuentas_participantes,
    i.volumen_promedio_diario, c.numero_cuenta, cl.nombre, cl.nivel_riesgo, i.ticker,
    p.pct_concentracion
HAVING
    SUM(o.cantidad)::numeric / NULLIF(vi.titulos_totales_jornada, 0) * 100 >= p.pct_concentracion
ORDER BY pct_titulos DESC;
