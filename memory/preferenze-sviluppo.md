---
name: preferenze-sviluppo
description: Macchine, stack, stile di spiegazione e convenzioni di Luca
metadata:
  type: user
---

Luca studia come **Cloud Specialist all'ITS ICT Piemonte** (biennio 2025–27). Lingua di lavoro: italiano.

## Macchine
- **Windows** (host principale, utente `luca.tarallo`, PowerShell; anche Windows Server 2025).
- **Pop!_OS** (utente `tara`): ambiente Dev/Cloud e server Minecraft attuale.
- **ASUS Vivobook** headless, Ubuntu 24.04 / Debian 12 (utente `luca`): vecchio homelab con ≤2 GB di RAM.

## Stack
- Cloud: Azure CLI, AWS CLI v2, Google Cloud SDK. IaC: Terraform, Ansible, Checkov.
- Container: **Podman rootless** come prima scelta, Docker per compatibilità; kubectl, Helm, K3s.
- Linguaggi: Python (uv, FastAPI, pygame-ce), C, C#, Node.js (Express), Bash, PowerShell.
- Claude Code con RTK (vedi `RTK.md`).

## Come spiegare
- Progressione: Intuizione → Definizione → Internals → Esempio.
- Esempi pratici, collegamenti tra le materie, domande di richiamo a fine spiegazione.
- Se un dato non si ricava dai file, scrivere *da verificare* invece di supporlo.

## Convenzioni
- Commit in stile Conventional Commits (`feat:`, `fix(scope):`, `docs:`, `chore:`).
- Codice didattico con nomi in italiano e commenti alle funzioni.
- Mai versionare `.env`, `*.tfstate`, `*.tfvars`, chiavi `.pem`, artefatti di build.

**Perché:** evita di rispiegare ogni volta ambiente e metodo di studio.
**Come applicare:** comandi bash/Debian per i server Linux, PowerShell per Windows; chiedere su quale macchina si lavora quando il comando cambia; preferire soluzioni leggere (Podman, `systemd --user`).
