-- Detecta cuentas que estuvieron inactivas por encima del umbral de meses
-- y hoy registran operaciones con importe significativamente mayor a su historial

WITH params AS (
    SELECT
        MAX(CASE WHEN clave = 'dormant_meses_inactividad'   THEN valor::int  END) AS meses_inactividad,
        MAX(CASE WHEN clave = 'dormant_factor_volumen'      THEN valor::numeric END) AS factor_volumen
    FROM surveillance.parametros
    WHERE clave IN ('dormant_meses_inactividad', 'dormant_factor_volumen')
),
historial AS (
    -- importe promedio histórico por cuenta, excluyendo la jornada actual
    SELECT
        cuenta_id,
        AVG(monto_total)  AS importe_promedio_historico,
        MAX(monto_total)  AS importe_maximo_historico,
        COUNT(*)          AS total_operaciones_historicas,
        MAX(fecha)        AS ultima_fecha_operacion
    FROM surveillance.espejo_operaciones
    WHERE fecha < %(fecha_jornada)s
      AND estado = 'ejecutada'
    GROUP BY cuenta_id
),
operaciones_hoy AS (
    SELECT
        o.cuenta_id,
        o.instrumento_id,
        COUNT(*)          AS num_operaciones_hoy,
        SUM(o.monto_total) AS importe_total_hoy,
        MAX(o.monto_total) AS importe_maximo_hoy,
        o.fecha
    FROM surveillance.espejo_operaciones o
    WHERE o.fecha  = %(fecha_jornada)s
      AND o.estado = 'ejecutada'
    GROUP BY o.cuenta_id, o.instrumento_id, o.fecha
)
SELECT
    oh.cuenta_id,
    oh.instrumento_id,
    oh.fecha,
    oh.num_operaciones_hoy,
    oh.importe_total_hoy,
    oh.importe_maximo_hoy,
    h.importe_promedio_historico,
    h.importe_maximo_historico,
    h.total_operaciones_historicas,
    h.ultima_fecha_operacion,
    (%(fecha_jornada)s::date - h.ultima_fecha_operacion::date) AS dias_inactiva,
    oh.importe_total_hoy / NULLIF(h.importe_promedio_historico, 0) AS factor_incremento,
    c.numero_cuenta,
    cl.nombre,
    cl.nivel_riesgo,
    i.ticker,
    p.meses_inactividad AS umbral_meses,
    p.factor_volumen    AS umbral_factor
FROM operaciones_hoy    oh
JOIN historial          h  ON h.cuenta_id = oh.cuenta_id
JOIN surveillance.espejo_cuentas      c  ON c.id  = oh.cuenta_id
JOIN surveillance.espejo_clientes     cl ON cl.id = c.cliente_id
JOIN surveillance.espejo_instrumentos i  ON i.id  = oh.instrumento_id
CROSS JOIN params p
WHERE (%(fecha_jornada)s::date - h.ultima_fecha_operacion::date) >= p.meses_inactividad * 30
  AND oh.importe_total_hoy / NULLIF(h.importe_promedio_historico, 0) >= p.factor_volumen
ORDER BY factor_incremento DESC;
