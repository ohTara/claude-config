---
name: configurazione-homeserver
description: Stato e ottimizzazioni del server domestico multifunzione
metadata:
  type: project
---

Il server (ASUS Vivobook / hardware con RAM limitata ≤2GB) è configurato in modalità headless con le seguenti caratteristiche:
- **Sicurezza:** Hardening SSH applicato (no root login, no password authentication, solo chiavi pubbliche), Firewall UFW attivo, `fail2ban` pronto.
- **Storage:** Condivisione NAS tramite Samba configurata in modo sicuro.
- **Media:** Jellyfin containerizzato (Podman rootless) con limiti hardware rigidi (max 500M RAM, 1 CPU core) e transcodifica limitata per prevenire blocchi OOM.
- **Gaming:** Server Minecraft PaperMC containerizzato (Podman rootless), limitato a 800M RAM, 0.5 CPU, max 4 giocatori e view-distance ridotta (6). Script di backup locale pronto per l'integrazione S3.
- **IaC:** Configurazione predisposta per la gestione centralizzata tramite Terraform.

**Perché:** Evita di proporre configurazioni standard o pesanti che manderebbero il server in Out-Of-Memory (OOM) o saturerebbero la CPU Celeron/Atom.
**Como applicare:** Quando si aggiornano o si aggiungono servizi, mantenere sempre l'approccio dei container Podman gestiti tramite file di servizio `systemd --user` (senza sudo) nella home dell'utente.