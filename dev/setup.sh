#!/usr/bin/env sh
set -e

echo "==> Installing pnpm..."

# Install pnpm (official installer)
curl -fsSL https://get.pnpm.io/install.sh | sh -

# Ensure PNPM_HOME is set for this script run
export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"

echo "pnpm version:"
pnpm --version

echo "Installing latest Node.js LTS via pnpm..."
pnpm env use --global lts

echo "Node version:"
node --version

echo "==> Done."

echo "==> Installing tmux"

sudo pacman -Sy --needed \
  tmux \
  xclip \
  wl-clipboard \
  procps-ng \
  base-devel \
  ttf-nerd-fonts-symbols

echo "==> Setting zsh as default shell..."
if [ "$SHELL" != "/bin/zsh" ]; then
  chsh -s /bin/zsh
fi

echo "==> Installing TPM..."
TPM_DIR="$HOME/.tmux/plugins/tpm"

if [ ! -d "$TPM_DIR" ]; then
  git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
else
  echo "TPM already installed."
fi

echo "==> Ensuring tmux plugins directory exists..."
mkdir -p "$HOME/.tmux/plugins"

echo "==> Starting tmux server to install plugins..."
tmux start-server

echo "==> Creating temporary tmux session to install plugins..."
tmux new-session -d -s __tpm_install

sleep 1

echo "==> Installing tmux plugins via TPM..."
"$TPM_DIR/bin/install_plugins"

echo "==> Killing temporary tmux session..."
tmux kill-session -t __tpm_install

echo "==> Done."
echo ""
echo "IMPORTANT:"
echo "1. Start tmux"
echo "2. Press prefix (Ctrl-Space) + I to reinstall/update plugins if needed"
echo "3. Restart tmux completely to apply catppuccin theme"
