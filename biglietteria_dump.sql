--
-- PostgreSQL database dump
--

\restrict SoE5O2zzJya5F1tg2gYy7yD9HA8sIdVkUwHok4MM49yvjmiFQCj5FyVbvUT6XMM

-- Dumped from database version 18.0
-- Dumped by pg_dump version 18.0

-- Started on 2025-11-14 16:43:39

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 7 (class 2615 OID 16699)
-- Name: ferrovie; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA ferrovie;


ALTER SCHEMA ferrovie OWNER TO postgres;

--
-- TOC entry 2 (class 3079 OID 17097)
-- Name: btree_gist; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS btree_gist WITH SCHEMA ferrovie;


--
-- TOC entry 5545 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION btree_gist; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION btree_gist IS 'support for indexing common datatypes in GiST';


--
-- TOC entry 1155 (class 1247 OID 17018)
-- Name: esito_pagamento; Type: TYPE; Schema: ferrovie; Owner: postgres
--

CREATE TYPE ferrovie.esito_pagamento AS ENUM (
    'ok',
    'ko',
    'pendente'
);


ALTER TYPE ferrovie.esito_pagamento OWNER TO postgres;

--
-- TOC entry 1158 (class 1247 OID 17026)
-- Name: metodo_pagamento; Type: TYPE; Schema: ferrovie; Owner: postgres
--

CREATE TYPE ferrovie.metodo_pagamento AS ENUM (
    'carta',
    'paypal',
    'satispay',
    'altro'
);


ALTER TYPE ferrovie.metodo_pagamento OWNER TO postgres;

--
-- TOC entry 1149 (class 1247 OID 16998)
-- Name: stato_biglietto; Type: TYPE; Schema: ferrovie; Owner: postgres
--

CREATE TYPE ferrovie.stato_biglietto AS ENUM (
    'valido',
    'usato',
    'rimborsato',
    'annullato'
);


ALTER TYPE ferrovie.stato_biglietto OWNER TO postgres;

--
-- TOC entry 1146 (class 1247 OID 16991)
-- Name: stato_prenotazione; Type: TYPE; Schema: ferrovie; Owner: postgres
--

CREATE TYPE ferrovie.stato_prenotazione AS ENUM (
    'in_attesa',
    'confermata',
    'annullata'
);


ALTER TYPE ferrovie.stato_prenotazione OWNER TO postgres;

--
-- TOC entry 1152 (class 1247 OID 17008)
-- Name: stato_servizio; Type: TYPE; Schema: ferrovie; Owner: postgres
--

CREATE TYPE ferrovie.stato_servizio AS ENUM (
    'programmato',
    'in_corsa',
    'cancellato',
    'concluso'
);


ALTER TYPE ferrovie.stato_servizio OWNER TO postgres;

--
-- TOC entry 436 (class 1255 OID 17825)
-- Name: check_pagamento_confermato(); Type: FUNCTION; Schema: ferrovie; Owner: postgres
--

CREATE FUNCTION ferrovie.check_pagamento_confermato() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pagamento p
    WHERE p.id_prenotazione = NEW.id_prenotazione
      AND p.esito = 'ok'
  ) THEN
    RAISE EXCEPTION 'Impossibile emettere biglietto: pagamento non confermato';
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION ferrovie.check_pagamento_confermato() OWNER TO postgres;

--
-- TOC entry 305 (class 1255 OID 17827)
-- Name: prevent_deleted_biglietto(); Type: FUNCTION; Schema: ferrovie; Owner: postgres
--

CREATE FUNCTION ferrovie.prevent_deleted_biglietto() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF NEW.deleted_at IS NOT NULL THEN
    RAISE EXCEPTION 'Impossibile aggiornare un biglietto cancellato logicamente';
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION ferrovie.prevent_deleted_biglietto() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 242 (class 1259 OID 16862)
-- Name: biglietto; Type: TABLE; Schema: ferrovie; Owner: postgres
--

CREATE TABLE ferrovie.biglietto (
    id_biglietto bigint NOT NULL,
    id_prenotazione bigint,
    codice_qr character varying(50) NOT NULL,
    id_tariffa bigint,
    id_classe bigint,
    prezzo_totale numeric(10,2),
    valuta character varying(3) DEFAULT 'EUR'::character varying,
    stato ferrovie.stato_biglietto DEFAULT 'valido'::ferrovie.stato_biglietto,
    ts_emissione timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    deleted_at timestamp without time zone
);


ALTER TABLE ferrovie.biglietto OWNER TO postgres;

--
-- TOC entry 241 (class 1259 OID 16861)
-- Name: biglietto_id_biglietto_seq; Type: SEQUENCE; Schema: ferrovie; Owner: postgres
--

CREATE SEQUENCE ferrovie.biglietto_id_biglietto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ferrovie.biglietto_id_biglietto_seq OWNER TO postgres;

--
-- TOC entry 5546 (class 0 OID 0)
-- Dependencies: 241
-- Name: biglietto_id_biglietto_seq; Type: SEQUENCE OWNED BY; Schema: ferrovie; Owner: postgres
--

ALTER SEQUENCE ferrovie.biglietto_id_biglietto_seq OWNED BY ferrovie.biglietto.id_biglietto;


--
-- TOC entry 249 (class 1259 OID 16960)
-- Name: cambio; Type: TABLE; Schema: ferrovie; Owner: postgres
--

CREATE TABLE ferrovie.cambio (
    id_cambio bigint NOT NULL,
    id_biglietto bigint,
    ts_richiesta timestamp without time zone,
    motivo text,
    esito character varying(20),
    penale numeric(10,2),
    diff_prezzo numeric(10,2)
);


ALTER TABLE ferrovie.cambio OWNER TO postgres;

--
-- TOC entry 248 (class 1259 OID 16959)
-- Name: cambio_id_cambio_seq; Type: SEQUENCE; Schema: ferrovie; Owner: postgres
--

CREATE SEQUENCE ferrovie.cambio_id_cambio_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ferrovie.cambio_id_cambio_seq OWNER TO postgres;

--
-- TOC entry 5547 (class 0 OID 0)
-- Dependencies: 248
-- Name: cambio_id_cambio_seq; Type: SEQUENCE OWNED BY; Schema: ferrovie; Owner: postgres
--

ALTER SEQUENCE ferrovie.cambio_id_cambio_seq OWNED BY ferrovie.cambio.id_cambio;


--
-- TOC entry 230 (class 1259 OID 16767)
-- Name: classe; Type: TABLE; Schema: ferrovie; Owner: postgres
--

CREATE TABLE ferrovie.classe (
    id_classe bigint NOT NULL,
    nome character varying(30) NOT NULL,
    descrizione text
);


ALTER TABLE ferrovie.classe OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 16766)
-- Name: classe_id_classe_seq; Type: SEQUENCE; Schema: ferrovie; Owner: postgres
--

CREATE SEQUENCE ferrovie.classe_id_classe_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ferrovie.classe_id_classe_seq OWNER TO postgres;

--
-- TOC entry 5548 (class 0 OID 0)
-- Dependencies: 229
-- Name: classe_id_classe_seq; Type: SEQUENCE OWNED BY; Schema: ferrovie; Owner: postgres
--

ALTER SEQUENCE ferrovie.classe_id_classe_seq OWNED BY ferrovie.classe.id_classe;


--
-- TOC entry 245 (class 1259 OID 16918)
-- Name: dettaglio_prezzo_biglietto; Type: TABLE; Schema: ferrovie; Owner: postgres
--

CREATE TABLE ferrovie.dettaglio_prezzo_biglietto (
    id_biglietto bigint NOT NULL,
    id_percorso bigint NOT NULL,
    id_prezzo bigint,
    importo_applicato numeric(10,2) NOT NULL
);


ALTER TABLE ferrovie.dettaglio_prezzo_biglietto OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 16713)
-- Name: linea; Type: TABLE; Schema: ferrovie; Owner: postgres
--

CREATE TABLE ferrovie.linea (
    id_linea bigint NOT NULL,
    nome_linea character varying(100) NOT NULL,
    descrizione text
);


ALTER TABLE ferrovie.linea OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16712)
-- Name: linea_id_linea_seq; Type: SEQUENCE; Schema: ferrovie; Owner: postgres
--

CREATE SEQUENCE ferrovie.linea_id_linea_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ferrovie.linea_id_linea_seq OWNER TO postgres;

--
-- TOC entry 5549 (class 0 OID 0)
-- Dependencies: 223
-- Name: linea_id_linea_seq; Type: SEQUENCE OWNED BY; Schema: ferrovie; Owner: postgres
--

ALTER SEQUENCE ferrovie.linea_id_linea_seq OWNED BY ferrovie.linea.id_linea;


--
-- TOC entry 238 (class 1259 OID 16832)
-- Name: pagamento; Type: TABLE; Schema: ferrovie; Owner: postgres
--

CREATE TABLE ferrovie.pagamento (
    id_pagamento bigint NOT NULL,
    id_prenotazione bigint,
    metodo ferrovie.metodo_pagamento,
    importo numeric(10,2),
    valuta character varying(3) DEFAULT 'EUR'::character varying,
    esito ferrovie.esito_pagamento DEFAULT 'pendente'::ferrovie.esito_pagamento,
    ts_pagamento timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE ferrovie.pagamento OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 16831)
-- Name: pagamento_id_pagamento_seq; Type: SEQUENCE; Schema: ferrovie; Owner: postgres
--

CREATE SEQUENCE ferrovie.pagamento_id_pagamento_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ferrovie.pagamento_id_pagamento_seq OWNER TO postgres;

--
-- TOC entry 5550 (class 0 OID 0)
-- Dependencies: 237
-- Name: pagamento_id_pagamento_seq; Type: SEQUENCE OWNED BY; Schema: ferrovie; Owner: postgres
--

ALTER SEQUENCE ferrovie.pagamento_id_pagamento_seq OWNED BY ferrovie.pagamento.id_pagamento;


--
-- TOC entry 234 (class 1259 OID 16806)
-- Name: passeggero; Type: TABLE; Schema: ferrovie; Owner: postgres
--

CREATE TABLE ferrovie.passeggero (
    id_passeggero bigint NOT NULL,
    codice_fiscale character varying(16),
    nome character varying(50),
    cognome character varying(50),
    email character varying(100),
    telefono character varying(30)
);


ALTER TABLE ferrovie.passeggero OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 16805)
-- Name: passeggero_id_passeggero_seq; Type: SEQUENCE; Schema: ferrovie; Owner: postgres
--

CREATE SEQUENCE ferrovie.passeggero_id_passeggero_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ferrovie.passeggero_id_passeggero_seq OWNER TO postgres;

--
-- TOC entry 5551 (class 0 OID 0)
-- Dependencies: 233
-- Name: passeggero_id_passeggero_seq; Type: SEQUENCE OWNED BY; Schema: ferrovie; Owner: postgres
--

ALTER SEQUENCE ferrovie.passeggero_id_passeggero_seq OWNED BY ferrovie.passeggero.id_passeggero;


--
-- TOC entry 244 (class 1259 OID 16890)
-- Name: percorso_biglietto; Type: TABLE; Schema: ferrovie; Owner: postgres
--

CREATE TABLE ferrovie.percorso_biglietto (
    id_percorso bigint NOT NULL,
    id_biglietto bigint,
    id_servizio bigint,
    id_stazione_salita bigint,
    id_stazione_discesa bigint,
    CONSTRAINT percorso_biglietto_check CHECK ((id_stazione_salita <> id_stazione_discesa))
);


ALTER TABLE ferrovie.percorso_biglietto OWNER TO postgres;

--
-- TOC entry 243 (class 1259 OID 16889)
-- Name: percorso_biglietto_id_percorso_seq; Type: SEQUENCE; Schema: ferrovie; Owner: postgres
--

CREATE SEQUENCE ferrovie.percorso_biglietto_id_percorso_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ferrovie.percorso_biglietto_id_percorso_seq OWNER TO postgres;

--
-- TOC entry 5552 (class 0 OID 0)
-- Dependencies: 243
-- Name: percorso_biglietto_id_percorso_seq; Type: SEQUENCE OWNED BY; Schema: ferrovie; Owner: postgres
--

ALTER SEQUENCE ferrovie.percorso_biglietto_id_percorso_seq OWNED BY ferrovie.percorso_biglietto.id_percorso;


--
-- TOC entry 236 (class 1259 OID 16818)
-- Name: prenotazione; Type: TABLE; Schema: ferrovie; Owner: postgres
--

CREATE TABLE ferrovie.prenotazione (
    id_prenotazione bigint NOT NULL,
    id_passeggero bigint,
    ts_creazione timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    stato ferrovie.stato_prenotazione DEFAULT 'in_attesa'::ferrovie.stato_prenotazione
);


ALTER TABLE ferrovie.prenotazione OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 16817)
-- Name: prenotazione_id_prenotazione_seq; Type: SEQUENCE; Schema: ferrovie; Owner: postgres
--

CREATE SEQUENCE ferrovie.prenotazione_id_prenotazione_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ferrovie.prenotazione_id_prenotazione_seq OWNER TO postgres;

--
-- TOC entry 5553 (class 0 OID 0)
-- Dependencies: 235
-- Name: prenotazione_id_prenotazione_seq; Type: SEQUENCE OWNED BY; Schema: ferrovie; Owner: postgres
--

ALTER SEQUENCE ferrovie.prenotazione_id_prenotazione_seq OWNED BY ferrovie.prenotazione.id_prenotazione;


--
-- TOC entry 232 (class 1259 OID 16780)
-- Name: prezzo; Type: TABLE; Schema: ferrovie; Owner: postgres
--

CREATE TABLE ferrovie.prezzo (
    id_prezzo bigint NOT NULL,
    id_tariffa bigint,
    id_classe bigint,
    id_tratta bigint,
    importo numeric(10,2) NOT NULL,
    valuta character varying(3) DEFAULT 'EUR'::character varying,
    valid_from date NOT NULL,
    valid_to date
);


ALTER TABLE ferrovie.prezzo OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 16779)
-- Name: prezzo_id_prezzo_seq; Type: SEQUENCE; Schema: ferrovie; Owner: postgres
--

CREATE SEQUENCE ferrovie.prezzo_id_prezzo_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ferrovie.prezzo_id_prezzo_seq OWNER TO postgres;

--
-- TOC entry 5554 (class 0 OID 0)
-- Dependencies: 231
-- Name: prezzo_id_prezzo_seq; Type: SEQUENCE OWNED BY; Schema: ferrovie; Owner: postgres
--

ALTER SEQUENCE ferrovie.prezzo_id_prezzo_seq OWNED BY ferrovie.prezzo.id_prezzo;


--
-- TOC entry 251 (class 1259 OID 16975)
-- Name: rimborso; Type: TABLE; Schema: ferrovie; Owner: postgres
--

CREATE TABLE ferrovie.rimborso (
    id_rimborso bigint NOT NULL,
    id_biglietto bigint,
    ts_richiesta timestamp without time zone,
    importo_rimborsato numeric(10,2),
    esito character varying(20),
    motivo text
);


ALTER TABLE ferrovie.rimborso OWNER TO postgres;

--
-- TOC entry 250 (class 1259 OID 16974)
-- Name: rimborso_id_rimborso_seq; Type: SEQUENCE; Schema: ferrovie; Owner: postgres
--

CREATE SEQUENCE ferrovie.rimborso_id_rimborso_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ferrovie.rimborso_id_rimborso_seq OWNER TO postgres;

--
-- TOC entry 5555 (class 0 OID 0)
-- Dependencies: 250
-- Name: rimborso_id_rimborso_seq; Type: SEQUENCE OWNED BY; Schema: ferrovie; Owner: postgres
--

ALTER SEQUENCE ferrovie.rimborso_id_rimborso_seq OWNED BY ferrovie.rimborso.id_rimborso;


--
-- TOC entry 240 (class 1259 OID 16847)
-- Name: servizio; Type: TABLE; Schema: ferrovie; Owner: postgres
--

CREATE TABLE ferrovie.servizio (
    id_servizio bigint NOT NULL,
    id_linea bigint,
    codice_treno character varying(20) NOT NULL,
    data_partenza date NOT NULL,
    ora_partenza time without time zone,
    ora_arrivo time without time zone,
    stato ferrovie.stato_servizio DEFAULT 'programmato'::ferrovie.stato_servizio
);


ALTER TABLE ferrovie.servizio OWNER TO postgres;

--
-- TOC entry 239 (class 1259 OID 16846)
-- Name: servizio_id_servizio_seq; Type: SEQUENCE; Schema: ferrovie; Owner: postgres
--

CREATE SEQUENCE ferrovie.servizio_id_servizio_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ferrovie.servizio_id_servizio_seq OWNER TO postgres;

--
-- TOC entry 5556 (class 0 OID 0)
-- Dependencies: 239
-- Name: servizio_id_servizio_seq; Type: SEQUENCE OWNED BY; Schema: ferrovie; Owner: postgres
--

ALTER SEQUENCE ferrovie.servizio_id_servizio_seq OWNED BY ferrovie.servizio.id_servizio;


--
-- TOC entry 222 (class 1259 OID 16701)
-- Name: stazione; Type: TABLE; Schema: ferrovie; Owner: postgres
--

CREATE TABLE ferrovie.stazione (
    id_stazione bigint NOT NULL,
    codice character varying(10) NOT NULL,
    nome character varying(100) NOT NULL,
    citta character varying(50),
    provincia character varying(50),
    nazione character varying(50),
    latitudine numeric(9,6),
    longitudine numeric(9,6)
);


ALTER TABLE ferrovie.stazione OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16700)
-- Name: stazione_id_stazione_seq; Type: SEQUENCE; Schema: ferrovie; Owner: postgres
--

CREATE SEQUENCE ferrovie.stazione_id_stazione_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ferrovie.stazione_id_stazione_seq OWNER TO postgres;

--
-- TOC entry 5557 (class 0 OID 0)
-- Dependencies: 221
-- Name: stazione_id_stazione_seq; Type: SEQUENCE OWNED BY; Schema: ferrovie; Owner: postgres
--

ALTER SEQUENCE ferrovie.stazione_id_stazione_seq OWNED BY ferrovie.stazione.id_stazione;


--
-- TOC entry 228 (class 1259 OID 16754)
-- Name: tariffa; Type: TABLE; Schema: ferrovie; Owner: postgres
--

CREATE TABLE ferrovie.tariffa (
    id_tariffa bigint NOT NULL,
    nome character varying(50) NOT NULL,
    condizioni text
);


ALTER TABLE ferrovie.tariffa OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 16753)
-- Name: tariffa_id_tariffa_seq; Type: SEQUENCE; Schema: ferrovie; Owner: postgres
--

CREATE SEQUENCE ferrovie.tariffa_id_tariffa_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ferrovie.tariffa_id_tariffa_seq OWNER TO postgres;

--
-- TOC entry 5558 (class 0 OID 0)
-- Dependencies: 227
-- Name: tariffa_id_tariffa_seq; Type: SEQUENCE OWNED BY; Schema: ferrovie; Owner: postgres
--

ALTER SEQUENCE ferrovie.tariffa_id_tariffa_seq OWNED BY ferrovie.tariffa.id_tariffa;


--
-- TOC entry 226 (class 1259 OID 16726)
-- Name: tratta; Type: TABLE; Schema: ferrovie; Owner: postgres
--

CREATE TABLE ferrovie.tratta (
    id_tratta bigint NOT NULL,
    id_linea bigint NOT NULL,
    id_stazione_partenza bigint NOT NULL,
    id_stazione_arrivo bigint NOT NULL,
    ordine integer NOT NULL,
    distanza_km numeric(7,2),
    CONSTRAINT tratta_check CHECK ((id_stazione_partenza <> id_stazione_arrivo))
);


ALTER TABLE ferrovie.tratta OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 16725)
-- Name: tratta_id_tratta_seq; Type: SEQUENCE; Schema: ferrovie; Owner: postgres
--

CREATE SEQUENCE ferrovie.tratta_id_tratta_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ferrovie.tratta_id_tratta_seq OWNER TO postgres;

--
-- TOC entry 5559 (class 0 OID 0)
-- Dependencies: 225
-- Name: tratta_id_tratta_seq; Type: SEQUENCE OWNED BY; Schema: ferrovie; Owner: postgres
--

ALTER SEQUENCE ferrovie.tratta_id_tratta_seq OWNED BY ferrovie.tratta.id_tratta;


--
-- TOC entry 247 (class 1259 OID 16942)
-- Name: validazione; Type: TABLE; Schema: ferrovie; Owner: postgres
--

CREATE TABLE ferrovie.validazione (
    id_validazione bigint NOT NULL,
    id_biglietto bigint,
    ts_validazione timestamp without time zone,
    id_stazione bigint
);


ALTER TABLE ferrovie.validazione OWNER TO postgres;

--
-- TOC entry 246 (class 1259 OID 16941)
-- Name: validazione_id_validazione_seq; Type: SEQUENCE; Schema: ferrovie; Owner: postgres
--

CREATE SEQUENCE ferrovie.validazione_id_validazione_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ferrovie.validazione_id_validazione_seq OWNER TO postgres;

--
-- TOC entry 5560 (class 0 OID 0)
-- Dependencies: 246
-- Name: validazione_id_validazione_seq; Type: SEQUENCE OWNED BY; Schema: ferrovie; Owner: postgres
--

ALTER SEQUENCE ferrovie.validazione_id_validazione_seq OWNED BY ferrovie.validazione.id_validazione;


--
-- TOC entry 5254 (class 2604 OID 16865)
-- Name: biglietto id_biglietto; Type: DEFAULT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.biglietto ALTER COLUMN id_biglietto SET DEFAULT nextval('ferrovie.biglietto_id_biglietto_seq'::regclass);


--
-- TOC entry 5260 (class 2604 OID 16963)
-- Name: cambio id_cambio; Type: DEFAULT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.cambio ALTER COLUMN id_cambio SET DEFAULT nextval('ferrovie.cambio_id_cambio_seq'::regclass);


--
-- TOC entry 5241 (class 2604 OID 16770)
-- Name: classe id_classe; Type: DEFAULT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.classe ALTER COLUMN id_classe SET DEFAULT nextval('ferrovie.classe_id_classe_seq'::regclass);


--
-- TOC entry 5238 (class 2604 OID 16716)
-- Name: linea id_linea; Type: DEFAULT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.linea ALTER COLUMN id_linea SET DEFAULT nextval('ferrovie.linea_id_linea_seq'::regclass);


--
-- TOC entry 5248 (class 2604 OID 16835)
-- Name: pagamento id_pagamento; Type: DEFAULT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.pagamento ALTER COLUMN id_pagamento SET DEFAULT nextval('ferrovie.pagamento_id_pagamento_seq'::regclass);


--
-- TOC entry 5244 (class 2604 OID 16809)
-- Name: passeggero id_passeggero; Type: DEFAULT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.passeggero ALTER COLUMN id_passeggero SET DEFAULT nextval('ferrovie.passeggero_id_passeggero_seq'::regclass);


--
-- TOC entry 5258 (class 2604 OID 16893)
-- Name: percorso_biglietto id_percorso; Type: DEFAULT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.percorso_biglietto ALTER COLUMN id_percorso SET DEFAULT nextval('ferrovie.percorso_biglietto_id_percorso_seq'::regclass);


--
-- TOC entry 5245 (class 2604 OID 16821)
-- Name: prenotazione id_prenotazione; Type: DEFAULT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.prenotazione ALTER COLUMN id_prenotazione SET DEFAULT nextval('ferrovie.prenotazione_id_prenotazione_seq'::regclass);


--
-- TOC entry 5242 (class 2604 OID 16783)
-- Name: prezzo id_prezzo; Type: DEFAULT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.prezzo ALTER COLUMN id_prezzo SET DEFAULT nextval('ferrovie.prezzo_id_prezzo_seq'::regclass);


--
-- TOC entry 5261 (class 2604 OID 16978)
-- Name: rimborso id_rimborso; Type: DEFAULT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.rimborso ALTER COLUMN id_rimborso SET DEFAULT nextval('ferrovie.rimborso_id_rimborso_seq'::regclass);


--
-- TOC entry 5252 (class 2604 OID 16850)
-- Name: servizio id_servizio; Type: DEFAULT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.servizio ALTER COLUMN id_servizio SET DEFAULT nextval('ferrovie.servizio_id_servizio_seq'::regclass);


--
-- TOC entry 5237 (class 2604 OID 16704)
-- Name: stazione id_stazione; Type: DEFAULT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.stazione ALTER COLUMN id_stazione SET DEFAULT nextval('ferrovie.stazione_id_stazione_seq'::regclass);


--
-- TOC entry 5240 (class 2604 OID 16757)
-- Name: tariffa id_tariffa; Type: DEFAULT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.tariffa ALTER COLUMN id_tariffa SET DEFAULT nextval('ferrovie.tariffa_id_tariffa_seq'::regclass);


--
-- TOC entry 5239 (class 2604 OID 16729)
-- Name: tratta id_tratta; Type: DEFAULT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.tratta ALTER COLUMN id_tratta SET DEFAULT nextval('ferrovie.tratta_id_tratta_seq'::regclass);


--
-- TOC entry 5259 (class 2604 OID 16945)
-- Name: validazione id_validazione; Type: DEFAULT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.validazione ALTER COLUMN id_validazione SET DEFAULT nextval('ferrovie.validazione_id_validazione_seq'::regclass);


--
-- TOC entry 5530 (class 0 OID 16862)
-- Dependencies: 242
-- Data for Name: biglietto; Type: TABLE DATA; Schema: ferrovie; Owner: postgres
--

COPY ferrovie.biglietto (id_biglietto, id_prenotazione, codice_qr, id_tariffa, id_classe, prezzo_totale, valuta, stato, ts_emissione, deleted_at) FROM stdin;
5	5	QR-001	1	2	12.00	EUR	valido	2025-11-13 13:40:10.813078	\N
6	6	QR-002	1	2	22.00	EUR	rimborsato	2025-11-13 13:40:10.838057	\N
7	7	QR-003	1	2	15.00	EUR	valido	2025-11-13 13:40:10.853117	\N
\.


--
-- TOC entry 5537 (class 0 OID 16960)
-- Dependencies: 249
-- Data for Name: cambio; Type: TABLE DATA; Schema: ferrovie; Owner: postgres
--

COPY ferrovie.cambio (id_cambio, id_biglietto, ts_richiesta, motivo, esito, penale, diff_prezzo) FROM stdin;
2	7	2025-11-13 13:40:10.855536	Cambio corsa	ok	2.00	3.00
\.


--
-- TOC entry 5518 (class 0 OID 16767)
-- Dependencies: 230
-- Data for Name: classe; Type: TABLE DATA; Schema: ferrovie; Owner: postgres
--

COPY ferrovie.classe (id_classe, nome, descrizione) FROM stdin;
1	1A	Prima classe
2	2A	Seconda classe
\.


--
-- TOC entry 5533 (class 0 OID 16918)
-- Dependencies: 245
-- Data for Name: dettaglio_prezzo_biglietto; Type: TABLE DATA; Schema: ferrovie; Owner: postgres
--

COPY ferrovie.dettaglio_prezzo_biglietto (id_biglietto, id_percorso, id_prezzo, importo_applicato) FROM stdin;
5	5	1	12.00
6	6	1	12.00
6	7	2	10.00
\.


--
-- TOC entry 5512 (class 0 OID 16713)
-- Dependencies: 224
-- Data for Name: linea; Type: TABLE DATA; Schema: ferrovie; Owner: postgres
--

COPY ferrovie.linea (id_linea, nome_linea, descrizione) FROM stdin;
1	Linea Demo	Linea dimostrativa per scenari di test
\.


--
-- TOC entry 5526 (class 0 OID 16832)
-- Dependencies: 238
-- Data for Name: pagamento; Type: TABLE DATA; Schema: ferrovie; Owner: postgres
--

COPY ferrovie.pagamento (id_pagamento, id_prenotazione, metodo, importo, valuta, esito, ts_pagamento) FROM stdin;
5	5	carta	12.00	EUR	ok	2025-11-13 13:40:10.808098
6	6	carta	22.00	EUR	ok	2025-11-13 13:40:10.836991
7	7	carta	15.00	EUR	ok	2025-11-13 13:40:10.851976
\.


--
-- TOC entry 5522 (class 0 OID 16806)
-- Dependencies: 234
-- Data for Name: passeggero; Type: TABLE DATA; Schema: ferrovie; Owner: postgres
--

COPY ferrovie.passeggero (id_passeggero, codice_fiscale, nome, cognome, email, telefono) FROM stdin;
1	CFX11111A	Mario	Rossi	mario.rossi@example.com	111
2	CFX22222B	Luca	Bianchi	luca.bianchi@example.com	222
3	CFX33333C	Giulia	Verdi	giulia.verdi@example.com	333
\.


--
-- TOC entry 5532 (class 0 OID 16890)
-- Dependencies: 244
-- Data for Name: percorso_biglietto; Type: TABLE DATA; Schema: ferrovie; Owner: postgres
--

COPY ferrovie.percorso_biglietto (id_percorso, id_biglietto, id_servizio, id_stazione_salita, id_stazione_discesa) FROM stdin;
5	5	7	1	2
6	6	7	1	2
7	6	8	2	3
8	7	9	3	4
\.


--
-- TOC entry 5524 (class 0 OID 16818)
-- Dependencies: 236
-- Data for Name: prenotazione; Type: TABLE DATA; Schema: ferrovie; Owner: postgres
--

COPY ferrovie.prenotazione (id_prenotazione, id_passeggero, ts_creazione, stato) FROM stdin;
5	1	2025-11-13 13:40:10.804531	confermata
6	2	2025-11-13 13:40:10.836159	confermata
7	3	2025-11-13 13:40:10.850948	confermata
\.


--
-- TOC entry 5520 (class 0 OID 16780)
-- Dependencies: 232
-- Data for Name: prezzo; Type: TABLE DATA; Schema: ferrovie; Owner: postgres
--

COPY ferrovie.prezzo (id_prezzo, id_tariffa, id_classe, id_tratta, importo, valuta, valid_from, valid_to) FROM stdin;
1	1	2	1	12.00	EUR	2025-11-13	\N
2	1	2	2	10.00	EUR	2025-11-13	\N
3	1	2	3	15.00	EUR	2025-11-13	\N
\.


--
-- TOC entry 5539 (class 0 OID 16975)
-- Dependencies: 251
-- Data for Name: rimborso; Type: TABLE DATA; Schema: ferrovie; Owner: postgres
--

COPY ferrovie.rimborso (id_rimborso, id_biglietto, ts_richiesta, importo_rimborsato, esito, motivo) FROM stdin;
2	6	2025-11-13 13:40:10.844993	10.00	ok	Cliente impossibilitato
\.


--
-- TOC entry 5528 (class 0 OID 16847)
-- Dependencies: 240
-- Data for Name: servizio; Type: TABLE DATA; Schema: ferrovie; Owner: postgres
--

COPY ferrovie.servizio (id_servizio, id_linea, codice_treno, data_partenza, ora_partenza, ora_arrivo, stato) FROM stdin;
7	1	TR100	2025-11-13	08:00:00	10:00:00	programmato
8	1	TR200	2025-11-13	10:30:00	12:30:00	programmato
9	1	TR300	2025-11-13	17:00:00	19:00:00	programmato
\.


--
-- TOC entry 5510 (class 0 OID 16701)
-- Dependencies: 222
-- Data for Name: stazione; Type: TABLE DATA; Schema: ferrovie; Owner: postgres
--

COPY ferrovie.stazione (id_stazione, codice, nome, citta, provincia, nazione, latitudine, longitudine) FROM stdin;
1	STA	Stazione A	CittÃ  A	\N	\N	\N	\N
2	STB	Stazione B	CittÃ  B	\N	\N	\N	\N
3	STC	Stazione C	CittÃ  C	\N	\N	\N	\N
4	STD	Stazione D	CittÃ  D	\N	\N	\N	\N
\.


--
-- TOC entry 5516 (class 0 OID 16754)
-- Dependencies: 228
-- Data for Name: tariffa; Type: TABLE DATA; Schema: ferrovie; Owner: postgres
--

COPY ferrovie.tariffa (id_tariffa, nome, condizioni) FROM stdin;
1	Base	Tariffa base
2	Flex	Modificabile
3	Promo	Restrizioni
\.


--
-- TOC entry 5514 (class 0 OID 16726)
-- Dependencies: 226
-- Data for Name: tratta; Type: TABLE DATA; Schema: ferrovie; Owner: postgres
--

COPY ferrovie.tratta (id_tratta, id_linea, id_stazione_partenza, id_stazione_arrivo, ordine, distanza_km) FROM stdin;
1	1	1	2	1	50.00
2	1	2	3	2	40.00
3	1	3	4	3	60.00
\.


--
-- TOC entry 5535 (class 0 OID 16942)
-- Dependencies: 247
-- Data for Name: validazione; Type: TABLE DATA; Schema: ferrovie; Owner: postgres
--

COPY ferrovie.validazione (id_validazione, id_biglietto, ts_validazione, id_stazione) FROM stdin;
2	7	2025-11-13 13:40:10.857493	3
\.


--
-- TOC entry 5561 (class 0 OID 0)
-- Dependencies: 241
-- Name: biglietto_id_biglietto_seq; Type: SEQUENCE SET; Schema: ferrovie; Owner: postgres
--

SELECT pg_catalog.setval('ferrovie.biglietto_id_biglietto_seq', 7, true);


--
-- TOC entry 5562 (class 0 OID 0)
-- Dependencies: 248
-- Name: cambio_id_cambio_seq; Type: SEQUENCE SET; Schema: ferrovie; Owner: postgres
--

SELECT pg_catalog.setval('ferrovie.cambio_id_cambio_seq', 2, true);


--
-- TOC entry 5563 (class 0 OID 0)
-- Dependencies: 229
-- Name: classe_id_classe_seq; Type: SEQUENCE SET; Schema: ferrovie; Owner: postgres
--

SELECT pg_catalog.setval('ferrovie.classe_id_classe_seq', 4, true);


--
-- TOC entry 5564 (class 0 OID 0)
-- Dependencies: 223
-- Name: linea_id_linea_seq; Type: SEQUENCE SET; Schema: ferrovie; Owner: postgres
--

SELECT pg_catalog.setval('ferrovie.linea_id_linea_seq', 2, true);


--
-- TOC entry 5565 (class 0 OID 0)
-- Dependencies: 237
-- Name: pagamento_id_pagamento_seq; Type: SEQUENCE SET; Schema: ferrovie; Owner: postgres
--

SELECT pg_catalog.setval('ferrovie.pagamento_id_pagamento_seq', 7, true);


--
-- TOC entry 5566 (class 0 OID 0)
-- Dependencies: 233
-- Name: passeggero_id_passeggero_seq; Type: SEQUENCE SET; Schema: ferrovie; Owner: postgres
--

SELECT pg_catalog.setval('ferrovie.passeggero_id_passeggero_seq', 18, true);


--
-- TOC entry 5567 (class 0 OID 0)
-- Dependencies: 243
-- Name: percorso_biglietto_id_percorso_seq; Type: SEQUENCE SET; Schema: ferrovie; Owner: postgres
--

SELECT pg_catalog.setval('ferrovie.percorso_biglietto_id_percorso_seq', 8, true);


--
-- TOC entry 5568 (class 0 OID 0)
-- Dependencies: 235
-- Name: prenotazione_id_prenotazione_seq; Type: SEQUENCE SET; Schema: ferrovie; Owner: postgres
--

SELECT pg_catalog.setval('ferrovie.prenotazione_id_prenotazione_seq', 7, true);


--
-- TOC entry 5569 (class 0 OID 0)
-- Dependencies: 231
-- Name: prezzo_id_prezzo_seq; Type: SEQUENCE SET; Schema: ferrovie; Owner: postgres
--

SELECT pg_catalog.setval('ferrovie.prezzo_id_prezzo_seq', 6, true);


--
-- TOC entry 5570 (class 0 OID 0)
-- Dependencies: 250
-- Name: rimborso_id_rimborso_seq; Type: SEQUENCE SET; Schema: ferrovie; Owner: postgres
--

SELECT pg_catalog.setval('ferrovie.rimborso_id_rimborso_seq', 2, true);


--
-- TOC entry 5571 (class 0 OID 0)
-- Dependencies: 239
-- Name: servizio_id_servizio_seq; Type: SEQUENCE SET; Schema: ferrovie; Owner: postgres
--

SELECT pg_catalog.setval('ferrovie.servizio_id_servizio_seq', 9, true);


--
-- TOC entry 5572 (class 0 OID 0)
-- Dependencies: 221
-- Name: stazione_id_stazione_seq; Type: SEQUENCE SET; Schema: ferrovie; Owner: postgres
--

SELECT pg_catalog.setval('ferrovie.stazione_id_stazione_seq', 8, true);


--
-- TOC entry 5573 (class 0 OID 0)
-- Dependencies: 227
-- Name: tariffa_id_tariffa_seq; Type: SEQUENCE SET; Schema: ferrovie; Owner: postgres
--

SELECT pg_catalog.setval('ferrovie.tariffa_id_tariffa_seq', 6, true);


--
-- TOC entry 5574 (class 0 OID 0)
-- Dependencies: 225
-- Name: tratta_id_tratta_seq; Type: SEQUENCE SET; Schema: ferrovie; Owner: postgres
--

SELECT pg_catalog.setval('ferrovie.tratta_id_tratta_seq', 6, true);


--
-- TOC entry 5575 (class 0 OID 0)
-- Dependencies: 246
-- Name: validazione_id_validazione_seq; Type: SEQUENCE SET; Schema: ferrovie; Owner: postgres
--

SELECT pg_catalog.setval('ferrovie.validazione_id_validazione_seq', 2, true);


--
-- TOC entry 5314 (class 2606 OID 16873)
-- Name: biglietto biglietto_codice_qr_key; Type: CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.biglietto
    ADD CONSTRAINT biglietto_codice_qr_key UNIQUE (codice_qr);


--
-- TOC entry 5316 (class 2606 OID 16871)
-- Name: biglietto biglietto_pkey; Type: CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.biglietto
    ADD CONSTRAINT biglietto_pkey PRIMARY KEY (id_biglietto);


--
-- TOC entry 5331 (class 2606 OID 16968)
-- Name: cambio cambio_pkey; Type: CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.cambio
    ADD CONSTRAINT cambio_pkey PRIMARY KEY (id_cambio);


--
-- TOC entry 5285 (class 2606 OID 16778)
-- Name: classe classe_nome_key; Type: CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.classe
    ADD CONSTRAINT classe_nome_key UNIQUE (nome);


--
-- TOC entry 5287 (class 2606 OID 16776)
-- Name: classe classe_pkey; Type: CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.classe
    ADD CONSTRAINT classe_pkey PRIMARY KEY (id_classe);


--
-- TOC entry 5327 (class 2606 OID 16925)
-- Name: dettaglio_prezzo_biglietto dettaglio_prezzo_biglietto_pkey; Type: CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.dettaglio_prezzo_biglietto
    ADD CONSTRAINT dettaglio_prezzo_biglietto_pkey PRIMARY KEY (id_biglietto, id_percorso);


--
-- TOC entry 5289 (class 2606 OID 17824)
-- Name: prezzo ex_prezzo_periodo_non_overlapping; Type: CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.prezzo
    ADD CONSTRAINT ex_prezzo_periodo_non_overlapping EXCLUDE USING gist (id_tariffa WITH =, id_classe WITH =, id_tratta WITH =, daterange(valid_from, COALESCE(valid_to, 'infinity'::date), '[]'::text) WITH &&);


--
-- TOC entry 5272 (class 2606 OID 16724)
-- Name: linea linea_nome_linea_key; Type: CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.linea
    ADD CONSTRAINT linea_nome_linea_key UNIQUE (nome_linea);


--
-- TOC entry 5274 (class 2606 OID 16722)
-- Name: linea linea_pkey; Type: CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.linea
    ADD CONSTRAINT linea_pkey PRIMARY KEY (id_linea);


--
-- TOC entry 5307 (class 2606 OID 16840)
-- Name: pagamento pagamento_pkey; Type: CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.pagamento
    ADD CONSTRAINT pagamento_pkey PRIMARY KEY (id_pagamento);


--
-- TOC entry 5296 (class 2606 OID 16814)
-- Name: passeggero passeggero_codice_fiscale_key; Type: CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.passeggero
    ADD CONSTRAINT passeggero_codice_fiscale_key UNIQUE (codice_fiscale);


--
-- TOC entry 5298 (class 2606 OID 16816)
-- Name: passeggero passeggero_email_key; Type: CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.passeggero
    ADD CONSTRAINT passeggero_email_key UNIQUE (email);


--
-- TOC entry 5300 (class 2606 OID 16812)
-- Name: passeggero passeggero_pkey; Type: CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.passeggero
    ADD CONSTRAINT passeggero_pkey PRIMARY KEY (id_passeggero);


--
-- TOC entry 5323 (class 2606 OID 16897)
-- Name: percorso_biglietto percorso_biglietto_pkey; Type: CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.percorso_biglietto
    ADD CONSTRAINT percorso_biglietto_pkey PRIMARY KEY (id_percorso);


--
-- TOC entry 5303 (class 2606 OID 16825)
-- Name: prenotazione prenotazione_pkey; Type: CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.prenotazione
    ADD CONSTRAINT prenotazione_pkey PRIMARY KEY (id_prenotazione);


--
-- TOC entry 5292 (class 2606 OID 16789)
-- Name: prezzo prezzo_pkey; Type: CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.prezzo
    ADD CONSTRAINT prezzo_pkey PRIMARY KEY (id_prezzo);


--
-- TOC entry 5333 (class 2606 OID 16983)
-- Name: rimborso rimborso_pkey; Type: CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.rimborso
    ADD CONSTRAINT rimborso_pkey PRIMARY KEY (id_rimborso);


--
-- TOC entry 5310 (class 2606 OID 16855)
-- Name: servizio servizio_pkey; Type: CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.servizio
    ADD CONSTRAINT servizio_pkey PRIMARY KEY (id_servizio);


--
-- TOC entry 5267 (class 2606 OID 16711)
-- Name: stazione stazione_codice_key; Type: CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.stazione
    ADD CONSTRAINT stazione_codice_key UNIQUE (codice);


--
-- TOC entry 5269 (class 2606 OID 16709)
-- Name: stazione stazione_pkey; Type: CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.stazione
    ADD CONSTRAINT stazione_pkey PRIMARY KEY (id_stazione);


--
-- TOC entry 5281 (class 2606 OID 16765)
-- Name: tariffa tariffa_nome_key; Type: CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.tariffa
    ADD CONSTRAINT tariffa_nome_key UNIQUE (nome);


--
-- TOC entry 5283 (class 2606 OID 16763)
-- Name: tariffa tariffa_pkey; Type: CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.tariffa
    ADD CONSTRAINT tariffa_pkey PRIMARY KEY (id_tariffa);


--
-- TOC entry 5277 (class 2606 OID 16737)
-- Name: tratta tratta_pkey; Type: CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.tratta
    ADD CONSTRAINT tratta_pkey PRIMARY KEY (id_tratta);


--
-- TOC entry 5325 (class 2606 OID 17067)
-- Name: percorso_biglietto ux_posto_servizio_unico; Type: CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.percorso_biglietto
    ADD CONSTRAINT ux_posto_servizio_unico UNIQUE (id_servizio, id_stazione_salita, id_stazione_discesa, id_biglietto);


--
-- TOC entry 5294 (class 2606 OID 17065)
-- Name: prezzo ux_prezzo_tripla_from; Type: CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.prezzo
    ADD CONSTRAINT ux_prezzo_tripla_from UNIQUE (id_tariffa, id_classe, id_tratta, valid_from);


--
-- TOC entry 5312 (class 2606 OID 17063)
-- Name: servizio ux_servizio_treno_data; Type: CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.servizio
    ADD CONSTRAINT ux_servizio_treno_data UNIQUE (codice_treno, data_partenza);


--
-- TOC entry 5279 (class 2606 OID 17061)
-- Name: tratta ux_tratta_linea_ordine; Type: CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.tratta
    ADD CONSTRAINT ux_tratta_linea_ordine UNIQUE (id_linea, ordine);


--
-- TOC entry 5329 (class 2606 OID 16948)
-- Name: validazione validazione_pkey; Type: CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.validazione
    ADD CONSTRAINT validazione_pkey PRIMARY KEY (id_validazione);


--
-- TOC entry 5317 (class 1259 OID 17091)
-- Name: idx_biglietto_qr; Type: INDEX; Schema: ferrovie; Owner: postgres
--

CREATE UNIQUE INDEX idx_biglietto_qr ON ferrovie.biglietto USING btree (codice_qr);


--
-- TOC entry 5318 (class 1259 OID 18003)
-- Name: idx_biglietto_stato_data; Type: INDEX; Schema: ferrovie; Owner: postgres
--

CREATE INDEX idx_biglietto_stato_data ON ferrovie.biglietto USING btree (stato, ts_emissione DESC);


--
-- TOC entry 5319 (class 1259 OID 18004)
-- Name: idx_biglietto_validi; Type: INDEX; Schema: ferrovie; Owner: postgres
--

CREATE INDEX idx_biglietto_validi ON ferrovie.biglietto USING btree (ts_emissione DESC) WHERE (stato = 'valido'::ferrovie.stato_biglietto);


--
-- TOC entry 5270 (class 1259 OID 17085)
-- Name: idx_linea_nome; Type: INDEX; Schema: ferrovie; Owner: postgres
--

CREATE INDEX idx_linea_nome ON ferrovie.linea USING btree (nome_linea);


--
-- TOC entry 5304 (class 1259 OID 18007)
-- Name: idx_pagamento_esito; Type: INDEX; Schema: ferrovie; Owner: postgres
--

CREATE INDEX idx_pagamento_esito ON ferrovie.pagamento USING btree (esito);


--
-- TOC entry 5305 (class 1259 OID 18008)
-- Name: idx_pagamento_prenotazione_esito; Type: INDEX; Schema: ferrovie; Owner: postgres
--

CREATE INDEX idx_pagamento_prenotazione_esito ON ferrovie.pagamento USING btree (id_prenotazione, esito, ts_pagamento DESC);


--
-- TOC entry 5320 (class 1259 OID 17094)
-- Name: idx_pb_biglietto; Type: INDEX; Schema: ferrovie; Owner: postgres
--

CREATE INDEX idx_pb_biglietto ON ferrovie.percorso_biglietto USING btree (id_biglietto);


--
-- TOC entry 5321 (class 1259 OID 17095)
-- Name: idx_pb_servizio; Type: INDEX; Schema: ferrovie; Owner: postgres
--

CREATE INDEX idx_pb_servizio ON ferrovie.percorso_biglietto USING btree (id_servizio);


--
-- TOC entry 5301 (class 1259 OID 17088)
-- Name: idx_prenotazione_passeggero_data; Type: INDEX; Schema: ferrovie; Owner: postgres
--

CREATE INDEX idx_prenotazione_passeggero_data ON ferrovie.prenotazione USING btree (id_passeggero, ts_creazione DESC);


--
-- TOC entry 5290 (class 1259 OID 17096)
-- Name: idx_prezzo_corrente; Type: INDEX; Schema: ferrovie; Owner: postgres
--

CREATE INDEX idx_prezzo_corrente ON ferrovie.prezzo USING btree (id_tratta, id_classe, id_tariffa) WHERE (valid_to IS NULL);


--
-- TOC entry 5308 (class 1259 OID 17086)
-- Name: idx_servizio_linea_data_ora; Type: INDEX; Schema: ferrovie; Owner: postgres
--

CREATE INDEX idx_servizio_linea_data_ora ON ferrovie.servizio USING btree (id_linea, data_partenza, ora_partenza);


--
-- TOC entry 5264 (class 1259 OID 17083)
-- Name: idx_stazione_codice; Type: INDEX; Schema: ferrovie; Owner: postgres
--

CREATE UNIQUE INDEX idx_stazione_codice ON ferrovie.stazione USING btree (codice);


--
-- TOC entry 5265 (class 1259 OID 17084)
-- Name: idx_stazione_nome; Type: INDEX; Schema: ferrovie; Owner: postgres
--

CREATE INDEX idx_stazione_nome ON ferrovie.stazione USING btree (nome);


--
-- TOC entry 5275 (class 1259 OID 17087)
-- Name: idx_tratta_partenza_arrivo; Type: INDEX; Schema: ferrovie; Owner: postgres
--

CREATE INDEX idx_tratta_partenza_arrivo ON ferrovie.tratta USING btree (id_stazione_partenza, id_stazione_arrivo);


--
-- TOC entry 5360 (class 2620 OID 17826)
-- Name: biglietto trg_check_pagamento; Type: TRIGGER; Schema: ferrovie; Owner: postgres
--

CREATE TRIGGER trg_check_pagamento BEFORE INSERT ON ferrovie.biglietto FOR EACH ROW EXECUTE FUNCTION ferrovie.check_pagamento_confermato();


--
-- TOC entry 5361 (class 2620 OID 17828)
-- Name: biglietto trg_deleted_biglietto; Type: TRIGGER; Schema: ferrovie; Owner: postgres
--

CREATE TRIGGER trg_deleted_biglietto BEFORE UPDATE ON ferrovie.biglietto FOR EACH ROW WHEN ((old.deleted_at IS NOT NULL)) EXECUTE FUNCTION ferrovie.prevent_deleted_biglietto();


--
-- TOC entry 5344 (class 2606 OID 16884)
-- Name: biglietto biglietto_id_classe_fkey; Type: FK CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.biglietto
    ADD CONSTRAINT biglietto_id_classe_fkey FOREIGN KEY (id_classe) REFERENCES ferrovie.classe(id_classe);


--
-- TOC entry 5345 (class 2606 OID 16874)
-- Name: biglietto biglietto_id_prenotazione_fkey; Type: FK CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.biglietto
    ADD CONSTRAINT biglietto_id_prenotazione_fkey FOREIGN KEY (id_prenotazione) REFERENCES ferrovie.prenotazione(id_prenotazione);


--
-- TOC entry 5346 (class 2606 OID 16879)
-- Name: biglietto biglietto_id_tariffa_fkey; Type: FK CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.biglietto
    ADD CONSTRAINT biglietto_id_tariffa_fkey FOREIGN KEY (id_tariffa) REFERENCES ferrovie.tariffa(id_tariffa);


--
-- TOC entry 5358 (class 2606 OID 16969)
-- Name: cambio cambio_id_biglietto_fkey; Type: FK CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.cambio
    ADD CONSTRAINT cambio_id_biglietto_fkey FOREIGN KEY (id_biglietto) REFERENCES ferrovie.biglietto(id_biglietto);


--
-- TOC entry 5353 (class 2606 OID 16926)
-- Name: dettaglio_prezzo_biglietto dettaglio_prezzo_biglietto_id_biglietto_fkey; Type: FK CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.dettaglio_prezzo_biglietto
    ADD CONSTRAINT dettaglio_prezzo_biglietto_id_biglietto_fkey FOREIGN KEY (id_biglietto) REFERENCES ferrovie.biglietto(id_biglietto);


--
-- TOC entry 5354 (class 2606 OID 16931)
-- Name: dettaglio_prezzo_biglietto dettaglio_prezzo_biglietto_id_percorso_fkey; Type: FK CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.dettaglio_prezzo_biglietto
    ADD CONSTRAINT dettaglio_prezzo_biglietto_id_percorso_fkey FOREIGN KEY (id_percorso) REFERENCES ferrovie.percorso_biglietto(id_percorso);


--
-- TOC entry 5355 (class 2606 OID 16936)
-- Name: dettaglio_prezzo_biglietto dettaglio_prezzo_biglietto_id_prezzo_fkey; Type: FK CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.dettaglio_prezzo_biglietto
    ADD CONSTRAINT dettaglio_prezzo_biglietto_id_prezzo_fkey FOREIGN KEY (id_prezzo) REFERENCES ferrovie.prezzo(id_prezzo);


--
-- TOC entry 5347 (class 2606 OID 17068)
-- Name: biglietto fk_biglietto_prenotazione; Type: FK CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.biglietto
    ADD CONSTRAINT fk_biglietto_prenotazione FOREIGN KEY (id_prenotazione) REFERENCES ferrovie.prenotazione(id_prenotazione) ON DELETE CASCADE;


--
-- TOC entry 5341 (class 2606 OID 17073)
-- Name: pagamento fk_pagamento_prenotazione; Type: FK CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.pagamento
    ADD CONSTRAINT fk_pagamento_prenotazione FOREIGN KEY (id_prenotazione) REFERENCES ferrovie.prenotazione(id_prenotazione) ON DELETE CASCADE;


--
-- TOC entry 5348 (class 2606 OID 17078)
-- Name: percorso_biglietto fk_percorso_biglietto; Type: FK CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.percorso_biglietto
    ADD CONSTRAINT fk_percorso_biglietto FOREIGN KEY (id_biglietto) REFERENCES ferrovie.biglietto(id_biglietto) ON DELETE CASCADE;


--
-- TOC entry 5342 (class 2606 OID 16841)
-- Name: pagamento pagamento_id_prenotazione_fkey; Type: FK CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.pagamento
    ADD CONSTRAINT pagamento_id_prenotazione_fkey FOREIGN KEY (id_prenotazione) REFERENCES ferrovie.prenotazione(id_prenotazione);


--
-- TOC entry 5349 (class 2606 OID 16898)
-- Name: percorso_biglietto percorso_biglietto_id_biglietto_fkey; Type: FK CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.percorso_biglietto
    ADD CONSTRAINT percorso_biglietto_id_biglietto_fkey FOREIGN KEY (id_biglietto) REFERENCES ferrovie.biglietto(id_biglietto);


--
-- TOC entry 5350 (class 2606 OID 16903)
-- Name: percorso_biglietto percorso_biglietto_id_servizio_fkey; Type: FK CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.percorso_biglietto
    ADD CONSTRAINT percorso_biglietto_id_servizio_fkey FOREIGN KEY (id_servizio) REFERENCES ferrovie.servizio(id_servizio);


--
-- TOC entry 5351 (class 2606 OID 16913)
-- Name: percorso_biglietto percorso_biglietto_id_stazione_discesa_fkey; Type: FK CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.percorso_biglietto
    ADD CONSTRAINT percorso_biglietto_id_stazione_discesa_fkey FOREIGN KEY (id_stazione_discesa) REFERENCES ferrovie.stazione(id_stazione);


--
-- TOC entry 5352 (class 2606 OID 16908)
-- Name: percorso_biglietto percorso_biglietto_id_stazione_salita_fkey; Type: FK CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.percorso_biglietto
    ADD CONSTRAINT percorso_biglietto_id_stazione_salita_fkey FOREIGN KEY (id_stazione_salita) REFERENCES ferrovie.stazione(id_stazione);


--
-- TOC entry 5340 (class 2606 OID 16826)
-- Name: prenotazione prenotazione_id_passeggero_fkey; Type: FK CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.prenotazione
    ADD CONSTRAINT prenotazione_id_passeggero_fkey FOREIGN KEY (id_passeggero) REFERENCES ferrovie.passeggero(id_passeggero);


--
-- TOC entry 5337 (class 2606 OID 16795)
-- Name: prezzo prezzo_id_classe_fkey; Type: FK CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.prezzo
    ADD CONSTRAINT prezzo_id_classe_fkey FOREIGN KEY (id_classe) REFERENCES ferrovie.classe(id_classe);


--
-- TOC entry 5338 (class 2606 OID 16790)
-- Name: prezzo prezzo_id_tariffa_fkey; Type: FK CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.prezzo
    ADD CONSTRAINT prezzo_id_tariffa_fkey FOREIGN KEY (id_tariffa) REFERENCES ferrovie.tariffa(id_tariffa);


--
-- TOC entry 5339 (class 2606 OID 16800)
-- Name: prezzo prezzo_id_tratta_fkey; Type: FK CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.prezzo
    ADD CONSTRAINT prezzo_id_tratta_fkey FOREIGN KEY (id_tratta) REFERENCES ferrovie.tratta(id_tratta);


--
-- TOC entry 5359 (class 2606 OID 16984)
-- Name: rimborso rimborso_id_biglietto_fkey; Type: FK CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.rimborso
    ADD CONSTRAINT rimborso_id_biglietto_fkey FOREIGN KEY (id_biglietto) REFERENCES ferrovie.biglietto(id_biglietto);


--
-- TOC entry 5343 (class 2606 OID 16856)
-- Name: servizio servizio_id_linea_fkey; Type: FK CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.servizio
    ADD CONSTRAINT servizio_id_linea_fkey FOREIGN KEY (id_linea) REFERENCES ferrovie.linea(id_linea);


--
-- TOC entry 5334 (class 2606 OID 16738)
-- Name: tratta tratta_id_linea_fkey; Type: FK CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.tratta
    ADD CONSTRAINT tratta_id_linea_fkey FOREIGN KEY (id_linea) REFERENCES ferrovie.linea(id_linea);


--
-- TOC entry 5335 (class 2606 OID 16748)
-- Name: tratta tratta_id_stazione_arrivo_fkey; Type: FK CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.tratta
    ADD CONSTRAINT tratta_id_stazione_arrivo_fkey FOREIGN KEY (id_stazione_arrivo) REFERENCES ferrovie.stazione(id_stazione);


--
-- TOC entry 5336 (class 2606 OID 16743)
-- Name: tratta tratta_id_stazione_partenza_fkey; Type: FK CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.tratta
    ADD CONSTRAINT tratta_id_stazione_partenza_fkey FOREIGN KEY (id_stazione_partenza) REFERENCES ferrovie.stazione(id_stazione);


--
-- TOC entry 5356 (class 2606 OID 16949)
-- Name: validazione validazione_id_biglietto_fkey; Type: FK CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.validazione
    ADD CONSTRAINT validazione_id_biglietto_fkey FOREIGN KEY (id_biglietto) REFERENCES ferrovie.biglietto(id_biglietto);


--
-- TOC entry 5357 (class 2606 OID 16954)
-- Name: validazione validazione_id_stazione_fkey; Type: FK CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.validazione
    ADD CONSTRAINT validazione_id_stazione_fkey FOREIGN KEY (id_stazione) REFERENCES ferrovie.stazione(id_stazione);


-- Completed on 2025-11-14 16:43:40

--
-- PostgreSQL database dump complete
--

\unrestrict SoE5O2zzJya5F1tg2gYy7yD9HA8sIdVkUwHok4MM49yvjmiFQCj5FyVbvUT6XMM

