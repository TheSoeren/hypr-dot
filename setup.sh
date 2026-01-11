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
echo "==> Installing Oh My Zsh..."
if [[ -d "$HOME/.oh-my-zsh" ]]; then
  echo "Oh My Zsh already installed."
else
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

echo "==> Installing Zsh syntax highlighting plugins..."

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# zsh-syntax-highlighting
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
    "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
else
  echo "zsh-syntax-highlighting already installed."
fi

# fast-syntax-highlighting
if [ ! -d "$ZSH_CUSTOM/plugins/fast-syntax-highlighting" ]; then
  git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git \
    "$ZSH_CUSTOM/plugins/fast-syntax-highlighting"
else
  echo "fast-syntax-highlighting already installed."
fi

echo "==> Configuring .zshrc plugins..."

ZSHRC="$HOME/.zshrc"

echo "==> Done."
echo "==> Installing ripgrep..."
sudo pacman -S ripgrep
echo "==> Done."
echo "==> Setting up Caps Lock ↔ Escape swap using udevmon with intercept and caps2esc..."

# Ensure interception-tools is installed
if ! command -v intercept >/dev/null 2>&1; then
    echo "Installing interception-tools..."
    sudo pacman -Sy --needed interception-tools
fi

UDEVMON_CONF="$HOME/.config/udevmon/udevmon.yaml"

echo "==> Creating systemd user service for udevmon..."

# Systemd user service directory
SYSTEMD_USER_DIR="$HOME/.config/systemd/user"
mkdir -p "$SYSTEMD_USER_DIR"

UDEVMON_SERVICE="$SYSTEMD_USER_DIR/udevmon.service"
cat > "$UDEVMON_SERVICE" << EOF
[Unit]
Description=Monitor input devices for launching tasks
Wants=systemd-udev-settle.service
After=systemd-udev-settle.service
Documentation=man:udev(7)

[Service]
ExecStart=$(command -v udevmon) -c $UDEVMON_CONF
Nice=-20
Restart=on-failure
OOMScoreAdjust=-1000

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the user service
systemctl --user daemon-reload
systemctl --user enable --now udevmon.service

echo "==> Done."
echo ""
echo "You may need to log out and log back in for full effect."
echo "You may need to restart your terminal to use the font."
echo ""
echo "IMPORTANT:"
echo "1. Start tmux"
echo "2. Press prefix (Ctrl-Space) + I to reinstall/update plugins if needed"
echo "3. Restart tmux completely to apply catppuccin theme"
