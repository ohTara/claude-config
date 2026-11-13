---
name: server-wtmemmico
description: Server Minecraft PaperMC + Geyser attuale su Pop!_OS
metadata:
  type: project
---

Repo: `ohTara/Server_WTMemmico`. Installazione con `install-mc-server.sh`.

- **Macchina:** Pop!_OS / Ubuntu 24.04+, almeno 8 GB di RAM, utente `tara`. Server in `~/minecraft-server`.
- **Software:** PaperMC 1.21.11, Java 21 nativo (non in container), heap 6 GB con flag Aikar.
- **Plugin:** Geyser + Floodgate (cross-play Java/Bedrock), ViaVersion, ViaRewind, ViaBackwards, EssentialsX (Core, Chat, Spawn), Spark.
- **Servizio:** `mc-server` come unit `systemd --user`.
- **Rete:** 25565 TCP (Java), 19132 UDP (Bedrock), accesso degli amici via Tailscale.
- **Impostazioni:** 30 giocatori, view-distance 10, simulation-distance 6, `online-mode=false`, nessuna whitelist, rcon spento.
- **Backup:** `backup.sh`, ogni giorno alle 03:00, rotazione 14 giorni, copia remota opzionale con rclone (`BACKUP_REMOTE`).
- **Alias:** `mc-start`, `mc-stop`, `mc-restart`, `mc-status`, `mc-logs`, `mc-console`, `mc-backup`, `mc-backup-list`, `mc-version`.
- **Problemi noti:** Geyser "zip file closed" dopo un restart (si risolve con `mc-restart`); le build recenti di WorldEdit richiedono Java 25.

**Perché:** i limiti del vecchio homelab (800 MB, 4 giocatori) non valgono per questa macchina.
**Come applicare:** `online-mode=false` senza whitelist è accettabile solo finché il server è raggiungibile unicamente da Tailscale; prima di esporlo su Internet attivare `online-mode=true` o la whitelist.
