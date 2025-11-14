-- =========================================================
-- 002_types_enums.sql
-- Tipi ENUM per domini di stato/metodo/esito + ALTER colonne
-- Target DB: biglietteria_db
-- =========================================================

SET search_path TO ferrovie, public;

-- Creazione sicura dei tipi (se non esistono)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'stato_prenotazione') THEN
    CREATE TYPE stato_prenotazione AS ENUM ('in_attesa','confermata','annullata');
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'stato_biglietto') THEN
    CREATE TYPE stato_biglietto AS ENUM ('valido','usato','rimborsato','annullato');
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'stato_servizio') THEN
    CREATE TYPE stato_servizio AS ENUM ('programmato','in_corsa','cancellato','concluso');
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'esito_pagamento') THEN
    CREATE TYPE esito_pagamento AS ENUM ('ok','ko','pendente');
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'metodo_pagamento') THEN
    CREATE TYPE metodo_pagamento AS ENUM ('carta','paypal','satispay','altro');
  END IF;
END$$;

-- Conversione colonne VARCHAR -> ENUM (con cast)
ALTER TABLE ferrovie.prenotazione
  ALTER COLUMN stato TYPE stato_prenotazione USING stato::stato_prenotazione;

ALTER TABLE ferrovie.biglietto
  ALTER COLUMN stato TYPE stato_biglietto USING stato::stato_biglietto;

ALTER TABLE ferrovie.servizio
  ALTER COLUMN stato TYPE stato_servizio USING stato::stato_servizio;

ALTER TABLE ferrovie.pagamento
  ALTER COLUMN esito TYPE esito_pagamento USING esito::esito_pagamento;

ALTER TABLE ferrovie.pagamento
  ALTER COLUMN metodo TYPE metodo_pagamento USING metodo::metodo_pagamento;

-- Valori di default ragionevoli (facoltativi)
ALTER TABLE ferrovie.prenotazione ALTER COLUMN stato SET DEFAULT 'in_attesa';
ALTER TABLE ferrovie.biglietto    ALTER COLUMN stato SET DEFAULT 'valido';
ALTER TABLE ferrovie.servizio     ALTER COLUMN stato SET DEFAULT 'programmato';
ALTER TABLE ferrovie.pagamento    ALTER COLUMN esito  SET DEFAULT 'pendente';
