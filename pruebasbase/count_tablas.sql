-- =============================================================================
-- COUNT por tabla — esquemas broker y surveillance
-- =============================================================================

SELECT 'broker.contrapartes'           AS tabla, COUNT(*) AS registros FROM broker.contrapartes
UNION ALL
SELECT 'broker.contratos',              COUNT(*) FROM broker.contratos
UNION ALL
SELECT 'broker.instrucciones',          COUNT(*) FROM broker.instrucciones
UNION ALL
SELECT 'broker.resumen_diario',         COUNT(*) FROM broker.resumen_diario
UNION ALL
SELECT 'broker.tenencias',              COUNT(*) FROM broker.tenencias
UNION ALL
SELECT 'broker.traders',                COUNT(*) FROM broker.traders
UNION ALL
SELECT 'broker.transacciones',          COUNT(*) FROM broker.transacciones
UNION ALL
SELECT 'broker.valores',                COUNT(*) FROM broker.valores
UNION ALL
SELECT '---',                           0
UNION ALL
SELECT 'surveillance.alertas',          COUNT(*) FROM surveillance.alertas
UNION ALL
SELECT 'surveillance.analisis_alerta',  COUNT(*) FROM surveillance.analisis_alerta
UNION ALL
SELECT 'surveillance.bitacora_etl',     COUNT(*) FROM surveillance.bitacora_etl
UNION ALL
SELECT 'surveillance.caso_alertas',     COUNT(*) FROM surveillance.caso_alertas
UNION ALL
SELECT 'surveillance.casos',            COUNT(*) FROM surveillance.casos
UNION ALL
SELECT 'surveillance.contexto_mercado', COUNT(*) FROM surveillance.contexto_mercado
UNION ALL
SELECT 'surveillance.espejo_clientes',  COUNT(*) FROM surveillance.espejo_clientes
UNION ALL
SELECT 'surveillance.espejo_cuentas',   COUNT(*) FROM surveillance.espejo_cuentas
UNION ALL
SELECT 'surveillance.espejo_instrumentos', COUNT(*) FROM surveillance.espejo_instrumentos
UNION ALL
SELECT 'surveillance.espejo_operaciones',  COUNT(*) FROM surveillance.espejo_operaciones
UNION ALL
SELECT 'surveillance.espejo_operadores',   COUNT(*) FROM surveillance.espejo_operadores
UNION ALL
SELECT 'surveillance.espejo_ordenes',      COUNT(*) FROM surveillance.espejo_ordenes
UNION ALL
SELECT 'surveillance.espejo_posiciones',   COUNT(*) FROM surveillance.espejo_posiciones
UNION ALL
SELECT 'surveillance.espejo_saldos_diarios', COUNT(*) FROM surveillance.espejo_saldos_diarios
UNION ALL
SELECT 'surveillance.evidencia_operaciones', COUNT(*) FROM surveillance.evidencia_operaciones
UNION ALL
SELECT 'surveillance.evidencia_ordenes',     COUNT(*) FROM surveillance.evidencia_ordenes
UNION ALL
SELECT 'surveillance.legislacion',           COUNT(*) FROM surveillance.legislacion
UNION ALL
SELECT 'surveillance.notas_cliente',         COUNT(*) FROM surveillance.notas_cliente
UNION ALL
SELECT 'surveillance.parametros',            COUNT(*) FROM surveillance.parametros

ORDER BY tabla;
