# claude-config

Configurazione personale di [Claude Code](https://claude.com/claude-code), sincronizzata tra Windows e Linux (Pop!_OS). Si clona direttamente in `~/.claude`.

## Contenuto

```
~/.claude/
├── CLAUDE.md                  # Istruzioni globali: importa RTK.md e la memory
├── RTK.md                     # Uso di RTK (Rust Token Killer)
├── memory/                    # Ricordi persistenti, validi su ogni macchina
│   ├── MEMORY.md              #   indice
│   ├── preferenze-sviluppo.md #   macchine, stack, stile di spiegazione
│   ├── progetti-its.md        #   Omnia System, Sage, Echoes of the Crypt, Materie_ITS
│   ├── server-wtmemmico.md    #   server Minecraft attuale
│   ├── homelab-vivobook.md    #   vecchio homeserver ≤2 GB
│   └── troubleshooting-jellyfin.md
├── settings/                  # Modelli di settings.json (Linux e Windows)
├── install-popos.sh           # Ambiente Dev/Cloud su Pop!_OS / Ubuntu
├── install-mc-server.sh       # Server Minecraft PaperMC + Geyser (Linux)
└── scripts/
    ├── install-windows.ps1    # Ambiente Dev/Cloud su Windows + Free Claude Code
    ├── install-mc-server.ps1  # Server Minecraft (Windows)
    └── install-muse.ps1, uninstall-muse.ps1
```

## Setup

```bash
git clone https://github.com/ohTara/claude-config.git ~/.claude
cd ~/.claude
```

| Macchina | Comando |
|---|---|
| Pop!_OS / Ubuntu | `./install-popos.sh` |
| Windows | `./scripts/install-windows.ps1 -RtkHeadroom` |

Poi, su entrambe:

```bash
cp settings/settings.linux.json settings.json   # su Windows: settings.windows.json
rtk init -g --dry-run                            # anteprima delle modifiche
rtk init -g                                      # collega RTK a Claude Code
rtk gain                                         # deve mostrare le statistiche
```

## Memory

Claude Code salva la memory automatica in `projects/<percorso-della-cartella>/memory/`. Il nome di quella cartella dipende dal percorso in cui lavori (`C--Users-luca-tarallo` su Windows, un altro su Linux), quindi i ricordi salvati lì **non si ritrovano sull'altra macchina**.

Per questo i ricordi stanno in `memory/` e vengono importati da `CLAUDE.md` con `@memory/<file>.md`: `CLAUDE.md` è globale e viene letto ovunque. Per aggiungerne uno, vedi `memory/MEMORY.md`.

`projects/` resta fuori da Git: contiene le trascrizioni delle sessioni.

## Cosa installa `install-popos.sh`

RTK, Node.js LTS, Node-RED (porta 1880), Podman rootless, Docker (opzionale), Terraform, Ansible, Azure CLI, AWS CLI v2, Google Cloud CLI, kubectl, Helm, Git con chiave SSH ed25519.

RTK viene installato con l'installer ufficiale di [rtk-ai/rtk](https://github.com/rtk-ai/rtk). `cargo install rtk` installerebbe un altro progetto con lo stesso nome.

Alla fine lo script clona in `~/claude-repos/` 18 repository di riferimento (skill, setup e strumenti per Claude Code). Sono materiale da consultare: Claude Code non li carica da solo.

## Free Claude Code (solo Windows)

`install-windows.ps1` installa anche [Free Claude Code](https://github.com/Alishahryar1/free-claude-code) e i launcher `fcc-claude`, `fcc-codex`, `fcc-opencode`, `fcc-pi`, `fcc-cline`, `fcc-hermes`, `fcc-dsh`, `fcc-grok`, `fcc-muse`, `fcc-aider`, `fcc-agy`. Il sorgente di quel progetto non è più copiato in questa repo: l'installer lo scarica dalla release ufficiale.

Gli script in `scripts/` derivano da quel progetto, distribuito con licenza AGPL-3.0 (vedi `LICENSE`).

## Server Minecraft

`install-mc-server.sh` è lo stesso script di [Server_WTMemmico](https://github.com/ohTara/Server_WTMemmico), dove si trova la documentazione completa. Si può rilanciare per aggiornare PaperMC e i plugin: non sovrascrive `server.properties`, `paper.yml` e la configurazione di Geyser se esistono già.

## Sincronizzazione

```bash
cd ~/.claude
git add -A && git commit -m "chore: <cosa è cambiato>" && git push   # macchina modificata
git pull                                                             # altra macchina
```
