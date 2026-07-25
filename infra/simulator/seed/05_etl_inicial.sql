-- ETL manual: copia broker → surveillance.espejo_*
-- Correr después de cargar los seeds del simulador
-- Orden importante: respetar foreign keys

SET search_path = surveillance;

INSERT INTO espejo_operadores (id, clave_operador, nombre, estado, fecha_alta)
SELECT trader_id, clave_op, nombre_completo, estatus, fecha_registro
FROM broker.traders
ON CONFLICT (id) DO NOTHING;

INSERT INTO espejo_clientes (id, nombre, tipo, rfc, fecha_alta, pais, nivel_riesgo, estado)
SELECT contraparte_id, nombre_razon_social, tipo_persona, clave_fiscal, fecha_alta, pais_origen, perfil_riesgo, estatus
FROM broker.contrapartes
ON CONFLICT (id) DO NOTHING;

INSERT INTO espejo_cuentas (id, cliente_id, numero_cuenta, tipo, moneda, fecha_apertura, fecha_ultimo_movimiento, estado)
SELECT contrato_id, contraparte_id, num_contrato, modalidad, divisa, fecha_apertura, ultimo_movimiento, estatus
FROM broker.contratos
ON CONFLICT (id) DO NOTHING;

INSERT INTO espejo_instrumentos (id, ticker, nombre, sector, mercado, tipo, volumen_promedio_diario, precio_referencia, estado)
SELECT valor_id, clave_cotizacion, razon_social, sector_economico, bolsa, tipo_valor, vol_promedio, precio_cierre, estatus
FROM broker.valores
ON CONFLICT (id) DO NOTHING;

INSERT INTO espejo_operaciones (id, cuenta_id, instrumento_id, operador_id, tipo, cantidad, precio, monto_total, timestamp, fecha, estado)
SELECT folio, contrato_id, valor_id, trader_id, sentido, titulos, precio_ejec, importe, fecha_hora, fecha_op, estatus
FROM broker.transacciones
ON CONFLICT (id) DO NOTHING;

INSERT INTO espejo_ordenes (id, cuenta_id, instrumento_id, operador_id, operacion_id, tipo, cantidad, precio, timestamp_envio, timestamp_cancelacion, estado, fecha)
SELECT instruccion_id, contrato_id, valor_id, trader_id, folio_transaccion, sentido, titulos, precio_limite, hora_envio, hora_cancelacion, estatus, fecha_op
FROM broker.instrucciones
ON CONFLICT (id) DO NOTHING;
