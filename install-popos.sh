#!/usr/bin/env bash
# install-popos.sh — Setup ambiente Dev/Cloud su Pop!_OS per Claude Code + ITS
# Uso: chmod +x install-popos.sh && ./install-popos.sh

set -euo pipefail

# ──────────────────────────────────────────────────────────────────────────────
# Colori output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log()   { echo -e "${GREEN}[✓]${NC} $*"; }
warn()  { echo -e "${YELLOW}[!]${NC} $*"; }
error() { echo -e "${RED}[✗]${NC} $*"; exit 1; }

# ──────────────────────────────────────────────────────────────────────────────
# Verifica Pop!_OS / Ubuntu base
if ! grep -q "Pop" /etc/os-release 2>/dev/null && ! grep -q "Ubuntu" /etc/os-release 2>/dev/null; then
  warn "Non su Pop!_OS/Ubuntu — alcuni pacchetti potrebbero avere nomi diversi"
fi

# ──────────────────────────────────────────────────────────────────────────────
# Aggiorna sistema
log "Aggiornamento apt..."
sudo apt update && sudo apt upgrade -y

# ──────────────────────────────────────────────────────────────────────────────
# Pacchetti base
log "Installazione pacchetti base..."
sudo apt install -y \
  git curl wget unzip jq build-essential \
  software-properties-common apt-transport-https ca-certificates gnupg lsb-release \
  vim htop btop tree fzf ripgrep fd-find bat

# ──────────────────────────────────────────────────────────────────────────────
# Rust + Cargo (per RTK)
if ! command -v cargo &>/dev/null; then
  log "Installazione Rust (via rustup)..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source "$HOME/.cargo/env"
else
  log "Rust già presente: $(rustc --version)"
fi

# ──────────────────────────────────────────────────────────────────────────────
# RTK (Rust Token Killer)
if ! command -v rtk &>/dev/null; then
  log "Installazione RTK..."
  cargo install rtk
  # Verifica che ~/.cargo/bin sia nel PATH
  if ! grep -q '$HOME/.cargo/bin' ~/.bashrc 2>/dev/null; then
    echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.bashrc
  fi
  export PATH="$HOME/.cargo/bin:$PATH"
else
  log "RTK già presente: $(rtk --version)"
fi

# ──────────────────────────────────────────────────────────────────────────────
# Node.js + npm (per Node-RED, Claude Code)
if ! command -v node &>/dev/null; then
  log "Installazione Node.js (LTS) via NodeSource..."
  curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
  sudo apt install -y nodejs
else
  log "Node.js già presente: $(node --version)"
fi

# ──────────────────────────────────────────────────────────────────────────────
# Node-RED (globale)
if ! command -v node-red &>/dev/null; then
  log "Installazione Node-RED..."
  sudo npm install -g --unsafe-perm node-red
else
  log "Node-RED già presente: $(node-red --version)"
fi

# ──────────────────────────────────────────────────────────────────────────────
# Podman (già su Pop!_OS, ma assicura versione recente)
log "Verifica Podman..."
if ! command -v podman &>/dev/null; then
  sudo apt install -y podman
fi
# Abilita socket rootless
systemctl --user enable --now podman.socket 2>/dev/null || true
log "Podman: $(podman --version)"

# ──────────────────────────────────────────────────────────────────────────────
# Docker (opzionale, per compatibilità)
read -rp "Installare anche Docker Engine? [y/N] " -n 1; echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  log "Installazione Docker..."
  curl -fsSL https://get.docker.com | sh
  sudo usermod -aG docker "$USER"
  warn "Riavvia la sessione (logout/login) per usare docker senza sudo"
fi

# ──────────────────────────────────────────────────────────────────────────────
# Terraform
if ! command -v terraform &>/dev/null; then
  log "Installazione Terraform..."
  wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
  sudo apt update && sudo apt install -y terraform
else
  log "Terraform già presente: $(terraform version | head -1)"
fi

# ──────────────────────────────────────────────────────────────────────────────
# Ansible
if ! command -v ansible &>/dev/null; then
  log "Installazione Ansible..."
  sudo apt install -y ansible
else
  log "Ansible già presente: $(ansible --version | head -1)"
fi

# ──────────────────────────────────────────────────────────────────────────────
# Azure CLI
if ! command -v az &>/dev/null; then
  log "Installazione Azure CLI..."
  curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
else
  log "Azure CLI già presente: $(az version --output tsv | cut -f1)"
fi

# ──────────────────────────────────────────────────────────────────────────────
# AWS CLI v2
if ! command -v aws &>/dev/null; then
  log "Installazione AWS CLI v2..."
  cd /tmp
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip -q awscliv2.zip
  sudo ./aws/install
  rm -rf awscliv2.zip aws
  cd -
else
  log "AWS CLI già presente: $(aws --version)"
fi

# ──────────────────────────────────────────────────────────────────────────────
# Google Cloud CLI (gcloud)
if ! command -v gcloud &>/dev/null; then
  log "Installazione Google Cloud CLI..."
  echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list
  curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
  sudo apt update && sudo apt install -y google-cloud-cli
else
  log "gcloud già presente: $(gcloud version --format='value(Google Cloud SDK)' | head -1)"
fi

# ──────────────────────────────────────────────────────────────────────────────
# kubectl
if ! command -v kubectl &>/dev/null; then
  log "Installazione kubectl..."
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
  rm kubectl
else
  log "kubectl già presente: $(kubectl version --client --output=yaml | grep gitVersion | head -1)"
fi

# ──────────────────────────────────────────────────────────────────────────────
# Helm
if ! command -v helm &>/dev/null; then
  log "Installazione Helm..."
  curl https://baltocdn.com/helm/signing.asc | sudo gpg --dearmor -o /usr/share/keyrings/helm.gpg
  echo "deb [signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
  sudo apt update && sudo apt install -y helm
else
  log "Helm già presente: $(helm version --short)"
fi

# ──────────────────────────────────────────────────────────────────────────────
# Claude Code (verifica)
if command -v claude &>/dev/null; then
  log "Claude Code già presente: $(claude --version)"
else
  warn "Claude Code NON installato — installa da https://claude.com/claude-code (richiede login browser)"
fi

# ──────────────────────────────────────────────────────────────────────────────
# Config git (se non già fatto)
if ! git config --global user.name &>/dev/null; then
  read -rp "Git user.name: " gname
  read -rp "Git user.email: " gemail
  git config --global user.name "$gname"
  git config --global user.email "$gemail"
  log "Git configurato: $gname <$gemail>"
fi

# ──────────────────────────────────────────────────────────────────────────────
# SSH key per GitHub (se non esiste)
if [[ ! -f ~/.ssh/id_ed25519 ]]; then
  read -rp "Generare chiave SSH ed25519 per GitHub? [y/N] " -n 1; echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -rp "Email per chiave SSH: " ssh_email
    ssh-keygen -t ed25519 -C "$ssh_email" -f ~/.ssh/id_ed25519 -N ""
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_ed25519
    log "Chiave generata. Aggiungi la pubblica a GitHub:"
    cat ~/.ssh/id_ed25519.pub
  fi
fi

# ──────────────────────────────────────────────────────────────────────────────
# Riepilogo
echo
echo "═══════════════════════════════════════════════════════════"
log "SETUP COMPLETATO"
echo "═══════════════════════════════════════════════════════════"
echo
echo "Verifiche rapide:"
command -v rtk     && echo "  rtk:       $(rtk --version)"
command -v node    && echo "  node:      $(node --version)"
command -v npm     && echo "  npm:       $(npm --version)"
command -v node-red && echo "  node-red:  $(node-red --version)"
command -v podman  && echo "  podman:    $(podman --version | head -1)"
command -v terraform && echo "  terraform: $(terraform version | head -1)"
command -v ansible && echo "  ansible:   $(ansible --version | head -1)"
command -v az      && echo "  az:        $(az version --output tsv | cut -f1)"
command -v aws     && echo "  aws:       $(aws --version)"
command -v gcloud  && echo "  gcloud:    $(gcloud version --format='value(Google Cloud SDK)' | head -1)"
command -v kubectl && echo "  kubectl:   $(kubectl version --client --output=yaml | grep gitVersion | head -1 | cut -d' ' -f2)"
command -v helm    && echo "  helm:      $(helm version --short)"
command -v claude  && echo "  claude:    $(claude --version)"
echo
warn "IMPORTANTE: Riavvia il terminale (o 'source ~/.bashrc') per avere cargo/bin nel PATH"
echo
echo "Prossimi passi:"
echo "  1. git clone https://github.com/TUO-USERNAME/claude-config.git ~/.claude"
echo "  2. claude  # primo avvio, farà login browser"
echo "  3. rtk gain  # verifica RTK"
echo "  4. node-red  # test Node-RED (poi Ctrl+C, gira su porta 1880)"
# ──────────────────────────────────────────────────────────────────────────────
# Clone 18 repo extra per potenziare Claude Code
log "Clonazione repo extra per Claude Code..."
mkdir -p ~/claude-repos
cd ~/claude-repos

repos=(
  "https://github.com/centminmod/my-claude-code-setup.git"
  "https://github.com/rse/claude-code-setup.git"
  "https://github.com/alexandrosnt/Reach.git"
  "https://github.com/thedotmack/claude-mem.git"
  "https://github.com/usestrix/strix.git"
  "https://github.com/multica-ai/multica.git"
  "https://github.com/Panniantong/Agent-Reach.git"
  "https://github.com/NVIDIA/SkillSpector.git"
  "https://github.com/ruvnet/ruflo.git"
  "https://github.com/open-jarvis/OpenJarvis.git"
  "https://github.com/multica-ai/andrej-karpathy-skills.git"
  "https://github.com/nyldn/claude-octopus.git"
  "https://github.com/Graphify-Labs/graphify.git"
  "https://github.com/obra/superpowers.git"
  "https://github.com/storytold/craft-anything.git"
  "https://github.com/DietrichGebert/ponytail.git"
  "https://github.com/tashfeenahmed/freellmapi.git"
  "https://github.com/lemomo-ai/lemo-opuscar.git"
)

for repo in "${repos[@]}"; do
  name=$(basename "$repo" .git)
  if [[ -d "$name" ]]; then
    log "  $name già presente, aggiorno..."
    git -C "$name" pull
  else
    log "  Clono $name..."
    git clone "$repo"
  fi
done

log "Repo extra clonati in ~/claude-repos/"
