# free-claude-code

Claude Code configuration and setup for Pop!_OS development environment.

---

## 📍 Due Percorsi / Two Repositories

| Repository | Scopo | URL |
|---|---|---|
| **ohTara/claude-config** ← **LA TUA CONFIG** | Config completa: Pop!_OS installer, memory, RTK, 17 repo aggiunti | `https://github.com/ohTara/claude-config.git` |
| **Alishahryar1/free-claude-code** | Upstream base: progetto Python con CI/tests | `https://github.com/Alishahryar1/free-claude-code.git` |

**Usa `ohTara/claude-config` per il setup reale.** Questo repo (`free-claude-code`) è l'upstream di partenza.

---

## Quick Start on Pop!_OS (da ohTara/claude-config)

```bash
# Clona LA TUA config
git clone https://github.com/ohTara/claude-config.git
cd claude-config
./install-popos.sh
```

Lo script installa lo stack Dev/Cloud completo:
- **RTK** (Rust Token Killer) — token-optimized CLI proxy
- **Node-RED** — flow-based development
- **Terraform** — infrastructure as code
- **Ansible** — automation
- **Cloud CLIs**: Azure CLI, AWS CLI, GCP CLI
- **Kubernetes**: kubectl, Helm
- **Containers**: Podman, Docker
- **+ 17 repo aggiuntivi** per potenziare Claude Code

---

## RTK — Rust Token Killer

RTK cuts up to 90% of bash output tokens in Claude Code.

### Meta Commands (always use `rtk` directly)

```bash
rtk gain              # Show token savings analytics
rtk gain --history    # Show command usage history with savings
rtk discover          # Analyze Claude Code history for missed opportunities
rtk proxy <cmd>       # Execute raw command without filtering (for debugging)
```

### Installation Verification

```bash
rtk --version         # Should show: rtk X.Y.Z
rtk gain              # Should work (not "command not found")
which rtk             # Verify correct binary
```

⚠️ **Name collision**: If `rtk gain` fails, you may have `reachingforthejack/rtk` (Rust Type Kit) installed instead of Rust Token Killer.

### Hook-Based Usage

All other commands are automatically rewritten by the Claude Code hook:

```bash
git status     # → rtk git status (transparent, 0 tokens overhead)
ls -la         # → rtk ls -la
<any command>  # → rtk <command>
```

Refer to [RTK.md](RTK.md) for full command reference.

---

## Project Structure (ohTara/claude-config)

```
claude-config/
├── CLAUDE.md              # Behavioral guidelines for coding tasks
├── RTK.md                 # RTK documentation
├── install-popos.sh       # Pop!_OS setup script (235 lines)
├── README.md              # This file
├── .claude/
│   ├── settings.json      # Claude Code settings (hooks, permissions)
│   └── CLAUDE.md          # User-global instructions
└── projects/              # Memory files per project
    ├── C--Users-luca-tarallo/
    │   └── memory/
    │       ├── MEMORY.md
    │       ├── configurazione-homeserver.md
    │       ├── guida-sistema-e-troubleshooting.md
    │       └── preferenze-sviluppo.md
    └── -home-tara--claude-projects/
        └── memory/
            └── MEMORY.md
```

---

## Claude Code Configuration (da ohTara/claude-config)

Questa config include:
- **Hooks** per automatic RTK command rewriting
- **Permissions** allowlist per operazioni read-only comuni
- **Global instructions** (CLAUDE.md) con coding guidelines
- **Memory system** persistente tra sessioni

---

## Useful Commands

```bash
# Check RTK savings
rtk gain

# See what commands could have used RTK
rtk discover

# Debug: run command without RTK filtering
rtk proxy git log --oneline -10
```

---

## Sync con Upstream (se serve)

```bash
# In free-claude-code
git remote add upstream https://github.com/Alishahryar1/free-claude-code.git
git fetch upstream
git merge upstream/main --allow-unrelated-histories  # se history divergenti
```

---

## License

MIT