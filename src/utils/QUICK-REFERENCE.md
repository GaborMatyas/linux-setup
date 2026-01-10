# Utility Functions Quick Reference

## Setup (Required for all scripts)

```bash
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." &>/dev/null && pwd)"
source "${REPO_ROOT}/src/utils/common.sh"
```

---

## Function Quick Reference

### `create_symlink`
Create or update a symlink
```bash
create_symlink <source> <target> [--chmod-x]
```
**Example:**
```bash
create_symlink "${REPO_CONFIG}" "${HOME}/.config/app.conf"
create_symlink "${REPO_SCRIPT}" "${HOME}/.local/bin/script" --chmod-x
```

---

### `get_repo_root`
Get repository root path
```bash
REPO_ROOT="$(get_repo_root)"
```

---

### `is_installed`
Check if something is installed
```bash
is_installed <type> <identifier>
```
**Types:** `binary`, `command`, `flatpak`

**Examples:**
```bash
is_installed binary "${HOME}/.local/bin/fzf"
is_installed command tmux
is_installed flatpak "org.keepassxc.KeePassXC"
```

---

### `check_dependency`
Check if command exists or exit
```bash
check_dependency <command> [error_message]
```
**Examples:**
```bash
check_dependency curl
check_dependency jq "jq is required for JSON parsing"
```

---

### `log_info`
Print informational message
```bash
log_info <message>
```
**Example:**
```bash
log_info "Downloading package..."
```

---

### `log_success`
Print success message with ✅ icon
```bash
log_success <message>
```
**Example:**
```bash
log_success "Installation complete"
```

---

### `log_error`
Print error message with ❌ icon (to stderr)
```bash
log_error <message>
```
**Example:**
```bash
log_error "Failed to download package"
```

---

### `log_warn`
Print warning message with ❗ icon
```bash
log_warn <message>
```
**Example:**
```bash
log_warn "Configuration file not found, using defaults"
```

---

### `log_skip`
Print skip message with ⏭️ icon
```bash
log_skip <message>
```
**Example:**
```bash
log_skip "Already installed: ripgrep"
```

---

### `log_result`
Print labeled result (key: value)
```bash
log_result <label> <value>
```
**Example:**
```bash
log_result "Binary" "${HOME}/.local/bin/rg"
log_result "Version" "ripgrep 15.1.0"
```

---

### `section_header`
Start a section with clear visual separation
```bash
section_header <title>
```
**Example:**
```bash
section_header "Installing Ripgrep"
```

---

### `section_end`
End a section (optional)
```bash
section_end
```

---

### `detect_architecture`
Detect system architecture
```bash
PLATFORM="$(detect_architecture <format>)"
```
**Formats:** `fzf`, `ripgrep`, `fd`

**Examples:**
```bash
PLATFORM="$(detect_architecture fzf)"        # → linux_amd64
PLATFORM="$(detect_architecture ripgrep)"    # → x86_64-unknown-linux-musl
PLATFORM="$(detect_architecture fd)"         # → x86_64-unknown-linux-gnu
```

---

### `fetch_github_release`
Fetch GitHub release download URL
```bash
URL="$(fetch_github_release <owner> <repo> <pattern>)"
```
**Examples:**
```bash
URL="$(fetch_github_release junegunn fzf "fzf-[0-9]+\.[0-9]+\.[0-9]+-${PLATFORM}\.tar\.gz")"
URL="$(fetch_github_release BurntSushi ripgrep "ripgrep-[0-9]+\.[0-9]+\.[0-9]+-${PLATFORM}\.tar\.gz")"
```

---

### `create_temp_dir`
Create temp directory with auto-cleanup
```bash
TMP_DIR="$(create_temp_dir)"
```

---

### `download_and_extract`
Download and extract tarball
```bash
download_and_extract <url> <destination_dir>
```
**Example:**
```bash
download_and_extract "${URL}" "${TMP_DIR}"
```

---

### `install_binary`
Install binary with permissions
```bash
install_binary <source> <destination>
```
**Example:**
```bash
install_binary "${TMP_DIR}/fzf" "${HOME}/.local/bin/fzf"
```

---

### `install_bashrc_snippet`
Install bash integration snippet
```bash
install_bashrc_snippet <source_snippet> <snippet_name>
```
**Example:**
```bash
install_bashrc_snippet "${REPO_ROOT}/files-to-copy/dotfiles/bashrc.d/fzf.sh" "fzf.sh"
```

---

## Common Patterns

### Pattern 1: Check if Already Installed
```bash
section_header "Installing App"

if is_installed binary "${HOME}/.local/bin/app"; then
  log_skip "Already installed: app"
  log_result "Binary" "${HOME}/.local/bin/app"
  section_end
  exit 0
fi
```

### Pattern 2: Install GitHub CLI Tool
```bash
section_header "Installing App"

# Dependencies
log_info "Checking dependencies..."
check_dependency curl
check_dependency tar
log_success "Dependencies satisfied"

# Detect architecture
log_info "Detecting architecture..."
PLATFORM="$(detect_architecture fzf)"
log_success "Architecture: ${PLATFORM}"

# Fetch latest release
log_info "Fetching latest release..."
URL="$(fetch_github_release owner repo "app-[0-9]+\.[0-9]+\.[0-9]+-${PLATFORM}\.tar\.gz")"
log_success "Found release"

# Download and extract
log_info "Downloading and extracting..."
TMP_DIR="$(create_temp_dir)"
download_and_extract "${URL}" "${TMP_DIR}"

# Install
log_info "Installing binary..."
install_binary "${TMP_DIR}/app" "${HOME}/.local/bin/app"
log_success "Installation complete"

log_result "Binary" "${HOME}/.local/bin/app"
section_end
```

### Pattern 3: Symlink Config Files
```bash
REPO_CONFIG="${REPO_ROOT}/files-to-copy/dotfiles/app/config.ini"
TARGET_CONFIG="${HOME}/.config/app/config.ini"

create_symlink "${REPO_CONFIG}" "${TARGET_CONFIG}"
```

### Pattern 4: Install with Bash Integration
```bash
# Install snippet
SNIPPET="${REPO_ROOT}/files-to-copy/dotfiles/bashrc.d/app.sh"
install_bashrc_snippet "${SNIPPET}" "app.sh"

# Install binary (as above)
# ...

echo "==> Restart terminal or run: source ~/.bashrc"
```

---

## Full Example: Minimal Installer

```bash
#!/usr/bin/env bash
set -euo pipefail

APP_ID="my-app"
BIN_PATH="${HOME}/.local/bin/${APP_ID}"

# Setup
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." &>/dev/null && pwd)"
source "${REPO_ROOT}/src/utils/common.sh"

section_header "Installing ${APP_ID}"

# Check if already installed
if is_installed binary "${BIN_PATH}"; then
  log_skip "Already installed: ${APP_ID}"
  log_result "Binary" "${BIN_PATH}"
  section_end
  exit 0
fi

# Dependencies
log_info "Checking dependencies..."
check_dependency curl
check_dependency tar
log_success "Dependencies satisfied"

# Fetch and install
log_info "Detecting architecture..."
PLATFORM="$(detect_architecture fzf)"
log_info "Fetching latest release..."
URL="$(fetch_github_release owner repo "${APP_ID}-[0-9]+\.[0-9]+\.[0-9]+-${PLATFORM}\.tar\.gz")"
log_info "Downloading and extracting..."
TMP_DIR="$(create_temp_dir)"
download_and_extract "${URL}" "${TMP_DIR}"
log_info "Installing binary..."
install_binary "${TMP_DIR}/${APP_ID}" "${BIN_PATH}"

log_success "Installation complete"
log_result "Binary" "${BIN_PATH}"
section_end
```

---

## Testing Individual Utilities

```bash
# Test utilities standalone
./src/utils/detect-architecture.sh fzf
./src/utils/is-installed.sh command curl
./src/utils/check-dependency.sh curl
./src/utils/get-repo-root.sh
```

---

## Error Handling

All utilities:
- Return `0` on success
- Return `1` on failure
- Print errors to stderr
- Exit with proper codes when used standalone

---

## See Also

- **Full Reference:** `src/utils/README.md`
- **Logging Guide:** `src/utils/LOGGING-GUIDE.md`
- **Example Script:** `src/ripgrep-install.WITH-LOGGING.sh`
