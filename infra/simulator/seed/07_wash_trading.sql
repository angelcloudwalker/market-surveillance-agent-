-- =============================================================================
-- SEED: Wash Trading — Casos 1, 2 y 3
-- Datos de prueba para validar detección de operaciones espejo entre cuentas
-- del mismo cliente en el mismo instrumento.
-- Fecha de prueba: 2026-07-24
-- =============================================================================

-- =============================================================================
-- Caso 1 — Mismo cliente, mismo operador, precio exacto, cantidad exacta
-- Cliente: Inversiones Alfa S.A. de C.V. (cliente_id=11)
-- Cuenta vendedora: CB-000111 (cuenta_id=11) / Compradora: CB-000112 (cuenta_id=12)
-- Instrumento: AMXL (valor_id=1)
-- Operador: trader_id=1 en ambas
-- =============================================================================
INSERT INTO broker.transacciones
    (folio, contrato_id, valor_id, trader_id, sentido, titulos, precio_ejec, importe, fecha_hora, fecha_op, estatus)
VALUES
    (300, 11, 1, 1, 'venta',  500, 120.00, 60000.00, '2026-01-15 10:00:00+00', '2026-01-15', 'ejecutada'),
    (301, 12, 1, 1, 'compra', 500, 120.00, 60000.00, '2026-01-15 10:00:45+00', '2026-01-15', 'ejecutada')
ON CONFLICT (folio) DO NOTHING;

-- =============================================================================
-- Caso 2 — Mismo cliente, diferente operador, precio exacto, cantidad exacta
-- Cliente: Inversiones Alfa S.A. de C.V. (cliente_id=11)
-- Cuenta vendedora: CB-000111 (cuenta_id=11) / Compradora: CB-000112 (cuenta_id=12)
-- Instrumento: FEMSAUBD (valor_id=2)
-- Operador venta: trader_id=1 / Operador compra: trader_id=2
-- =============================================================================
INSERT INTO broker.transacciones
    (folio, contrato_id, valor_id, trader_id, sentido, titulos, precio_ejec, importe, fecha_hora, fecha_op, estatus)
VALUES
    (302, 11, 2, 1, 'venta',  300, 200.00, 60000.00, '2026-01-15 11:00:00+00', '2026-01-15', 'ejecutada'),
    (303, 12, 2, 2, 'compra', 300, 200.00, 60000.00, '2026-01-15 11:02:00+00', '2026-01-15', 'ejecutada')
ON CONFLICT (folio) DO NOTHING;

-- =============================================================================
-- Caso 3 — Mismo cliente, precio similar (±0.5%), cantidad similar (±5%)
-- Cliente: Grupo Inversor Metropolitano S.C. (cliente_id=15)
-- Cuenta vendedora: CB-000116 (cuenta_id=16) / Compradora: CB-000117 (cuenta_id=17)
-- Instrumento: GFNORTEO (valor_id=3)
-- Pequeña variación en precio y cantidad para disimular el patrón
-- =============================================================================
INSERT INTO broker.transacciones
    (folio, contrato_id, valor_id, trader_id, sentido, titulos, precio_ejec, importe, fecha_hora, fecha_op, estatus)
VALUES
    (304, 16, 3, 1, 'venta',  1000, 150.00, 150000.00, '2026-01-15 12:00:00+00', '2026-01-15', 'ejecutada'),
    (305, 17, 3, 2, 'compra',  980, 150.50, 147490.00, '2026-01-15 12:01:30+00', '2026-01-15', 'ejecutada')
ON CONFLICT (folio) DO NOTHING;
