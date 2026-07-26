-- =============================================================================
-- ESQUEMA: surveillance
-- Base de datos del sistema de vigilancia
-- Acceso: lectura y escritura para agentes y OPLE
-- brokerage nunca se toca en horario hábil — todo opera sobre este esquema
-- =============================================================================

CREATE SCHEMA IF NOT EXISTS surveillance;

SET search_path = surveillance;

-- =============================================================================
-- CAPA 1: ESPEJO DE BROKERAGE
-- Copia nocturna de todas las tablas del origen
-- Estructura idéntica a brokerage + columna fecha_snapshot
-- IDs originales preservados — no se generan nuevos SERIALs
-- =============================================================================

CREATE TABLE espejo_operadores (
    id                  INT          PRIMARY KEY,   -- id original de brokerage
    clave_operador      VARCHAR(20)  NOT NULL,
    nombre              VARCHAR(200) NOT NULL,
    estado              VARCHAR(10)  NOT NULL,
    fecha_alta          DATE         NOT NULL,
    fecha_snapshot      DATE         NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE espejo_clientes (
    id                  INT          PRIMARY KEY,
    nombre              VARCHAR(200) NOT NULL,
    tipo                VARCHAR(10)  NOT NULL,
    rfc                 VARCHAR(13)  NOT NULL,
    fecha_alta          DATE         NOT NULL,
    pais                CHAR(2)      NOT NULL,
    nivel_riesgo        VARCHAR(10)  NOT NULL,
    estado              VARCHAR(10)  NOT NULL,
    fecha_snapshot      DATE         NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE espejo_cuentas (
    id                      INT          PRIMARY KEY,
    cliente_id              INT          NOT NULL REFERENCES espejo_clientes(id),
    numero_cuenta           VARCHAR(20)  NOT NULL,
    tipo                    VARCHAR(10)  NOT NULL,
    moneda                  CHAR(3)      NOT NULL,
    fecha_apertura          DATE         NOT NULL,
    fecha_ultimo_movimiento DATE,
    estado                  VARCHAR(10)  NOT NULL,
    fecha_snapshot          DATE         NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE espejo_instrumentos (
    id                      INT          PRIMARY KEY,
    ticker                  VARCHAR(20)  NOT NULL,
    nombre                  VARCHAR(200) NOT NULL,
    sector                  VARCHAR(100),
    mercado                 VARCHAR(20)  NOT NULL,
    tipo                    VARCHAR(20)  NOT NULL,
    volumen_promedio_diario BIGINT       NOT NULL,
    precio_referencia       NUMERIC(18,6),
    estado                  VARCHAR(10)  NOT NULL,
    fecha_snapshot          DATE         NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE espejo_operaciones (
    id                  BIGINT       PRIMARY KEY,
    cuenta_id           INT          NOT NULL REFERENCES espejo_cuentas(id),
    instrumento_id      INT          NOT NULL REFERENCES espejo_instrumentos(id),
    operador_id         INT          REFERENCES espejo_operadores(id),
    tipo                VARCHAR(6)   NOT NULL,
    cantidad            BIGINT       NOT NULL,
    precio              NUMERIC(18,6) NOT NULL,
    monto_total         NUMERIC(18,2) NOT NULL,
    timestamp           TIMESTAMPTZ  NOT NULL,
    fecha               DATE         NOT NULL,
    estado              VARCHAR(12)  NOT NULL,
    fecha_snapshot      DATE         NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE espejo_ordenes (
    id                      BIGINT       PRIMARY KEY,
    cuenta_id               INT          NOT NULL REFERENCES espejo_cuentas(id),
    instrumento_id          INT          NOT NULL REFERENCES espejo_instrumentos(id),
    operador_id             INT          REFERENCES espejo_operadores(id),
    operacion_id            BIGINT       REFERENCES espejo_operaciones(id),
    tipo                    VARCHAR(6)   NOT NULL,
    cantidad                BIGINT       NOT NULL,
    precio                  NUMERIC(18,6) NOT NULL,
    timestamp_envio         TIMESTAMPTZ  NOT NULL,
    timestamp_cancelacion   TIMESTAMPTZ,
    estado                  VARCHAR(12)  NOT NULL,
    fecha                   DATE         NOT NULL,
    fecha_snapshot          DATE         NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE espejo_posiciones (
    id                      BIGINT       PRIMARY KEY,
    cuenta_id               INT          NOT NULL REFERENCES espejo_cuentas(id),
    instrumento_id          INT          NOT NULL REFERENCES espejo_instrumentos(id),
    fecha                   DATE         NOT NULL,
    cantidad                BIGINT       NOT NULL,
    precio_promedio         NUMERIC(18,6),
    valor_mercado           NUMERIC(18,2),
    fecha_snapshot          DATE         NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE espejo_saldos_diarios (
    id                  BIGINT       PRIMARY KEY,
    cuenta_id           INT          NOT NULL REFERENCES espejo_cuentas(id),
    fecha               DATE         NOT NULL,
    saldo_efectivo      NUMERIC(18,2) NOT NULL,
    valor_portafolio    NUMERIC(18,2) NOT NULL,
    total               NUMERIC(18,2) NOT NULL,
    fecha_snapshot      DATE         NOT NULL DEFAULT CURRENT_DATE
);

-- Índices espejo — mismos patrones de acceso que brokerage
CREATE INDEX idx_eop_cuenta_fecha       ON espejo_operaciones (cuenta_id, fecha);
CREATE INDEX idx_eop_instrumento_fecha  ON espejo_operaciones (instrumento_id, fecha);
CREATE INDEX idx_eop_cuenta_inst_fecha  ON espejo_operaciones (cuenta_id, instrumento_id, fecha);
CREATE INDEX idx_eop_monto              ON espejo_operaciones (monto_total);
CREATE INDEX idx_eord_estado_fecha      ON espejo_ordenes (estado, fecha);
CREATE INDEX idx_eord_canceladas        ON espejo_ordenes (estado, timestamp_envio, timestamp_cancelacion)
    WHERE estado = 'cancelada';
CREATE INDEX idx_ecta_cliente           ON espejo_cuentas (cliente_id);
CREATE INDEX idx_ecta_ultimo_mov        ON espejo_cuentas (fecha_ultimo_movimiento);
CREATE INDEX idx_epos_cuenta_inst       ON espejo_posiciones (cuenta_id, instrumento_id, fecha);
CREATE INDEX idx_esal_cuenta_fecha      ON espejo_saldos_diarios (cuenta_id, fecha);

-- =============================================================================
-- CAPA 2: TABLAS PROPIAS DEL SISTEMA
-- Lo que genera el sistema — alertas, casos, evidencia, decisiones del OPLE
-- =============================================================================

-- =============================================================================
-- ALERTAS
-- Una alerta por patrón detectado por un agente
-- detectada_en : timestamp del agente — indicio técnico
-- confirmada_en: timestamp del OPLE — aquí inicia el plazo legal Art. 18 LFPIORPI
-- =============================================================================
CREATE TABLE alertas (
    id                  BIGSERIAL    PRIMARY KEY,
    patron              VARCHAR(30)  NOT NULL
                            CHECK (patron IN (
                                'structuring', 'wash_trading', 'dormant',
                                'concentration', 'spoofing',
                                'pump_dump', 'churning', 'colusion'
                            )),
    nivel               VARCHAR(5)   NOT NULL CHECK (nivel IN ('ALTO', 'MEDIO', 'BAJO')),
    estado              VARCHAR(20)  NOT NULL DEFAULT 'nueva'
                            CHECK (estado IN ('nueva', 'en_revision', 'confirmada', 'descartada', 'reportada_uif')),
    cuenta_id           INT          NOT NULL REFERENCES espejo_cuentas(id),
    instrumento_id      INT          REFERENCES espejo_instrumentos(id),  -- NULL si aplica a varios
    fecha_jornada       DATE         NOT NULL,
    resumen             TEXT         NOT NULL,   -- narrativa del agente
    score               NUMERIC(5,2),            -- score de riesgo 0-100
    detectada_en        TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    confirmada_en       TIMESTAMPTZ,             -- NULL hasta que el OPLE confirma — aquí inicia plazo legal
    vence_en            DATE,                    -- días hábiles desde confirmada_en
    reportada_uif_en    TIMESTAMPTZ,
    ople_id             INT,
    notas_ople          TEXT
);

CREATE INDEX idx_alt_estado             ON alertas (estado);
CREATE INDEX idx_alt_cuenta_fecha       ON alertas (cuenta_id, fecha_jornada);
CREATE INDEX idx_alt_patron_nivel       ON alertas (patron, nivel);
CREATE INDEX idx_alt_vence              ON alertas (vence_en) WHERE estado IN ('nueva', 'en_revision');

-- =============================================================================
-- EVIDENCIA DE OPERACIONES
-- Operaciones específicas que sustentan una alerta
-- rol describe el papel de cada operación dentro del patrón detectado
-- =============================================================================
CREATE TABLE evidencia_operaciones (
    id                  BIGSERIAL    PRIMARY KEY,
    alerta_id           BIGINT       NOT NULL REFERENCES alertas(id),
    operacion_id        BIGINT       NOT NULL REFERENCES espejo_operaciones(id),
    rol                 VARCHAR(20)  NOT NULL
                            CHECK (rol IN (
                                'principal',    -- operación que disparó la alerta
                                'contraparte',  -- operación espejo en wash trading
                                'fragmento',    -- uno de los fragmentos en structuring
                                'historico',    -- operación histórica de contexto
                                'beneficiaria'  -- operación que se benefició del patrón
                            ))
);

CREATE INDEX idx_evop_alerta            ON evidencia_operaciones (alerta_id);

-- =============================================================================
-- EVIDENCIA DE ÓRDENES
-- Órdenes específicas que sustentan una alerta (principalmente spoofing)
-- =============================================================================
CREATE TABLE evidencia_ordenes (
    id                  BIGSERIAL    PRIMARY KEY,
    alerta_id           BIGINT       NOT NULL REFERENCES alertas(id),
    orden_id            BIGINT       NOT NULL REFERENCES espejo_ordenes(id),
    rol                 VARCHAR(20)  NOT NULL
                            CHECK (rol IN (
                                'fantasma',     -- orden cancelada en spoofing
                                'ejecutada'     -- orden que se benefició del movimiento
                            ))
);

CREATE INDEX idx_evord_alerta           ON evidencia_ordenes (alerta_id);

-- =============================================================================
-- CASOS
-- Agrupador cuando varias alertas apuntan al mismo cliente o patrón sostenido
-- =============================================================================
CREATE TABLE casos (
    id                  BIGSERIAL    PRIMARY KEY,
    cliente_id          INT          NOT NULL REFERENCES espejo_clientes(id),
    estado              VARCHAR(20)  NOT NULL DEFAULT 'abierto'
                            CHECK (estado IN ('abierto', 'en_investigacion', 'cerrado', 'reportado_uif')),
    descripcion         TEXT,
    abierto_en          TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    cerrado_en          TIMESTAMPTZ
);

CREATE TABLE caso_alertas (
    caso_id             BIGINT       NOT NULL REFERENCES casos(id),
    alerta_id           BIGINT       NOT NULL REFERENCES alertas(id),
    PRIMARY KEY (caso_id, alerta_id)
);

CREATE INDEX idx_caso_cliente           ON casos (cliente_id, estado);

-- =============================================================================
-- LEGISLACIÓN
-- Base de conocimiento regulatorio — búsqueda BM25 full-text
-- =============================================================================
CREATE TABLE legislacion (
    id                  SERIAL       PRIMARY KEY,
    ordenamiento        VARCHAR(100) NOT NULL,
    articulo            VARCHAR(20)  NOT NULL,
    titulo              VARCHAR(200) NOT NULL,
    contenido           TEXT         NOT NULL,
    vigente_desde       DATE,
    notas               TEXT
);

CREATE INDEX idx_leg_bm25
    ON legislacion
    USING gin(to_tsvector('spanish', contenido || ' ' || titulo));

-- =============================================================================
-- CONTEXTO DE MERCADO
-- Notas de analistas, operadores y área de research
-- Complementa APIs automáticas con conocimiento institucional
-- =============================================================================
CREATE TABLE contexto_mercado (
    id                  SERIAL       PRIMARY KEY,
    fecha               DATE         NOT NULL,
    ticker              VARCHAR(20),
    tipo                VARCHAR(30)  NOT NULL
                            CHECK (tipo IN ('hecho_relevante', 'macro', 'sectorial', 'otro')),
    fuente              VARCHAR(100) NOT NULL,
    descripcion         TEXT         NOT NULL,
    cargado_por         VARCHAR(50),
    timestamp           TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_ctx_bm25
    ON contexto_mercado
    USING gin(to_tsvector('spanish', descripcion));
CREATE INDEX idx_ctx_ticker_fecha       ON contexto_mercado (ticker, fecha);

-- =============================================================================
-- NOTAS DE CLIENTE
-- Aportaciones internas de cualquier área sobre un cliente específico
-- Contexto institucional que el agente usa para enriquecer el análisis
-- Una nota puede justificar o agravar una alerta — el OPLE decide
-- =============================================================================
CREATE TABLE notas_cliente (
    id          BIGSERIAL    PRIMARY KEY,
    cliente_id  INT          NOT NULL REFERENCES espejo_clientes(id),
    autor       VARCHAR(100) NOT NULL,
    area        VARCHAR(20)  NOT NULL
                    CHECK (area IN ('compliance', 'comercial', 'riesgos', 'operaciones', 'direccion')),
    contenido   TEXT         NOT NULL,
    creada_en   TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_notas_cliente ON notas_cliente (cliente_id, creada_en DESC);

-- =============================================================================
-- ANÁLISIS DE ALERTAS
-- Registro completo de cada sesión de análisis del OPLE con el agente
-- historial_raw : conversación completa turno a turno — evidencia regulatoria
-- justificacion : narrativa final del OPLE — máx 500 caracteres
-- =============================================================================
CREATE TABLE analisis_alerta (
    id              BIGSERIAL    PRIMARY KEY,
    alerta_id       BIGINT       NOT NULL REFERENCES alertas(id),
    ople_id         VARCHAR(100) NOT NULL,
    inicio          TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    fin             TIMESTAMPTZ,
    decision        VARCHAR(20)
                        CHECK (decision IN ('confirmada', 'descartada', 'escalada', 'pendiente')),
    justificacion   VARCHAR(500),
    historial_raw   JSONB        NOT NULL DEFAULT '[]'
);

CREATE INDEX idx_analisis_alerta    ON analisis_alerta (alerta_id);
CREATE INDEX idx_analisis_ople      ON analisis_alerta (ople_id, inicio DESC);

-- =============================================================================
-- BITÁCORA ETL
-- Registro de cada ejecución del Lambda ETL nocturno
-- Auditoría de qué se copió, cuándo y cuántos registros
-- =============================================================================
CREATE TABLE bitacora_etl (
    id                      BIGSERIAL    PRIMARY KEY,
    fecha_jornada           DATE         NOT NULL,
    inicio                  TIMESTAMPTZ  NOT NULL,
    fin                     TIMESTAMPTZ,
    estado                  VARCHAR(10)  NOT NULL DEFAULT 'en_proceso'
                                CHECK (estado IN ('en_proceso', 'completado', 'error')),
    registros_operaciones   INT          DEFAULT 0,
    registros_ordenes       INT          DEFAULT 0,
    registros_posiciones    INT          DEFAULT 0,
    registros_saldos        INT          DEFAULT 0,
    registros_catalogos     INT          DEFAULT 0,
    error_detalle           TEXT
);
