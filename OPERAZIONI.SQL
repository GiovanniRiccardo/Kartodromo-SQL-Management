-- 1. Apre un intervento di riparazione
CREATE OR REPLACE PROCEDURE SP_APRI_RIPARAZIONE (
    p_cod_intervento NUMBER, p_num_kart VARCHAR2, p_num_telaio VARCHAR2,
    p_partita_iva VARCHAR2, p_manutentore VARCHAR2, p_tipo_guasto VARCHAR2
) IS
    v_check NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_check FROM KART WHERE NUMERO_KART = p_num_kart AND NUMERO_TELAIO = p_num_telaio;
    IF v_check = 0 THEN
        RAISE_APPLICATION_ERROR(-20061, 'Errore: Il Kart specificato non esiste nel sistema.');
    END IF;
    SELECT COUNT(*) INTO v_check FROM DITTA WHERE PARTITA_IVA = p_partita_iva;
    IF v_check = 0 THEN
        RAISE_APPLICATION_ERROR(-20062, 'Errore: La Ditta specificata non esiste.');
    END IF;
    SELECT COUNT(*) INTO v_check FROM INTERVENTO_RIPARAZIONE WHERE NUMERO_KART = p_num_kart AND NUMERO_TELAIO = p_num_telaio AND DATA_FINE IS NULL;
    IF v_check > 0 THEN
        RAISE_APPLICATION_ERROR(-20060, 'Errore: Kart gia in riparazione.');
    END IF;
    INSERT INTO INTERVENTO_RIPARAZIONE (CODICE_INTERVENTO, NUMERO_KART, NUMERO_TELAIO, PARTITA_IVA, CODICE_FISCALE, TIPO_GUASTO, DATA_INIZIO, ORA_INIZIO) 
    VALUES (p_cod_intervento, p_num_kart, p_num_telaio, p_partita_iva, p_manutentore, p_tipo_guasto, TRUNC(SYSDATE), TO_CHAR(SYSDATE, 'HH24:MI'));
END;
/
-- 2. Aggiorna i dettagli dell'intervento
CREATE OR REPLACE PROCEDURE SP_AGGIORNA_DETTAGLI_RIPARAZIONE (
    p_cod_intervento NUMBER, p_tipo_guasto VARCHAR2, p_tipi_ricambi VARCHAR2
) IS
    v_num_kart VARCHAR2(100);
    v_partita_iva VARCHAR2(100);
    v_check NUMBER;
BEGIN
    BEGIN
        SELECT NUMERO_KART, PARTITA_IVA INTO v_num_kart, v_partita_iva FROM INTERVENTO_RIPARAZIONE WHERE CODICE_INTERVENTO = p_cod_intervento AND DATA_FINE IS NULL;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20095, 'Errore: Intervento inesistente o gia chiuso.');
    END;
    SELECT COUNT(*) INTO v_check FROM KART WHERE NUMERO_KART = v_num_kart;
    IF v_check = 0 THEN
        RAISE_APPLICATION_ERROR(-20061, 'Errore: Integrita violata, il Kart associato non esiste piu.');
    END IF;
    SELECT COUNT(*) INTO v_check FROM DITTA WHERE PARTITA_IVA = v_partita_iva;
    IF v_check = 0 THEN
        RAISE_APPLICATION_ERROR(-20062, 'Errore: Integrita violata, la Ditta associata non esiste piu.');
    END IF;
    UPDATE INTERVENTO_RIPARAZIONE SET TIPO_GUASTO = p_tipo_guasto, TIPI_RICAMBI = p_tipi_ricambi WHERE CODICE_INTERVENTO = p_cod_intervento;
END;
/
-- 3. Conclude l'intervento
CREATE OR REPLACE PROCEDURE SP_CHIUDI_RIPARAZIONE (
    p_cod_intervento NUMBER, p_cod_fattura VARCHAR2, p_costo NUMBER
) IS
    v_num_kart VARCHAR2(100);
    v_check NUMBER;
BEGIN
    BEGIN
        SELECT NUMERO_KART INTO v_num_kart FROM INTERVENTO_RIPARAZIONE WHERE CODICE_INTERVENTO = p_cod_intervento AND DATA_FINE IS NULL;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20096, 'Errore: Impossibile chiudere un intervento inesistente o gia chiuso.');
    END;
    SELECT COUNT(*) INTO v_check FROM FATTURA WHERE CODICE_FATTURA = p_cod_fattura;
    IF v_check = 0 THEN
        RAISE_APPLICATION_ERROR(-20063, 'Errore: La Fattura specificata non esiste nel sistema.');
    END IF;
    SELECT COUNT(*) INTO v_check FROM KART WHERE NUMERO_KART = v_num_kart;
    IF v_check = 0 THEN
        RAISE_APPLICATION_ERROR(-20061, 'Errore: Integrita violata, il Kart non esiste piu.');
    END IF;
    UPDATE INTERVENTO_RIPARAZIONE SET DATA_FINE = TRUNC(SYSDATE), ORA_FINE = TO_CHAR(SYSDATE, 'HH24:MI'), CODICE_FATTURA = p_cod_fattura, COSTO = p_costo WHERE CODICE_INTERVENTO = p_cod_intervento;
END;
/
-- 4. Inserisce una prenotazione
CREATE OR REPLACE PROCEDURE SP_INSERISCI_PRENOTAZIONE ( 
    p_data_prenotazione DATE, p_ora_prenotazione VARCHAR2, p_partecipanti NUMBER, 
    p_pista VARCHAR2, p_data_gara DATE, p_ora_gara VARCHAR2, p_cellulare VARCHAR2, 
    p_pacchetto VARCHAR2, p_cod_fiscale_admin VARCHAR2
) IS 
    v_check NUMBER; 
    v_prezzo_pacchetto NUMBER; 
    v_max_partecipanti NUMBER; 
BEGIN 
    SELECT COUNT(*) INTO v_check FROM UTENTE WHERE CELLULARE = p_cellulare; 
    IF v_check = 0 THEN 
        RAISE_APPLICATION_ERROR(-20010, 'Errore: Utente inesistente.'); 
    END IF; 
    SELECT COUNT(*) INTO v_check FROM AMMINISTRATORE WHERE CODICE_FISCALE = p_cod_fiscale_admin;
    IF v_check = 0 THEN
        RAISE_APPLICATION_ERROR(-20015, 'Errore: Amministratore non autorizzato o inesistente.');
    END IF;
    BEGIN 
        SELECT PREZZO, NUMERO_PARTECIPANTI INTO v_prezzo_pacchetto, v_max_partecipanti FROM PACCHETTO_GARA WHERE NOME_PACCHETTO = p_pacchetto AND NOME_PISTA = p_pista; 
    EXCEPTION 
        WHEN NO_DATA_FOUND THEN 
            RAISE_APPLICATION_ERROR(-20011, 'Errore: Pacchetto non valido per la pista selezionata.'); 
    END; 
    IF p_partecipanti > v_max_partecipanti THEN 
        RAISE_APPLICATION_ERROR(-20012, 'Errore: I partecipanti superano il limite del pacchetto.'); 
    END IF; 
    INSERT INTO PRENOTAZIONE (DATA_PRENOTAZIONE, ORA_PRENOTAZIONE, QUOTA_ISCRIZIONE, NUMERO_PARTECIPANTI_EFFETTIVO, NOME_PISTA, DATA_GARA, ORA_GARA, CELLULARE, NOME_PACCHETTO, CODICE_FISCALE) 
    VALUES (p_data_prenotazione, p_ora_prenotazione, v_prezzo_pacchetto, p_partecipanti, p_pista, p_data_gara, p_ora_gara, p_cellulare, p_pacchetto, p_cod_fiscale_admin); 
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        RAISE_APPLICATION_ERROR(-20013, 'Errore: Prenotazione gia esistente per questa data e ora.');
END;
/
-- 5. Registra un Pilota e lo associa al Team
CREATE OR REPLACE PROCEDURE SP_REGISTRA_PILOTA_TEAM ( 
    p_licenza VARCHAR2, p_nome VARCHAR2, p_cognome VARCHAR2, p_peso NUMBER, 
    p_categoria VARCHAR2, p_data_nascita DATE, p_nome_team VARCHAR2, p_anno_ingaggio NUMBER
) IS 
    v_check NUMBER; 
BEGIN 
    SELECT COUNT(*) INTO v_check FROM TEAM WHERE NOME_TEAM = p_nome_team; 
    IF v_check = 0 THEN 
        RAISE_APPLICATION_ERROR(-20020, 'Errore: Il Team specificato non e registrato nel sistema.'); 
    END IF; 
    SELECT COUNT(*) INTO v_check FROM INGAGGIA WHERE NOME_TEAM = p_nome_team AND ANNO = p_anno_ingaggio;
    IF v_check >= 2 THEN
        RAISE_APPLICATION_ERROR(-20046, 'Errore: Un team non puo ingaggiare piu di 2 piloti l''anno.');
    END IF;
    SELECT COUNT(*) INTO v_check FROM PILOTA WHERE LICENZA = p_licenza;
    IF v_check > 0 THEN
        RAISE_APPLICATION_ERROR(-20021, 'Errore: Licenza Pilota gia presente a sistema.');
    END IF;
    INSERT INTO PILOTA (LICENZA, NOME, COGNOME, PESO, CATEGORIA, DATA_NASCITA) VALUES (p_licenza, p_nome, p_cognome, p_peso, p_categoria, p_data_nascita); 
    INSERT INTO INGAGGIA (LICENZA, NOME_TEAM, ANNO) VALUES (p_licenza, p_nome_team, p_anno_ingaggio);  
END;
/
-- 6. Registra il pagamento 
CREATE OR REPLACE PROCEDURE SP_REGISTRA_PAGAMENTO ( 
    p_data_pagamento DATE, p_ora_pagamento VARCHAR2, p_modalita VARCHAR2, 
    p_data_prenotazione DATE, p_ora_prenotazione VARCHAR2, p_nome_team VARCHAR2
) IS 
    v_cellulare VARCHAR2(100);
    v_check NUMBER; 
BEGIN 
    BEGIN
        SELECT CELLULARE INTO v_cellulare FROM PRENOTAZIONE WHERE DATA_PRENOTAZIONE = p_data_prenotazione AND ORA_PRENOTAZIONE = p_ora_prenotazione; 
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20030, 'Errore: La prenotazione specificata non esiste.'); 
    END;
    SELECT COUNT(*) INTO v_check FROM UTENTE WHERE CELLULARE = v_cellulare;
    IF v_check = 0 THEN
        RAISE_APPLICATION_ERROR(-20010, 'Errore: Integrita violata, l''utente della prenotazione non esiste.');
    END IF;
    SELECT COUNT(*) INTO v_check FROM TEAM WHERE NOME_TEAM = p_nome_team; 
    IF v_check = 0 THEN 
        RAISE_APPLICATION_ERROR(-20031, 'Errore: Il Team specificato per il pagamento non e registrato.'); 
    END IF; 
    INSERT INTO PAGAMENTO (DATA_PAGAMENTO, ORA_PAGAMENTO, MODALITA, DATA_PRENOTAZIONE, ORA_PRENOTAZIONE, NOME_TEAM) 
    VALUES (p_data_pagamento, p_ora_pagamento, p_modalita, p_data_prenotazione, p_ora_prenotazione, p_nome_team); 
EXCEPTION 
    WHEN DUP_VAL_ON_INDEX THEN 
        RAISE_APPLICATION_ERROR(-20032, 'Errore: Pagamento gia registrato per questa data e ora.'); 
END;
/