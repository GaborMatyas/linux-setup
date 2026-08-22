# Linux Setup

Personal dotfiles and system configuration scripts for multiple operating systems and Linux distributions.

## Purpose

Automated setup and configuration management for my development environments across different platforms. Currently supports Bazzite Linux, with macOS and WSL support planned.

## Currently Supported

### Bazzite Linux

Bazzite is an immutable Fedora-based Linux distribution optimized for gaming and desktop use.

**Run:** `./bazzite-install.sh`

**Installs:**
- Core applications (KeePassXC, Zed, Thunderbird, Transmission, VLC)
- Development tools (ripgrep, fd, fzf, zoxide, tmux, yazi)
- Terminal setup (Kitty with custom config)
- KDE Plasma configurations (shortcuts, power management)
- Monitor switching utilities
- pCloud client

**Features:**
- ✅ Idempotent (safe to run multiple times)
- ✅ Symlinked configurations (edit repo, changes apply automatically)
- ✅ Modular installer scripts
- ✅ Clear logging with icons and colors
- ✅ Comprehensive error handling

## Planned Support

- **macOS** - `macos-install.sh` (coming soon)
- **Windows Subsystem for Linux (WSL)** - `wsl-install.sh` (coming soon)
- **Other Linux distros** - As needed

## Quick Start

### Bazzite Linux

```bash
# Clone repository
git clone git@github.com:GaborMatyas/linux-setup.git
cd linux-setup

# Make installer executable
chmod +x bazzite-install.sh

# Run installer
./bazzite-install.sh
```

After installation:
- Restart your system for KDE config changes to take effect
- New terminal sessions will have bash integrations loaded

## 🛠️ How It Works

### Modular Design

Each tool/application has its own installer script in `src/`:
- **Self-contained** - Can run independently
- **Idempotent** - Safe to run multiple times
- **Clear output** - Icons and colors for easy scanning
- **Error handling** - Proper validation and error messages

### Utility Functions

Common functionality extracted into `src/utils/`:
- **DRY principle** - No code duplication
- **Consistent behavior** - Same patterns across all scripts
- **Well documented** - API reference + quick reference guide
- **Tested** - Used across all installer scripts

### Configuration Management

Configuration files in `files-to-copy/` are **symlinked**, not copied:
- ✅ Edit in repo → changes apply immediately
- ✅ Version controlled
- ✅ Easy to sync across machines
- ✅ No manual copying needed

## 📖 Documentation

- **Utility Functions:** See `src/utils/README.md` for complete API reference
- **Quick Reference:** See `src/utils/QUICK-REFERENCE.md` for syntax cheat sheet
- **Individual Scripts:** Each script has usage comments in header

## 🔧 Customization

### Adding Applications (Bazzite)

Edit `bazzite-install.sh` and add to the `APPS` array:

```bash
APPS=(
  "org.keepassxc.KeePassXC"
  "dev.zed.Zed"
  "your.new.App"  # Add here
)
```

### Creating New Installers

Use the utility functions for consistent behavior:

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." &>/dev/null && pwd)"
source "${REPO_ROOT}/src/utils/common.sh"

section_header "Installing My Tool"

if is_installed command mytool; then
  log_skip "Already installed: mytool"
  section_end
  exit 0
fi

log_info "Installing mytool..."
# Installation steps here
log_success "Installation complete"

section_end
```

See `src/utils/README.md` for all available utility functions.

## 📝 License

MIT License - Feel free to use and modify for your own setup.
