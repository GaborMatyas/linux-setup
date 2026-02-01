# fzf (fuzzy finder)
# Shell integration: key-bindings + completion
# Works in both bash and zsh
# Uses fd for default file listing if available.
# Prints a warning every interactive shell start until fzf (or fd) is installed.

# Only run in interactive shells
case $- in *i*) ;; *) return ;; esac

if command -v fzf >/dev/null 2>&1; then
  # Modern integration method (fzf >= 0.48.0)
  if [[ -n "${ZSH_VERSION:-}" ]]; then
    eval "$(fzf --zsh)"
  else
    eval "$(fzf --bash)"
  fi

  # Prefer fd for file discovery if available
  if command -v fd >/dev/null 2>&1; then
    # Use fd for default input when running `fzf` with no stdin
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    # Ensure Ctrl+T uses the same list command
    export FZF_CTRL_T_COMMAND="${FZF_DEFAULT_COMMAND}"
  else
    echo "==> fd is not installed. Install it to improve fzf performance (recommended)."
  fi
else
  echo "==> fzf is not installed. Run your setup script to install it."
fi
