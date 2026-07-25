CREATE TABLE IF NOT EXISTS surveillance.parametros (
    clave       VARCHAR(100) PRIMARY KEY,
    valor       NUMERIC(18,4) NOT NULL,
    descripcion TEXT          NOT NULL,
    vigente_desde DATE        NOT NULL,
    updated_at  TIMESTAMP     DEFAULT NOW()
);

-- UMA 2025 (INEGI, vigente desde 01-feb-2025)
-- Fuente: https://www.inegi.org.mx/temas/uma/
INSERT INTO surveillance.parametros (clave, valor, descripcion, vigente_desde) VALUES
('uma_diaria',               108.57,   'Unidad de Medida y Actualización diaria (MXN) — INEGI 2025',          '2025-02-01'),
('uma_mensual',             3299.48,   'Unidad de Medida y Actualización mensual (MXN) — INEGI 2025',         '2025-02-01'),
('uma_anual',              39593.76,   'Unidad de Medida y Actualización anual (MXN) — INEGI 2025',           '2025-02-01'),
-- Umbral structuring: 645 x UMA diaria (Art. 17 LFPIORPI — actividades vulnerables, aviso a UIF)
('limite_structuring_mxn',  70027.65,  'Límite structuring: 645 x UMA diaria — Art. 17 LFPIORPI (MXN)',      '2025-02-01'),
('limite_structuring_veces_uma', 645,  'Multiplicador UMA para structuring — Art. 17 LFPIORPI',              '2025-02-01'),
('structuring_ventana_dias',      30,  'Ventana en días para detección de structuring multi-día — Caso 2',   '2025-02-01'),
-- Wash trading
('limite_wash_trading_pct_volumen',  10,   'Mínimo % del volumen diario del instrumento para considerar wash trading', '2025-02-01'),
-- Dormant
('dormant_meses_inactividad',         6,   'Meses sin actividad para considerar cuenta dormida',                  '2025-02-01'),
('dormant_factor_volumen',            5,   'Factor mínimo de incremento vs importe promedio histórico',           '2025-02-01'),
-- Concentration
('limite_concentration_pct_volumen', 25,   'Mínimo % del volumen diario del instrumento para alerta de concentración', '2025-02-01'),
-- Spoofing
('spoofing_segundos_cancelacion',    60,   'Máximo de segundos de vida de una orden para considerarla fantasma',  '2025-02-01'),
('spoofing_pct_volumen_orden',       10,   'Mínimo % del volumen diario que debe tener la orden fantasma',        '2025-02-01')
ON CONFLICT (clave) DO UPDATE
    SET valor = EXCLUDED.valor,
        descripcion = EXCLUDED.descripcion,
        vigente_desde = EXCLUDED.vigente_desde,
        updated_at = NOW();
