CREATE TABLE IF NOT EXISTS surveillance.ley_articulos (
    id          SERIAL PRIMARY KEY,
    ley         VARCHAR(50)  NOT NULL DEFAULT 'LFPIORPI',
    articulo    INTEGER      NOT NULL,
    texto       TEXT         NOT NULL,
    created_at  TIMESTAMP    DEFAULT NOW(),
    UNIQUE(ley, articulo)
);
