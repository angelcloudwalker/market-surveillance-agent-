-- =============================================================================
-- SEED: patrones sospechosos
-- Un caso de prueba por agente del MVP
-- Si el agente no lo detecta, el problema está en filter.sql o en el prompt
-- Fecha de referencia: 2025-01-15 (jornada actual)
-- =============================================================================
--
-- PATRÓN 1 — STRUCTURING       contrato 16 (Grupo Inversor Metropolitano)
--   Instrumento: GISSAA (valor_id=30), vol_promedio 28,000 títulos/día
--   Operación: 9 compras de ~$49,000 c/u en el mismo día
--   Umbral típico de reporte: $50,000 MXN
--   Señal: fragmentación deliberada justo por debajo del umbral
--
-- PATRÓN 2 — WASH TRADING      contratos 11 y 12 (Inversiones Alfa — misma contraparte)
--   Instrumento: VITROA (valor_id=27), baja liquidez
--   Operación: contrato 11 vende 10,000 títulos → contrato 12 compra 10,000 títulos
--   Mismo precio, mismo día, mismo trader
--   Señal: transferencia artificial de posición entre contratos de la misma contraparte
--
-- PATRÓN 3 — DORMANT           contrato 18 (Héctor Manuel Villanueva Prado)
--   Últimas operaciones: septiembre 2020 (~4 años de inactividad)
--   El 2025-01-15 opera $1,200,000 en POCHTECB (valor_id=26)
--   Señal: contrato dormido que despierta con volumen 300x su historial
--
-- PATRÓN 4 — CONCENTRATION     contrato 15 (Capital Empresarial MX)
--   Instrumento: POCHTECB (valor_id=26), vol_promedio 42,000 títulos/día
--   Operación: compra 38,000 títulos = 90.5% del volumen diario del instrumento
--   Señal: un solo contrato acapara casi todo el mercado de esa emisora
--
-- PATRÓN 5 — SPOOFING          contrato 5 (Fernando Javier Castillo Ruiz)
--   Instrumento: GISSAA (valor_id=30), baja liquidez (vol_promedio 28,000)
--   Operación: 5 instrucciones grandes de venta canceladas en <30 segundos c/u
--   seguidas de una compra ejecutada a precio más bajo
--   Señal: presión artificial de venta para bajar el precio y luego comprar
-- =============================================================================

SET search_path = broker;

-- =============================================================================
-- PATRÓN 1: STRUCTURING
-- Grupo Inversor Metropolitano (contrato_id=16, contraparte_id=15)
-- trader_id=4 (Alejandra Torres Ibáñez)
-- GISSAA (valor_id=30), precio ~52.40, umbral $50,000
-- 9 transacciones de 940 títulos = $49,256 c/u — todas el 2025-01-15
-- =============================================================================

INSERT INTO transacciones (contrato_id, valor_id, trader_id, sentido, titulos, precio_ejec, importe, fecha_hora, fecha_op) VALUES
(16, 30, 4, 'compra', 940, 52.400000, 49256.00, '2025-01-15 09:05:00-06', '2025-01-15'),
(16, 30, 4, 'compra', 940, 52.400000, 49256.00, '2025-01-15 09:32:00-06', '2025-01-15'),
(16, 30, 4, 'compra', 940, 52.400000, 49256.00, '2025-01-15 10:01:00-06', '2025-01-15'),
(16, 30, 4, 'compra', 940, 52.400000, 49256.00, '2025-01-15 10:28:00-06', '2025-01-15'),
(16, 30, 4, 'compra', 940, 52.400000, 49256.00, '2025-01-15 10:55:00-06', '2025-01-15'),
(16, 30, 4, 'compra', 940, 52.400000, 49256.00, '2025-01-15 11:22:00-06', '2025-01-15'),
(16, 30, 4, 'compra', 940, 52.400000, 49256.00, '2025-01-15 11:49:00-06', '2025-01-15'),
(16, 30, 4, 'compra', 940, 52.400000, 49256.00, '2025-01-15 12:30:00-06', '2025-01-15'),
(16, 30, 4, 'compra', 940, 52.400000, 49256.00, '2025-01-15 13:05:00-06', '2025-01-15');
-- Total acumulado: 8,460 títulos / $443,304 — fragmentado en 9 tickets de $49,256

-- =============================================================================
-- PATRÓN 2: WASH TRADING
-- Inversiones Alfa S.A. de C.V. — contraparte_id=11, contratos 11 y 12
-- trader_id=2 (Patricia Sánchez Vega) en ambas puntas
-- VITROA (valor_id=27), precio 18.90, baja liquidez (vol_promedio 38,000)
-- Venta desde contrato 11 → compra en contrato 12, mismo precio, mismo día
-- =============================================================================

INSERT INTO transacciones (contrato_id, valor_id, trader_id, sentido, titulos, precio_ejec, importe, fecha_hora, fecha_op) VALUES
(11, 27, 2, 'venta',  10000, 18.900000, 189000.00, '2025-01-15 10:15:00-06', '2025-01-15'),
(12, 27, 2, 'compra', 10000, 18.900000, 189000.00, '2025-01-15 10:16:00-06', '2025-01-15');
-- Misma contraparte, mismo trader, mismo precio, 60 segundos de diferencia
-- 10,000 títulos = 26.3% del volumen diario de VITROA

-- =============================================================================
-- PATRÓN 3: DORMANT
-- Héctor Manuel Villanueva Prado (contrato_id=18, contraparte_id=16)
-- trader_id=1 (Carlos Mendoza Ríos)
-- Historial: 3 operaciones pequeñas en 2020 (promedio ~$3,907)
-- Hoy: compra masiva de POCHTECB (valor_id=26) por $1,200,000 (~307x el promedio)
-- =============================================================================

UPDATE contratos SET ultimo_movimiento = '2025-01-15' WHERE contrato_id = 18;

INSERT INTO transacciones (contrato_id, valor_id, trader_id, sentido, titulos, precio_ejec, importe, fecha_hora, fecha_op) VALUES
(18, 26, 1, 'compra', 96000, 12.500000, 1200000.00, '2025-01-15 09:45:00-06', '2025-01-15');
-- 96,000 títulos = 228% del volumen diario de POCHTECB (vol_promedio=42,000)
-- Importe 35x mayor que cualquier transacción previa de este contrato

-- =============================================================================
-- PATRÓN 4: CONCENTRATION
-- Capital Empresarial MX S.A. (contrato_id=15, contraparte_id=14)
-- trader_id=3 (Roberto Fuentes Mora)
-- POCHTECB (valor_id=26), vol_promedio 42,000 títulos/día
-- Compra 38,000 títulos = 90.5% del volumen diario
-- =============================================================================

INSERT INTO transacciones (contrato_id, valor_id, trader_id, sentido, titulos, precio_ejec, importe, fecha_hora, fecha_op) VALUES
(15, 26, 3, 'compra', 38000, 12.500000, 475000.00, '2025-01-15 11:00:00-06', '2025-01-15');
-- 38,000 / 42,000 = 90.5% del mercado diario de POCHTECB en una sola transacción

-- =============================================================================
-- PATRÓN 5: SPOOFING
-- Fernando Javier Castillo Ruiz (contrato_id=5, contraparte_id=5)
-- trader_id=2 (Patricia Sánchez Vega)
-- GISSAA (valor_id=30), precio referencia 52.40, vol_promedio 28,000
-- 5 instrucciones de venta de 25,000 títulos canceladas en <30 segundos → compra ejecutada más barata
-- =============================================================================

-- Transacción real: compra ejecutada después de cancelar las instrucciones falsas
INSERT INTO transacciones (contrato_id, valor_id, trader_id, sentido, titulos, precio_ejec, importe, fecha_hora, fecha_op) VALUES
(5, 30, 2, 'compra', 15000, 51.800000, 777000.00, '2025-01-15 13:45:35-06', '2025-01-15');
-- Compra a 51.80 — 0.60 pesos por debajo del precio de referencia (52.40)
-- Beneficio de la manipulación: $9,000 en una sola transacción

-- Instrucciones de venta falsas — canceladas en 8 a 25 segundos
INSERT INTO instrucciones (contrato_id, valor_id, trader_id, folio_transaccion, sentido, titulos, precio_limite, hora_envio, hora_cancelacion, estatus, fecha_op) VALUES
(5, 30, 2, NULL, 'venta', 25000, 52.200000, '2025-01-15 13:44:00-06', '2025-01-15 13:44:08-06', 'cancelada', '2025-01-15'),
(5, 30, 2, NULL, 'venta', 25000, 52.100000, '2025-01-15 13:44:10-06', '2025-01-15 13:44:23-06', 'cancelada', '2025-01-15'),
(5, 30, 2, NULL, 'venta', 25000, 52.000000, '2025-01-15 13:44:25-06', '2025-01-15 13:44:40-06', 'cancelada', '2025-01-15'),
(5, 30, 2, NULL, 'venta', 25000, 51.900000, '2025-01-15 13:44:42-06', '2025-01-15 13:45:05-06', 'cancelada', '2025-01-15'),
(5, 30, 2, NULL, 'venta', 25000, 51.800000, '2025-01-15 13:45:07-06', '2025-01-15 13:45:28-06', 'cancelada', '2025-01-15');
-- 5 instrucciones × 25,000 títulos = 125,000 títulos de presión artificial (446% del vol diario)
-- Canceladas entre 8 y 23 segundos
-- Precio bajando escalonadamente: 52.20 → 51.80

-- Instrucción ejecutada vinculada a la compra real
INSERT INTO instrucciones (contrato_id, valor_id, trader_id, folio_transaccion, sentido, titulos, precio_limite, hora_envio, hora_cancelacion, estatus, fecha_op) VALUES
(5, 30, 2, 66, 'compra', 15000, 51.800000, '2025-01-15 13:45:30-06', NULL, 'ejecutada', '2025-01-15');
