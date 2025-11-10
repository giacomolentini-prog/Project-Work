--
-- PostgreSQL database dump
--

\restrict sFXsGXyjsiWyA3jdLf8DsHWcgCLPeJtqj9p9mmLAb0E4mL6pqUkhKLIMUqmrLjV

-- Dumped from database version 18.0
-- Dumped by pg_dump version 18.0

-- Started on 2025-11-10 18:31:56

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
-- TOC entry 7 (class 2615 OID 16393)
-- Name: ferrovie; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA ferrovie;


ALTER SCHEMA ferrovie OWNER TO postgres;

--
-- TOC entry 2 (class 3079 OID 16566)
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA ferrovie;


--
-- TOC entry 5234 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 242 (class 1259 OID 16605)
-- Name: biglietto; Type: TABLE; Schema: ferrovie; Owner: postgres
--

CREATE TABLE ferrovie.biglietto (
    id_biglietto integer NOT NULL,
    id_prenotazione integer,
    codice_qr uuid DEFAULT gen_random_uuid(),
    id_tariffa integer,
    id_classe integer,
    prezzo_totale numeric(8,2),
    stato character varying(20) DEFAULT 'valido'::character varying,
    ts_emissione timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT biglietto_stato_check CHECK (((stato)::text = ANY ((ARRAY['valido'::character varying, 'usato'::character varying, 'rimborsato'::character varying, 'annullato'::character varying])::text[])))
);


ALTER TABLE ferrovie.biglietto OWNER TO postgres;

--
-- TOC entry 241 (class 1259 OID 16604)
-- Name: biglietto_id_biglietto_seq; Type: SEQUENCE; Schema: ferrovie; Owner: postgres
--

CREATE SEQUENCE ferrovie.biglietto_id_biglietto_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ferrovie.biglietto_id_biglietto_seq OWNER TO postgres;

--
-- TOC entry 5235 (class 0 OID 0)
-- Dependencies: 241
-- Name: biglietto_id_biglietto_seq; Type: SEQUENCE OWNED BY; Schema: ferrovie; Owner: postgres
--

ALTER SEQUENCE ferrovie.biglietto_id_biglietto_seq OWNED BY ferrovie.biglietto.id_biglietto;


--
-- TOC entry 236 (class 1259 OID 16510)
-- Name: classe; Type: TABLE; Schema: ferrovie; Owner: postgres
--

CREATE TABLE ferrovie.classe (
    id_classe integer NOT NULL,
    nome character varying(30) NOT NULL,
    descrizione text
);


ALTER TABLE ferrovie.classe OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 16509)
-- Name: classe_id_classe_seq; Type: SEQUENCE; Schema: ferrovie; Owner: postgres
--

CREATE SEQUENCE ferrovie.classe_id_classe_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ferrovie.classe_id_classe_seq OWNER TO postgres;

--
-- TOC entry 5236 (class 0 OID 0)
-- Dependencies: 235
-- Name: classe_id_classe_seq; Type: SEQUENCE OWNED BY; Schema: ferrovie; Owner: postgres
--

ALTER SEQUENCE ferrovie.classe_id_classe_seq OWNED BY ferrovie.classe.id_classe;


--
-- TOC entry 245 (class 1259 OID 16662)
-- Name: dettaglio_prezzo_biglietto; Type: TABLE; Schema: ferrovie; Owner: postgres
--

CREATE TABLE ferrovie.dettaglio_prezzo_biglietto (
    id_biglietto integer NOT NULL,
    id_percorso integer NOT NULL,
    id_prezzo integer,
    importo_applicato numeric(8,2) NOT NULL
);


ALTER TABLE ferrovie.dettaglio_prezzo_biglietto OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 16407)
-- Name: linea; Type: TABLE; Schema: ferrovie; Owner: postgres
--

CREATE TABLE ferrovie.linea (
    id_linea integer NOT NULL,
    nome_linea character varying(100) NOT NULL,
    descrizione text
);


ALTER TABLE ferrovie.linea OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16406)
-- Name: linea_id_linea_seq; Type: SEQUENCE; Schema: ferrovie; Owner: postgres
--

CREATE SEQUENCE ferrovie.linea_id_linea_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ferrovie.linea_id_linea_seq OWNER TO postgres;

--
-- TOC entry 5237 (class 0 OID 0)
-- Dependencies: 223
-- Name: linea_id_linea_seq; Type: SEQUENCE OWNED BY; Schema: ferrovie; Owner: postgres
--

ALTER SEQUENCE ferrovie.linea_id_linea_seq OWNED BY ferrovie.linea.id_linea;


--
-- TOC entry 232 (class 1259 OID 16480)
-- Name: pagamento; Type: TABLE; Schema: ferrovie; Owner: postgres
--

CREATE TABLE ferrovie.pagamento (
    id_pagamento integer NOT NULL,
    id_prenotazione integer,
    metodo character varying(20),
    importo numeric(8,2),
    valuta character varying(3) DEFAULT 'EUR'::character varying,
    esito character varying(20),
    ts_pagamento timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pagamento_esito_check CHECK (((esito)::text = ANY ((ARRAY['ok'::character varying, 'ko'::character varying, 'pendente'::character varying])::text[]))),
    CONSTRAINT pagamento_metodo_check CHECK (((metodo)::text = ANY ((ARRAY['carta'::character varying, 'paypal'::character varying, 'satispay'::character varying, 'altro'::character varying])::text[])))
);


ALTER TABLE ferrovie.pagamento OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 16479)
-- Name: pagamento_id_pagamento_seq; Type: SEQUENCE; Schema: ferrovie; Owner: postgres
--

CREATE SEQUENCE ferrovie.pagamento_id_pagamento_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ferrovie.pagamento_id_pagamento_seq OWNER TO postgres;

--
-- TOC entry 5238 (class 0 OID 0)
-- Dependencies: 231
-- Name: pagamento_id_pagamento_seq; Type: SEQUENCE OWNED BY; Schema: ferrovie; Owner: postgres
--

ALTER SEQUENCE ferrovie.pagamento_id_pagamento_seq OWNED BY ferrovie.pagamento.id_pagamento;


--
-- TOC entry 228 (class 1259 OID 16450)
-- Name: passeggero; Type: TABLE; Schema: ferrovie; Owner: postgres
--

CREATE TABLE ferrovie.passeggero (
    id_passeggero integer NOT NULL,
    codice_fiscale character varying(16),
    nome character varying(50) NOT NULL,
    cognome character varying(50) NOT NULL,
    email character varying(100),
    telefono character varying(30)
);


ALTER TABLE ferrovie.passeggero OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 16449)
-- Name: passeggero_id_passeggero_seq; Type: SEQUENCE; Schema: ferrovie; Owner: postgres
--

CREATE SEQUENCE ferrovie.passeggero_id_passeggero_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ferrovie.passeggero_id_passeggero_seq OWNER TO postgres;

--
-- TOC entry 5239 (class 0 OID 0)
-- Dependencies: 227
-- Name: passeggero_id_passeggero_seq; Type: SEQUENCE OWNED BY; Schema: ferrovie; Owner: postgres
--

ALTER SEQUENCE ferrovie.passeggero_id_passeggero_seq OWNED BY ferrovie.passeggero.id_passeggero;


--
-- TOC entry 244 (class 1259 OID 16634)
-- Name: percorso_biglietto; Type: TABLE; Schema: ferrovie; Owner: postgres
--

CREATE TABLE ferrovie.percorso_biglietto (
    id_percorso integer NOT NULL,
    id_biglietto integer,
    id_servizio integer,
    id_stazione_salita integer,
    id_stazione_discesa integer,
    CONSTRAINT percorso_biglietto_check CHECK ((id_stazione_salita <> id_stazione_discesa))
);


ALTER TABLE ferrovie.percorso_biglietto OWNER TO postgres;

--
-- TOC entry 243 (class 1259 OID 16633)
-- Name: percorso_biglietto_id_percorso_seq; Type: SEQUENCE; Schema: ferrovie; Owner: postgres
--

CREATE SEQUENCE ferrovie.percorso_biglietto_id_percorso_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ferrovie.percorso_biglietto_id_percorso_seq OWNER TO postgres;

--
-- TOC entry 5240 (class 0 OID 0)
-- Dependencies: 243
-- Name: percorso_biglietto_id_percorso_seq; Type: SEQUENCE OWNED BY; Schema: ferrovie; Owner: postgres
--

ALTER SEQUENCE ferrovie.percorso_biglietto_id_percorso_seq OWNED BY ferrovie.percorso_biglietto.id_percorso;


--
-- TOC entry 230 (class 1259 OID 16464)
-- Name: prenotazione; Type: TABLE; Schema: ferrovie; Owner: postgres
--

CREATE TABLE ferrovie.prenotazione (
    id_prenotazione integer NOT NULL,
    id_passeggero integer,
    ts_creazione timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    stato character varying(20) DEFAULT 'in_attesa'::character varying,
    CONSTRAINT prenotazione_stato_check CHECK (((stato)::text = ANY ((ARRAY['in_attesa'::character varying, 'confermata'::character varying, 'annullata'::character varying])::text[])))
);


ALTER TABLE ferrovie.prenotazione OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 16463)
-- Name: prenotazione_id_prenotazione_seq; Type: SEQUENCE; Schema: ferrovie; Owner: postgres
--

CREATE SEQUENCE ferrovie.prenotazione_id_prenotazione_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ferrovie.prenotazione_id_prenotazione_seq OWNER TO postgres;

--
-- TOC entry 5241 (class 0 OID 0)
-- Dependencies: 229
-- Name: prenotazione_id_prenotazione_seq; Type: SEQUENCE OWNED BY; Schema: ferrovie; Owner: postgres
--

ALTER SEQUENCE ferrovie.prenotazione_id_prenotazione_seq OWNED BY ferrovie.prenotazione.id_prenotazione;


--
-- TOC entry 238 (class 1259 OID 16523)
-- Name: prezzo; Type: TABLE; Schema: ferrovie; Owner: postgres
--

CREATE TABLE ferrovie.prezzo (
    id_prezzo integer NOT NULL,
    id_tariffa integer,
    id_classe integer,
    id_tratta integer,
    importo numeric(8,2) NOT NULL,
    valid_from date NOT NULL,
    valid_to date,
    CONSTRAINT prezzo_check CHECK (((valid_to IS NULL) OR (valid_to > valid_from)))
);


ALTER TABLE ferrovie.prezzo OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 16522)
-- Name: prezzo_id_prezzo_seq; Type: SEQUENCE; Schema: ferrovie; Owner: postgres
--

CREATE SEQUENCE ferrovie.prezzo_id_prezzo_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ferrovie.prezzo_id_prezzo_seq OWNER TO postgres;

--
-- TOC entry 5242 (class 0 OID 0)
-- Dependencies: 237
-- Name: prezzo_id_prezzo_seq; Type: SEQUENCE OWNED BY; Schema: ferrovie; Owner: postgres
--

ALTER SEQUENCE ferrovie.prezzo_id_prezzo_seq OWNED BY ferrovie.prezzo.id_prezzo;


--
-- TOC entry 240 (class 1259 OID 16549)
-- Name: servizio; Type: TABLE; Schema: ferrovie; Owner: postgres
--

CREATE TABLE ferrovie.servizio (
    id_servizio integer NOT NULL,
    id_linea integer,
    codice_treno character varying(20) NOT NULL,
    data_partenza date NOT NULL,
    ora_partenza time without time zone,
    ora_arrivo time without time zone,
    stato character varying(20),
    CONSTRAINT servizio_stato_check CHECK (((stato)::text = ANY ((ARRAY['programmato'::character varying, 'in_corsa'::character varying, 'cancellato'::character varying, 'concluso'::character varying])::text[])))
);


ALTER TABLE ferrovie.servizio OWNER TO postgres;

--
-- TOC entry 239 (class 1259 OID 16548)
-- Name: servizio_id_servizio_seq; Type: SEQUENCE; Schema: ferrovie; Owner: postgres
--

CREATE SEQUENCE ferrovie.servizio_id_servizio_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ferrovie.servizio_id_servizio_seq OWNER TO postgres;

--
-- TOC entry 5243 (class 0 OID 0)
-- Dependencies: 239
-- Name: servizio_id_servizio_seq; Type: SEQUENCE OWNED BY; Schema: ferrovie; Owner: postgres
--

ALTER SEQUENCE ferrovie.servizio_id_servizio_seq OWNED BY ferrovie.servizio.id_servizio;


--
-- TOC entry 222 (class 1259 OID 16395)
-- Name: stazione; Type: TABLE; Schema: ferrovie; Owner: postgres
--

CREATE TABLE ferrovie.stazione (
    id_stazione integer NOT NULL,
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
-- TOC entry 221 (class 1259 OID 16394)
-- Name: stazione_id_stazione_seq; Type: SEQUENCE; Schema: ferrovie; Owner: postgres
--

CREATE SEQUENCE ferrovie.stazione_id_stazione_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ferrovie.stazione_id_stazione_seq OWNER TO postgres;

--
-- TOC entry 5244 (class 0 OID 0)
-- Dependencies: 221
-- Name: stazione_id_stazione_seq; Type: SEQUENCE OWNED BY; Schema: ferrovie; Owner: postgres
--

ALTER SEQUENCE ferrovie.stazione_id_stazione_seq OWNED BY ferrovie.stazione.id_stazione;


--
-- TOC entry 234 (class 1259 OID 16497)
-- Name: tariffa; Type: TABLE; Schema: ferrovie; Owner: postgres
--

CREATE TABLE ferrovie.tariffa (
    id_tariffa integer NOT NULL,
    nome character varying(50) NOT NULL,
    condizioni text
);


ALTER TABLE ferrovie.tariffa OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 16496)
-- Name: tariffa_id_tariffa_seq; Type: SEQUENCE; Schema: ferrovie; Owner: postgres
--

CREATE SEQUENCE ferrovie.tariffa_id_tariffa_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ferrovie.tariffa_id_tariffa_seq OWNER TO postgres;

--
-- TOC entry 5245 (class 0 OID 0)
-- Dependencies: 233
-- Name: tariffa_id_tariffa_seq; Type: SEQUENCE OWNED BY; Schema: ferrovie; Owner: postgres
--

ALTER SEQUENCE ferrovie.tariffa_id_tariffa_seq OWNED BY ferrovie.tariffa.id_tariffa;


--
-- TOC entry 226 (class 1259 OID 16420)
-- Name: tratta; Type: TABLE; Schema: ferrovie; Owner: postgres
--

CREATE TABLE ferrovie.tratta (
    id_tratta integer NOT NULL,
    id_linea integer NOT NULL,
    id_stazione_partenza integer NOT NULL,
    id_stazione_arrivo integer NOT NULL,
    ordine integer NOT NULL,
    distanza_km numeric(7,2),
    CONSTRAINT tratta_check CHECK ((id_stazione_partenza <> id_stazione_arrivo))
);


ALTER TABLE ferrovie.tratta OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 16419)
-- Name: tratta_id_tratta_seq; Type: SEQUENCE; Schema: ferrovie; Owner: postgres
--

CREATE SEQUENCE ferrovie.tratta_id_tratta_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ferrovie.tratta_id_tratta_seq OWNER TO postgres;

--
-- TOC entry 5246 (class 0 OID 0)
-- Dependencies: 225
-- Name: tratta_id_tratta_seq; Type: SEQUENCE OWNED BY; Schema: ferrovie; Owner: postgres
--

ALTER SEQUENCE ferrovie.tratta_id_tratta_seq OWNED BY ferrovie.tratta.id_tratta;


--
-- TOC entry 4968 (class 2604 OID 16608)
-- Name: biglietto id_biglietto; Type: DEFAULT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.biglietto ALTER COLUMN id_biglietto SET DEFAULT nextval('ferrovie.biglietto_id_biglietto_seq'::regclass);


--
-- TOC entry 4965 (class 2604 OID 16513)
-- Name: classe id_classe; Type: DEFAULT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.classe ALTER COLUMN id_classe SET DEFAULT nextval('ferrovie.classe_id_classe_seq'::regclass);


--
-- TOC entry 4955 (class 2604 OID 16410)
-- Name: linea id_linea; Type: DEFAULT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.linea ALTER COLUMN id_linea SET DEFAULT nextval('ferrovie.linea_id_linea_seq'::regclass);


--
-- TOC entry 4961 (class 2604 OID 16483)
-- Name: pagamento id_pagamento; Type: DEFAULT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.pagamento ALTER COLUMN id_pagamento SET DEFAULT nextval('ferrovie.pagamento_id_pagamento_seq'::regclass);


--
-- TOC entry 4957 (class 2604 OID 16453)
-- Name: passeggero id_passeggero; Type: DEFAULT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.passeggero ALTER COLUMN id_passeggero SET DEFAULT nextval('ferrovie.passeggero_id_passeggero_seq'::regclass);


--
-- TOC entry 4972 (class 2604 OID 16637)
-- Name: percorso_biglietto id_percorso; Type: DEFAULT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.percorso_biglietto ALTER COLUMN id_percorso SET DEFAULT nextval('ferrovie.percorso_biglietto_id_percorso_seq'::regclass);


--
-- TOC entry 4958 (class 2604 OID 16467)
-- Name: prenotazione id_prenotazione; Type: DEFAULT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.prenotazione ALTER COLUMN id_prenotazione SET DEFAULT nextval('ferrovie.prenotazione_id_prenotazione_seq'::regclass);


--
-- TOC entry 4966 (class 2604 OID 16526)
-- Name: prezzo id_prezzo; Type: DEFAULT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.prezzo ALTER COLUMN id_prezzo SET DEFAULT nextval('ferrovie.prezzo_id_prezzo_seq'::regclass);


--
-- TOC entry 4967 (class 2604 OID 16552)
-- Name: servizio id_servizio; Type: DEFAULT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.servizio ALTER COLUMN id_servizio SET DEFAULT nextval('ferrovie.servizio_id_servizio_seq'::regclass);


--
-- TOC entry 4954 (class 2604 OID 16398)
-- Name: stazione id_stazione; Type: DEFAULT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.stazione ALTER COLUMN id_stazione SET DEFAULT nextval('ferrovie.stazione_id_stazione_seq'::regclass);


--
-- TOC entry 4964 (class 2604 OID 16500)
-- Name: tariffa id_tariffa; Type: DEFAULT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.tariffa ALTER COLUMN id_tariffa SET DEFAULT nextval('ferrovie.tariffa_id_tariffa_seq'::regclass);


--
-- TOC entry 4956 (class 2604 OID 16423)
-- Name: tratta id_tratta; Type: DEFAULT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.tratta ALTER COLUMN id_tratta SET DEFAULT nextval('ferrovie.tratta_id_tratta_seq'::regclass);


--
-- TOC entry 5225 (class 0 OID 16605)
-- Dependencies: 242
-- Data for Name: biglietto; Type: TABLE DATA; Schema: ferrovie; Owner: postgres
--

COPY ferrovie.biglietto (id_biglietto, id_prenotazione, codice_qr, id_tariffa, id_classe, prezzo_totale, stato, ts_emissione) FROM stdin;
1	1	7dff67cb-8189-4e19-8c89-a4c16cfdeb12	1	1	15.00	valido	2025-11-10 17:54:39.555295
\.


--
-- TOC entry 5219 (class 0 OID 16510)
-- Dependencies: 236
-- Data for Name: classe; Type: TABLE DATA; Schema: ferrovie; Owner: postgres
--

COPY ferrovie.classe (id_classe, nome, descrizione) FROM stdin;
1	Standard	Seconda classe
\.


--
-- TOC entry 5228 (class 0 OID 16662)
-- Dependencies: 245
-- Data for Name: dettaglio_prezzo_biglietto; Type: TABLE DATA; Schema: ferrovie; Owner: postgres
--

COPY ferrovie.dettaglio_prezzo_biglietto (id_biglietto, id_percorso, id_prezzo, importo_applicato) FROM stdin;
1	1	1	7.50
1	2	2	7.50
\.


--
-- TOC entry 5207 (class 0 OID 16407)
-- Dependencies: 224
-- Data for Name: linea; Type: TABLE DATA; Schema: ferrovie; Owner: postgres
--

COPY ferrovie.linea (id_linea, nome_linea, descrizione) FROM stdin;
1	Linea Bologna–Piacenza	\N
\.


--
-- TOC entry 5215 (class 0 OID 16480)
-- Dependencies: 232
-- Data for Name: pagamento; Type: TABLE DATA; Schema: ferrovie; Owner: postgres
--

COPY ferrovie.pagamento (id_pagamento, id_prenotazione, metodo, importo, valuta, esito, ts_pagamento) FROM stdin;
1	1	carta	15.00	EUR	ok	2025-11-10 17:54:39.522978
\.


--
-- TOC entry 5211 (class 0 OID 16450)
-- Dependencies: 228
-- Data for Name: passeggero; Type: TABLE DATA; Schema: ferrovie; Owner: postgres
--

COPY ferrovie.passeggero (id_passeggero, codice_fiscale, nome, cognome, email, telefono) FROM stdin;
1	RSSMRA80A01H501U	Mario	Rossi	mario.rossi@example.com	\N
\.


--
-- TOC entry 5227 (class 0 OID 16634)
-- Dependencies: 244
-- Data for Name: percorso_biglietto; Type: TABLE DATA; Schema: ferrovie; Owner: postgres
--

COPY ferrovie.percorso_biglietto (id_percorso, id_biglietto, id_servizio, id_stazione_salita, id_stazione_discesa) FROM stdin;
1	1	1	1	2
2	1	1	2	3
\.


--
-- TOC entry 5213 (class 0 OID 16464)
-- Dependencies: 230
-- Data for Name: prenotazione; Type: TABLE DATA; Schema: ferrovie; Owner: postgres
--

COPY ferrovie.prenotazione (id_prenotazione, id_passeggero, ts_creazione, stato) FROM stdin;
1	1	2025-11-10 17:54:39.516743	in_attesa
\.


--
-- TOC entry 5221 (class 0 OID 16523)
-- Dependencies: 238
-- Data for Name: prezzo; Type: TABLE DATA; Schema: ferrovie; Owner: postgres
--

COPY ferrovie.prezzo (id_prezzo, id_tariffa, id_classe, id_tratta, importo, valid_from, valid_to) FROM stdin;
1	1	1	1	7.50	2025-01-01	\N
2	1	1	2	7.50	2025-01-01	\N
3	1	1	3	7.50	2025-01-01	\N
4	1	1	4	7.50	2025-01-01	\N
\.


--
-- TOC entry 5223 (class 0 OID 16549)
-- Dependencies: 240
-- Data for Name: servizio; Type: TABLE DATA; Schema: ferrovie; Owner: postgres
--

COPY ferrovie.servizio (id_servizio, id_linea, codice_treno, data_partenza, ora_partenza, ora_arrivo, stato) FROM stdin;
1	1	R1234	2025-11-10	08:05:00	10:05:00	programmato
\.


--
-- TOC entry 5205 (class 0 OID 16395)
-- Dependencies: 222
-- Data for Name: stazione; Type: TABLE DATA; Schema: ferrovie; Owner: postgres
--

COPY ferrovie.stazione (id_stazione, codice, nome, citta, provincia, nazione, latitudine, longitudine) FROM stdin;
1	BOC	Bologna Centrale	Bologna	\N	\N	\N	\N
2	MOD	Modena	Modena	\N	\N	\N	\N
3	REG	Reggio Emilia	Reggio Emilia	\N	\N	\N	\N
4	PAR	Parma	Parma	\N	\N	\N	\N
5	PC	Piacenza	Piacenza	\N	\N	\N	\N
\.


--
-- TOC entry 5217 (class 0 OID 16497)
-- Dependencies: 234
-- Data for Name: tariffa; Type: TABLE DATA; Schema: ferrovie; Owner: postgres
--

COPY ferrovie.tariffa (id_tariffa, nome, condizioni) FROM stdin;
1	Base	Rimborsabile parziale
\.


--
-- TOC entry 5209 (class 0 OID 16420)
-- Dependencies: 226
-- Data for Name: tratta; Type: TABLE DATA; Schema: ferrovie; Owner: postgres
--

COPY ferrovie.tratta (id_tratta, id_linea, id_stazione_partenza, id_stazione_arrivo, ordine, distanza_km) FROM stdin;
1	1	1	2	1	38.00
2	1	2	3	2	37.50
3	1	3	4	3	29.00
4	1	4	5	4	66.00
\.


--
-- TOC entry 5247 (class 0 OID 0)
-- Dependencies: 241
-- Name: biglietto_id_biglietto_seq; Type: SEQUENCE SET; Schema: ferrovie; Owner: postgres
--

SELECT pg_catalog.setval('ferrovie.biglietto_id_biglietto_seq', 1, true);


--
-- TOC entry 5248 (class 0 OID 0)
-- Dependencies: 235
-- Name: classe_id_classe_seq; Type: SEQUENCE SET; Schema: ferrovie; Owner: postgres
--

SELECT pg_catalog.setval('ferrovie.classe_id_classe_seq', 1, true);


--
-- TOC entry 5249 (class 0 OID 0)
-- Dependencies: 223
-- Name: linea_id_linea_seq; Type: SEQUENCE SET; Schema: ferrovie; Owner: postgres
--

SELECT pg_catalog.setval('ferrovie.linea_id_linea_seq', 1, true);


--
-- TOC entry 5250 (class 0 OID 0)
-- Dependencies: 231
-- Name: pagamento_id_pagamento_seq; Type: SEQUENCE SET; Schema: ferrovie; Owner: postgres
--

SELECT pg_catalog.setval('ferrovie.pagamento_id_pagamento_seq', 1, true);


--
-- TOC entry 5251 (class 0 OID 0)
-- Dependencies: 227
-- Name: passeggero_id_passeggero_seq; Type: SEQUENCE SET; Schema: ferrovie; Owner: postgres
--

SELECT pg_catalog.setval('ferrovie.passeggero_id_passeggero_seq', 1, true);


--
-- TOC entry 5252 (class 0 OID 0)
-- Dependencies: 243
-- Name: percorso_biglietto_id_percorso_seq; Type: SEQUENCE SET; Schema: ferrovie; Owner: postgres
--

SELECT pg_catalog.setval('ferrovie.percorso_biglietto_id_percorso_seq', 2, true);


--
-- TOC entry 5253 (class 0 OID 0)
-- Dependencies: 229
-- Name: prenotazione_id_prenotazione_seq; Type: SEQUENCE SET; Schema: ferrovie; Owner: postgres
--

SELECT pg_catalog.setval('ferrovie.prenotazione_id_prenotazione_seq', 1, true);


--
-- TOC entry 5254 (class 0 OID 0)
-- Dependencies: 237
-- Name: prezzo_id_prezzo_seq; Type: SEQUENCE SET; Schema: ferrovie; Owner: postgres
--

SELECT pg_catalog.setval('ferrovie.prezzo_id_prezzo_seq', 4, true);


--
-- TOC entry 5255 (class 0 OID 0)
-- Dependencies: 239
-- Name: servizio_id_servizio_seq; Type: SEQUENCE SET; Schema: ferrovie; Owner: postgres
--

SELECT pg_catalog.setval('ferrovie.servizio_id_servizio_seq', 1, true);


--
-- TOC entry 5256 (class 0 OID 0)
-- Dependencies: 221
-- Name: stazione_id_stazione_seq; Type: SEQUENCE SET; Schema: ferrovie; Owner: postgres
--

SELECT pg_catalog.setval('ferrovie.stazione_id_stazione_seq', 5, true);


--
-- TOC entry 5257 (class 0 OID 0)
-- Dependencies: 233
-- Name: tariffa_id_tariffa_seq; Type: SEQUENCE SET; Schema: ferrovie; Owner: postgres
--

SELECT pg_catalog.setval('ferrovie.tariffa_id_tariffa_seq', 1, true);


--
-- TOC entry 5258 (class 0 OID 0)
-- Dependencies: 225
-- Name: tratta_id_tratta_seq; Type: SEQUENCE SET; Schema: ferrovie; Owner: postgres
--

SELECT pg_catalog.setval('ferrovie.tratta_id_tratta_seq', 4, true);


--
-- TOC entry 5025 (class 2606 OID 16617)
-- Name: biglietto biglietto_codice_qr_key; Type: CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.biglietto
    ADD CONSTRAINT biglietto_codice_qr_key UNIQUE (codice_qr);


--
-- TOC entry 5027 (class 2606 OID 16615)
-- Name: biglietto biglietto_pkey; Type: CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.biglietto
    ADD CONSTRAINT biglietto_pkey PRIMARY KEY (id_biglietto);


--
-- TOC entry 5013 (class 2606 OID 16521)
-- Name: classe classe_nome_key; Type: CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.classe
    ADD CONSTRAINT classe_nome_key UNIQUE (nome);


--
-- TOC entry 5015 (class 2606 OID 16519)
-- Name: classe classe_pkey; Type: CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.classe
    ADD CONSTRAINT classe_pkey PRIMARY KEY (id_classe);


--
-- TOC entry 5037 (class 2606 OID 16669)
-- Name: dettaglio_prezzo_biglietto dettaglio_prezzo_biglietto_pkey; Type: CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.dettaglio_prezzo_biglietto
    ADD CONSTRAINT dettaglio_prezzo_biglietto_pkey PRIMARY KEY (id_biglietto, id_percorso);


--
-- TOC entry 4987 (class 2606 OID 16418)
-- Name: linea linea_nome_linea_key; Type: CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.linea
    ADD CONSTRAINT linea_nome_linea_key UNIQUE (nome_linea);


--
-- TOC entry 4989 (class 2606 OID 16416)
-- Name: linea linea_pkey; Type: CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.linea
    ADD CONSTRAINT linea_pkey PRIMARY KEY (id_linea);


--
-- TOC entry 5007 (class 2606 OID 16490)
-- Name: pagamento pagamento_pkey; Type: CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.pagamento
    ADD CONSTRAINT pagamento_pkey PRIMARY KEY (id_pagamento);


--
-- TOC entry 4997 (class 2606 OID 16460)
-- Name: passeggero passeggero_codice_fiscale_key; Type: CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.passeggero
    ADD CONSTRAINT passeggero_codice_fiscale_key UNIQUE (codice_fiscale);


--
-- TOC entry 4999 (class 2606 OID 16462)
-- Name: passeggero passeggero_email_key; Type: CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.passeggero
    ADD CONSTRAINT passeggero_email_key UNIQUE (email);


--
-- TOC entry 5001 (class 2606 OID 16458)
-- Name: passeggero passeggero_pkey; Type: CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.passeggero
    ADD CONSTRAINT passeggero_pkey PRIMARY KEY (id_passeggero);


--
-- TOC entry 5035 (class 2606 OID 16641)
-- Name: percorso_biglietto percorso_biglietto_pkey; Type: CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.percorso_biglietto
    ADD CONSTRAINT percorso_biglietto_pkey PRIMARY KEY (id_percorso);


--
-- TOC entry 5004 (class 2606 OID 16473)
-- Name: prenotazione prenotazione_pkey; Type: CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.prenotazione
    ADD CONSTRAINT prenotazione_pkey PRIMARY KEY (id_prenotazione);


--
-- TOC entry 5018 (class 2606 OID 16532)
-- Name: prezzo prezzo_pkey; Type: CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.prezzo
    ADD CONSTRAINT prezzo_pkey PRIMARY KEY (id_prezzo);


--
-- TOC entry 5020 (class 2606 OID 16560)
-- Name: servizio servizio_codice_treno_data_partenza_key; Type: CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.servizio
    ADD CONSTRAINT servizio_codice_treno_data_partenza_key UNIQUE (codice_treno, data_partenza);


--
-- TOC entry 5022 (class 2606 OID 16558)
-- Name: servizio servizio_pkey; Type: CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.servizio
    ADD CONSTRAINT servizio_pkey PRIMARY KEY (id_servizio);


--
-- TOC entry 4982 (class 2606 OID 16405)
-- Name: stazione stazione_codice_key; Type: CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.stazione
    ADD CONSTRAINT stazione_codice_key UNIQUE (codice);


--
-- TOC entry 4984 (class 2606 OID 16403)
-- Name: stazione stazione_pkey; Type: CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.stazione
    ADD CONSTRAINT stazione_pkey PRIMARY KEY (id_stazione);


--
-- TOC entry 5009 (class 2606 OID 16508)
-- Name: tariffa tariffa_nome_key; Type: CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.tariffa
    ADD CONSTRAINT tariffa_nome_key UNIQUE (nome);


--
-- TOC entry 5011 (class 2606 OID 16506)
-- Name: tariffa tariffa_pkey; Type: CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.tariffa
    ADD CONSTRAINT tariffa_pkey PRIMARY KEY (id_tariffa);


--
-- TOC entry 4992 (class 2606 OID 16433)
-- Name: tratta tratta_id_linea_ordine_key; Type: CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.tratta
    ADD CONSTRAINT tratta_id_linea_ordine_key UNIQUE (id_linea, ordine);


--
-- TOC entry 4994 (class 2606 OID 16431)
-- Name: tratta tratta_pkey; Type: CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.tratta
    ADD CONSTRAINT tratta_pkey PRIMARY KEY (id_tratta);


--
-- TOC entry 5028 (class 1259 OID 16691)
-- Name: idx_biglietto_prenotazione; Type: INDEX; Schema: ferrovie; Owner: postgres
--

CREATE INDEX idx_biglietto_prenotazione ON ferrovie.biglietto USING btree (id_prenotazione);


--
-- TOC entry 5029 (class 1259 OID 16692)
-- Name: idx_biglietto_stato_data; Type: INDEX; Schema: ferrovie; Owner: postgres
--

CREATE INDEX idx_biglietto_stato_data ON ferrovie.biglietto USING btree (stato, ts_emissione DESC);


--
-- TOC entry 5030 (class 1259 OID 16693)
-- Name: idx_biglietto_validi_parziale; Type: INDEX; Schema: ferrovie; Owner: postgres
--

CREATE INDEX idx_biglietto_validi_parziale ON ferrovie.biglietto USING btree (ts_emissione DESC) WHERE ((stato)::text = 'valido'::text);


--
-- TOC entry 5005 (class 1259 OID 16690)
-- Name: idx_pagamento_pren_esito; Type: INDEX; Schema: ferrovie; Owner: postgres
--

CREATE INDEX idx_pagamento_pren_esito ON ferrovie.pagamento USING btree (id_prenotazione, esito, ts_pagamento DESC);


--
-- TOC entry 5031 (class 1259 OID 16694)
-- Name: idx_pb_biglietto; Type: INDEX; Schema: ferrovie; Owner: postgres
--

CREATE INDEX idx_pb_biglietto ON ferrovie.percorso_biglietto USING btree (id_biglietto);


--
-- TOC entry 5032 (class 1259 OID 16695)
-- Name: idx_pb_servizio; Type: INDEX; Schema: ferrovie; Owner: postgres
--

CREATE INDEX idx_pb_servizio ON ferrovie.percorso_biglietto USING btree (id_servizio);


--
-- TOC entry 5033 (class 1259 OID 16696)
-- Name: idx_pb_servizio_tratta; Type: INDEX; Schema: ferrovie; Owner: postgres
--

CREATE INDEX idx_pb_servizio_tratta ON ferrovie.percorso_biglietto USING btree (id_servizio, id_stazione_salita, id_stazione_discesa);


--
-- TOC entry 5002 (class 1259 OID 16689)
-- Name: idx_prenotazione_pax_data; Type: INDEX; Schema: ferrovie; Owner: postgres
--

CREATE INDEX idx_prenotazione_pax_data ON ferrovie.prenotazione USING btree (id_passeggero, ts_creazione DESC);


--
-- TOC entry 5016 (class 1259 OID 16697)
-- Name: idx_prezzo_tripla_from; Type: INDEX; Schema: ferrovie; Owner: postgres
--

CREATE INDEX idx_prezzo_tripla_from ON ferrovie.prezzo USING btree (id_tariffa, id_classe, id_tratta, valid_from DESC);


--
-- TOC entry 4990 (class 1259 OID 16686)
-- Name: ux_linea_nome; Type: INDEX; Schema: ferrovie; Owner: postgres
--

CREATE UNIQUE INDEX ux_linea_nome ON ferrovie.linea USING btree (nome_linea);


--
-- TOC entry 5023 (class 1259 OID 16688)
-- Name: ux_servizio_treno_data; Type: INDEX; Schema: ferrovie; Owner: postgres
--

CREATE UNIQUE INDEX ux_servizio_treno_data ON ferrovie.servizio USING btree (codice_treno, data_partenza);


--
-- TOC entry 4985 (class 1259 OID 16685)
-- Name: ux_stazione_codice; Type: INDEX; Schema: ferrovie; Owner: postgres
--

CREATE UNIQUE INDEX ux_stazione_codice ON ferrovie.stazione USING btree (codice);


--
-- TOC entry 4995 (class 1259 OID 16687)
-- Name: ux_tratta_linea_ordine; Type: INDEX; Schema: ferrovie; Owner: postgres
--

CREATE UNIQUE INDEX ux_tratta_linea_ordine ON ferrovie.tratta USING btree (id_linea, ordine);


--
-- TOC entry 5047 (class 2606 OID 16628)
-- Name: biglietto biglietto_id_classe_fkey; Type: FK CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.biglietto
    ADD CONSTRAINT biglietto_id_classe_fkey FOREIGN KEY (id_classe) REFERENCES ferrovie.classe(id_classe);


--
-- TOC entry 5048 (class 2606 OID 16618)
-- Name: biglietto biglietto_id_prenotazione_fkey; Type: FK CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.biglietto
    ADD CONSTRAINT biglietto_id_prenotazione_fkey FOREIGN KEY (id_prenotazione) REFERENCES ferrovie.prenotazione(id_prenotazione);


--
-- TOC entry 5049 (class 2606 OID 16623)
-- Name: biglietto biglietto_id_tariffa_fkey; Type: FK CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.biglietto
    ADD CONSTRAINT biglietto_id_tariffa_fkey FOREIGN KEY (id_tariffa) REFERENCES ferrovie.tariffa(id_tariffa);


--
-- TOC entry 5054 (class 2606 OID 16670)
-- Name: dettaglio_prezzo_biglietto dettaglio_prezzo_biglietto_id_biglietto_fkey; Type: FK CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.dettaglio_prezzo_biglietto
    ADD CONSTRAINT dettaglio_prezzo_biglietto_id_biglietto_fkey FOREIGN KEY (id_biglietto) REFERENCES ferrovie.biglietto(id_biglietto) ON DELETE CASCADE;


--
-- TOC entry 5055 (class 2606 OID 16675)
-- Name: dettaglio_prezzo_biglietto dettaglio_prezzo_biglietto_id_percorso_fkey; Type: FK CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.dettaglio_prezzo_biglietto
    ADD CONSTRAINT dettaglio_prezzo_biglietto_id_percorso_fkey FOREIGN KEY (id_percorso) REFERENCES ferrovie.percorso_biglietto(id_percorso) ON DELETE CASCADE;


--
-- TOC entry 5056 (class 2606 OID 16680)
-- Name: dettaglio_prezzo_biglietto dettaglio_prezzo_biglietto_id_prezzo_fkey; Type: FK CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.dettaglio_prezzo_biglietto
    ADD CONSTRAINT dettaglio_prezzo_biglietto_id_prezzo_fkey FOREIGN KEY (id_prezzo) REFERENCES ferrovie.prezzo(id_prezzo);


--
-- TOC entry 5042 (class 2606 OID 16491)
-- Name: pagamento pagamento_id_prenotazione_fkey; Type: FK CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.pagamento
    ADD CONSTRAINT pagamento_id_prenotazione_fkey FOREIGN KEY (id_prenotazione) REFERENCES ferrovie.prenotazione(id_prenotazione);


--
-- TOC entry 5050 (class 2606 OID 16642)
-- Name: percorso_biglietto percorso_biglietto_id_biglietto_fkey; Type: FK CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.percorso_biglietto
    ADD CONSTRAINT percorso_biglietto_id_biglietto_fkey FOREIGN KEY (id_biglietto) REFERENCES ferrovie.biglietto(id_biglietto);


--
-- TOC entry 5051 (class 2606 OID 16647)
-- Name: percorso_biglietto percorso_biglietto_id_servizio_fkey; Type: FK CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.percorso_biglietto
    ADD CONSTRAINT percorso_biglietto_id_servizio_fkey FOREIGN KEY (id_servizio) REFERENCES ferrovie.servizio(id_servizio);


--
-- TOC entry 5052 (class 2606 OID 16657)
-- Name: percorso_biglietto percorso_biglietto_id_stazione_discesa_fkey; Type: FK CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.percorso_biglietto
    ADD CONSTRAINT percorso_biglietto_id_stazione_discesa_fkey FOREIGN KEY (id_stazione_discesa) REFERENCES ferrovie.stazione(id_stazione);


--
-- TOC entry 5053 (class 2606 OID 16652)
-- Name: percorso_biglietto percorso_biglietto_id_stazione_salita_fkey; Type: FK CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.percorso_biglietto
    ADD CONSTRAINT percorso_biglietto_id_stazione_salita_fkey FOREIGN KEY (id_stazione_salita) REFERENCES ferrovie.stazione(id_stazione);


--
-- TOC entry 5041 (class 2606 OID 16474)
-- Name: prenotazione prenotazione_id_passeggero_fkey; Type: FK CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.prenotazione
    ADD CONSTRAINT prenotazione_id_passeggero_fkey FOREIGN KEY (id_passeggero) REFERENCES ferrovie.passeggero(id_passeggero);


--
-- TOC entry 5043 (class 2606 OID 16538)
-- Name: prezzo prezzo_id_classe_fkey; Type: FK CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.prezzo
    ADD CONSTRAINT prezzo_id_classe_fkey FOREIGN KEY (id_classe) REFERENCES ferrovie.classe(id_classe);


--
-- TOC entry 5044 (class 2606 OID 16533)
-- Name: prezzo prezzo_id_tariffa_fkey; Type: FK CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.prezzo
    ADD CONSTRAINT prezzo_id_tariffa_fkey FOREIGN KEY (id_tariffa) REFERENCES ferrovie.tariffa(id_tariffa);


--
-- TOC entry 5045 (class 2606 OID 16543)
-- Name: prezzo prezzo_id_tratta_fkey; Type: FK CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.prezzo
    ADD CONSTRAINT prezzo_id_tratta_fkey FOREIGN KEY (id_tratta) REFERENCES ferrovie.tratta(id_tratta);


--
-- TOC entry 5046 (class 2606 OID 16561)
-- Name: servizio servizio_id_linea_fkey; Type: FK CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.servizio
    ADD CONSTRAINT servizio_id_linea_fkey FOREIGN KEY (id_linea) REFERENCES ferrovie.linea(id_linea);


--
-- TOC entry 5038 (class 2606 OID 16434)
-- Name: tratta tratta_id_linea_fkey; Type: FK CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.tratta
    ADD CONSTRAINT tratta_id_linea_fkey FOREIGN KEY (id_linea) REFERENCES ferrovie.linea(id_linea);


--
-- TOC entry 5039 (class 2606 OID 16444)
-- Name: tratta tratta_id_stazione_arrivo_fkey; Type: FK CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.tratta
    ADD CONSTRAINT tratta_id_stazione_arrivo_fkey FOREIGN KEY (id_stazione_arrivo) REFERENCES ferrovie.stazione(id_stazione);


--
-- TOC entry 5040 (class 2606 OID 16439)
-- Name: tratta tratta_id_stazione_partenza_fkey; Type: FK CONSTRAINT; Schema: ferrovie; Owner: postgres
--

ALTER TABLE ONLY ferrovie.tratta
    ADD CONSTRAINT tratta_id_stazione_partenza_fkey FOREIGN KEY (id_stazione_partenza) REFERENCES ferrovie.stazione(id_stazione);


-- Completed on 2025-11-10 18:31:56

--
-- PostgreSQL database dump complete
--

\unrestrict sFXsGXyjsiWyA3jdLf8DsHWcgCLPeJtqj9p9mmLAb0E4mL6pqUkhKLIMUqmrLjV

