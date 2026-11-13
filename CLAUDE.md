@RTK.md
@memory/MEMORY.md
@memory/preferenze-sviluppo.md
@memory/progetti-its.md
@memory/server-wtmemmico.md
@memory/homelab-vivobook.md

# Regole generali

- Rispondi in italiano.
- Prima di proporre comandi di sistema, verifica su quale macchina si sta lavorando (Windows, Pop!_OS, Vivobook): vedi `memory/preferenze-sviluppo.md`.
- La guida `memory/troubleshooting-jellyfin.md` non è caricata in automatico: leggila quando serve.

# Setup di una macchina nuova

- **Pop!_OS / Ubuntu**: `./install-popos.sh` (RTK, Node-RED, Terraform, Ansible, CLI Azure/AWS/GCP, kubectl, Helm, Podman, Docker).
- **Windows**: `./scripts/install-windows.ps1` (stesso ambiente, più Free Claude Code e gli agenti opzionali).
- **Server Minecraft**: `./install-mc-server.sh` (Linux) oppure `./scripts/install-mc-server.ps1` (Windows).
- Poi copia il modello di `settings.json` da `settings/` ed esegui `rtk init -g`.
