-- =============================================================================
-- SEED: Structuring — Caso 2 y Caso 3
-- Datos de prueba para validar detección de fragmentación multi-día
-- y fragmentación multi-instrumento mismo día.
-- Umbral: $70,028 MXN (645 x UMA diaria)
-- =============================================================================

-- =============================================================================
-- Caso 2 — Varios días, mismo instrumento
-- Cuenta: CB-000101 (cuenta_id=1) / Instrumento: AMXL (instrumento_id=1)
-- 4 compras en 4 días distintos dentro de ventana 30 días al 2026-01-15
-- Ninguna supera $70,028 individualmente ($68,000) pero acumulado = $272,000
-- =============================================================================
INSERT INTO broker.transacciones
    (folio, contrato_id, valor_id, trader_id, sentido, titulos, precio_ejec, importe, fecha_hora, fecha_op, estatus)
VALUES
    (200, 1, 1, 1, 'compra', 100, 680.00, 68000.00, '2026-01-05 10:00:00+00', '2026-01-05', 'ejecutada'),
    (201, 1, 1, 1, 'compra', 100, 680.00, 68000.00, '2026-01-07 10:00:00+00', '2026-01-07', 'ejecutada'),
    (202, 1, 1, 1, 'compra', 100, 680.00, 68000.00, '2026-01-09 10:00:00+00', '2026-01-09', 'ejecutada'),
    (203, 1, 1, 1, 'compra', 100, 680.00, 68000.00, '2026-01-11 10:00:00+00', '2026-01-11', 'ejecutada')
ON CONFLICT (folio) DO NOTHING;

-- =============================================================================
-- Caso 3 — Mismo día, varios instrumentos
-- Cuenta: CB-000102 (cuenta_id=2) / Fecha: 2026-01-15
-- 3 compras en 3 instrumentos distintos (FEMSAUBD, GFNORTEO, WALMEX*)
-- Ninguna supera $70,028 individualmente ($68,000) pero acumulado = $204,000
-- =============================================================================
INSERT INTO broker.transacciones
    (folio, contrato_id, valor_id, trader_id, sentido, titulos, precio_ejec, importe, fecha_hora, fecha_op, estatus)
VALUES
    (204, 2, 2, 1, 'compra', 100, 680.00, 68000.00, '2026-01-15 09:00:00+00', '2026-01-15', 'ejecutada'),
    (205, 2, 3, 1, 'compra', 100, 680.00, 68000.00, '2026-01-15 10:00:00+00', '2026-01-15', 'ejecutada'),
    (206, 2, 4, 1, 'compra', 100, 680.00, 68000.00, '2026-01-15 11:00:00+00', '2026-01-15', 'ejecutada')
ON CONFLICT (folio) DO NOTHING;
