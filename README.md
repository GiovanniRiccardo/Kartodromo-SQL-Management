# Karting Track Relational Database Management

## Abstract
Progettazione, normalizzazione e implementazione di un database relazionale in Oracle PL/SQL per la gestione completa delle operazioni di un kartodromo commerciale[cite: 1]. L'architettura è strutturata per amministrare le prenotazioni delle piste, l'erogazione dei pacchetti gara, i pagamenti, la flotta dei kart, il tracking delle manutenzioni e la registrazione avanzata della telemetria per i team professionistici[cite: 1].

## Tech Stack
* **RDBMS:** Oracle Database[cite: 1].
* **Linguaggi:** SQL (DDL, DML, DCL), PL/SQL[cite: 1].
* **Modellazione:** Diagramma Entità/Associazione (E/R), Schema Logico Relazionale (Normalizzazione certificata fino alla Terza Forma Normale e BCNF)[cite: 1].

## Features Implementate
* **Architettura e Normalizzazione (DDL):** Strutturazione di 20 tabelle relazionali (tra cui `PRENOTAZIONE`, `TELEMETRIA`, `INTERVENTO_RIPARAZIONE`, `TEAM`, `PILOTA`) prive di anomalie e dipendenze parziali o transitive[cite: 1].
* **Data Integrity (Constraints):** Ingegnerizzazione di vincoli statici per garantire la coerenza logica, come il controllo sui limiti di peso dei piloti (30-150 kg), la validazione restrittiva dei formati orari (00:00-23:59) e l'univocità delle chiavi anagrafiche (Codici Fiscali e Partite IVA)[cite: 1].
* **Automazione avanzata tramite PL/SQL Triggers:** Sviluppo di logiche di business dinamiche per automatizzare le operazioni in pista, tra cui:
  * `T_CHECK_KART_LIBERO`: Blocca a livello di database l'assegnazione di un kart già impegnato in un intervento di riparazione non concluso[cite: 1].
  * `MINIMO_PARTECIPANTI`: Esegue la validazione automatica delle prenotazioni in base ai requisiti minimi del pacchetto gara selezionato[cite: 1].
  * `T_LIMITE_PILOTI_TEAM`: Impone un tetto massimo di 2 piloti ingaggiabili per team durante la medesima stagione sportiva[cite: 1].
  * `T_COERENZA_DATE_PAGAMENTO`: Impedisce incongruenze temporali tra le transazioni finanziarie e le relative date di prenotazione[cite: 1].
* **Estrazioni Dati e Data Control (DQL/DCL):** Creazione di viste specializzate (es. `V_CLASSIFICA_FINALE_GARA` per l'estrapolazione automatica del posizionamento finale basato sull'ultimo giro registrato) e segmentazione dei privilegi di accesso al database (tramite GRANT) per i profili di Amministratore, Gestore e Manutentore[cite: 1].

## Contesto di Sviluppo
Progetto accademico (valutato con punteggio di 6/7) sviluppato in team per il corso di Basi di Dati. All'interno dell'architettura generale, mi sono occupato personalmente dell'implementazione logica e fisica, curando la strutturazione delle tabelle DDL, la stesura degli script di popolamento massivo (DML) e la programmazione delle logiche di automazione tramite viste e trigger in ambiente Oracle.
