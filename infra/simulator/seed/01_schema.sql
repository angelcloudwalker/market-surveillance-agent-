-- =============================================================================
-- ESQUEMA: broker
-- Representa la base de datos de una casa de bolsa con sistema legacy
-- Nomenclatura deliberadamente diferente a surveillance
-- El adaptador es el único que sabe cómo traducir este esquema al canónico
-- =============================================================================

CREATE SCHEMA IF NOT EXISTS broker;

SET search_path = broker;

-- =============================================================================
-- TRADERS
-- Equivalente a: brokerage.operadores
-- Diferencias: clave_op en lugar de clave_operador, estatus en lugar de estado
-- =============================================================================
CREATE TABLE traders (
    trader_id           SERIAL       PRIMARY KEY,
    clave_op            VARCHAR(20)  NOT NULL UNIQUE,
    nombre_completo     VARCHAR(200) NOT NULL,
    estatus             VARCHAR(10)  NOT NULL DEFAULT 'activo'
                            CHECK (estatus IN ('activo', 'inactivo', 'suspendido')),
    fecha_registro      DATE         NOT NULL DEFAULT CURRENT_DATE
);

-- =============================================================================
-- CONTRAPARTES
-- Equivalente a: brokerage.clientes
-- Diferencias: contraparte_id, tipo_persona, clave_fiscal, perfil_riesgo
-- =============================================================================
CREATE TABLE contrapartes (
    contraparte_id      SERIAL       PRIMARY KEY,
    nombre_razon_social VARCHAR(200) NOT NULL,
    tipo_persona        VARCHAR(10)  NOT NULL CHECK (tipo_persona IN ('fisica', 'moral')),
    clave_fiscal        VARCHAR(13)  NOT NULL UNIQUE,
    fecha_alta          DATE         NOT NULL,
    pais_origen         CHAR(2)      NOT NULL DEFAULT 'MX',
    perfil_riesgo       VARCHAR(10)  NOT NULL DEFAULT 'bajo'
                            CHECK (perfil_riesgo IN ('bajo', 'medio', 'alto')),
    estatus             VARCHAR(10)  NOT NULL DEFAULT 'activo'
                            CHECK (estatus IN ('activo', 'inactivo', 'bloqueado'))
);

-- =============================================================================
-- CONTRATOS
-- Equivalente a: brokerage.cuentas
-- Diferencias: contrato_id, contraparte_id, num_contrato, ultimo_movimiento
-- =============================================================================
CREATE TABLE contratos (
    contrato_id         SERIAL       PRIMARY KEY,
    contraparte_id      INT          NOT NULL REFERENCES contrapartes(contraparte_id),
    num_contrato        VARCHAR(20)  NOT NULL UNIQUE,
    modalidad           VARCHAR(10)  NOT NULL DEFAULT 'cash'
                            CHECK (modalidad IN ('cash', 'margin')),
    divisa              CHAR(3)      NOT NULL DEFAULT 'MXN',
    fecha_apertura      DATE         NOT NULL,
    ultimo_movimiento   DATE,
    estatus             VARCHAR(10)  NOT NULL DEFAULT 'activa'
                            CHECK (estatus IN ('activa', 'inactiva', 'bloqueada', 'cerrada'))
);

-- =============================================================================
-- VALORES
-- Equivalente a: brokerage.instrumentos
-- Diferencias: valor_id, clave_cotizacion, razon_social, vol_promedio, precio_cierre
-- =============================================================================
CREATE TABLE valores (
    valor_id            SERIAL       PRIMARY KEY,
    clave_cotizacion    VARCHAR(20)  NOT NULL UNIQUE,
    razon_social        VARCHAR(200) NOT NULL,
    sector_economico    VARCHAR(100),
    bolsa               VARCHAR(20)  NOT NULL DEFAULT 'BMV'
                            CHECK (bolsa IN ('BMV', 'BIVA', 'SIC')),
    tipo_valor          VARCHAR(20)  NOT NULL DEFAULT 'accion'
                            CHECK (tipo_valor IN ('accion', 'etf', 'cete', 'bono', 'fibra')),
    vol_promedio        BIGINT       NOT NULL DEFAULT 0,
    precio_cierre       NUMERIC(18,6),
    estatus             VARCHAR(10)  NOT NULL DEFAULT 'activo'
                            CHECK (estatus IN ('activo', 'suspendido', 'inactivo'))
);

-- =============================================================================
-- TRANSACCIONES
-- Equivalente a: brokerage.operaciones
-- Diferencias: folio, contrato_id, valor_id, operador_id→trader_id,
--              tipo→sentido, cantidad→titulos, precio→precio_ejec,
--              monto_total→importe, timestamp→fecha_hora, estado→estatus
-- =============================================================================
CREATE TABLE transacciones (
    folio               BIGSERIAL    PRIMARY KEY,
    contrato_id         INT          NOT NULL REFERENCES contratos(contrato_id),
    valor_id            INT          NOT NULL REFERENCES valores(valor_id),
    trader_id           INT          REFERENCES traders(trader_id),
    sentido             VARCHAR(6)   NOT NULL CHECK (sentido IN ('compra', 'venta')),
    titulos             BIGINT       NOT NULL CHECK (titulos > 0),
    precio_ejec         NUMERIC(18,6) NOT NULL CHECK (precio_ejec > 0),
    importe             NUMERIC(18,2) NOT NULL,
    fecha_hora          TIMESTAMPTZ  NOT NULL,
    fecha_op            DATE         NOT NULL,
    estatus             VARCHAR(12)  NOT NULL DEFAULT 'ejecutada'
                            CHECK (estatus IN ('ejecutada', 'anulada'))
);

-- =============================================================================
-- INSTRUCCIONES
-- Equivalente a: brokerage.ordenes
-- Diferencias: instruccion_id, contrato_id, valor_id, trader_id,
--              folio_transaccion, sentido, titulos, precio_limite,
--              hora_envio, hora_cancelacion, estatus
-- =============================================================================
CREATE TABLE instrucciones (
    instruccion_id      BIGSERIAL    PRIMARY KEY,
    contrato_id         INT          NOT NULL REFERENCES contratos(contrato_id),
    valor_id            INT          NOT NULL REFERENCES valores(valor_id),
    trader_id           INT          REFERENCES traders(trader_id),
    folio_transaccion   BIGINT       REFERENCES transacciones(folio),
    sentido             VARCHAR(6)   NOT NULL CHECK (sentido IN ('compra', 'venta')),
    titulos             BIGINT       NOT NULL CHECK (titulos > 0),
    precio_limite       NUMERIC(18,6) NOT NULL CHECK (precio_limite > 0),
    hora_envio          TIMESTAMPTZ  NOT NULL,
    hora_cancelacion    TIMESTAMPTZ,
    estatus             VARCHAR(12)  NOT NULL
                            CHECK (estatus IN ('activa', 'ejecutada', 'cancelada', 'expirada')),
    fecha_op            DATE         NOT NULL
);

-- =============================================================================
-- TENENCIAS
-- Equivalente a: brokerage.posiciones
-- Diferencias: tenencia_id, contrato_id, valor_id, saldo_titulos,
--              costo_promedio, valuacion
-- =============================================================================
CREATE TABLE tenencias (
    tenencia_id         SERIAL       PRIMARY KEY,
    contrato_id         INT          NOT NULL REFERENCES contratos(contrato_id),
    valor_id            INT          NOT NULL REFERENCES valores(valor_id),
    fecha_valuacion     DATE         NOT NULL,
    saldo_titulos       BIGINT       NOT NULL DEFAULT 0,
    costo_promedio      NUMERIC(18,6),
    valuacion           NUMERIC(18,2),
    UNIQUE (contrato_id, valor_id, fecha_valuacion)
);

-- =============================================================================
-- RESUMEN_DIARIO
-- Equivalente a: brokerage.saldos_diarios
-- Diferencias: resumen_id, contrato_id, saldo_disponible,
--              valor_portafolio→valuacion_cartera, total→patrimonio
-- =============================================================================
CREATE TABLE resumen_diario (
    resumen_id          SERIAL       PRIMARY KEY,
    contrato_id         INT          NOT NULL REFERENCES contratos(contrato_id),
    fecha_corte         DATE         NOT NULL,
    saldo_disponible    NUMERIC(18,2) NOT NULL DEFAULT 0,
    valuacion_cartera   NUMERIC(18,2) NOT NULL DEFAULT 0,
    patrimonio          NUMERIC(18,2) NOT NULL DEFAULT 0,
    UNIQUE (contrato_id, fecha_corte)
);

-- =============================================================================
-- ÍNDICES
-- =============================================================================
CREATE INDEX idx_tx_contrato_fecha      ON transacciones (contrato_id, fecha_op);
CREATE INDEX idx_tx_valor_fecha         ON transacciones (valor_id, fecha_op);
CREATE INDEX idx_tx_contrato_val_fecha  ON transacciones (contrato_id, valor_id, fecha_op);
CREATE INDEX idx_tx_importe             ON transacciones (importe);
CREATE INDEX idx_ins_estatus_fecha      ON instrucciones (estatus, fecha_op);
CREATE INDEX idx_ins_canceladas         ON instrucciones (estatus, hora_envio, hora_cancelacion)
    WHERE estatus = 'cancelada';
CREATE INDEX idx_con_ultimo_mov         ON contratos (ultimo_movimiento);
CREATE INDEX idx_con_contraparte        ON contratos (contraparte_id);
CREATE INDEX idx_ten_contrato_val       ON tenencias (contrato_id, valor_id, fecha_valuacion);
CREATE INDEX idx_res_contrato_fecha     ON resumen_diario (contrato_id, fecha_corte);
