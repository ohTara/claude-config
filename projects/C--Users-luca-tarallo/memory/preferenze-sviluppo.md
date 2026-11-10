---
name: preferenze-sviluppo
description: Preferenze dell'ambiente di sviluppo e studio di Luca
metadata:
  type: user
---

L'utente sta studiando per diventare Cloud Specialist e lavora con il seguente stack:
- **OS Principale (Host):** Windows (dove risiede Claude e la CLI).
- **Ambiente di Lab/Server:** Ubuntu 24.04 LTS / Debian 12 (ambiente minimale per i servizi).
- **Strumenti Cloud:** AWS CLI, Azure CLI, Google Cloud SDK, Terraform, kubectl, Helm.
- **Container Engine:** Podman (scelta primaria rootless/daemonless per risparmio RAM) e Docker.

**Perché:** Permette di tarare ogni script, comando e configurazione (es. l'uso di `sudo` o i path di sistema) sull'architettura corretta senza doverla rispiegare ogni volta.
**Come applicare:** Fornire sempre comandi compatibili con bash/Debian per il server e PowerShell/CMD per i tool locali su Windows, prediligendo configurazioni "low-RAM-friendly" (Podman).