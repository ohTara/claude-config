---
name: guida-sistema-e-troubleshooting
description: Guida combinata al sistema di memoria persistente di Claude Code e troubleshooting accesso Jellyfin
metadata: 
  node_type: memory
  type: reference
  originSessionId: 73d8db00-8d29-43f3-8b9c-68063804bc72
---

# Sistema di Memoria Persistente in Claude Code

## Come funziona
Claude Code utilizza un sistema di memoria basato su file nella seguente directory:
```
C:\Users\luca.tarallo\.claude\projects\C--Users-luca-tarallo\memory\
```

Ogni ricordo è salvato come un file singolo con questo formato:
```markdown
---
name: <short-kebab-case-slug>
description: <one-line summary>
metadata:
  type: user | feedback | project | reference
---

<il contenuto del ricordo>
**Perché:** [spiegazione]
**Come applicare:** [istruzioni]
[[link-a-ricordi-correlati]]
```

Dopo aver creato un file di memoria, devi aggiungere un riferimento in `MEMORY.md` (che si trova nella stessa directory) per farlo caricare automaticamente ad ogni sessione:
```markdown
- [Titolo del ricordo](nome-file.md) — descrizione breve
```

## Configurazione Attuale dell'Ambiente

### Preferenze di Sviluppo (preferenze-sviluppo.md)
L'utente sta studiando per diventare Cloud Specialist e lavora con il seguente stack:
- **OS Principale (Host):** Windows (dove risiede Claude e la CLI).
- **Ambiente di Lab/Server:** Ubuntu 24.04 LTS / Debian 12 (ambiente minimale per i servizi).
- **Strumenti Cloud:** AWS CLI, Azure CLI, Google Cloud SDK, Terraform, kubectl, Helm.
- **Container Engine:** Podman (scelta primaria rootless/daemonless per risparmio RAM) e Docker.

**Perché:** Permette di tarare ogni script, comando e configurazione (es. l'uso di `sudo` o i path di sistema) sull'architettura corretta senza doverla rispiegare ogni volta.
**Come applicare:** Fornire sempre comandi compatibili con bash/Debian per il server e PowerShell/CMD per i tool locali su Windows, prediligendo configurazioni "low-RAM-friendly" (Podman).

### Configurazione Homeserver (configurazione-homeserver.md)
Il server (ASUS Vivobook / hardware con RAM limitata ≤2GB) è configurato in modalità headless con le seguenti caratteristiche:
- **Sicurezza:** Hardening SSH applicato (no root login, no password authentication, solo chiavi pubbliche), Firewall UFW attivo, `fail2ban` pronto.
- **Storage:** Condivisione NAS tramite Samba configurata in modo sicuro.
- **Media:** Jellyfin containerizzato (Podman rootless) con limiti hardware rigidi (max 500M RAM, 1 CPU core) e transcodifica limitata per prevenire blocchi OOM.
- **Gaming:** Server Minecraft PaperMC containerizzato (Podman rootless), limitato a 800M RAM, 0.5 CPU, max 4 giocatori e view-distance ridotta (6). Script di backup locale pronto per l'integrazione S3.
- **IaC:** Configurazione predisposta per la gestione centralizzata tramite Terraform.

**Perché:** Evita di proporre configurazioni standard o pesanti che manderebbero il server in Out-Of-Memory (OOM) o saturerebbero la CPU Celeron/Atom.
**Come applicare:** Quando si aggiornano o si aggiungono servizi, mantenere sempre l'approccio dei container Podman gestiti tramite file di servizio `systemd --user` (senza sudo) nella home dell'utente.

# Troubleshooting: Accesso a Jellyfin dal PC Fisso

## Problema
Non riesci ad accedere alle cartelle di Jellyfin dal tuo PC fisso, nonostante aver installato tutti i programmi relativi al cloud.

## Analisi basata sulla tua configurazione

### Cosa NON funziona
Jellyfin **non espone normalmente le proprie cartelle interne** tramite esplora file (SMB/NFS). È un media server che:
1. Espone un'interfaccia web (di solito su porta 8096)
2. Accede ai tuoi file media tramite percorsi configurati nella sua interfaccia
3. Non rende direttamente accessibili le proprie cartelle interne via SMB/NFS

### Cosa probabilmente vuoi fare
- Accedere all'interfaccia web di Jellyfin per gestire la tua libreria media
- Oppure accedere ai file media originali (quelli che Jellyfin sta servendo) tramite la tua condivisione Samba

## Passaggi Diagnostici Consigliati

### 1. Verifica connettività di base
Da PowerShell/CMD sul tuo PC Windows:
```powershell
# Sostituisci con l'IP effettivo del tuo homeserver
Test-Connection -ComputerName 192.168.x.x  # oppure ping 192.168.x.x
```
Se fallisce: problema di rete/IP/server spento

### 2. Controlla se Jellyfin è acceso e in ascolto
Da terminale sul tuo homeserver (Ubuntu/Debian via SSH):
```bash
# Lista container Podman in esecuzione
podman ps

# Cerca specificamente jellyfin
podman ps | grep jellyfin

# Se non vedi nulla, potrebbe essere spento:
podman start jellyfin  # oppure il nome esatto che gli hai dato
```

### 3. Verifica porta e firewall
Sempre sul homeserver:
```bash
# Controlla se Jellyfin sta ascoltando sulla porta (di solito 8096)
ss -tlnp | grep :8096   # oppure: netstat -tlnp | grep :8096

# Controlla UFW
sudo ufw status
# Dovresti vedere qualcosa come: 8096/tcp ALLOW IN  oppure 8096/tcp ALLOW ANYWHERE
```
Se la porta non è consentita:
```bash
sudo ufw allow 8096/tcp
sudo ufw reload
```

### 4. Verifica la configurazione media library di Jellyfin
Accedi all'interfaccia web (`http://IP-homeserver:8096`) → Dashboard → Media Libraries
- Controlli che i percorsi puntino correrettamente alla tua condivisione Samba o alle cartelle media
- Esempi di percorsi validi:
  - `/mnt/tua-share-samba/film`  (se montato direttamente sul serveur)
  - `\\IP-server\share\film`  (meno comune da dentro container, meglio usare mount locale)
  - `/home/tuoutente/media/film`  (se hai i file nella home e li hai condivisi via Samba altrove)

### 5. Se usi Samba per i file media (non per Jellyfin stesso)
Da Windows:
- Prova ad accedere direttamente alla share Samba: `\\IP-homeserver\nome-condivisione-media`
- Se chiede credenziali: usa quelle che hai configurato per Samba (non quelle di Jellyfin!)
- Se fallisce: controlla su server:
  ```bash
  sudo ufw status  # assicurati che le porte Samba (139, 445) siano consentite
  testparm        # verifica configurazione Samba
  sudo systemctl status smbd  # oppure controlla se è attivo
  ```

## 💡 Suggerimenti Basati sulle Tue Preferenze
Dato che preferisci configurazioni **low-RAM-friendly** e usi **Podman rootless**:
- Assicurati che il container Jellyfin abbia effettivamente i limiti che hai impostato (500M RAM, 1 CPU) - se sta cercando di usare di più potrebbe essere stato killato dal kernel OOM killer
- Controlla i log per vedere se ci sono errori di memoria:
  ```bash
  podman logs jellyfin  # oppure whatever nome gli hai dato
  ```

## Riepilogo delle Azioni Consigliate
1. ✅ Verifica connettività di base (ping)
2. ✅ Conferma che Jellyfin sia in esecuzione (`podman ps`)
3. ✅ Controlla che la porta 8096 sia aperta nel firewall UFW
4. ✅ Accedi tramite browser a `http://IP-homeserver:8096`
5. ✅ Se vuoi i file media originali, accedi alla share Samba separatamente

## Perché questa guida è utile
Permette di avere a portata di mano sia le informazioni sul tuo ambiente di lavoro che le procedure specifiche per risolvere un problema comune con il tuo homeserver, evitando di dover ricercare o ricostruire il contesto ad ogni sessione.

## Come applicare
- Utilizza questa guida come riferimento iniziale quando incontri problemi di accesso a Jellyfin
- Adatta gli indirizzi IP e i nomi dei container alla tua configurazione specifica
- Aggiorna questa guida con nuove scoperte o soluzioni man mano che le incontri
- Collegala ad altri ricordi pertinenti tramite [[nome-guida-ricordato]]