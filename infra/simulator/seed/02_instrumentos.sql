-- =============================================================================
-- SEED: valores (instrumentos)
-- Emisoras del IPC con volumen promedio diario y precio de cierre
-- Fuente de referencia: BMV / datos públicos de mercado
-- Fecha de referencia: 2025-01-15
-- =============================================================================

SET search_path = broker;

INSERT INTO valores (clave_cotizacion, razon_social, sector_economico, bolsa, tipo_valor, vol_promedio, precio_cierre) VALUES

-- Alta liquidez
('AMXL',        'América Móvil S.A.B. de C.V.',              'Telecomunicaciones',  'BMV', 'accion',  18500000,   16.850000),
('FEMSAUBD',    'Fomento Económico Mexicano S.A.B. de C.V.', 'Consumo',             'BMV', 'accion',   4200000,  168.500000),
('GFNORTEO',    'Grupo Financiero Banorte S.A.B. de C.V.',   'Financiero',          'BMV', 'accion',   8900000,  145.200000),
('WALMEX*',     'Walmart de México S.A.B. de C.V.',          'Consumo',             'BMV', 'accion',   6300000,   62.300000),
('GMEXICOB',    'Grupo México S.A.B. de C.V.',               'Minería',             'BMV', 'accion',   5100000,   98.750000),
('CEMEXCPO',    'CEMEX S.A.B. de C.V.',                      'Materiales',          'BMV', 'accion',  12400000,    8.920000),
('TLEVISACPO',  'Grupo Televisa S.A.B.',                     'Telecomunicaciones',  'BMV', 'accion',   3800000,   22.150000),
('BIMBOA',      'Grupo Bimbo S.A.B. de C.V.',                'Consumo',             'BMV', 'accion',   2100000,   78.400000),
('ALSEA*',      'Alsea S.A.B. de C.V.',                      'Consumo',             'BMV', 'accion',   1900000,   42.600000),
('GCARSOA1',    'Grupo Carso S.A.B. de C.V.',                'Conglomerado',        'BMV', 'accion',    980000,  112.300000),
('KIMBERA',     'Kimberly-Clark de México S.A.B. de C.V.',   'Consumo',             'BMV', 'accion',   1650000,   34.800000),
('LABB',        'Genomma Lab Internacional S.A.B. de C.V.',  'Salud',               'BMV', 'accion',   2300000,   18.250000),
('PINFRA*',     'Promotora y Operadora de Infraestructura',  'Infraestructura',     'BMV', 'accion',    720000,  185.600000),
('GRUMAB',      'Gruma S.A.B. de C.V.',                      'Consumo',             'BMV', 'accion',    540000,  248.000000),
('ASURB',       'Grupo Aeroportuario del Sureste S.A.B.',    'Transporte',          'BMV', 'accion',    610000,  398.500000),
('OMAB',        'Grupo Aeroportuario del Centro Norte',      'Transporte',          'BMV', 'accion',    480000,  142.800000),
('GAPB',        'Grupo Aeroportuario del Pacífico S.A.B.',   'Transporte',          'BMV', 'accion',    390000,  268.000000),
('BOLSAA',      'Bolsa Mexicana de Valores S.A.B. de C.V.',  'Financiero',          'BMV', 'accion',    310000,   38.200000),
('CUERVO*',     'Becle S.A.B. de C.V.',                      'Consumo',             'BMV', 'accion',    870000,   28.750000),
('ORBIA*',      'Orbia Advance Corporation S.A.B. de C.V.',  'Materiales',          'BMV', 'accion',   1240000,   32.100000),

-- Liquidez media
('MEGACPO',     'Megacable Holdings S.A.B. de C.V.',         'Telecomunicaciones',  'BMV', 'accion',    420000,   68.500000),
('CHDRAUIB',    'Grupo Comercial Chedraui S.A.B. de C.V.',   'Consumo',             'BMV', 'accion',    380000,   92.300000),
('LIVEPOLC-1',  'El Puerto de Liverpool S.A.B. de C.V.',     'Consumo',             'BMV', 'accion',    290000,  148.000000),
('RCENTROA',    'Regional S.A.B. de C.V.',                   'Financiero',          'BMV', 'accion',    260000,  178.500000),
('VESTA*',      'Corporación Inmobiliaria Vesta S.A.B.',     'Inmobiliario',        'BMV', 'accion',    340000,   42.800000),

-- Baja liquidez — susceptibles a concentración y manipulación
('POCHTECB',    'Grupo Pochteca S.A.B. de C.V.',             'Materiales',          'BMV', 'accion',     42000,   12.500000),
('VITROA',      'Vitro S.A.B. de C.V.',                      'Materiales',          'BMV', 'accion',     38000,   18.900000),
('HERDEZ*',     'Grupo Herdez S.A.B. de C.V.',               'Consumo',             'BMV', 'accion',     95000,   38.600000),
('IENOVA*',     'Infraestructura Energética Nova S.A.B.',    'Energía',             'BMV', 'accion',     67000,   88.200000),
('GISSAA',      'Grupo Industrial Saltillo S.A.B. de C.V.',  'Industrial',          'BMV', 'accion',     28000,   52.400000),

-- ETFs
('NAFTRAC',     'ETF que replica el IPC',                    'ETF',                 'BMV', 'etf',      3200000,   52.180000),
('MEXTRAC',     'ETF México amplio',                         'ETF',                 'BMV', 'etf',       180000,   48.600000),

-- FIBRAs
('FUNO11',      'Fibra Uno Administración S.A. de C.V.',     'Inmobiliario',        'BMV', 'fibra',    2100000,   22.400000),
('FIHO12',      'Fibra Hotel',                               'Inmobiliario',        'BMV', 'fibra',     320000,    8.750000);
