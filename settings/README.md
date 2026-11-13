# Modelli di `settings.json`

`~/.claude/settings.json` **non è versionato**: cambia da macchina a macchina e viene modificato da `rtk init`. Qui ci sono i modelli di partenza.

```bash
# Linux
cp ~/.claude/settings/settings.linux.json ~/.claude/settings.json
rtk init -g --dry-run   # anteprima
rtk init -g             # aggiunge l'hook RTK
```

```powershell
# Windows
Copy-Item $HOME\.claude\settings\settings.windows.json $HOME\.claude\settings.json
rtk init -g --dry-run
rtk init -g
```

## Differenze rispetto al vecchio `settings.json`

- **Hook**: non è più scritto a mano. Lo installa `rtk init -g`, così resta allineato alla versione di RTK.
- **Permessi tolti**: `curl`, `wget`, `ssh`, `scp`, `rsync`. Con il permesso automatico, Claude poteva scaricare file o collegarsi a un server senza chiedere conferma. Ora chiede; per riattivarli basta aggiungere la riga in `permissions.allow`.
- **`CLAUDE_CONFIG_DIR`** tolto: `~/.claude` è già il valore predefinito.
