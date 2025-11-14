-- =========================================================
-- 020_seed_scenari.sql
-- Scenari realistici (4)
-- =========================================================
SET search_path TO ferrovie, public;

-- Servizi del giorno
WITH l AS (SELECT id_linea FROM linea WHERE nome_linea='Linea Demo')
INSERT INTO servizio(id_linea,codice_treno,data_partenza,ora_partenza,ora_arrivo,stato)
SELECT l.id_linea,'TR100',CURRENT_DATE,'08:00'::time,'10:00'::time,'programmato'::stato_servizio FROM l
UNION ALL SELECT l.id_linea,'TR200',CURRENT_DATE,'10:30'::time,'12:30'::time,'programmato'::stato_servizio FROM l
UNION ALL SELECT l.id_linea,'TR300',CURRENT_DATE,'17:00'::time,'19:00'::time,'programmato'::stato_servizio FROM l
ON CONFLICT (codice_treno, data_partenza) DO NOTHING;


-- Passeggeri
INSERT INTO passeggero(codice_fiscale,nome,cognome,email,telefono) VALUES
('CFX11111A','Mario','Rossi','mario.rossi@example.com','111'),
('CFX22222B','Luca','Bianchi','luca.bianchi@example.com','222'),
('CFX33333C','Giulia','Verdi','giulia.verdi@example.com','333')
ON CONFLICT (email) DO NOTHING;

-- Comodi alias ID
WITH ids AS (
  SELECT
    (SELECT id_linea FROM linea WHERE nome_linea='Linea Demo') AS id_linea,
    (SELECT id_stazione FROM stazione WHERE codice='STA') AS STA,
    (SELECT id_stazione FROM stazione WHERE codice='STB') AS STB,
    (SELECT id_stazione FROM stazione WHERE codice='STC') AS STC,
    (SELECT id_stazione FROM stazione WHERE codice='STD') AS STD
)
SELECT 1;

-- ================
-- Scenario 1: STA->STB su TR100 (Mario)
-- ================
-- Prenotazione + pagamento OK (trigger richiede pagamento OK per emettere biglietto)
INSERT INTO prenotazione(id_passeggero,stato)
SELECT id_passeggero,'confermata' FROM passeggero WHERE email='mario.rossi@example.com';

INSERT INTO pagamento(id_prenotazione,metodo,importo,esito)
SELECT p.id_prenotazione,'carta',12.00,'ok'
FROM prenotazione p
JOIN passeggero x ON x.id_passeggero=p.id_passeggero AND x.email='mario.rossi@example.com'
ORDER BY p.id_prenotazione DESC LIMIT 1;

INSERT INTO biglietto(id_prenotazione,codice_qr,id_tariffa,id_classe,prezzo_totale,stato)
SELECT p.id_prenotazione,'QR-001',
       (SELECT id_tariffa FROM tariffa WHERE nome='Base'),
       (SELECT id_classe  FROM classe  WHERE nome='2A'),
       12.00,'valido'
FROM prenotazione p
JOIN passeggero x ON x.id_passeggero=p.id_passeggero AND x.email='mario.rossi@example.com'
ORDER BY p.id_prenotazione DESC LIMIT 1;

INSERT INTO percorso_biglietto(id_biglietto,id_servizio,id_stazione_salita,id_stazione_discesa)
SELECT b.id_biglietto, s.id_servizio,
       (SELECT id_stazione FROM stazione WHERE codice='STA'),
       (SELECT id_stazione FROM stazione WHERE codice='STB')
FROM biglietto b
JOIN servizio s ON s.codice_treno='TR100' AND s.data_partenza=CURRENT_DATE
WHERE b.codice_qr='QR-001';

INSERT INTO dettaglio_prezzo_biglietto(id_biglietto,id_percorso,id_prezzo,importo_applicato)
SELECT b.id_biglietto, pb.id_percorso, pr.id_prezzo, 12.00
FROM biglietto b
JOIN percorso_biglietto pb ON pb.id_biglietto=b.id_biglietto
JOIN tratta tr ON tr.id_linea=(SELECT id_linea FROM linea WHERE nome_linea='Linea Demo') AND tr.ordine=1
JOIN prezzo pr ON pr.id_tratta=tr.id_tratta
WHERE b.codice_qr='QR-001'
  AND pr.valid_from<=CURRENT_DATE
  AND (pr.valid_to IS NULL OR pr.valid_to>=CURRENT_DATE)
LIMIT 1;

-- ================
-- Scenario 2: Multi-leg STA->STC (TR100 + TR200) (Luca)
-- ================
INSERT INTO prenotazione(id_passeggero,stato)
SELECT id_passeggero,'confermata' FROM passeggero WHERE email='luca.bianchi@example.com';

INSERT INTO pagamento(id_prenotazione,metodo,importo,esito)
SELECT p.id_prenotazione,'carta',22.00,'ok'
FROM prenotazione p
JOIN passeggero x ON x.id_passeggero=p.id_passeggero AND x.email='luca.bianchi@example.com'
ORDER BY p.id_prenotazione DESC LIMIT 1;

INSERT INTO biglietto(id_prenotazione,codice_qr,id_tariffa,id_classe,prezzo_totale,stato)
SELECT p.id_prenotazione,'QR-002',
       (SELECT id_tariffa FROM tariffa WHERE nome='Base'),
       (SELECT id_classe  FROM classe  WHERE nome='2A'),
       22.00,'valido'
FROM prenotazione p
JOIN passeggero x ON x.id_passeggero=p.id_passeggero AND x.email='luca.bianchi@example.com'
ORDER BY p.id_prenotazione DESC LIMIT 1;

-- Leg1 STA->STB TR100
INSERT INTO percorso_biglietto(id_biglietto,id_servizio,id_stazione_salita,id_stazione_discesa)
SELECT b.id_biglietto, s.id_servizio,
       (SELECT id_stazione FROM stazione WHERE codice='STA'),
       (SELECT id_stazione FROM stazione WHERE codice='STB')
FROM biglietto b
JOIN servizio s ON s.codice_treno='TR100' AND s.data_partenza=CURRENT_DATE
WHERE b.codice_qr='QR-002';

-- Leg2 STB->STC TR200
INSERT INTO percorso_biglietto(id_biglietto,id_servizio,id_stazione_salita,id_stazione_discesa)
SELECT b.id_biglietto, s.id_servizio,
       (SELECT id_stazione FROM stazione WHERE codice='STB'),
       (SELECT id_stazione FROM stazione WHERE codice='STC')
FROM biglietto b
JOIN servizio s ON s.codice_treno='TR200' AND s.data_partenza=CURRENT_DATE
WHERE b.codice_qr='QR-002';

-- Dettaglio prezzi per QR-002: un record per ogni leg
INSERT INTO dettaglio_prezzo_biglietto(id_biglietto, id_percorso, id_prezzo, importo_applicato)
SELECT 
  b.id_biglietto,
  pb.id_percorso,
  pr.id_prezzo,
  pr.importo AS importo_applicato
FROM biglietto b
JOIN percorso_biglietto pb 
  ON pb.id_biglietto = b.id_biglietto
JOIN servizio s 
  ON s.id_servizio = pb.id_servizio
JOIN linea ln 
  ON ln.id_linea = s.id_linea
JOIN tratta tr 
  ON tr.id_linea = ln.id_linea
 AND tr.id_stazione_partenza = pb.id_stazione_salita
 AND tr.id_stazione_arrivo   = pb.id_stazione_discesa
JOIN prezzo pr 
  ON pr.id_tratta = tr.id_tratta
WHERE b.codice_qr = 'QR-002'
  AND pr.valid_from <= CURRENT_DATE
  AND (pr.valid_to IS NULL OR pr.valid_to >= CURRENT_DATE);


-- ================
-- Scenario 3: Rimborso parziale su QR-002
-- ================
INSERT INTO rimborso(id_biglietto, ts_richiesta, importo_rimborsato, esito, motivo)
SELECT id_biglietto, CURRENT_TIMESTAMP, 10.00, 'ok', 'Cliente impossibilitato'
FROM biglietto WHERE codice_qr='QR-002';

UPDATE biglietto SET stato='rimborsato' WHERE codice_qr='QR-002';

-- ================
-- Scenario 4: Cambio + validazione (Giulia STC->STD TR300)
-- ================
INSERT INTO prenotazione(id_passeggero,stato)
SELECT id_passeggero,'confermata' FROM passeggero WHERE email='giulia.verdi@example.com';

INSERT INTO pagamento(id_prenotazione,metodo,importo,esito)
SELECT p.id_prenotazione,'carta',15.00,'ok'
FROM prenotazione p
JOIN passeggero x ON x.id_passeggero=p.id_passeggero AND x.email='giulia.verdi@example.com'
ORDER BY p.id_prenotazione DESC LIMIT 1;

INSERT INTO biglietto(id_prenotazione,codice_qr,id_tariffa,id_classe,prezzo_totale,stato)
SELECT p.id_prenotazione,'QR-003',
       (SELECT id_tariffa FROM tariffa WHERE nome='Base'),
       (SELECT id_classe  FROM classe  WHERE nome='2A'),
       15.00,'valido'
FROM prenotazione p
JOIN passeggero x ON x.id_passeggero=p.id_passeggero AND x.email='giulia.verdi@example.com'
ORDER BY p.id_prenotazione DESC LIMIT 1;

INSERT INTO percorso_biglietto(id_biglietto,id_servizio,id_stazione_salita,id_stazione_discesa)
SELECT b.id_biglietto, s.id_servizio,
       (SELECT id_stazione FROM stazione WHERE codice='STC'),
       (SELECT id_stazione FROM stazione WHERE codice='STD')
FROM biglietto b
JOIN servizio s ON s.codice_treno='TR300' AND s.data_partenza=CURRENT_DATE
WHERE b.codice_qr='QR-003';

INSERT INTO cambio(id_biglietto, ts_richiesta, motivo, esito, penale, diff_prezzo)
SELECT id_biglietto, CURRENT_TIMESTAMP, 'Cambio corsa', 'ok', 2.00, 3.00
FROM biglietto WHERE codice_qr='QR-003';

INSERT INTO validazione(id_biglietto, ts_validazione, id_stazione)
SELECT id_biglietto, CURRENT_TIMESTAMP,
       (SELECT id_stazione FROM stazione WHERE codice='STC')
FROM biglietto WHERE codice_qr='QR-003';
