-- =========================================================
-- queries.sql
-- 5 query rappresentative per il sistema di biglietteria
-- Target DB: biglietteria_db (schema ferrovie)
-- =========================================================

SET search_path TO ferrovie, public;

------------------------------------------------------------
-- 1) Ricerca servizi e prezzi disponibili
--    Tra due stazioni (codice) in una determinata data
------------------------------------------------------------
SELECT
  s.codice_treno,
  s.data_partenza,
  s.ora_partenza,
  s.ora_arrivo,
  sp.nome AS stazione_partenza,
  sa.nome AS stazione_arrivo,
  c.nome  AS classe,
  t.nome  AS tariffa,
  p.importo,
  p.valuta
FROM servizio s
JOIN linea   l   ON l.id_linea = s.id_linea
JOIN tratta  tr  ON tr.id_linea = l.id_linea
JOIN stazione sp ON sp.id_stazione = tr.id_stazione_partenza
JOIN stazione sa ON sa.id_stazione = tr.id_stazione_arrivo
JOIN prezzo  p   ON p.id_tratta = tr.id_tratta
JOIN classe  c   ON c.id_classe = p.id_classe
JOIN tariffa t   ON t.id_tariffa = p.id_tariffa
WHERE sp.codice = 'STA'      -- stazione partenza
  AND sa.codice = 'STC'      -- stazione arrivo
  AND s.data_partenza = CURRENT_DATE
  AND s.stato = 'programmato'
  AND p.valid_from <= s.data_partenza
  AND (p.valid_to IS NULL OR p.valid_to >= s.data_partenza)
ORDER BY s.ora_partenza, c.nome, t.nome;

------------------------------------------------------------
-- 2) Storico prenotazioni di un cliente
--    (es. Mario Rossi, con ultimo pagamento associato)
------------------------------------------------------------
WITH ultimo_pagamento AS (
  SELECT DISTINCT ON (pg.id_prenotazione)
         pg.id_prenotazione,
         pg.importo,
         pg.esito,
         pg.ts_pagamento
  FROM pagamento pg
  ORDER BY pg.id_prenotazione, pg.ts_pagamento DESC
)
SELECT
  pr.id_prenotazione,
  pr.ts_creazione,
  pr.stato       AS stato_prenotazione,
  b.codice_qr,
  b.prezzo_totale,
  b.stato        AS stato_biglietto,
  up.importo     AS importo_ultimo_pagamento,
  up.esito       AS esito_ultimo_pagamento,
  up.ts_pagamento
FROM prenotazione pr
JOIN passeggero pax
  ON pax.id_passeggero = pr.id_passeggero
LEFT JOIN biglietto b
  ON b.id_prenotazione = pr.id_prenotazione
LEFT JOIN ultimo_pagamento up
  ON up.id_prenotazione = pr.id_prenotazione
WHERE pax.email = 'mario.rossi@example.com'
ORDER BY pr.ts_creazione DESC, b.ts_emissione DESC NULLS LAST;

------------------------------------------------------------
-- 3) Verifica della validità di un biglietto
--    partendo dal codice QR
------------------------------------------------------------
SELECT
  b.id_biglietto,
  b.codice_qr,
  b.stato,
  pax.nome,
  pax.cognome,
  MIN(s.data_partenza) AS data_primo_servizio,
  MIN(s.ora_partenza)  AS ora_prima_partenza,
  MAX(s.ora_arrivo)    AS ora_ultima_arrivo
FROM biglietto b
JOIN prenotazione pr
  ON pr.id_prenotazione = b.id_prenotazione
JOIN passeggero pax
  ON pax.id_passeggero = pr.id_passeggero
JOIN percorso_biglietto pb
  ON pb.id_biglietto = b.id_biglietto
JOIN servizio s
  ON s.id_servizio = pb.id_servizio
WHERE b.codice_qr = 'QR-001'
  AND b.stato IN ('valido','usato')
GROUP BY
  b.id_biglietto,
  b.codice_qr,
  b.stato,
  pax.nome,
  pax.cognome;

------------------------------------------------------------
-- 4) Report vendite per linea e data
--    (numero biglietti, incasso, prezzo medio)
------------------------------------------------------------
SELECT
  l.nome_linea,
  s.data_partenza,
  COUNT(DISTINCT b.id_biglietto) AS biglietti_venduti,
  SUM(b.prezzo_totale)           AS incasso_totale,
  AVG(NULLIF(b.prezzo_totale,0)) AS prezzo_medio
FROM linea l
JOIN servizio s
  ON s.id_linea = l.id_linea
JOIN percorso_biglietto pb
  ON pb.id_servizio = s.id_servizio
JOIN biglietto b
  ON b.id_biglietto = pb.id_biglietto
WHERE s.data_partenza = CURRENT_DATE
  AND b.stato IN ('valido','usato','rimborsato')
GROUP BY l.nome_linea, s.data_partenza
ORDER BY s.data_partenza DESC, incasso_totale DESC;

------------------------------------------------------------
-- 5) “Occupazione” per servizio (proxy via leg)
--    Conta quanti percorsi/biglietti insistono su un servizio
------------------------------------------------------------
SELECT
  s.id_servizio,
  s.codice_treno,
  s.data_partenza,
  COUNT(pb.id_percorso)           AS num_leg_su_servizio,
  COUNT(DISTINCT pb.id_biglietto) AS num_biglietti_coinvolti
FROM servizio s
LEFT JOIN percorso_biglietto pb
  ON pb.id_servizio = s.id_servizio
WHERE s.codice_treno = 'TR100'
  AND s.data_partenza = CURRENT_DATE
GROUP BY s.id_servizio, s.codice_treno, s.data_partenza;
