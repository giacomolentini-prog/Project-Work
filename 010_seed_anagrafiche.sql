-- =========================================================
-- 010_seed_anagrafiche.sql
-- Anagrafiche base (rete + commerciale)
-- =========================================================
SET search_path TO ferrovie, public;

-- Linea
INSERT INTO linea(nome_linea, descrizione)
VALUES ('Linea Demo', 'Linea dimostrativa per scenari di test')
ON CONFLICT (nome_linea) DO NOTHING;

-- Stazioni
INSERT INTO stazione(codice, nome, citta) VALUES
('STA','Stazione A','Città A'),
('STB','Stazione B','Città B'),
('STC','Stazione C','Città C'),
('STD','Stazione D','Città D')
ON CONFLICT (codice) DO NOTHING;

-- Tratte A->B->C->D (ordine 1..3)
WITH l AS (SELECT id_linea FROM linea WHERE nome_linea='Linea Demo'),
     a AS (SELECT id_stazione AS id FROM stazione WHERE codice='STA'),
     b AS (SELECT id_stazione AS id FROM stazione WHERE codice='STB'),
     c AS (SELECT id_stazione AS id FROM stazione WHERE codice='STC'),
     d AS (SELECT id_stazione AS id FROM stazione WHERE codice='STD')
INSERT INTO tratta(id_linea,id_stazione_partenza,id_stazione_arrivo,ordine,distanza_km)
SELECT l.id_linea, a.id, b.id, 1, 50 FROM l,a,b
UNION ALL
SELECT l.id_linea, b.id, c.id, 2, 40 FROM l,b,c
UNION ALL
SELECT l.id_linea, c.id, d.id, 3, 60 FROM l,c,d
ON CONFLICT DO NOTHING;

-- Tariffe / Classi
INSERT INTO tariffa(nome, condizioni) VALUES
('Base','Tariffa base'), ('Flex','Modificabile'), ('Promo','Restrizioni')
ON CONFLICT (nome) DO NOTHING;

INSERT INTO classe(nome, descrizione) VALUES
('1A','Prima classe'), ('2A','Seconda classe')
ON CONFLICT (nome) DO NOTHING;

-- Prezzi correnti (valid_to NULL) per classe 2A, tariffa Base
WITH t AS (SELECT id_tariffa FROM tariffa WHERE nome='Base'),
     c AS (SELECT id_classe  FROM classe  WHERE nome='2A')
INSERT INTO prezzo(id_tariffa,id_classe,id_tratta,importo,valuta,valid_from,valid_to)
SELECT (SELECT id_tariffa FROM t), (SELECT id_classe FROM c), tr.id_tratta,
       CASE tr.ordine WHEN 1 THEN 12.00 WHEN 2 THEN 10.00 WHEN 3 THEN 15.00 END,
       'EUR', CURRENT_DATE, NULL
FROM tratta tr
ON CONFLICT (id_tariffa,id_classe,id_tratta,valid_from) DO NOTHING;
