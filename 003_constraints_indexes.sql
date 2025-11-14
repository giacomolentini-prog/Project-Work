-- =========================================================
-- 003_constraints_indexes.sql
-- Vincoli di integrità, indici e ottimizzazioni (PostgreSQL)
-- Target DB: biglietteria_db
-- =========================================================

SET search_path TO ferrovie, public;

-- =========================
-- 1. VINCOLI DI UNIVOCITÀ / INTEGRITÀ
-- =========================

DO $$
BEGIN
  -- Tratta: ogni linea ha tratte con ordine univoco
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'ux_tratta_linea_ordine'
  ) THEN
    ALTER TABLE tratta
      ADD CONSTRAINT ux_tratta_linea_ordine UNIQUE (id_linea, ordine);
  END IF;

  -- Servizio: ogni treno in una data è unico
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'ux_servizio_treno_data'
  ) THEN
    ALTER TABLE servizio
      ADD CONSTRAINT ux_servizio_treno_data UNIQUE (codice_treno, data_partenza);
  END IF;

  -- Prezzo: chiave logica di validità temporale
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'ux_prezzo_tripla_from'
  ) THEN
    ALTER TABLE prezzo
      ADD CONSTRAINT ux_prezzo_tripla_from UNIQUE (id_tariffa, id_classe, id_tratta, valid_from);
  END IF;

  -- Percorso biglietto: prevenzione overbooking (fix #1)
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'ux_posto_servizio_unico'
  ) THEN
    ALTER TABLE percorso_biglietto
      ADD CONSTRAINT ux_posto_servizio_unico UNIQUE (id_servizio, id_stazione_salita, id_stazione_discesa, id_biglietto);
  END IF;
END$$;

-- =========================
-- 2. VINCOLI DI INTEGRITÀ REFERENZIALE
-- =========================

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'fk_biglietto_prenotazione'
  ) THEN
    ALTER TABLE biglietto
      ADD CONSTRAINT fk_biglietto_prenotazione
      FOREIGN KEY (id_prenotazione) REFERENCES prenotazione(id_prenotazione)
      ON DELETE CASCADE;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'fk_pagamento_prenotazione'
  ) THEN
    ALTER TABLE pagamento
      ADD CONSTRAINT fk_pagamento_prenotazione
      FOREIGN KEY (id_prenotazione) REFERENCES prenotazione(id_prenotazione)
      ON DELETE CASCADE;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'fk_percorso_biglietto'
  ) THEN
    ALTER TABLE percorso_biglietto
      ADD CONSTRAINT fk_percorso_biglietto
      FOREIGN KEY (id_biglietto) REFERENCES biglietto(id_biglietto)
      ON DELETE CASCADE;
  END IF;
END$$;

-- =========================
-- 3. INDICI OPERATIVI
-- =========================

-- Ricerche su stazioni e linee
CREATE UNIQUE INDEX IF NOT EXISTS idx_stazione_codice ON stazione(codice);
CREATE INDEX IF NOT EXISTS idx_stazione_nome ON stazione(nome);
CREATE INDEX IF NOT EXISTS idx_linea_nome ON linea(nome_linea);

-- Servizi e tratte
CREATE INDEX IF NOT EXISTS idx_servizio_linea_data_ora ON servizio(id_linea, data_partenza, ora_partenza);
CREATE INDEX IF NOT EXISTS idx_tratta_partenza_arrivo ON tratta(id_stazione_partenza, id_stazione_arrivo);

-- Prenotazioni e pagamenti
CREATE INDEX IF NOT EXISTS idx_prenotazione_passeggero_data ON prenotazione(id_passeggero, ts_creazione DESC);
CREATE INDEX IF NOT EXISTS idx_pagamento_esito ON pagamento(esito);
CREATE INDEX IF NOT EXISTS idx_pagamento_prenotazione_esito ON pagamento(id_prenotazione, esito, ts_pagamento DESC);

-- Biglietti
CREATE UNIQUE INDEX IF NOT EXISTS idx_biglietto_qr ON biglietto(codice_qr);
CREATE INDEX IF NOT EXISTS idx_biglietto_stato_data ON biglietto(stato, ts_emissione DESC);
CREATE INDEX IF NOT EXISTS idx_biglietto_validi ON biglietto(ts_emissione DESC) WHERE stato = 'valido';

-- Percorso biglietto
CREATE INDEX IF NOT EXISTS idx_pb_biglietto ON percorso_biglietto(id_biglietto);
CREATE INDEX IF NOT EXISTS idx_pb_servizio ON percorso_biglietto(id_servizio);

-- Prezzi
CREATE INDEX IF NOT EXISTS idx_prezzo_corrente 
  ON prezzo(id_tratta, id_classe, id_tariffa)
  WHERE valid_to IS NULL;

-- =========================
-- 4. EXCLUSION CONSTRAINT per overlap prezzi (fix #6)
-- =========================

CREATE EXTENSION IF NOT EXISTS btree_gist;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'ex_prezzo_periodo_non_overlapping'
  ) THEN
    ALTER TABLE prezzo
      ADD CONSTRAINT ex_prezzo_periodo_non_overlapping
      EXCLUDE USING gist (
        id_tariffa WITH =,
        id_classe WITH =,
        id_tratta WITH =,
        daterange(valid_from, COALESCE(valid_to, 'infinity'::date), '[]') WITH &&
      );
  END IF;
END$$;

-- =========================
-- 5. TRIGGER DI COERENZA (facoltativo, opzionale)
-- =========================

-- Esempio: impedisce prenotazioni senza pagamento confermato
CREATE OR REPLACE FUNCTION check_pagamento_confermato()
RETURNS TRIGGER AS $$
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
$$ LANGUAGE plpgsql;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger
    WHERE tgname = 'trg_check_pagamento'
  ) THEN
    CREATE TRIGGER trg_check_pagamento
    BEFORE INSERT ON biglietto
    FOR EACH ROW
    EXECUTE FUNCTION check_pagamento_confermato();
  END IF;
END$$;

-- =========================
-- 6. SOFT DELETE (fix #7)
-- =========================

CREATE OR REPLACE FUNCTION prevent_deleted_biglietto()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.deleted_at IS NOT NULL THEN
    RAISE EXCEPTION 'Impossibile aggiornare un biglietto cancellato logicamente';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger
    WHERE tgname = 'trg_deleted_biglietto'
  ) THEN
    CREATE TRIGGER trg_deleted_biglietto
    BEFORE UPDATE ON biglietto
    FOR EACH ROW
    WHEN (OLD.deleted_at IS NOT NULL)
    EXECUTE FUNCTION prevent_deleted_biglietto();
  END IF;
END$$;

