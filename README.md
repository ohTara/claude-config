# claude-config

Configurazione personale per [Claude Code](https://claude.com/claude-code) — sincronizzata tra Windows (VM ITS) e Linux (Pop!_OS).

---

## 📍 Due Percorsi / Two Repositories

| Repository | Scopo | URL |
|---|---|---|
| **ohTara/claude-config** ← **QUESTO** | Config completa: Pop!_OS installer, memory, RTK, 17 repo aggiunti | `https://github.com/ohTara/claude-config.git` |
| **Alishahryar1/free-claude-code** | Upstream base: progetto Python con CI/tests | `https://github.com/Alishahryar1/free-claude-code.git` |

**Usa `ohTara/claude-config` per il setup reale.** L'altro repo è l'upstream di partenza.

---

## Contenuto

## Contenuto

```
.claude/
├── CLAUDE.md              # Istruzioni globali (override default behavior)
├── RTK.md                 # Rust Token Killer - CLI proxy per risparmio token
├── install-popos.sh       # Setup completo ambiente Dev/Cloud su Pop!_OS
└── projects/
    └── C--Users-luca-tarallo/
        └── memory/
            ├── MEMORY.md                      # Indice ricordi
            ├── preferenze-sviluppo.md         # Stack: Windows/Ubuntu, AWS/Azure/GCP, Terraform, k8s, Podman
            ├── configurazione-homeserver.md   # ASUS Vivobook headless: SSH, UFW, fail2ban, Samba, Jellyfin, Minecraft
            └── guida-sistema-e-troubleshooting.md  # Diagnostica accesso Jellyfin, Podman logs, Samba
```

## Setup rapido

```bash
# Clona nella posizione attesa da Claude Code
git clone https://github.com/ohTara/claude-config.git ~/.claude

# Verifica
ls ~/.claude/
claude --version
```

## Setup ambiente Pop!_OS (nuova macchina)

```bash
# Rendi eseguibile e lancia lo script di installazione
cd ~/.claude
chmod +x install-popos.sh
./install-popos.sh
```

Lo script installa:
- **Rust + Cargo** → per RTK
- **RTK** (Rust Token Killer) — proxy CLI che taglia ~90% output bash
- **Node.js LTS + npm** — per Node-RED e tool JS
- **Node-RED** — editor flow IoT (porta 1880)
- **Podman** — container rootless (già su Pop!_OS)
- **Docker** (opzionale) — compatibilità
- **Terraform** — IaC (HashiCorp repo)
- **Ansible** — config management
- **Azure CLI** (`az`) — cloud Microsoft
- **AWS CLI v2** — cloud Amazon
- **Google Cloud CLI** (`gcloud`) — cloud Google
- **kubectl** — Kubernetes CLI
- **Helm** — package manager k8s
- **Git** + chiave SSH ed25519 per GitHub

## Memory system

I file in `projects/*/memory/` sono **caricati automaticamente** all'avvio di Claude Code. Contengono:
- Preferenze e stack tecnologico
- Configurazione homeserver (servizi, porte, troubleshooting)
- Riferimenti a progetti ITS (27 moduli + Omnia System DevSecOps lab)

## Nota sui path

La cartella `C--Users-luca-tarallo` è un hash del path Windows originale. Funziona identicamente su Linux — Claude Code usa il contenuto, non il nome.

## Sync futuri

```bash
# Dopo modifiche su una macchina:
cd ~/.claude
git add -A
git commit -m "Update: <cosa>"
git push

# Sull'altra macchina:
cd ~/.claude && git pull
```

## Verifica post-install

```bash
# Test RTK
rtk --version
rtk gain

# Test Node-RED
node-red  # Ctrl+C per uscire, gira su http://localhost:1880

# Test cloud CLI
az version
aws --version
gcloud version
kubectl version --client
helm version --short
```

---

**Licenza:** Uso personale — niente segreti/chiavi in repo (usa variabili d'ambiente o keyring).