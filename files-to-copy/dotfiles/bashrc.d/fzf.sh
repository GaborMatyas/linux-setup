# fzf (fuzzy finder)
# Bash integration: key-bindings + completion
# Prints a warning every interactive shell start until fzf is installed.

if command -v fzf >/dev/null 2>&1; then
  # Modern integration method (fzf >= 0.48.0)
  eval "$(fzf --bash)"
else
  echo "==> fzf is not installed. Run your setup script to install it."
fi
