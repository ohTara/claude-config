# free-claude-code

Claude Code configuration and setup for Pop!_OS development environment.

## Quick Start on Pop!_OS

```bash
# Clone and run the setup script
git clone https://github.com/Alishahryar1/free-claude-code.git
cd free-claude-code
./install-popos.sh
```

The script installs the full Dev/Cloud stack:
- **RTK** (Rust Token Killer) — token-optimized CLI proxy
- **Node-RED** — flow-based development
- **Terraform** — infrastructure as code
- **Ansible** — automation
- **Cloud CLIs**: Azure CLI, AWS CLI, GCP CLI
- **Kubernetes**: kubectl, Helm
- **Containers**: Podman, Docker

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

## Project Structure

```
.
├── CLAUDE.md          # Behavioral guidelines for coding tasks
├── RTK.md             # RTK documentation
├── install-popos.sh   # Pop!_OS setup script
└── .claude/
    ├── settings.json  # Claude Code settings (hooks, permissions)
    └── CLAUDE.md      # User-global instructions
```

## Claude Code Configuration

This repo includes:
- **Hooks** for automatic RTK command rewriting
- **Permissions** allowlist for common read-only operations
- **Global instructions** (CLAUDE.md) with coding guidelines

## Useful Commands

```bash
# Check RTK savings
rtk gain

# See what commands could have used RTK
rtk discover

# Debug: run command without RTK filtering
rtk proxy git log --oneline -10
```

## License

MIT