---
name: troubleshooting-jellyfin
description: Diagnostica quando Jellyfin o la share Samba non sono raggiungibili dal PC
metadata:
  type: reference
---

Vale per il vecchio homelab: vedi [[homelab-vivobook]].

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
- Controlli che i percorsi puntino correttamente alla tua condivisione Samba o alle cartelle media
- Esempi di percorsi validi:
  - `/mnt/tua-share-samba/film`  (se montato direttamente sul server)
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
  podman logs jellyfin  # oppure il nome che gli hai dato
  ```

## Riepilogo delle Azioni Consigliate
1. ✅ Verifica connettività di base (ping)
2. ✅ Conferma che Jellyfin sia in esecuzione (`podman ps`)
3. ✅ Controlla che la porta 8096 sia aperta nel firewall UFW
4. ✅ Accedi tramite browser a `http://IP-homeserver:8096`
5. ✅ Se vuoi i file media originali, accedi alla share Samba separatamente

**Perché:** è il problema che si è ripresentato più volte sull'homeserver.
**Come applicare:** seguire i passaggi nell'ordine, adattando IP e nomi dei container.
