@RTK.md

# Setup Windows Dev/Cloud Environment
Esegui `./scripts/install-windows.ps1` per installare tutto l'ambiente Dev/Cloud (RTK, Node-RED, Terraform, Ansible, Azure/AWS/GCP CLI, kubectl, Helm, Podman, Docker, Free Claude Code + agenti).

## Quick Start
```powershell
# 1. Clona e configura
git clone https://github.com/ohTara/claude-config.git ~/.claude
cd ~/.claude

# 2. Installa tutto (interattivo - scegli gli agenti)
./scripts/install-windows.ps1 -RtkHeadroom

# 3. Verifica
rtk gain
fcc-server --version
```

## Agenti Supportati (via Free Claude Code)
| Comando | Agente | Descrizione |
|---------|--------|-------------|
| `fcc-claude` | Claude Code | Official Anthropic CLI |
| `fcc-codex` | Codex | OpenAI coding agent |
| `fcc-opencode` | OpenCode | Open source coding agent |
| `fcc-pi` | Pi | Local-first coding agent |
| `fcc-cline` | Cline | VS Code extension CLI |
| `fcc-hermes` | Hermes | Nous Research agent |
| `fcc-dsh` | DeepSeek Harness | DeepSeek coding agent |
| `fcc-grok` | Grok Build | xAI coding agent |
| `fcc-muse` | Muse Code | Meta coding agent |
| `fcc-aider` | Aider | Terminal pair programming |
| `fcc-agy` | Antigravity CLI | Google coding agent |

## RTK + Headroom (Token Optimization)
```powershell
# Attiva per tutti gli agenti supportati
rtk init --global --auto-patch    # Claude Code
rtk init --global --codex         # Codex
rtk init --global --agent pi      # Pi
```

## Project Work - Omnia System
Vedi `~/Desktop/Project-Work---Omnia-System-main/` per il lab Cloud Security & DevSecOps su Azure (Terraform + Ansible + Wazuh + ModSecurity).