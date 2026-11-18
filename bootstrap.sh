#!/usr/bin/env bash
############################
# bootstrap.sh
# Sets up a fresh macOS or Linux (apt-based) machine with these dotfiles:
#   1. installs packages (Homebrew on macOS, apt on Linux)
#   2. installs oh-my-zsh, powerlevel10k and the zsh plugins used in zshrc
#   3. installs tmux plugin manager (tpm) and the tmux plugins in tmux.conf
#   4. runs make-symlinks.sh to link the dotfiles into $HOME
#
# Safe to re-run: every step checks whether it is already done.
# Usage: ./bootstrap.sh
############################

set -euo pipefail

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log()  { printf '\n==> %s\n' "$*"; }
have() { command -v "$1" >/dev/null 2>&1; }

# clone a git repo only if its target directory does not exist yet
clone() {
  local url="$1" target="$2"
  if [ -d "$target" ]; then
    echo "exists: $target"
  else
    git clone --depth 1 "$url" "$target"
  fi
}

########## 1. OS detection and packages

case "$(uname -s)" in
  Darwin) os="macos" ;;
  Linux)
    if have apt-get; then os="linux"; else
      echo "Unsupported Linux distro: only apt-based distros are supported." >&2
      exit 1
    fi ;;
  *) echo "Unsupported OS: $(uname -s)" >&2; exit 1 ;;
esac
log "Detected: $os"

install_packages() {
  if [ "$os" = "macos" ]; then
    if ! have brew; then
      log "Installing Homebrew"
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      # Apple Silicon installs brew to /opt/homebrew
      if [ -x /opt/homebrew/bin/brew ]; then eval "$(/opt/homebrew/bin/brew shellenv)"; fi
    fi
    log "Installing packages with Homebrew"
    brew install git zsh tmux neovim fzf
  else
    log "Installing packages with apt"
    sudo apt-get update
    sudo apt-get install -y git zsh tmux neovim fzf curl
  fi
}

install_packages

########## 2. oh-my-zsh, theme and plugins

ZSH_DIR="${ZSH:-$HOME/.oh-my-zsh}"
ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-$ZSH_DIR/custom}"

if [ ! -d "$ZSH_DIR" ]; then
  log "Installing oh-my-zsh (keeping existing ~/.zshrc, linked later)"
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

log "Installing zsh theme and plugins"
clone https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM_DIR/themes/powerlevel10k"
clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions"
clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM_DIR/plugins/zsh-syntax-highlighting"

# make zsh the login shell if it is not already
zsh_path="$(command -v zsh)"
if [ "${SHELL:-}" != "$zsh_path" ]; then
  log "Setting zsh as default shell (may ask for your password)"
  grep -qx "$zsh_path" /etc/shells || echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
  chsh -s "$zsh_path" || echo "WARN: could not change shell; run 'chsh -s $zsh_path' manually"
fi

########## 3. tmux plugin manager and plugins

log "Installing tmux plugin manager (tpm)"
clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"

# tpm needs the tmux.conf symlink to exist before it can read the plugin list,
# so link first (make-symlinks.sh is idempotent and backs up old files).

########## 4. symlink dotfiles

log "Linking dotfiles"
"$dir/make-symlinks.sh"

log "Installing tmux plugins"
if [ -x "$HOME/.tmux/plugins/tpm/bin/install_plugins" ]; then
  "$HOME/.tmux/plugins/tpm/bin/install_plugins" || echo "WARN: tpm plugin install failed; press prefix + I inside tmux"
fi

log "Done"
cat <<EOF
Next steps:
  - Open a new terminal (or run: exec zsh) to load the new shell config.
  - Run 'p10k configure' to set up the powerlevel10k prompt if you have no ~/.p10k.zsh.
  - Inside tmux, plugins are already installed; press prefix + I if any are missing.
EOF
