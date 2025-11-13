          Project Work – Sistema di Biglietteria Ferroviaria

Database relazionale • PostgreSQL • Modellazione ER • Normalizzazione • SQL

          Descrizione del progetto

Questo repository contiene l’implementazione completa del Project Work relativo alla progettazione di uno schema di persistenza dati per un sistema di biglietteria ferroviaria digitale.

Il lavoro segue i requisiti della traccia UniPegaso e comprende:

- modellazione concettuale (ER)

- traduzione in schema logico-relazionale

- applicazione delle forme normali (1NF → 3NF)

- definizione di vincoli, indici e strategie di ottimizzazione

- script SQL completi (DDL, DML, query dimostrative)

- dump del database PostgreSQL

- documentazione tecnica e funzionale

Il progetto modella l’intero ciclo di vita del titolo di viaggio:

Ricerca → Prenotazione → Pagamento → Emissione Biglietto → Percorso Multi-Leg → Validazione → Post-vendita (cambi/rimborsi)

          Struttura del repository
          
Project-Work/
│
├── ferrovie_dump.sql               ← Dump completo del database PostgreSQL
├── README.md                       ← Questo file
│
├── DDL/
│   ├── 001_schema.sql                      ← Creazione schema + tipi + tabelle
│   ├── 003_constraints_indexes.sql         ← PK, FK, UNIQUE, CHECK, EXCLUSION, Indici e ottimizzazioni
│   └── 002_types_enums.sql                 ← Tipi ENUM separati (migliora chiarezza)
│
├── DML/
│   ├── 010_seed_anagrafiche.sql    ← Dati anagrafici (linee, stazioni, tariffe…)
│   └── 020_seed_scenari.sql        ← Scenari di test (servizi, biglietti, percorsi)
│
└── queries/
    └── queries.sql                 ← 5 query richieste dalla traccia


          Requisiti

PostgreSQL 15+

psql oppure pgAdmin 4

Sistema operativo: Windows, macOS o Linux

          Le query permettono di:

Cercare servizi e prezzi disponibili

Visualizzare lo storico prenotazioni

Verificare un biglietto via QR

Generare report vendite

Contare occupazione “logica” dei servizi

          Dump del database 

Il dump completo è disponibile:

📎 ferrovie_dump.sql


          Documentazione tecnica

La documentazione contiene:

- Descrizione situazione-problema

- Obiettivi

- Modellazione concettuale (ER)

- Modellazione logica

- Normalizzazione

- Strategie di indicizzazione

- Query rappresentative

- Appendice SQL


          Autore

Giacomo Lentini
