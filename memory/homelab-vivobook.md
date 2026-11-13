---
name: homelab-vivobook
description: Vecchio homeserver ASUS Vivobook a basso consumo (≤2 GB RAM)
metadata:
  type: project
---

Configurazione di luglio 2026, documentata in `Server_WTMemmico` (`guida-server-cloud.md`, `homelab-phases.md`). **Non è il server Minecraft attuale**: vedi [[server-wtmemmico]].

- **Hardware:** ASUS Vivobook headless, CPU Celeron/Atom, ≤2 GB RAM. Ubuntu 24.04 / Debian 12.
- **Sicurezza:** SSH solo con chiave (no root, no password, `MaxAuthTries 3`), UFW default deny con `limit` su SSH, fail2ban. Su Ubuntu il servizio si chiama `ssh`, non `sshd`.
- **Ottimizzazioni:** ZRAM zstd, `vm.swappiness=10`, journald volatile, servizi superflui rimossi.
- **Storage:** Samba, share `Media` su `/srv/media/{tv,film,immagini,giochi}`, utente `media`, nessun guest.
- **Media:** Jellyfin in Podman rootless, max 500 MB RAM e 1 CPU, porta 8096, transcodifica limitata.
- **Gaming:** PaperMC (`itzg/minecraft-server`) in Podman rootless, 800 MB RAM, 0,5 CPU, 4 giocatori, view-distance 6. Backup S3 ancora da implementare.
- **IaC:** previsto di gestire le unit systemd con Terraform (`~/homelab-terraform`).

**Perché:** una configurazione standard manderebbe questa macchina in Out-Of-Memory.
**Come applicare:** su questa macchina usare container Podman con limiti espliciti, gestiti da unit `systemd --user` nella home, senza sudo; ricordare `systemctl --user daemon-reload` e `loginctl enable-linger`.
