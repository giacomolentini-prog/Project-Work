-- =========================================================
-- 001_schema.sql
-- Schema logico e tabelle principali (PostgreSQL)
-- Target DB: biglietteria_db
-- =========================================================

CREATE SCHEMA IF NOT EXISTS ferrovie;
SET search_path TO ferrovie, public;

-- =========================
-- Anagrafiche di rete
-- =========================

-- Nodo ferroviario (stazione)
CREATE TABLE IF NOT EXISTS stazione (
  id_stazione        BIGSERIAL PRIMARY KEY,
  codice             VARCHAR(10) UNIQUE NOT NULL,
  nome               VARCHAR(100) NOT NULL,
  citta              VARCHAR(50),
  provincia          VARCHAR(50),
  nazione            VARCHAR(50),
  latitudine         DECIMAL(9,6),
  longitudine        DECIMAL(9,6)
);

-- Linea ferroviaria (es. Bologna–Piacenza)
CREATE TABLE IF NOT EXISTS linea (
  id_linea           BIGSERIAL PRIMARY KEY,
  nome_linea         VARCHAR(100) UNIQUE NOT NULL,
  descrizione        TEXT
);

-- Segmento ordinato di una linea (topologia)
CREATE TABLE IF NOT EXISTS tratta (
  id_tratta              BIGSERIAL PRIMARY KEY,
  id_linea               BIGINT NOT NULL REFERENCES linea(id_linea),
  id_stazione_partenza   BIGINT NOT NULL REFERENCES stazione(id_stazione),
  id_stazione_arrivo     BIGINT NOT NULL REFERENCES stazione(id_stazione),
  ordine                 INT     NOT NULL,     -- posizione nella sequenza della linea
  distanza_km            DECIMAL(7,2),
  CHECK (id_stazione_partenza <> id_stazione_arrivo)
);
-- Unique logico: sarà aggiunto in 003_constraints_indexes.sql

-- =========================
-- Area commerciale
-- =========================

CREATE TABLE IF NOT EXISTS tariffa (
  id_tariffa    BIGSERIAL PRIMARY KEY,
  nome          VARCHAR(50) UNIQUE NOT NULL,
  condizioni    TEXT
);

CREATE TABLE IF NOT EXISTS classe (
  id_classe     BIGSERIAL PRIMARY KEY,
  nome          VARCHAR(30) UNIQUE NOT NULL,
  descrizione   TEXT
);

-- Listino storicizzato: Tariffa × Classe × Tratta
CREATE TABLE IF NOT EXISTS prezzo (
  id_prezzo   BIGSERIAL PRIMARY KEY,
  id_tariffa  BIGINT REFERENCES tariffa(id_tariffa),
  id_classe   BIGINT REFERENCES classe(id_classe),
  id_tratta   BIGINT REFERENCES tratta(id_tratta),
  importo     DECIMAL(10,2) NOT NULL,
  valuta      VARCHAR(3) DEFAULT 'EUR',
  valid_from  DATE NOT NULL,
  valid_to    DATE
  -- Sovrapposizioni bloccate in 003 via EXCLUDE (fix #3)
);

-- =========================
-- Passeggeri / prenotazioni / pagamenti
-- =========================

CREATE TABLE IF NOT EXISTS passeggero (
  id_passeggero   BIGSERIAL PRIMARY KEY,
  codice_fiscale  VARCHAR(16) UNIQUE,
  nome            VARCHAR(50),
  cognome         VARCHAR(50),
  email           VARCHAR(100) UNIQUE,
  telefono        VARCHAR(30)
);

CREATE TABLE IF NOT EXISTS prenotazione (
  id_prenotazione BIGSERIAL PRIMARY KEY,
  id_passeggero   BIGINT REFERENCES passeggero(id_passeggero),
  ts_creazione    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  stato           VARCHAR(20)    -- convertita a ENUM in 002 (fix #2)
);

CREATE TABLE IF NOT EXISTS pagamento (
  id_pagamento    BIGSERIAL PRIMARY KEY,
  id_prenotazione BIGINT REFERENCES prenotazione(id_prenotazione),
  metodo          VARCHAR(20),
  importo         DECIMAL(10,2),
  valuta          VARCHAR(3) DEFAULT 'EUR',
  esito           VARCHAR(20),   -- convertita a ENUM in 002 (fix #2)
  ts_pagamento    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =========================
-- Esercizio & biglietti
-- =========================

CREATE TABLE IF NOT EXISTS servizio (
  id_servizio   BIGSERIAL PRIMARY KEY,
  id_linea      BIGINT REFERENCES linea(id_linea),
  codice_treno  VARCHAR(20) NOT NULL,
  data_partenza DATE        NOT NULL,
  ora_partenza  TIME,
  ora_arrivo    TIME,
  stato         VARCHAR(20)  -- convertita a ENUM in 002 (fix #2)
  -- Unique (codice_treno, data_partenza) in 003 (fix #8)
);

-- Titolo di viaggio emesso
CREATE TABLE IF NOT EXISTS biglietto (
  id_biglietto     BIGSERIAL PRIMARY KEY,
  id_prenotazione  BIGINT REFERENCES prenotazione(id_prenotazione),
  codice_qr        VARCHAR(50) UNIQUE NOT NULL,
  id_tariffa       BIGINT REFERENCES tariffa(id_tariffa),
  id_classe        BIGINT REFERENCES classe(id_classe),
  prezzo_totale    DECIMAL(10,2),        -- snapshot (denormalizzazione consapevole)
  valuta           VARCHAR(3) DEFAULT 'EUR',
  stato            VARCHAR(20),          -- convertita a ENUM in 002 (fix #2)
  ts_emissione     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  deleted_at       TIMESTAMP             -- soft-delete (fix #6)
);

-- Leg del biglietto (percorso effettivo)
CREATE TABLE IF NOT EXISTS percorso_biglietto (
  id_percorso          BIGSERIAL PRIMARY KEY,
  id_biglietto         BIGINT REFERENCES biglietto(id_biglietto),
  id_servizio          BIGINT REFERENCES servizio(id_servizio),
  id_stazione_salita   BIGINT REFERENCES stazione(id_stazione),
  id_stazione_discesa  BIGINT REFERENCES stazione(id_stazione),
  CHECK (id_stazione_salita <> id_stazione_discesa)
  -- Unique combinazioni aggiunto in 003 (fix #1)
);

-- Dettaglio prezzi applicati per ogni leg del biglietto
-- Necessaria per tracciare i prezzi effettivi usati a EMISSIONE (audit storico)
CREATE TABLE IF NOT EXISTS dettaglio_prezzo_biglietto (
  id_biglietto  BIGINT REFERENCES biglietto(id_biglietto),
  id_percorso   BIGINT REFERENCES percorso_biglietto(id_percorso),
  id_prezzo     BIGINT REFERENCES prezzo(id_prezzo),
  importo_applicato DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (id_biglietto, id_percorso)
);

-- =========================
-- Eventi post-vendita
-- =========================

CREATE TABLE IF NOT EXISTS validazione (
  id_validazione BIGSERIAL PRIMARY KEY,
  id_biglietto   BIGINT REFERENCES biglietto(id_biglietto),
  ts_validazione TIMESTAMP,
  id_stazione    BIGINT REFERENCES stazione(id_stazione)
);

CREATE TABLE IF NOT EXISTS cambio (
  id_cambio      BIGSERIAL PRIMARY KEY,
  id_biglietto   BIGINT REFERENCES biglietto(id_biglietto),
  ts_richiesta   TIMESTAMP,
  motivo         TEXT,
  esito          VARCHAR(20),
  penale         DECIMAL(10,2),
  diff_prezzo    DECIMAL(10,2)
);

CREATE TABLE IF NOT EXISTS rimborso (
  id_rimborso          BIGSERIAL PRIMARY KEY,
  id_biglietto         BIGINT REFERENCES biglietto(id_biglietto),
  ts_richiesta         TIMESTAMP,
  importo_rimborsato   DECIMAL(10,2),
  esito                VARCHAR(20),
  motivo               TEXT
);
