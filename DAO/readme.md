# Smart Contract per la DAO Besteam

## Descrizione
Questo smart contract, sviluppato per la DAO "Besteam" e basato su Solidity versione ^0.8.20, implementa funzionalità essenziali per una gestione efficace dei membri, delle elezioni, e delle proposte all'interno della DAO. Assicura trasparenza, sicurezza, e una struttura organizzativa chiara.

## Funzioni Principali

### Gestione dei Membri
- **Iscrizione**: Gli utenti possono iscriversi come `Player` o `President` pagando il costo associato in token Besteam.
- **Gestione dei Ruoli**: I membri possono avere ruoli quali `None`, `Player`, `President`, `Counselor`, `Shareholder`, o `Besteam`, ognuno con diritti specifici.
- **Approvazione dei Membri**: Gli amministratori possono approvare o rifiutare l'iscrizione dei membri pendenti, gestendo il trasferimento o il rimborso dei token Besteam.

### Elezioni
- **Registrazione dei Candidati**: I membri possono candidarsi durante il periodo di registrazione aperto dall'owner.
- **Votazione**: I membri votano per i candidati durante il periodo di elezione. Il peso del voto può variare in base al ruolo del membro.
- **Controllo Candidati e Voti**: Il sistema previene la registrazione multipla dei candidati e i voti doppi.

### Gestione delle Proposte
- **Creazione di Proposte**: Proposte possono essere create specificando una descrizione, le opzioni di voto, la durata, il ruolo richiesto per votare, e il quorum.
- **Votazione sulle Proposte**: I membri votano sulle proposte attive. È implementato un controllo per prevenire voti multipli.
- **Calcolo del Quorum**: Ogni proposta richiede il raggiungimento di un quorum specifico per essere approvata.

## Sicurezza e Ottimizzazione
- **ReentrancyGuard**: Protegge dalle vulnerabilità di reentrancy nelle funzioni critiche.
- **Pausable**: Permette di mettere in pausa le operazioni del contratto in caso di emergenza.
- **Controllo dei Ruoli e dei Permessi**: Garantisce che solo i membri autorizzati possano eseguire azioni specifiche.

## Eventi
- `NewProposal`: Emanato alla creazione di una nuova proposta.
- `Voted`: Emanato quando un membro vota su una proposta.

## Implementazioni Specifiche
- **Gestione dei Token Besteam**: Le operazioni di pagamento e rimborso sono gestite in token Besteam.
- **Flexibilità del Quorum**: Il quorum per le proposte può essere impostato dinamicamente al momento della creazione della proposta.
- **Modularità e Manutenibilità**: Il codice sorgente è strutturato in modo chiaro e modulare, facilitando la manutenibilità e l'aggiornamento futuro del contratto.
