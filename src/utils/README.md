# Utility Functions Reference

This directory contains reusable utility functions for the bazzite-setup installer scripts.

## Quick Start

To use all utilities in your script:

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." &>/dev/null && pwd)"

# Source all utilities
source "${REPO_ROOT}/src/utils/common.sh"

# Now all utility functions are available
```

## Available Utilities

### `create-symlink.sh`

Creates or updates a symlink, with optional executable permissions.

**Function:** `create_symlink <source> <target> [--chmod-x]`

**Parameters:**
- `source` - Path to the source file/directory
- `target` - Path where the symlink should be created
- `--chmod-x` - (Optional) Make source executable

**Example:**
```bash
create_symlink "${REPO_CONFIG}" "${HOME}/.config/app/config.ini"
create_symlink "${REPO_SCRIPT}" "${HOME}/.local/bin/script.sh" --chmod-x
```

**Behavior:**
- Ensures parent directory exists for target
- Removes existing file/symlink at target (refuses to remove directories)
- Creates symlink: target → source
- If `--chmod-x` provided, makes source executable

---

### `get-repo-root.sh`

Determines the absolute path to the repository root.

**Function:** `get_repo_root`

**Returns:** Absolute path to repository root (assumes utilities are in `src/utils/`)

**Example:**
```bash
REPO_ROOT="$(get_repo_root)"
```

---

### `is-installed.sh`

Checks if an application, binary, or package is installed.

**Function:** `is_installed <type> <identifier>`

**Types:**
- `binary` - Check if executable exists at specific path
- `command` - Check if command is available on PATH
- `flatpak` - Check if Flatpak app is installed

**Examples:**
```bash
if is_installed binary "${HOME}/.local/bin/fzf"; then
  echo "fzf binary exists"
fi

if is_installed command tmux; then
  echo "tmux is on PATH"
fi

if is_installed flatpak "org.keepassxc.KeePassXC"; then
  echo "KeePassXC flatpak is installed"
fi
```

**Returns:**
- `0` if installed
- `1` if not installed
- `2` on invalid type

---

### `check-dependency.sh`

Checks if a required command exists, exits with error if missing.

**Function:** `check_dependency <command_name> [error_message]`

**Parameters:**
- `command_name` - Command to check for
- `error_message` - (Optional) Custom error message

**Examples:**
```bash
check_dependency curl
check_dependency jq "jq is required for JSON parsing"
```

**Behavior:**
- Checks if command is on PATH
- If missing, prints error and returns 1
- If present, returns 0 silently

---

### `detect-architecture.sh`

Detects system architecture and returns platform-specific strings.

**Function:** `detect_architecture <format>`

**Formats:**
- `fzf` - Returns platform string for fzf releases (e.g., `linux_amd64`, `linux_arm64`, `linux_armv7`)
- `ripgrep` - Returns platform string for ripgrep releases (e.g., `x86_64-unknown-linux-musl`)
- `fd` - Returns platform string for fd releases (e.g., `x86_64-unknown-linux-gnu`)

**Examples:**
```bash
PLATFORM="$(detect_architecture fzf)"
# Returns: linux_amd64 (on x86_64 systems)

PLATFORM="$(detect_architecture ripgrep)"
# Returns: x86_64-unknown-linux-musl (on x86_64 systems)
```

**Behavior:**
- Detects architecture using `uname -m`
- Maps to format-specific platform string
- Exits with error if architecture is unsupported for that format

---

### `fetch-github-release.sh`

Fetches the download URL for the latest release from GitHub.

**Function:** `fetch_github_release <owner> <repo> <asset_pattern>`

**Parameters:**
- `owner` - GitHub repository owner
- `repo` - Repository name
- `asset_pattern` - Regex pattern to match release asset filename

**Examples:**
```bash
URL="$(fetch_github_release junegunn fzf "fzf-[0-9]+\.[0-9]+\.[0-9]+-linux_amd64\.tar\.gz")"

URL="$(fetch_github_release BurntSushi ripgrep "ripgrep-[0-9]+\.[0-9]+\.[0-9]+-x86_64-unknown-linux-musl\.tar\.gz")"
```

**Behavior:**
- Queries GitHub API for latest release
- Extracts download URL matching the asset pattern
- Returns URL via stdout
- Exits with error if URL cannot be determined

**Note:** Does not require `jq` - uses `grep` for parsing

---

### `create-temp-dir.sh`

Creates a temporary directory with automatic cleanup on script exit.

**Function:** `create_temp_dir`

**Returns:** Path to temporary directory

**Example:**
```bash
TMP_DIR="$(create_temp_dir)"
# Use TMP_DIR for operations...
# Automatically cleaned up on script exit
```

**Behavior:**
- Creates temporary directory using `mktemp -d`
- Registers EXIT trap for automatic cleanup
- Returns directory path via stdout

---

### `download-and-extract.sh`

Downloads a tarball and extracts it to a destination directory.

**Function:** `download_and_extract <url> <destination_dir>`

**Parameters:**
- `url` - Download URL for the tarball
- `destination_dir` - Directory where tarball should be extracted

**Examples:**
```bash
download_and_extract "https://example.com/app.tar.gz" "${TMP_DIR}"
```

**Behavior:**
- Creates destination directory if it doesn't exist
- Downloads tarball using `curl`
- Extracts using `tar -xzf`
- Removes tarball after successful extraction
- Returns 0 on success, 1 on failure

**Requirements:** `curl`, `tar`

---

### `install-binary.sh`

Installs a binary with proper permissions.

**Function:** `install_binary <source> <destination>`

**Parameters:**
- `source` - Path to source binary
- `destination` - Target installation path

**Examples:**
```bash
install_binary "${TMP_DIR}/fzf" "${HOME}/.local/bin/fzf"
install_binary "${EXTRACTED_DIR}/rg" "${HOME}/.local/bin/rg"
```

**Behavior:**
- Ensures parent directory exists
- Installs with executable permissions (0755)
- Uses `install` command for atomic installation
- Validates destination is executable after installation
- Returns 0 on success, 1 on failure

---

### `install-bashrc-snippet.sh`

Installs a bash integration snippet via symlink to `~/.bashrc.d/`.

**Function:** `install_bashrc_snippet <source_snippet> <snippet_name>`

**Parameters:**
- `source_snippet` - Path to repo-managed snippet file
- `snippet_name` - Filename to use in `~/.bashrc.d/`

**Examples:**
```bash
install_bashrc_snippet "${REPO_ROOT}/files-to-copy/dotfiles/bashrc.d/fzf.sh" "fzf.sh"
install_bashrc_snippet "${REPO_ROOT}/files-to-copy/dotfiles/bashrc.d/zoxide.sh" "zoxide.sh"
```

**Behavior:**
- Creates `~/.bashrc.d` directory if needed
- Symlinks snippet to `~/.bashrc.d/<snippet_name>`
- Uses `create_symlink` internally
- Validates source exists
- Returns 0 on success, 1 on failure

**Note:** The snippet file is repo-managed via symlink, so updates don't require reinstallation.

---

### `log.sh`

Provides consistent, colorful, and icon-based logging for installer scripts.

**Functions:**

#### `section_header <title>`
Prints a section header with clear visual separation. Use at the start of each major process.

```bash
section_header "Installing Ripgrep"
```

#### `section_end`
Marks the end of a section (optional, helps with spacing).

```bash
section_end
```

#### `log_info <message>`
Prints an informational message (cyan, "==>" prefix).

```bash
log_info "Downloading package..."
```

#### `log_success <message>`
Prints a success message with ✅ icon (green).

```bash
log_success "Installation complete"
```

#### `log_error <message>`
Prints an error message with ❌ icon (red, to stderr).

```bash
log_error "Failed to download package"
```

#### `log_warn <message>`
Prints a warning message with ❗ icon (yellow).

```bash
log_warn "Configuration file not found, using defaults"
```

#### `log_skip <message>`
Prints a skip message with ⏭️ icon (blue).

```bash
log_skip "Already installed: ripgrep"
```

#### `log_result <label> <value>`
Prints a labeled result in "key: value" format.

```bash
log_result "Binary" "${HOME}/.local/bin/rg"
log_result "Version" "ripgrep 15.1.0"
```

#### Aliases (backward compatibility)
- `info()` → `log_info()`
- `ok()` → `log_success()`
- `warn()` → `log_warn()`
- `error()` → `log_error()`

**Icons Used:**
- ✅ Success (green)
- ❌ Error (red)
- ❗ Warning (yellow)
- ⏭️ Skip (blue)
- ==> Info (cyan)

**Example Usage:**
```bash
source "${REPO_ROOT}/src/utils/common.sh"

section_header "Installing Ripgrep"
log_info "Checking dependencies..."
check_dependency curl
log_success "Dependencies satisfied"

if is_installed binary "${RG_BIN}"; then
  log_skip "Already installed: ripgrep"
  log_result "Version" "$(rg --version | head -n1)"
  section_end
  exit 0
fi

log_info "Downloading and extracting..."
# ... installation steps ...
log_success "Installation complete"
log_result "Binary" "${RG_BIN}"
section_end
```

**Behavior:**
- Automatically detects color support
- Disables colors if not in a terminal
- Proper spacing between sections
- No empty lines within sections
- Consistent visual hierarchy

---

## Common Usage Patterns

### Installing a GitHub CLI Tool

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." &>/dev/null && pwd)"
source "${REPO_ROOT}/src/utils/common.sh"

APP_ID="my-tool"
LOCAL_BIN="${HOME}/.local/bin"
BINARY_PATH="${LOCAL_BIN}/${APP_ID}"

# Check if already installed
if is_installed binary "${BINARY_PATH}"; then
  echo "==> Already installed: ${APP_ID} (skipping)"
  exit 0
fi

# Ensure dependencies
check_dependency curl
check_dependency tar

# Detect architecture
PLATFORM="$(detect_architecture fzf)"

# Fetch latest release
URL="$(fetch_github_release owner repo "my-tool-[0-9]+\.[0-9]+\.[0-9]+-${PLATFORM}\.tar\.gz")"

# Download and extract
TMP_DIR="$(create_temp_dir)"
download_and_extract "${URL}" "${TMP_DIR}"

# Install binary
install_binary "${TMP_DIR}/my-tool" "${BINARY_PATH}"

echo "==> ${APP_ID} installed successfully."
```

### Installing Config Files via Symlink

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." &>/dev/null && pwd)"
source "${REPO_ROOT}/src/utils/common.sh"

REPO_CONFIG="${REPO_ROOT}/files-to-copy/dotfiles/app/config.ini"
TARGET_CONFIG="${HOME}/.config/app/config.ini"

create_symlink "${REPO_CONFIG}" "${TARGET_CONFIG}"

echo "==> Config installed via symlink"
```

### Installing with Bash Integration

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." &>/dev/null && pwd)"
source "${REPO_ROOT}/src/utils/common.sh"

APP_ID="my-tool"
REPO_SNIPPET="${REPO_ROOT}/files-to-copy/dotfiles/bashrc.d/my-tool.sh"

# Install bash integration snippet
install_bashrc_snippet "${REPO_SNIPPET}" "my-tool.sh"

# ... install binary as usual ...

echo "==> Restart your terminal or run: source ~/.bashrc"
```

---

## Design Principles

1. **Idempotent**: All utilities can be run multiple times safely
2. **Self-contained**: Each utility can be used standalone or sourced
3. **Error handling**: Proper error messages and exit codes
4. **Consistent API**: Similar parameter ordering and return conventions
5. **No regression**: Logic matches existing working scripts exactly

## Testing Utilities

Each utility can be tested standalone:

```bash
# Test create-symlink
./src/utils/create-symlink.sh /path/to/source /path/to/target

# Test is-installed
./src/utils/is-installed.sh command curl

# Test detect-architecture
./src/utils/detect-architecture.sh fzf

# Test get-repo-root
./src/utils/get-repo-root.sh
```
