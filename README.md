          Project Work – Schema di Persistenza Dati per Biglietteria Ferroviaria

Questo repository contiene il dump completo del database relazionale progettato per il Project Work del corso di laurea in Informatica per le Aziende Digitali – Università Telematica Pegaso.

L’obiettivo del progetto è la modellazione e implementazione di uno schema di persistenza dati a supporto del processo di bigliettazione ferroviaria digitale, ispirato al dominio reale.

          Contenuti del repository

ferrovie_dump.sql → dump PostgreSQL completo
Include:

definizione dello schema logico (DDL)

tabelle, chiavi primarie ed esterne, vincoli CHECK/UNIQUE

dati di esempio (DML)

indici e query dimostrative

          Ambiente di esecuzione

DBMS: PostgreSQL ≥ 15

Schema: ferrovie

File principale: ferrovie_dump.sql


Per creare il database:

psql -U postgres -f ferrovie_dump.sql

          Struttura logica

Le principali entità del modello includono:

stazione, linea, tratta, servizio (infrastruttura ed esercizio)

passeggero, prenotazione, pagamento, biglietto

tariffa, classe, prezzo (gestione commerciale)

percorso_biglietto, validazione, cambio, rimborso (processi post-vendita)


          Descrizione sintetica

Il modello rispetta i principi di normalizzazione (1NF–3NF), integra vincoli di integrità referenziale e adotta strategie di ottimizzazione (indici B-tree, chiavi composite, partizionamento temporale).
Le query dimostrative permettono di validare i processi principali: ricerca servizi, storico cliente, verifica biglietto e calcolo tariffe.


          Risorse utili

  Dump completo: ferrovie_dump.sql

  Autore: Giacomo Lentini

  Università: UniPegaso – Informatica per le Aziende Digitali

  Anno accademico: 2024–2025
