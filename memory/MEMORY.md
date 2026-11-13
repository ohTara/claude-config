# Indice della memory

File caricati da `~/.claude/CLAUDE.md` tramite `@memory/...`, quindi validi su ogni macchina e in ogni cartella.

- [Preferenze di sviluppo](preferenze-sviluppo.md) — macchine, stack, stile di spiegazione, convenzioni.
- [Progetti ITS](progetti-its.md) — Omnia System, Sage RAG, Echoes of the Crypt, repo Materie_ITS.
- [Server WTMemmico](server-wtmemmico.md) — server Minecraft attuale (Pop!_OS, 6 GB, Tailscale).
- [Homelab Vivobook](homelab-vivobook.md) — vecchio homeserver a basso consumo (≤2 GB): Samba, Jellyfin, Minecraft in Podman.
- [Troubleshooting Jellyfin](troubleshooting-jellyfin.md) — diagnostica accesso a Jellyfin e Samba.

## Come aggiungere un ricordo

1. Crea `memory/<slug>.md` con frontmatter `name`, `description`, `metadata.type` (`user` | `feedback` | `project` | `reference`).
2. Chiudi con **Perché** e **Come applicare**.
3. Aggiungi una riga qui sopra e una riga `@memory/<slug>.md` in `CLAUDE.md`.
